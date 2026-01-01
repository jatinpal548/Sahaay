import 'package:flutter/material.dart';
import 'package:sahaay/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

/// Stress Graph with animated bars/dots
/// Uses hard-coded sample data: [4, 6, 7, 5, 8, 6, 4]
class StressGraph extends StatefulWidget {
  const StressGraph({super.key});

  @override
  State<StressGraph> createState() => _StressGraphState();
}

class _StressGraphState extends State<StressGraph>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<int> _stressData = [4, 6, 7, 5, 8, 6, 4]; // Last 7 days
  final List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<double> _animatedValues = [];

  @override
  void initState() {
    super.initState();
    _animatedValues = List.filled(_stressData.length, 0.0);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Animate bars one-by-one
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your stress this week',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          
          const SizedBox(height: 24),
          
          // Animated line chart
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                // Calculate animated values
                for (int i = 0; i < _stressData.length; i++) {
                  final delay = i * 0.15;
                  final progress = ((_animationController.value - delay).clamp(0.0, 1.0) * (1.0 / (1.0 - delay))).clamp(0.0, 1.0);
                  _animatedValues[i] = _stressData[i] * progress;
                }
                
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppTheme.textLight.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt() - 1;
                            if (index >= 0 && index < _dayLabels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _dayLabels[index],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.textLight.withOpacity(0.3),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: AppTheme.textLight.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    minX: 1,
                    maxX: 7,
                    minY: 0,
                    maxY: 10,
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          _stressData.length,
                          (index) => FlSpot(
                            (index + 1).toDouble(),
                            _animatedValues[index],
                          ),
                        ),
                        isCurved: true,
                        color: AppTheme.pastelTeal,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: AppTheme.getStressColor(_stressData[index]),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.pastelTeal.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Gentle insight text
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _animationController.value > 0.8 ? 1.0 : 0.0,
                child: Text(
                  _getInsightText(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getInsightText() {
    final avg = _stressData.reduce((a, b) => a + b) / _stressData.length;
    if (avg > 6) {
      return "This week felt a little heavier than usual.";
    } else if (avg > 4) {
      return "You've had ups and downs — that's okay.";
    } else {
      return "You've been managing well this week.";
    }
  }
}

