import 'package:flutter/foundation.dart';
import 'package:sahaay/models/chat_message.dart';
import 'package:sahaay/services/chatbot_service.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  int _stressLevel = 5;
  bool _isLoading = false;
  bool _isInitializing = false; // Prevent multiple initialization calls
  final ChatbotService _chatbotService = ChatbotService();
  Function(int)? _onStressLevelChanged;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  int get stressLevel => _stressLevel;

  /// Set callback to notify when stress level changes
  void setStressLevelCallback(Function(int) callback) {
    _onStressLevelChanged = callback;
  }

  void updateStressLevel(int level) {
    final newLevel = level.clamp(1, 10);
    if (_stressLevel != newLevel) {
      _stressLevel = newLevel;
      _onStressLevelChanged?.call(_stressLevel);
      notifyListeners();
    }
  }

  /// Initialize chat with welcome message
  Future<void> initializeChat() async {
    // Prevent multiple initialization calls
    if (_messages.isNotEmpty || _isInitializing) return;
    
    _isInitializing = true;
    _isLoading = true;
    notifyListeners();

    // Show immediate placeholder message for better UX
    final placeholderId = DateTime.now().millisecondsSinceEpoch.toString();
    _messages.add(ChatMessage(
      id: placeholderId,
      text: "Hey! I'm Sahaay. Just a moment while I think of what to say...",
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    try {
      // Get first message - use faster model/prompt
      final firstMessage = await _chatbotService.generateFirstMessage(_stressLevel);

      // Replace placeholder with actual message
      final index = _messages.indexWhere((m) => m.id == placeholderId);
      if (index != -1) {
        _messages[index] = ChatMessage(
          id: placeholderId,
          text: firstMessage,
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        // Fallback: add new message if placeholder not found
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: firstMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      // Show actual error details to help debug
      String errorMessage = 'Error: ';
      final errorStr = e.toString();
      
      if (errorStr.contains('SocketException') || errorStr.contains('Failed host lookup')) {
        errorMessage += 'No internet connection. Please check your network.';
      } else if (errorStr.contains('401') || errorStr.contains('API key') || errorStr.contains('INVALID_ARGUMENT')) {
        errorMessage += 'API key may be invalid or expired.';
      } else if (errorStr.contains('403')) {
        errorMessage += 'API access denied. Check API key permissions.';
      } else if (errorStr.contains('404')) {
        errorMessage += 'API endpoint not found.';
      } else if (errorStr.contains('429') || errorStr.contains('rate limit')) {
        errorMessage += 'Too many requests right now. Please wait a moment and try again.';
      } else {
        // Show the actual error message
        String cleanError = errorStr
            .replaceAll('Exception: ', '')
            .replaceAll('Gemini API error: ', '');
        errorMessage += cleanError;
      }
      
      // Replace placeholder with error message
      final index = _messages.indexWhere((m) => m.id == placeholderId);
      if (index != -1) {
        _messages[index] = ChatMessage(
          id: placeholderId,
          text: errorMessage,
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        // Fallback: add new message if placeholder not found
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: errorMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
    } finally {
      _isLoading = false;
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Send a message and get AI response with stress detection
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    // Add user message immediately
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      // Auto-detect stress level from conversation (in background, don't wait)
      final conversationHistory = _messages.where((m) => !m.isLoading).toList();
      
      // Get AI response immediately - no artificial delays
      final response = await _chatbotService.sendMessage(
        text.trim(),
        conversationHistory,
        _stressLevel,
      );

      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      // Update stress level asynchronously - only every 3rd message to reduce API calls
      // This helps avoid rate limits while still tracking stress
      if (_messages.length % 3 == 0) {
        _chatbotService.detectStressLevel(
          text.trim(),
          conversationHistory,
          _stressLevel,
        ).then((detectedStress) {
          if ((detectedStress - _stressLevel).abs() >= 1) {
            updateStressLevel(detectedStress);
          }
        }).catchError((_) {
          // Silently handle stress detection errors - don't interrupt chat
        });
      }
    } catch (e) {
      // Fallback response should have already been returned by chatbot service
      // This catch block is just a safety net - should rarely be reached
      // Still provide a helpful response instead of showing error
      final lowerMessage = text.toLowerCase();
      String fallbackMessage;
      
      if (lowerMessage.contains('exam') || lowerMessage.contains('test') || lowerMessage.contains('study')) {
        fallbackMessage = "I understand exams can be really stressful. You're not alone in feeling this way. What's the main thing that's worrying you right now?";
      } else if (lowerMessage.contains('sad') || lowerMessage.contains('down') || lowerMessage.contains('upset')) {
        fallbackMessage = "I'm really sorry you're feeling this way. It takes courage to share. I'm here to listen. What's been on your mind?";
      } else if (lowerMessage.contains('anxious') || lowerMessage.contains('worried') || lowerMessage.contains('stress')) {
        fallbackMessage = "I hear you, and I'm here with you. These feelings can be really intense. What's making you feel this way?";
      } else {
        fallbackMessage = "I'm here to listen and support you. Thanks for sharing. What would you like to talk about?";
      }
      
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: fallbackMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear chat history
  void clearChat() {
    _messages.clear();
    _isInitializing = false;
    _isLoading = false;
    notifyListeners();
  }
}


