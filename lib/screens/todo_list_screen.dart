import 'package:flutter/material.dart';
import 'package:sahaay/theme/app_theme.dart';
import 'package:sahaay/widgets/animated_card.dart';
import 'package:sahaay/widgets/calm_button.dart';
import 'package:sahaay/widgets/stress_indicator.dart';

/// To-Do List Screen - Emotion-aware task management
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _screenController;
  late Animation<double> _fadeAnimation;
  
  // Mock tasks with stress levels
  final List<TodoTask> _tasks = [
    TodoTask(id: '1', text: 'Revise Math', isCompleted: false, stressLevel: 5),
    TodoTask(id: '2', text: 'Submit Assignment', isCompleted: false, stressLevel: 7),
    TodoTask(id: '3', text: 'Take a break', isCompleted: false, stressLevel: 2),
  ];
  
  String? _completionMessage;
  
  bool _showAddTask = false;
  final TextEditingController _newTaskController = TextEditingController();

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
    _screenController.forward();
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    _screenController.dispose();
    super.dispose();
  }

  void _toggleTask(int index) {
    final wasCompleted = _tasks[index].isCompleted;
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      
      // Show completion message if task was just completed
      if (!wasCompleted && _tasks[index].isCompleted) {
        _completionMessage = "Nice work. No need to rush the rest.";
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _completionMessage = null;
            });
          }
        });
      }
    });
  }

  void _addTask() {
    if (_newTaskController.text.trim().isEmpty) {
      setState(() {
        _showAddTask = false;
      });
      return;
    }

    setState(() {
      _tasks.add(TodoTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: _newTaskController.text.trim(),
        isCompleted: false,
        stressLevel: 5, // Default medium stress for new tasks
      ));
      _newTaskController.clear();
      _showAddTask = false;
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
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
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
                              'Today\'s To-Do',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              "Do what you can. That's enough.",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stress indicator
                      StressIndicator(),
                    ],
                  ),
                ),
                
                // Task list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _tasks.length + (_showAddTask ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_showAddTask && index == _tasks.length) {
                        // Add task input field
                        return AnimatedCard(
                          delay: Duration.zero,
                          child: Column(
                            children: [
                              TextField(
                                controller: _newTaskController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter new task...',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
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
                                onSubmitted: (_) => _addTask(),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showAddTask = false;
                                        _newTaskController.clear();
                                      });
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: _addTask,
                                    child: Text(
                                      'Add',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.pastelTeal,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      
                      final task = _tasks[index];
                      return _TaskItem(
                        task: task,
                        index: index,
                        onToggle: () => _toggleTask(index),
                        delay: Duration(milliseconds: 200 + (index * 100)),
                      );
                    },
                  ),
                ),
                
                // Completion message (if shown)
                if (_completionMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedCard(
                      delay: Duration.zero,
                      backgroundColor: AppTheme.softGreen.withOpacity(0.2),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _completionMessage!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Add task button and gentle message
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (!_showAddTask)
                        CalmButton(
                          text: '+ Add task',
                          icon: Icons.add,
                          onTap: () {
                            setState(() {
                              _showAddTask = true;
                            });
                          },
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'Your stress matters more than finishing everything.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Task item widget with animations
class _TaskItem extends StatefulWidget {
  final TodoTask task;
  final int index;
  final VoidCallback onToggle;
  final Duration delay;

  const _TaskItem({
    required this.task,
    required this.index,
    required this.onToggle,
    required this.delay,
  });

  @override
  State<_TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<_TaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _strikeAnimation;

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
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.softCurve),
    );

    _strikeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.softCurve),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });

    // Initialize strike animation based on task state
    _strikeAnimation = Tween<double>(
      begin: 0.0,
      end: widget.task.isCompleted ? 1.0 : 0.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.softCurve),
    );
    
    if (widget.task.isCompleted) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.isCompleted != oldWidget.task.isCompleted) {
      _strikeAnimation = Tween<double>(
        begin: widget.task.isCompleted ? 0.0 : 1.0,
        end: widget.task.isCompleted ? 1.0 : 0.0,
      ).animate(
        CurvedAnimation(parent: _controller, curve: AppTheme.softCurve),
      );
      _controller.forward(from: 0.0);
    }
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
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedCard(
              delay: Duration.zero,
              backgroundColor: widget.task.isCompleted
                  ? Colors.white.withOpacity(0.6)
                  : (widget.task.stressLevel >= 7
                      ? Colors.white.withOpacity(0.7) // Softer for high stress
                      : Colors.white.withOpacity(0.9)), // Brighter for low stress
            child: InkWell(
              onTap: widget.onToggle,
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  // Checkbox
                  AnimatedContainer(
                    duration: AppTheme.fastAnimation,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.task.isCompleted
                          ? AppTheme.softGreen
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.task.isCompleted
                            ? AppTheme.softGreen
                            : AppTheme.textLight,
                        width: 2,
                      ),
                    ),
                    child: widget.task.isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Task text with strike-through animation
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedBuilder(
                          animation: _strikeAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _StrikeThroughPainter(
                                progress: _strikeAnimation.value,
                                color: AppTheme.textSecondary,
                              ),
                              child: Opacity(
                                opacity: widget.task.isCompleted ? 0.5 : 1.0,
                                child: Text(
                                  widget.task.text,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: AppTheme.textPrimary,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        // Stress tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.getStressColor(widget.task.stressLevel)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.task.effortTag,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.getStressColor(widget.task.stressLevel),
                                  fontSize: 11,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for animated strike-through
class _StrikeThroughPainter extends CustomPainter {
  final double progress;
  final Color color;

  _StrikeThroughPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress > 0) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width * progress, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StrikeThroughPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Task model with stress level
class TodoTask {
  final String id;
  final String text;
  bool isCompleted;
  final int stressLevel; // 1-10 stress level for this task

  TodoTask({
    required this.id,
    required this.text,
    required this.isCompleted,
    this.stressLevel = 5, // Default medium stress
  });
  
  /// Get stress effort tag: "Low effort", "Medium effort", "High effort"
  String get effortTag {
    if (stressLevel <= 3) return 'Low effort';
    if (stressLevel <= 6) return 'Medium effort';
    return 'High effort';
  }
}

