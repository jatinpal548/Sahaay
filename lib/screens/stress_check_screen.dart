import 'package:flutter/material.dart';
import 'package:sahaay/theme/app_theme.dart';
import 'package:sahaay/widgets/animated_stress_slider.dart';
import 'package:sahaay/screens/stress_handler_screen.dart';

/// Stress Check Screen with animated slider and optional text field
class StressCheckScreen extends StatefulWidget {
  const StressCheckScreen({super.key});

  @override
  State<StressCheckScreen> createState() => _StressCheckScreenState();
}

class _StressCheckScreenState extends State<StressCheckScreen>
    with SingleTickerProviderStateMixin {
  int _stressLevel = 5;
  final TextEditingController _textController = TextEditingController();
  bool _sliderMoved = false;
  bool _canContinue = false;
  
  late AnimationController _questionController;
  late Animation<double> _questionAnimation;
  late Animation<double> _sliderAnimation;
  late Animation<double> _textFieldAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    
    _questionController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    )..repeat(reverse: true);
    
    // Question slides from top
    _questionAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _questionController,
        curve: AppTheme.softCurve,
      ),
    );
    
    // Slider fades in
    _sliderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionController,
        curve: const Interval(0.2, 0.8, curve: AppTheme.softCurve),
      ),
    );
    
    // Text field fades in after slider is moved
    _textFieldAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionController,
        curve: const Interval(0.5, 1.0, curve: AppTheme.softCurve),
      ),
    );
    
    // Button animation
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionController,
        curve: const Interval(0.7, 1.0, curve: AppTheme.softCurve),
      ),
    );
    
    _questionController.forward();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onStressLevelChanged(int level) {
    setState(() {
      _stressLevel = level;
      if (!_sliderMoved) {
        _sliderMoved = true;
        // Trigger text field animation
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _questionController.forward(from: 0.5);
          }
        });
      }
      _canContinue = true;
    });
  }

  void _navigateToHandler() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StressHandlerScreen(
          stressLevel: _stressLevel,
          notes: _textController.text,
        ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    
                    // Question slides from top
                    AnimatedBuilder(
                      animation: _questionAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _questionAnimation.value),
                          child: Opacity(
                            opacity: 1.0 - (_questionAnimation.value / -50.0).abs(),
                            child: Text(
                              "How stressed are you right now?",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 64),
                    
                    // Animated stress slider
                    AnimatedBuilder(
                      animation: _sliderAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _sliderAnimation.value,
                          child: Transform.scale(
                            scale: 0.9 + (_sliderAnimation.value * 0.1),
                            child: AnimatedStressSlider(
                              initialValue: _stressLevel,
                              onChanged: _onStressLevelChanged,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const Spacer(),
                    
                    // Optional text field fades in AFTER slider is moved
                    if (_sliderMoved)
                      AnimatedBuilder(
                        animation: _textFieldAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textFieldAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - _textFieldAnimation.value)),
                              child: TextField(
                                controller: _textController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: "What's been on your mind?",
                                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.textLight,
                                      ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.7),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                style: Theme.of(context).textTheme.bodyLarge,
                                onChanged: (value) {
                                  setState(() {
                                    _canContinue = value.trim().isNotEmpty || _stressLevel > 0;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Continue button
                    AnimatedBuilder(
                      animation: _buttonAnimation,
                      builder: (context, child) {
                        return AnimatedContainer(
                          duration: AppTheme.mediumAnimation,
                          curve: AppTheme.softCurve,
                          child: Opacity(
                            opacity: _canContinue ? 1.0 : 0.5,
                            child: Transform.scale(
                              scale: _canContinue ? 1.0 : 0.95,
                              child: ElevatedButton(
                                onPressed: _canContinue ? _navigateToHandler : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.pastelTeal,
                                  foregroundColor: AppTheme.textPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 18,
                                  ),
                                  disabledBackgroundColor: AppTheme.pastelTeal.withOpacity(0.5),
                                ),
                                child: Text(
                                  'Continue',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
