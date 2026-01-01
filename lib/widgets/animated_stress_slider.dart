import 'package:flutter/material.dart';
import 'package:sahaay/theme/app_theme.dart';

/// Animated stress slider (1-10) with color transitions and emoji reactions
class AnimatedStressSlider extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final int initialValue;

  const AnimatedStressSlider({
    super.key,
    required this.onChanged,
    this.initialValue = 5,
  });

  @override
  State<AnimatedStressSlider> createState() => _AnimatedStressSliderState();
}

class _AnimatedStressSliderState extends State<AnimatedStressSlider>
    with SingleTickerProviderStateMixin {
  late double _value;
  late AnimationController _colorController;
  Animation<Color?>? _colorAnimation;
  late Animation<double> _emojiScaleAnimation;
  Color _currentColor = AppTheme.mutedOrange;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.toDouble();
    
    _colorController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );
    
    // Initialize color animation with initial value
    final stressLevel = _value.round();
    _currentColor = AppTheme.getStressColor(stressLevel);
    _colorAnimation = ColorTween(
      begin: AppTheme.mutedOrange,
      end: _currentColor,
    ).animate(
      CurvedAnimation(
        parent: _colorController,
        curve: AppTheme.softCurve,
      ),
    );
    
    _colorController.forward();
    
    _emojiScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _colorController,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _updateColorAnimation() {
    final stressLevel = _value.round();
    Color targetColor = AppTheme.getStressColor(stressLevel);
    
    // Update current color and create new animation
    _currentColor = targetColor;
    _colorAnimation = ColorTween(
      begin: _colorAnimation?.value ?? _currentColor,
      end: targetColor,
    ).animate(
      CurvedAnimation(
        parent: _colorController,
        curve: AppTheme.softCurve,
      ),
    );
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  void _onChanged(double newValue) {
    setState(() {
      _value = newValue;
    });
    
    _colorController.reset();
    _updateColorAnimation();
    _colorController.forward();
    
    widget.onChanged(newValue.round());
  }

  @override
  Widget build(BuildContext context) {
    final stressLevel = _value.round();
    final emoji = AppTheme.getStressEmoji(stressLevel);
    
    return Column(
      children: [
        // Emoji with scale animation
        AnimatedBuilder(
          animation: _emojiScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _emojiScaleAnimation.value,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 64),
              ),
            );
          },
        ),
        
        const SizedBox(height: 32),
        
        // Slider with animated color
        AnimatedBuilder(
          animation: _colorAnimation ?? const AlwaysStoppedAnimation<Color?>(AppTheme.mutedOrange),
          builder: (context, child) {
            final color = _colorAnimation?.value ?? _currentColor;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: color,
                  inactiveTrackColor: color?.withOpacity(0.3),
                  thumbColor: color,
                  overlayColor: color?.withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 16,
                  ),
                  trackHeight: 8,
                ),
                child: Slider(
                  value: _value,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: stressLevel.toString(),
                  onChanged: _onChanged,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Stress level label
        AnimatedBuilder(
          animation: _colorAnimation ?? const AlwaysStoppedAnimation<Color?>(AppTheme.mutedOrange),
          builder: (context, child) {
            final color = _colorAnimation?.value ?? _currentColor;
            return Text(
              '$stressLevel / 10',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            );
          },
        ),
      ],
    );
  }
}

