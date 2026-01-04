import 'package:flutter/material.dart';
import 'package:sahaay/theme/app_theme.dart';
import 'package:sahaay/widgets/animated_card.dart';
import 'package:sahaay/widgets/stress_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

/// Stress Patterns Screen - Visual stress trend analysis
class StressPatternsScreen extends StatefulWidget {
  const StressPatternsScreen({super.key});

  @override
  State<StressPatternsScreen> createState() => _StressPatternsScreenState();
}

class _StressPatternsScreenState extends State<StressPatternsScreen>
    with TickerProviderStateMixin {
  late AnimationController _screenController;
  late AnimationController _graphController;
  late Animation<double> _fadeAnimation;
  
  // Mock data for last 7 days
  final List<int> _stressData = [4, 6, 7, 5, 8, 6, 4];
  final List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<double> _animatedValues = [];

  @override
  void initState() {
    super.initState();
    _animatedValues = List.filled(_stressData.length, 0.0);
    
    _screenController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _screenController, curve: AppTheme.softCurve),
    );
    
    _graphController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _screenController.forward();
    
    // Start graph animation after screen fades in
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _graphController.forward();
      }
    });
  }

  @override
  void dispose() {
    _screenController.dispose();
    _graphController.dispose();
    super.dispose();
  }

  void _goBack() {
    Navigator.of(context).pop();
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
  
  String _getObservationText() {
    // Check mid-week pattern (Wed, Thu, Fri)
    final midWeek = (_stressData[2] + _stressData[3] + _stressData[4]) / 3;
    final weekStart = (_stressData[0] + _stressData[1]) / 2;
    
    if (midWeek > weekStart + 1) {
      return "You tend to feel more stressed mid-week.";
    } else {
      return "Your stress levels vary naturally throughout the week.";
    }
  }
  
  String _getStressTip(int index) {
    final tips = [
      "Try breaking tasks into smaller steps.",
      "A 5-minute pause can reset your focus.",
      "Rest is part of progress.",
    ];
    return tips[index % tips.length];
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
                              'Your Stress Patterns',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              "Just observations, not judgments.",
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
                  
                  // Graph card with animation
                  AnimatedCard(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last 7 days',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Animated line chart
                        SizedBox(
                          height: 220,
                          child: AnimatedBuilder(
                            animation: _graphController,
                            builder: (context, child) {
                              // Calculate animated values (bars animate one-by-one)
                              for (int i = 0; i < _stressData.length; i++) {
                                final delay = i * 0.15;
                                final progress = ((_graphController.value - delay)
                                    .clamp(0.0, 1.0) * (1.0 / (1.0 - delay)))
                                    .clamp(0.0, 1.0);
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
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
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
                                            color: AppTheme.getStressColor(
                                              _stressData[index],
                                            ),
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
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Insight text (fades in after graph)
                  AnimatedBuilder(
                    animation: _graphController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _graphController.value > 0.8 ? 1.0 : 0.0,
                        child: AnimatedCard(
                          delay: Duration.zero,
                          backgroundColor: AppTheme.softBlue.withOpacity(0.2),
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Text('💭', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _getInsightText(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: AppTheme.textPrimary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Gentle observations section
                  AnimatedCard(
                    delay: const Duration(milliseconds: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gentle observations',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _ObservationItem(
                          text: _getObservationText(),
                          delay: const Duration(milliseconds: 1200),
                        ),
                        const SizedBox(height: 12),
                        _ObservationItem(
                          text: "Taking short breaks helped reduce stress on some days.",
                          delay: const Duration(milliseconds: 1400),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Ways to ease stress card
                  AnimatedCard(
                    delay: const Duration(milliseconds: 1600),
                    backgroundColor: AppTheme.pastelTeal.withOpacity(0.15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('💙', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Ways to ease your stress',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(
                          3,
                          (index) => _StressTipItem(
                            tip: _getStressTip(index),
                            delay: Duration(milliseconds: 1800 + (index * 200)),
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

/// Observation item widget
class _ObservationItem extends StatefulWidget {
  final String text;
  final Duration delay;

  const _ObservationItem({
    required this.text,
    required this.delay,
  });

  @override
  State<_ObservationItem> createState() => _ObservationItemState();
}

class _ObservationItemState extends State<_ObservationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.softCurve),
    );
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•', style: TextStyle(fontSize: 20, color: AppTheme.pastelTeal)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stress tip item widget
class _StressTipItem extends StatefulWidget {
  final String tip;
  final Duration delay;

  const _StressTipItem({
    required this.tip,
    required this.delay,
  });

  @override
  State<_StressTipItem> createState() => _StressTipItemState();
}

class _StressTipItemState extends State<_StressTipItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.softCurve),
    );
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            const Text('💙', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.tip,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
