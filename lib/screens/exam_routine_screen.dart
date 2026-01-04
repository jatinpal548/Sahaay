import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahaay/theme/app_theme.dart';
import 'package:sahaay/widgets/animated_card.dart';
import 'package:sahaay/widgets/calm_button.dart';
import 'package:sahaay/widgets/stress_indicator.dart';
import 'package:sahaay/providers/stress_provider.dart';

/// Exam Routine Planner Screen - Stress-aware routine with timetable input
class ExamRoutineScreen extends StatefulWidget {
  const ExamRoutineScreen({super.key});

  @override
  State<ExamRoutineScreen> createState() => _ExamRoutineScreenState();
}

class _ExamRoutineScreenState extends State<ExamRoutineScreen>
    with TickerProviderStateMixin {
  late AnimationController _screenController;
  late AnimationController _regenerateController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;
  
  // Form controllers
  final TextEditingController _examNameController = TextEditingController();
  final TextEditingController _examDateController = TextEditingController();
  final TextEditingController _examTimeController = TextEditingController();
  
  // State
  String _selectedDifficulty = 'Medium';
  List<ExamInfo> _exams = [];
  List<RoutineItem> _routineItems = [];
  bool _showRoutine = false;
  bool _isGenerating = false;
  bool _showInputForm = true;

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
    
    _regenerateController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _regenerateController, curve: AppTheme.softCurve),
    );
    
    _screenController.forward();
  }

  @override
  void dispose() {
    _examNameController.dispose();
    _examDateController.dispose();
    _examTimeController.dispose();
    _screenController.dispose();
    _regenerateController.dispose();
    super.dispose();
  }

  void _addExam() {
    if (_examNameController.text.trim().isEmpty) return;

    setState(() {
      _exams.add(ExamInfo(
        name: _examNameController.text.trim(),
        date: _examDateController.text.trim().isEmpty 
            ? 'TBD' 
            : _examDateController.text.trim(),
        time: _examTimeController.text.trim().isEmpty 
            ? 'TBD' 
            : _examTimeController.text.trim(),
        difficulty: _selectedDifficulty,
      ));
      _examNameController.clear();
      _examDateController.clear();
      _examTimeController.clear();
    });
  }

  void _generateRoutine() {
    if (_exams.isEmpty) {
      // Show message to add exams first
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one exam first'),
          backgroundColor: AppTheme.pastelTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _showRoutine = false;
    });

    // Simulate AI generation delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        final stressProvider = Provider.of<StressProvider>(context, listen: false);
        final stressLevel = stressProvider.currentStressLevel;
        
        setState(() {
          _routineItems = _generateStressAwareRoutine(stressLevel);
          _isGenerating = false;
          _showRoutine = true;
          _showInputForm = false;
        });
      }
    });
  }

  List<RoutineItem> _generateStressAwareRoutine(int stressLevel) {
    // Stress-aware routine generation (mock)
    if (stressLevel >= 7) {
      // High stress: More breaks, lighter study sessions
      return [
        RoutineItem(time: '9:00', activity: 'Light revision (30 mins)', type: 'study'),
        RoutineItem(time: '9:30', activity: 'Break', type: 'break'),
        RoutineItem(time: '10:00', activity: 'Practice key concepts', type: 'study'),
        RoutineItem(time: '11:00', activity: 'Rest', type: 'break'),
        RoutineItem(time: '2:00', activity: 'Quick review', type: 'study'),
        RoutineItem(time: '2:30', activity: 'Fresh air', type: 'break'),
      ];
    } else if (stressLevel >= 4) {
      // Medium stress: Balanced routine
      return [
        RoutineItem(time: '9:00', activity: 'Revise Physics', type: 'study'),
        RoutineItem(time: '10:00', activity: 'Break', type: 'break'),
        RoutineItem(time: '10:30', activity: 'Practice Questions', type: 'study'),
        RoutineItem(time: '12:00', activity: 'Rest', type: 'break'),
        RoutineItem(time: '2:00', activity: 'Review Notes', type: 'study'),
        RoutineItem(time: '3:30', activity: 'Short Walk', type: 'break'),
      ];
    } else {
      // Low stress: Can handle more study time
      return [
        RoutineItem(time: '8:30', activity: 'Deep revision', type: 'study'),
        RoutineItem(time: '10:00', activity: 'Break', type: 'break'),
        RoutineItem(time: '10:30', activity: 'Practice Problems', type: 'study'),
        RoutineItem(time: '12:00', activity: 'Lunch break', type: 'break'),
        RoutineItem(time: '1:00', activity: 'Review & Summarize', type: 'study'),
        RoutineItem(time: '3:00', activity: 'Light activity', type: 'break'),
      ];
    }
  }

  void _regenerateRoutine() {
    _regenerateController.forward().then((_) {
      _regenerateController.reverse();
    });

    // Simulate regeneration
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        final stressProvider = Provider.of<StressProvider>(context, listen: false);
        final stressLevel = stressProvider.currentStressLevel;
        
        setState(() {
          _routineItems = _generateStressAwareRoutine(stressLevel);
        });
      }
    });
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
                              'Exam Routine',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              "Balanced, realistic, and stress-aware.",
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
                  
                  // Input form (if not showing routine)
                  if (_showInputForm)
                    AnimatedCard(
                      delay: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('📅', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Add Your Exams',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Exam name
                          TextField(
                            controller: _examNameController,
                            decoration: InputDecoration(
                              labelText: 'Exam name',
                              hintText: 'E.g., Physics Final',
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
                          const SizedBox(height: 16),
                          
                          // Date and time row
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _examDateController,
                                  decoration: InputDecoration(
                                    labelText: 'Date',
                                    hintText: 'DD/MM/YYYY',
                                    filled: true,
                                    fillColor: AppTheme.softBeige.withOpacity(0.5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: AppTheme.textPrimary,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _examTimeController,
                                  decoration: InputDecoration(
                                    labelText: 'Time',
                                    hintText: 'HH:MM',
                                    filled: true,
                                    fillColor: AppTheme.softBeige.withOpacity(0.5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: AppTheme.textPrimary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Difficulty dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedDifficulty,
                            decoration: InputDecoration(
                              labelText: 'Subject difficulty',
                              filled: true,
                              fillColor: AppTheme.softBeige.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            items: ['Easy', 'Medium', 'Hard'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedDifficulty = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Add exam button
                          CalmButton(
                            text: ' Add exam',
                            icon: Icons.add,
                            onTap: _addExam,
                          ),
                        ],
                      ),
                    ),
                  
                  // Added exams list
                  if (_exams.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    AnimatedCard(
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Exams',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(
                            _exams.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.softBlue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.school_outlined,
                                      size: 16,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _exams[index].name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        Text(
                                          '${_exams[index].date} at ${_exams[index].time} • ${_exams[index].difficulty}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Generate routine button
                  if (_showInputForm && _exams.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    AnimatedCard(
                      delay: const Duration(milliseconds: 600),
                      padding: EdgeInsets.zero,
                      child: CalmButton(
                        text: 'Create stress-free routine',
                        icon: Icons.auto_awesome,
                        onTap: _generateRoutine,
                        isLoading: _isGenerating,
                      ),
                    ),
                  ],
                  
                  // Routine output (after generation)
                  if (_showRoutine) ...[
                    const SizedBox(height: 24),
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
                                  Icons.schedule_outlined,
                                  color: AppTheme.textPrimary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Routine',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      "Your routine is designed to keep things balanced.",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.textSecondary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Routine items (animate in sequence)
                          ...List.generate(
                            _routineItems.length,
                            (index) => _RoutineItemWidget(
                              item: _routineItems[index],
                              delay: Duration(milliseconds: 300 + (index * 100)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Stress note strip
                    AnimatedCard(
                      delay: const Duration(milliseconds: 900),
                      backgroundColor: AppTheme.pastelTeal.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          const Text('💙', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Built to avoid overload and protect your energy.",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Regenerate button
                    AnimatedCard(
                      delay: const Duration(milliseconds: 1100),
                      padding: EdgeInsets.zero,
                      child: AnimatedBuilder(
                        animation: _rotateAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotateAnimation.value * 0.1,
                            child: CalmButton(
                              text: 'Regenerate Routine',
                              icon: Icons.refresh,
                              onTap: _regenerateRoutine,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  
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

/// Routine item widget with animation
class _RoutineItemWidget extends StatefulWidget {
  final RoutineItem item;
  final Duration delay;

  const _RoutineItemWidget({
    required this.item,
    required this.delay,
  });

  @override
  State<_RoutineItemWidget> createState() => _RoutineItemWidgetState();
}

class _RoutineItemWidgetState extends State<_RoutineItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(
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
    final isBreak = widget.item.type == 'break';
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              // Time badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isBreak
                      ? AppTheme.softGreen.withOpacity(0.3)
                      : AppTheme.softBlue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.item.time,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              // Activity
              Expanded(
                child: Text(
                  widget.item.activity,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
              ),
              // Icon indicator
              Icon(
                isBreak ? Icons.coffee_outlined : Icons.school_outlined,
                color: isBreak
                    ? AppTheme.softGreen
                    : AppTheme.softBlue,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Routine item model
class RoutineItem {
  final String time;
  final String activity;
  final String type; // 'study' or 'break'

  RoutineItem({
    required this.time,
    required this.activity,
    required this.type,
  });
}

/// Exam info model
class ExamInfo {
  final String name;
  final String date;
  final String time;
  final String difficulty;

  ExamInfo({
    required this.name,
    required this.date,
    required this.time,
    required this.difficulty,
  });
}
