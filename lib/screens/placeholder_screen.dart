import 'package:flutter/material.dart';
import 'package:sahaay/theme/app_theme.dart';

/// Placeholder screen for feature screens with gentle bounce animation
class PlaceholderScreen extends StatefulWidget {
  final String title;
  final String emoji;
  final String description;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.emoji,
    required this.description,
  });

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );
    
    // Gentle bounce animation
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    
    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppTheme.softCurve,
      ),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          child: Column(
            children: [
              // Back button with Hero animation
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Hero(
                    tag: 'back_button',
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: _goBack,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.scale(
                          scale: 0.7 + (_bounceAnimation.value * 0.3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Big soft icon
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    widget.emoji,
                                    style: const TextStyle(fontSize: 64),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Title
                              Text(
                                widget.title,
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Description
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  widget.description,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppTheme.textSecondary,
                                        height: 1.6,
                                      ),
                                ),
                              ),
                              
                              // Additional content based on feature
                              if (widget.title == 'Daily Routine') ...[
                                const SizedBox(height: 32),
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _RoutineItem(time: '10:00', task: 'Revise Math'),
                                      const SizedBox(height: 12),
                                      _RoutineItem(time: '11:00', task: 'Break'),
                                      const SizedBox(height: 12),
                                      _RoutineItem(time: '12:00', task: 'Practice Questions'),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutineItem extends StatelessWidget {
  final String time;
  final String task;

  const _RoutineItem({
    required this.time,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.pastelTeal.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            task,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}

