import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class GeminiService {
  // Primary API key
  static const String _apiKey = 'AIzaSyDNlyZtfJoYB4rhTw200LsQ0bb0xy25nMY';
  
  // Fallback API keys (add more if you have them)
  // Leave empty if you only have one key - it will use fallback responses
  static const List<String> _fallbackApiKeys = [
    'sk-N9Pf8VlgIzdbMbaBCJVX9ucODtroFC1h3FVc9to93NqbH9Zn'
  ];
  
  // Use only fastest model for speed (gemini-2.5-flash)
  static const List<String> _models = [
    'gemini-2.5-flash', // Fastest model only
  ];
  
  static const String _basePath = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const Duration _timeout = Duration(seconds: 6); // Max 6 seconds timeout

  static String get apiKey => _apiKey;
  
  /// Get all API keys including fallbacks
  static List<String> get _allApiKeys => [_apiKey, ..._fallbackApiKeys];

  static Future<String> generateText(String prompt,
      {int maxTokens = 2048, double temperature = 0.7, int maxRetries = 1}) async {
    // Try each API key (primary + fallbacks) - reduced retries for speed
    Exception? lastError;
    
    for (final apiKey in _allApiKeys) {
      // Try each model until one works (only fastest model now)
      for (final model in _models) {
        // Single attempt only for speed (no retries with delays)
        for (int attempt = 0; attempt < maxRetries; attempt++) {
          try {
            final url = Uri.parse('$_basePath/$model:generateContent?key=$apiKey');

            // Use timeout for fast failure (6 seconds max)
            final response = await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': prompt}
                    ]
                  }
                ],
                'generationConfig': {
                  'temperature': temperature,
                  'topK': 40,
                  'topP': 0.95,
                  'maxOutputTokens': maxTokens,
                  'candidateCount': 1,
                },
                'safetySettings': [
                  {
                    'category': 'HARM_CATEGORY_HARASSMENT',
                    'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
                  },
                  {
                    'category': 'HARM_CATEGORY_HATE_SPEECH',
                    'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
                  },
                  {
                    'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                    'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
                  },
                  {
                    'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                    'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
                  },
                ],
              }),
            ).timeout(_timeout);

            if (response.statusCode == 200) {
              final text = _extractTextFromResponse(response);
              return text;
            } else if (response.statusCode == 429) {
              // Rate limit - try next API key immediately (no retry delay)
              lastError = Exception('Rate limit exceeded for this API key');
              break; // Exit retry loop, try next API key
            } else if (response.statusCode == 404) {
              // 404 means model not found, try next model
              try {
                final errorData = jsonDecode(response.body);
                final errorMsg = errorData['error']?['message'] ?? 'Model not found';
                lastError = Exception('API error ($model): $errorMsg');
              } catch (_) {
                lastError = Exception('Model $model not found (404)');
              }
              break; // Exit retry loop, try next model
            } else {
              // Other errors - parse and throw
              try {
                final errorData = jsonDecode(response.body);
                final errorMsg = errorData['error']?['message'] ?? 'Unknown error';
                final errorStatus = errorData['error']?['status'] ?? '';
                throw Exception('API error ($errorStatus): $errorMsg');
              } catch (parseError) {
                throw Exception('API error ${response.statusCode}: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
              }
            }
          } catch (e) {
            // Handle timeout exceptions
            if (e is TimeoutException) {
              lastError = e;
              break; // Exit retry loop immediately on timeout
            }
            // If it's a rate limit error, try next API key
            if ((e.toString().contains('429') || e.toString().contains('rate limit')) && attempt < maxRetries - 1) {
              continue; // Retry (though we only have 1 retry now)
            }
            // If it's a 404 error, exit retry loop and try next model
            if (e.toString().contains('404') || e.toString().contains('not found')) {
              lastError = e is Exception ? e : Exception(e.toString());
              break; // Exit retry loop, try next model
            }
            // For other errors on last attempt, save error and continue to next model/API key
            if (attempt == maxRetries - 1) {
              lastError = e is Exception ? e : Exception(e.toString());
              break; // Exit retry loop, try next model or API key
            }
            // Otherwise continue retry (though we only have 1 retry)
          }
        }
        // If we successfully got a response (no error), we would have returned by now
        // So if lastError is null, we should continue to next iteration
        if (lastError == null) {
          // This shouldn't happen, but if it does, break to try next model
          break;
        }
        // Reset lastError for next model attempt (keep only rate limit errors to try next API key)
        if (!lastError.toString().contains('rate limit') && !lastError.toString().contains('429') && !(lastError is TimeoutException)) {
          lastError = null; // Reset for next model
        }
      }
      // If we got a non-rate-limit error, we should try next API key
      // But if it's a rate limit error, continue to next API key
      if (lastError != null && (lastError.toString().contains('rate limit') || lastError.toString().contains('429'))) {
        if (apiKey != _allApiKeys.last) {
          lastError = null; // Reset for next API key
          continue; // Try next API key
        }
      }
    }
    
    // If all API keys exhausted, use fallback response
    return _generateFallbackResponse(prompt, lastError);
  }

  /// Extract text from API response
  static String _extractTextFromResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (data['candidates'] != null && data['candidates'].isNotEmpty) {
      final candidate = data['candidates'][0];
      
      if (candidate['finishReason'] == 'SAFETY') {
        throw Exception('Response blocked by safety filters');
      }
      
      if (candidate['content'] != null && 
          candidate['content']['parts'] != null && 
          candidate['content']['parts'].isNotEmpty) {
        final text = candidate['content']['parts'][0]['text'];
        return text.trim();
      }
    }
    throw Exception('No response from Gemini');
  }
  
  /// Generate fallback response when all APIs are rate-limited
  static String _generateFallbackResponse(String prompt, Exception? error) {
    // If it's a rate limit error, provide a helpful fallback message
    if (error != null && (error.toString().contains('rate limit') || error.toString().contains('429'))) {
      // Analyze the prompt to give a contextually appropriate response
      final lowerPrompt = prompt.toLowerCase();
      
      if (lowerPrompt.contains('first message') || lowerPrompt.contains('opening the chat')) {
        return "Hey! I'm Sahaay. How are you doing today? I'm here to listen whenever you need to talk.";
      }
      
      if (lowerPrompt.contains('stress level') || lowerPrompt.contains('stressed')) {
        return "I understand you're feeling stressed. That's completely okay. I'm here with you. Take a slow breath - we can work through this together. What's been on your mind?";
      }
      
      if (lowerPrompt.contains('exam') || lowerPrompt.contains('test')) {
        return "Exams can be really tough, I get that. It's okay to feel overwhelmed. Remember, you're doing your best, and that's what matters. What specifically about the exams is worrying you?";
      }
      
      // Check for common emotional keywords
      if (lowerPrompt.contains('anxious') || lowerPrompt.contains('worry') || lowerPrompt.contains('nervous')) {
        return "I hear you. Feeling anxious or worried is totally normal, especially when you're dealing with a lot. You're not alone in this. What's making you feel this way?";
      }
      
      if (lowerPrompt.contains('sad') || lowerPrompt.contains('down') || lowerPrompt.contains('depressed')) {
        return "I'm really sorry you're feeling this way. It takes courage to share how you're feeling. I'm here to listen and support you. What's been weighing on you?";
      }
      
      // Generic empathetic response with follow-up question
      return "I'm here with you, and I want to understand what you're going through. It sounds like you're dealing with something difficult right now. Would you like to tell me more about it? What's on your mind?";
    }
    
    // For other errors, throw to show the actual error
    throw error ?? Exception('All API keys failed. Please check your internet connection and try again later.');
  }
}
