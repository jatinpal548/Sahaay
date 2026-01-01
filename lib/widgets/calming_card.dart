import 'package:flutter/material.dart';
import 'package:sahaay/theme/app_theme.dart';

/// Calming card with breathing animation (expand → contract loop)
class CalmingCard extends StatefulWidget {
  final String message;

  const CalmingCard({
    super.key,
    required this.message,
  });

  @override
  State<CalmingCard> createState() => _CalmingCardState();
}

class _CalmingCardState extends State<CalmingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Sample messages that rotate randomly
  static final List<String> _messages = [
    "I hear you. Let's slow things down together.",
    "It's okay to feel overwhelmed sometimes.",
    "You don't have to handle everything at once.",
    "Take a moment. You're doing your best.",
    "Breathe. This feeling will pass.",
  ];

  @override
  void initState() {
    super.initState();
    
    // Breathing animation: expand → contract loop
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4), // Slow breathing cycle
      vsync: this,
    )..repeat(reverse: true);
    
    // Scale animation (gentle expansion/contraction)
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: AppTheme.softCurve,
      ),
    );
    
    // Opacity animation (subtle pulse)
    _opacityAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: AppTheme.softCurve,
      ),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.pastelTeal.withOpacity(0.3),
                    AppTheme.softPeach.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.pastelTeal.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Breathing indicator
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.pastelTeal.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '🌿',
                        style: TextStyle(
                          fontSize: 40 * _scaleAnimation.value,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Message text
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

