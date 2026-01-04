import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahaay/theme/app_theme.dart';
import 'package:sahaay/providers/stress_provider.dart';

/// Stress indicator widget - shows current stress level with gentle message
class StressIndicator extends StatelessWidget {
  final bool showMessage;
  
  const StressIndicator({
    super.key,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StressProvider>(
      builder: (context, stressProvider, child) {
        final stressLevel = stressProvider.currentStressLevel;
        final stressColor = AppTheme.getStressColor(stressLevel);
        final stressEmoji = AppTheme.getStressEmoji(stressLevel);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: stressColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: stressColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Current stress: ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  Text(
                    '$stressLevel / 10',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: stressColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stressEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              if (showMessage) ...[
                const SizedBox(height: 8),
                Text(
                  stressProvider.getStressAwareMessage(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

