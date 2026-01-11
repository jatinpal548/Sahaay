import 'package:flutter/material.dart';
import 'package:sahaay/services/gemini_service.dart';

class StressProvider extends ChangeNotifier {
  int _stressLevel = 5; // Default to middle stress level
  String _aiLine = "";
  String _profileName = "Focused Fox 🦊"; // Default profile for level 5

  int get stressLevel => _stressLevel;
  int get currentStressLevel => _stressLevel;
  String get aiLine => _aiLine;
  String get profileName => _profileName;

  /// Update stress level synchronously (without API call)
  void updateStressLevelSync(int level) {
    _stressLevel = level.clamp(1, 10);

    // Update profile based on stress level
    if (_stressLevel <= 3) {
      _profileName = "Calm Panda 🐼";
    } else if (_stressLevel <= 6) {
      _profileName = "Focused Fox 🦊";
    } else {
      _profileName = "Brave Lion 🦁";
    }

    notifyListeners();
  }

  Future<void> updateStressLevel(int level) async {
    // Update level and profile name immediately
    updateStressLevelSync(level);

    // Generate AI line in background
    try {
      String prompt = '''You are Sahaay, a calm, ethical student support companion. A student just checked in with a stress level of $_stressLevel/10.

Generate a brief, empathetic, one-sentence message (maximum 20 words) that acknowledges their current state gently. Use a calm, non-judgmental tone. Do NOT diagnose or use clinical terms. Be genuine and present.''';

      _aiLine = await GeminiService.generateText(prompt, maxTokens: 100);
      if (_aiLine.isEmpty) {
        _aiLine = "I'm here with you. Take a slow breath, and we can continue when you're ready.";
      }
    } catch (e) {
      _aiLine = "I'm here with you. Take a slow breath, and we can continue when you're ready.";
    }

    notifyListeners();
  }

  void updateStress(int level, String line) {
    _stressLevel = level.clamp(1, 10); // Ensure valid range
    _aiLine = line;

    // Update profile based on stress level
    if (_stressLevel <= 3) {
      _profileName = "Calm Panda 🐼";
    } else if (_stressLevel <= 6) {
      _profileName = "Focused Fox 🦊";
    } else {
      _profileName = "Brave Lion 🦁";
    }

    notifyListeners();
  }

  String getStressAwareMessage() {
    if (_stressLevel <= 3) {
      return "You're doing well. Keep taking care of yourself.";
    } else if (_stressLevel <= 6) {
      return "It's okay to feel this way. We'll work through it together.";
    } else {
      return "This is a tough moment. I'm here with you.";
    }
  }
}
