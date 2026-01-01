import 'package:flutter/material.dart';
import 'package:sahaay/theme/app_theme.dart';
import 'package:sahaay/screens/onboarding_screen.dart';

/// Splash Screen with soft gradient animation
/// Auto-navigates to onboarding after 4 seconds
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientAnimation;
  late Animation<double> _appNameAnimation;
  late Animation<double> _taglineAnimation;
  late Animation<double> _footerAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation controller for gradient shift (increased duration for slower animation)
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    
    // Gradient animation (slowly shifts between colors)
    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppTheme.softCurve,
      ),
    );
    
    // App name animation (fade + scale in) - slower entrance
    _appNameAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: AppTheme.softCurve),
      ),
    );
    
    // Tagline animation (fades in after delay) - more gradual
    _taglineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.55, curve: AppTheme.softCurve),
      ),
    );
    
    // Footer animation (fades in last) - slower appearance
    _footerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.75, curve: AppTheme.softCurve),
      ),
    );
    
    // Start animations
    _controller.forward();
    
    // Navigate to onboarding after 4 seconds with fade transition (increased from 2 seconds)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
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
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    AppTheme.gradientStart[0],
                    AppTheme.gradientEnd[0],
                    _gradientAnimation.value,
                  )!,
                  Color.lerp(
                    AppTheme.gradientStart[1],
                    AppTheme.gradientEnd[1],
                    _gradientAnimation.value,
                  )!,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // App name with fade + scale animation
                    AnimatedBuilder(
                      animation: _appNameAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (_appNameAnimation.value * 0.2),
                          child: Opacity(
                            opacity: _appNameAnimation.value,
                            child: Text(
                              'SAHAAY',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tagline with fade animation
                    AnimatedBuilder(
                      animation: _taglineAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _taglineAnimation.value,
                          child: Text(
                            'Your gentle companion',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const Spacer(),
                    
                    // Footer with fade animation
                    AnimatedBuilder(
                      animation: _footerAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _footerAnimation.value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: Text(
                              'Developed with ❤️ by INNOV8TORS',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textLight,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

