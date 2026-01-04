import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahaay/theme/app_theme.dart';
import 'package:sahaay/widgets/animated_card.dart';
import 'package:sahaay/widgets/calm_button.dart';
import 'package:sahaay/widgets/stress_indicator.dart';
import 'package:sahaay/providers/stress_provider.dart';

/// Study Helper Screen - Stress-aware academic support
class StudyHelperScreen extends StatefulWidget {
  const StudyHelperScreen({super.key});

  @override
  State<StudyHelperScreen> createState() => _StudyHelperScreenState();
}

class _StudyHelperScreenState extends State<StudyHelperScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  late AnimationController _screenController;
  late Animation<double> _fadeAnimation;
  String? _mockResponse;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _screenController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _screenController, curve: AppTheme.softCurve),
    );
    _screenController.forward();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _screenController.dispose();
    super.dispose();
  }

  void _handleGetHelp() {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _mockResponse = null;
    });

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _mockResponse = _getMockResponse(_inputController.text);
        });
      }
    });
  }

  String _getMockResponse(String input) {
    final lowerInput = input.toLowerCase();
    final stressProvider = Provider.of<StressProvider>(context, listen: false);
    final stressLevel = stressProvider.currentStressLevel;
    
    // Stress-aware prefix
    String stressPrefix = '';
    if (stressLevel >= 7) {
      stressPrefix = "If this feels like too much, we can slow it down.\n\n";
    } else if (stressLevel >= 4) {
      stressPrefix = "We'll focus on what feels manageable.\n\n";
    }
    
    if (lowerInput.contains('math') || lowerInput.contains('calculus')) {
      return '''$stressPrefix Let's break this topic into small parts.

1. Start with the basics — review the fundamental concepts first.
2. Practice one type of problem at a time.
3. Take breaks between practice sessions.
4. Don't worry about speed — understanding is more important.

Remember: It's okay to take your time. Learning happens step by step.''';
    } else if (lowerInput.contains('physics') || lowerInput.contains('formula')) {
      return '''$stressPrefix Physics can feel overwhelming, but we'll take it step by step.

1. Understand the concept behind the formula first.
2. Break down complex problems into smaller steps.
3. Visualize what's happening — draw diagrams if it helps.
4. Practice with simpler examples before moving to harder ones.

You're doing great by asking for help. That's the first step!''';
    } else if (lowerInput.contains('chemistry') || lowerInput.contains('reaction')) {
      return '''$stressPrefix Chemistry has many moving parts, and that's normal to feel stuck.

1. Focus on one chapter or topic at a time.
2. Create simple summaries or flashcards.
3. Connect concepts to real-world examples.
4. Practice balancing equations step by step.

Take it slow. There's no rush. Understanding comes with time.''';
    } else {
      return '''$stressPrefix Let's break this topic into small, manageable parts.

1. Start with what you already know — build from there.
2. Break the topic into smaller sections.
3. Study one section at a time, take breaks.
4. Review and connect the pieces together.

Remember: Learning is a journey, not a race. You're doing enough.''';
    }
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.softPeach, AppTheme.softBeige],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Header with back button
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _goBack,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.pastelTeal.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppTheme.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Study Helper',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              "We'll take it step by step.",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stress indicator
                  StressIndicator(),
                  
                  const SizedBox(height: 24),
                  
                  // Input card with animation
                  AnimatedCard(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your current stress is considered while helping you.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'What topic are you stuck on?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _inputController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'E.g., "I\'m struggling with calculus derivatives"',
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                            filled: true,
                            fillColor: AppTheme.softBeige.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stress reminder strip
                  AnimatedCard(
                    delay: const Duration(milliseconds: 400),
                    backgroundColor: AppTheme.pastelTeal.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        const Text('💙', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "We'll go slow. No rush.",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Get help button
                  AnimatedCard(
                    delay: const Duration(milliseconds: 600),
                    padding: EdgeInsets.zero,
                    child: CalmButton(
                      text: 'Get help',
                      icon: Icons.lightbulb_outline,
                      onTap: _handleGetHelp,
                      isLoading: _isLoading,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Mock response card (appears after button tap)
                  if (_mockResponse != null)
                    AnimatedCard(
                      delay: Duration.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.softBlue.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.school_outlined,
                                  color: AppTheme.textPrimary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Here\'s a gentle approach:',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _mockResponse!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textPrimary,
                                  height: 1.6,
                                ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

