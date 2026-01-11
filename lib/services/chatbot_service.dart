import 'package:sahaay/models/chat_message.dart';
import 'package:sahaay/services/gemini_service.dart';
import 'dart:math';

class ChatbotService {
  final Random _random = Random();
  /// Detects stress level from user message and conversation context
  Future<int> detectStressLevel(
    String userMessage,
    List<ChatMessage> conversationHistory,
    int currentStressLevel,
  ) async {
    try {
      // Build conversation context for stress detection
      String context = '';
      if (conversationHistory.isNotEmpty) {
        final recentMessages = conversationHistory.length > 4 
            ? conversationHistory.sublist(conversationHistory.length - 4)
            : conversationHistory;
        context = '\nRecent conversation context:\n';
        for (var msg in recentMessages) {
          context += '${msg.isUser ? "User" : "Assistant"}: ${msg.text}\n';
        }
      }

      String prompt = '''You are analyzing a student's emotional state. Their current reported stress level is $currentStressLevel/10.

$context
Latest message from student: "$userMessage"

Based on their message and conversation context, analyze if their stress level has changed. Consider:
- Emotional indicators (anxiety, worry, panic, frustration, calm, relief)
- Language intensity (exclamation marks, capitalization, urgency)
- Content themes (exams, deadlines, relationships, pressure)
- Overall sentiment and tone

Respond with ONLY a number from 1-10 representing the estimated stress level. Do not include any other text, just the number:''';

      // Use lower temperature for stress detection to be more accurate
      final response = await GeminiService.generateText(
        prompt, 
        maxTokens: 10,
        temperature: 0.3, // Lower temperature for more consistent/accurate detection
      );
      final detectedLevel = int.tryParse(response.trim().replaceAll(RegExp(r'[^0-9]'), '')) ?? currentStressLevel;
      return detectedLevel.clamp(1, 10);
    } catch (e) {
      return currentStressLevel;
    }
  }

  /// Gets appropriate tone guidance based on stress level
  String _getToneGuidance(int stressLevel) {
    if (stressLevel >= 8) {
      return '''VERY CALM, VERY GENTLE tone. Speak slowly and soothingly. Use short sentences. Focus entirely on emotional support and validation. Use phrases like "I'm here with you", "That sounds really difficult", "It's okay to feel this way". Avoid giving advice or solutions immediately. Just be present.''';
    } else if (stressLevel >= 6) {
      return '''CALM, REASSURING tone. Be gentle and supportive. Acknowledge their feelings first. Use phrases like "I understand", "That makes sense", "We can work through this together". Offer gentle guidance when appropriate.''';
    } else if (stressLevel >= 4) {
      return '''WARM, ENCOURAGING tone. Be friendly but mindful. Show understanding and offer constructive support. Balance empathy with gentle motivation.''';
    } else {
      return '''FRIENDLY, POSITIVE tone. Be warm and encouraging. Celebrate small wins. Offer supportive guidance and maintain a hopeful outlook.''';
    }
  }

  Future<String> sendMessage(
    String userMessage,
    List<ChatMessage> conversationHistory,
    int stressLevel,
  ) async {
    try {
      final toneGuidance = _getToneGuidance(stressLevel);
      
      // Build conversation history context (reduced for speed)
      String historyContext = '';
      if (conversationHistory.isNotEmpty) {
        // Only use last 4 messages for faster processing
        final recentMessages = conversationHistory.length > 4 
            ? conversationHistory.sublist(conversationHistory.length - 4)
            : conversationHistory;
        historyContext = '\n\nRecent:\n';
        for (var msg in recentMessages) {
          historyContext += '${msg.isUser ? "Student" : "You"}: ${msg.text}\n';
        }
      }

      // Natural, human-like prompt
      String prompt = '''You are Sahaay, a warm and supportive student companion. You're having a real conversation with a student.

Student (stress level $stressLevel/10) said: "$userMessage"

$historyContext

Be authentic and human:
- Respond naturally like a caring friend or counselor (2-4 sentences)
- Show genuine empathy and understanding
- Sometimes ask questions, sometimes offer reflections or support
- Vary your responses - don't always end with questions
- Match the conversation flow naturally
- Be present and attentive
- Tone: $toneGuidance

Respond naturally as Sahaay:''';

      // Adjust temperature based on stress level for more human-like responses
      // Higher stress = more controlled, lower stress = slightly more creative
      final temperature = stressLevel >= 7 ? 0.8 : (stressLevel >= 4 ? 0.75 : 0.7);
      
      // Use more tokens for complete responses (768 tokens = ~600 words)
      final response = await GeminiService.generateText(
        prompt, 
        maxTokens: 768, // Increased for fuller responses
        temperature: temperature,
      );
      if (response.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }
      return response.trim();
    } catch (e) {
      // Use intelligent fallback instead of rethrowing
      return _generateFallbackResponse(userMessage, conversationHistory, stressLevel, e);
    }
  }

  /// Generate intelligent fallback response when API fails
  String _generateFallbackResponse(
    String userMessage,
    List<ChatMessage> conversationHistory,
    int stressLevel,
    dynamic error,
  ) {
    final lowerMessage = userMessage.toLowerCase();
    
    // High stress responses (stressLevel >= 7)
    if (stressLevel >= 7) {
      if (lowerMessage.contains('exam') || lowerMessage.contains('test') || lowerMessage.contains('study')) {
        final responses = [
          "I can feel how overwhelming this is for you right now. Exams can really pile on the pressure. Take a moment - we can work through this together. What's the biggest thing worrying you about it?",
          "That sounds really tough, and it's completely okay to feel this way. You're dealing with a lot right now. Let's break this down together. What specifically is making you feel this stressed?",
          "I'm here with you. I know exams can feel like everything is on the line, but remember - you're more than your grades. How are you managing?",
        ];
        return responses[_random.nextInt(responses.length)];
      }
      
      if (lowerMessage.contains('anxious') || lowerMessage.contains('panic') || lowerMessage.contains('overwhelmed')) {
        final responses = [
          "I'm here with you. These feelings can be really intense, and that's okay. Let's take it one breath at a time.",
          "That sounds really difficult. You're not alone in feeling this way. Take a slow breath with me.",
          "I hear you, and I'm here. These moments can feel really heavy. It's okay to feel this way.",
          "I'm here. These feelings are valid. You don't have to go through this alone. What helps you feel more grounded?",
          "That sounds really tough. I want you to know that feeling this way is completely understandable. How can I support you right now?",
        ];
        return responses[_random.nextInt(responses.length)];
      }
      
      if (lowerMessage.contains('sad') || lowerMessage.contains('depressed') || lowerMessage.contains('down') || lowerMessage.contains('hopeless')) {
        final responses = [
          "I'm really sorry you're going through this. It takes courage to share how you're feeling. I'm here to listen.",
          "I can hear how much this is affecting you. You don't have to face this alone.",
          "I'm here with you. These feelings are really tough, and it's okay to feel them.",
          "That sounds incredibly difficult. I want you to know you're not alone in this. I'm here.",
          "I hear you. These moments are really hard. Take your time - I'm not going anywhere.",
        ];
        return responses[_random.nextInt(responses.length)];
      }
      
      // Generic high stress response
      final responses = [
        "I'm here with you right now. I can see you're going through a lot, and that's completely valid. Take your time.",
        "I hear you, and I'm listening. You're dealing with something really difficult, and I want to understand.",
        "I'm here. These feelings can be really intense, and it's okay. We can work through this together.",
        "You're going through a lot right now. I'm here with you through it all.",
        "I can feel how heavy this is for you. You don't have to carry it alone. I'm here.",
      ];
      return responses[_random.nextInt(responses.length)];
    }
    
    // Medium stress responses (stressLevel >= 4)
    if (stressLevel >= 4) {
      if (lowerMessage.contains('exam') || lowerMessage.contains('test') || lowerMessage.contains('study') || lowerMessage.contains('assignment')) {
        final responses = [
          "Exams and assignments can definitely be stressful! I get that. We can think through this together.",
          "That sounds challenging. It's normal to feel stressed about academics. I'm here to support you.",
          "I understand the pressure you're feeling. Academic stuff can really pile up. How are you managing?",
          "Academic pressure is real, and it's okay to feel overwhelmed. Let's break this down when you're ready.",
          "I hear you. The academic load can feel crushing sometimes. What would help you right now?",
        ];
        return responses[_random.nextInt(responses.length)];
      }
      
      if (lowerMessage.contains('tired') || lowerMessage.contains('exhausted') || lowerMessage.contains('sleep')) {
        final responses = [
          "It sounds like you're really worn out. That can make everything feel harder. How have you been managing your rest lately?",
          "Feeling tired all the time is really draining. It's important to take care of yourself. What's been keeping you up or wearing you down?",
          "I hear you - being exhausted makes everything feel more difficult. How are you taking care of yourself right now?",
        ];
        return responses[_random.nextInt(responses.length)];
      }
      
      if (lowerMessage.contains('friend') || lowerMessage.contains('relationship') || lowerMessage.contains('people')) {
        final responses = [
          "Relationships can be complicated and really affect how we feel. What's been going on? I'm here to listen.",
          "That sounds difficult. Relationships matter a lot, and when they're tough, it can really weigh on you. What's happening?",
          "I understand this is affecting you. Social stuff can be really stressful. What would you like to talk about?",
        ];
        return responses[_random.nextInt(responses.length)];
      }
      
      // Generic medium stress response
      final responses = [
        "I'm here to listen and support you. It sounds like you're dealing with something that's weighing on you.",
        "I hear you. It's okay to feel this way. Let's talk through what's happening.",
        "I understand. Sometimes things can feel really overwhelming. I'm here with you.",
        "That sounds tough. I'm here to listen whenever you want to share more.",
        "I can sense this is affecting you. Take your time - I'm here when you're ready.",
      ];
      return responses[_random.nextInt(responses.length)];
    }
    
    // Low stress responses (stressLevel < 4)
    if (lowerMessage.contains('exam') || lowerMessage.contains('test') || lowerMessage.contains('study')) {
      final responses = [
        "Preparing for exams can be challenging, but I believe in you! What's your plan?",
        "Academic stuff can definitely add pressure. How are you feeling about it all?",
        "That's a lot to balance! How are you managing everything?",
        "I'm here if you want to talk through any of it. How's your preparation going?",
        "That sounds manageable. Keep up the good work! How can I help support you?",
      ];
      return responses[_random.nextInt(responses.length)];
    }
    
    if (lowerMessage.contains('happy') || lowerMessage.contains('good') || lowerMessage.contains('excited') || lowerMessage.contains('great')) {
      final responses = [
        "That's wonderful to hear! I'm really glad things are going well for you. What's been making you feel this way?",
        "I love hearing that! It's great when things feel good. What's been going on that's bringing you this positive energy?",
        "That makes me happy to hear! I'm here to celebrate the good moments with you. What's got you feeling this way?",
      ];
      return responses[_random.nextInt(responses.length)];
    }
    
    // Check for greetings
    if (lowerMessage.contains('hi') || lowerMessage.contains('hello') || lowerMessage.contains('hey')) {
      final responses = [
        "Hey there! I'm Sahaay. How are you doing today?",
        "Hi! Good to hear from you. How are things going?",
        "Hello! I'm here and ready to listen. How are you feeling?",
        "Hey! It's good to connect. What's been on your heart lately?",
        "Hi there! I'm glad you're here. How can I support you today?",
      ];
      return responses[_random.nextInt(responses.length)];
    }
    
    // Check for thanks/gratitude
    if (lowerMessage.contains('thank') || lowerMessage.contains('thanks')) {
      final responses = [
        "You're so welcome! I'm really glad I could help. How are you feeling now?",
        "Of course! That's what I'm here for. Is there anything else you'd like to talk about?",
        "Anytime! I'm always here to listen. How are things going for you?",
      ];
      return responses[_random.nextInt(responses.length)];
    }
    
    // Generic low stress response
    final responses = [
      "I'm here to listen. Thanks for sharing that with me.",
      "I hear you. That's really helpful to know. How are you feeling about all of this?",
      "Thanks for opening up. I'm here to support you.",
      "I appreciate you sharing that. How are you doing with everything?",
      "I'm listening. What's been going on for you lately?",
      "That makes sense. I'm here whenever you want to talk more.",
      "I understand. How are you feeling about that?",
    ];
    return responses[_random.nextInt(responses.length)];
  }

  Future<String> generateFirstMessage(int stressLevel) async {
    try {
      final toneGuidance = _getToneGuidance(stressLevel);
      
      // Natural first message prompt
      String prompt = '''You are Sahaay, a warm and supportive student companion. A student is opening the chat for the first time.

They're at stress level $stressLevel/10. Tone guidance: $toneGuidance

Generate a warm, welcoming first message (2-3 sentences). Be natural and human - don't force a question. Sometimes just be present and supportive:''';

      // Use slightly higher temperature for first message to feel more natural
      final temperature = stressLevel >= 7 ? 0.8 : 0.75;
      
      // Use more tokens for complete first message
      final response = await GeminiService.generateText(
        prompt, 
        maxTokens: 512, // Increased for fuller first message
        temperature: temperature,
      );
      if (response.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }
      return response.trim();
    } catch (e) {
      // Return a friendly fallback message instead of rethrowing
      // This ensures the user always sees something immediately
      final fallbacks = [
        if (stressLevel >= 7) ...[
          "Hey there. I'm Sahaay, and I'm here with you. I can see you're going through a lot right now.",
          "Hi. I'm Sahaay. I'm here to listen whenever you need someone to talk to.",
          "Hello. I'm Sahaay, and I'm here for you. Take your time - I'm listening.",
        ] else if (stressLevel >= 4) ...[
          "Hi! I'm Sahaay. I'm here to listen and support you. How are you doing?",
          "Hey! I'm Sahaay. I'm here whenever you need to talk. How are you feeling?",
          "Hello! I'm Sahaay. I'm glad you're here. What's going on for you today?",
        ] else ...[
          "Hey! I'm Sahaay, your supportive companion. I'm here whenever you need to talk.",
          "Hi! I'm Sahaay. How are you doing today? I'm here to listen.",
          "Hello! I'm Sahaay. I'm glad you reached out. How can I support you today?",
        ],
      ];
      return fallbacks[_random.nextInt(fallbacks.length)];
    }
  }
}
