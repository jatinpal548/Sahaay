import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sahaay/theme/app_theme.dart';
import 'package:sahaay/widgets/calming_card.dart';
import 'package:sahaay/screens/dashboard_screen.dart';

/// Stress Handler Screen with calming card and breathing animation
class StressHandlerScreen extends StatefulWidget {
  final int stressLevel;
  final String notes;

  const StressHandlerScreen({
    super.key,
    required this.stressLevel,
    this.notes = '',
  });

  @override
  State<StressHandlerScreen> createState() => _StressHandlerScreenState();
}

class _StressHandlerScreenState extends State<StressHandlerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _screenController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _buttonAnimation;
  
  late String _selectedMessage;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Select a random message
    final messages = [
      "I hear you. Let's slow things down together.",
      "It's okay to feel overwhelmed sometimes.",
      "You don't have to handle everything at once.",
      "Take a moment. You're doing your best.",
      "Breathe. This feeling will pass.",
    ];
    _selectedMessage = messages[_random.nextInt(messages.length)];
    
    _screenController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    )..repeat(reverse: true);
    
    // Screen fades in slowly
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _screenController,
        curve: AppTheme.softCurve,
      ),
    );
    
    // Card animation
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _screenController,
        curve: const Interval(0.2, 0.8, curve: AppTheme.softCurve),
      ),
    );
    
    // Button appears after delay
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _screenController,
        curve: const Interval(0.6, 1.0, curve: AppTheme.softCurve),
      ),
    );
    
    _screenController.forward();
  }

  @override
  void dispose() {
    _screenController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardScreen(),
        transitionDuration: AppTheme.slowAnimation,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: AppTheme.softCurve,
            ),
            child: child,
          );
        },
      ),
    );
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
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Calming card with breathing animation
                      AnimatedBuilder(
                        animation: _cardAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.8 + (_cardAnimation.value * 0.2),
                            child: Opacity(
                              opacity: _cardAnimation.value,
                              child: CalmingCard(
                                message: _selectedMessage,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 64),
                      
                      // Continue button appears after delay
                      AnimatedBuilder(
                        animation: _buttonAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.8 + (_buttonAnimation.value * 0.2),
                            child: Opacity(
                              opacity: _buttonAnimation.value,
                              child: ElevatedButton(
                                onPressed: _navigateToDashboard,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.pastelTeal,
                                  foregroundColor: AppTheme.textPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 18,
                                  ),
                                ),
                                child: Text(
                                  'Continue when ready',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
