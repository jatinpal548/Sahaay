import 'package:flutter/material.dart';
import 'package:sahaay/theme/app_theme.dart';
import 'package:sahaay/widgets/footer.dart';
import 'package:sahaay/screens/placeholder_screen.dart';
import 'package:sahaay/screens/stress_check_screen.dart';

/// Main Dashboard - Stress-First, Emotionally Safe Design
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _identityAnimation;
  late Animation<double> _stressHandlerAnimation;
  late Animation<double> _insightAnimation;
  late Animation<double> _actionsAnimation;
  late Animation<double> _counselorAnimation;
  
  // Sample data
  final int _currentStress = 6;
  final String _userName = "Calm Panda";
  final String _emoji = "🐼";
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller
    _mainController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    )..repeat(reverse: true);
    
    // Pulse controller for stress handler
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    // Staggered animations
    _identityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: AppTheme.softCurve),
      ),
    );
    
    _stressHandlerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.6, curve: AppTheme.softCurve),
      ),
    );
    
    _insightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.7, curve: AppTheme.softCurve),
      ),
    );
    
    _actionsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: AppTheme.softCurve),
      ),
    );
    
    _counselorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.8, 1.0, curve: AppTheme.softCurve),
      ),
    );
    
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToFeature(String title, String emoji, String description) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PlaceholderScreen(
          title: title,
          emoji: emoji,
          description: description,
        ),
        transitionDuration: AppTheme.slowAnimation,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: AppTheme.softCurve,
              ),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _navigateToStressCheck() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const StressCheckScreen(),
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
          child: AnimatedBuilder( 
            animation: _mainController,
            builder: (context, child) {
             return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // SECTION 1: Emotional Identity Card
                  _EmotionalIdentityCard(
                    userName: _userName,
                    emoji: _emoji,
                    animationValue: _identityAnimation.value,
                    onSettingsTap: () {
                      _navigateToFeature(
                        'Settings',
                        '⚙️',
                        'Customize your SAHAAY experience.',
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // SECTION 2: PRIMARY STRESS HANDLER (BIGGEST ELEMENT)
                  _PrimaryStressHandler(
                    stressLevel: _currentStress,
                    animationValue: _stressHandlerAnimation.value,
                    pulseAnimation: _pulseController,
                    onTalkTap: _navigateToStressCheck,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // SECTION 3: Calm Insight Strip
                  _CalmInsightStrip(
                    animationValue: _insightAnimation.value,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // SECTION 4: Secondary Actions (2x2 Grid - Only 4 features)
                  _SecondaryActionsGrid(
                    animationValue: _actionsAnimation.value,
                    onTap: _navigateToFeature,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // SECTION 5: Campus Counselor Card
                  _CampusCounselorCard(
                    animationValue: _counselorAnimation.value,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // SECTION 6: Footer
                  const Footer(),
                ],
              ),
             );
            }
          ),
        ),
      ),
    );
  }
}

// SECTION 1: Emotional Identity Card
class _EmotionalIdentityCard extends StatefulWidget {
  final String userName;
  final String emoji;
  final double animationValue;
  final VoidCallback onSettingsTap;

  const _EmotionalIdentityCard({
    required this.userName,
    required this.emoji,
    required this.animationValue,
    required this.onSettingsTap,
  });

  @override
  State<_EmotionalIdentityCard> createState() => _EmotionalIdentityCardState();
}

class _EmotionalIdentityCardState extends State<_EmotionalIdentityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _avatarController;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );
    
    if (widget.animationValue > 0.3) {
      _avatarController.forward();
    }
  }

  @override
  void didUpdateWidget(_EmotionalIdentityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationValue > 0.3 && oldWidget.animationValue <= 0.3) {
      _avatarController.forward();
    }
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.animationValue,
      duration: AppTheme.mediumAnimation,
      child: Transform.translate(
        offset: Offset(0, 30 * (1 - widget.animationValue)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.pastelTeal.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with scale animation
              AnimatedBuilder(
                animation: _avatarController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (_avatarController.value * 0.2),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.pastelTeal.withOpacity(0.3),
                            AppTheme.softPeach.withOpacity(0.3),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.pastelTeal.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 16),
              
              // Name and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.userName} ${widget.emoji}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "We'll keep things light today.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              
              // Settings icon
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onSettingsTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.pastelTeal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
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

// SECTION 2: PRIMARY STRESS HANDLER (BIGGEST ELEMENT)
class _PrimaryStressHandler extends StatelessWidget {
  final int stressLevel;
  final double animationValue;
  final AnimationController pulseAnimation;
  final VoidCallback onTalkTap;

  const _PrimaryStressHandler({
    required this.stressLevel,
    required this.animationValue,
    required this.pulseAnimation,
    required this.onTalkTap,
  });

  @override
  Widget build(BuildContext context) {
    final stressColor = AppTheme.getStressColor(stressLevel);
    
    return AnimatedOpacity(
      opacity: animationValue,
      duration: AppTheme.mediumAnimation,
      child: Transform.translate(
        offset: Offset(0, 30 * (1 - animationValue)),
        child: AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (pulseAnimation.value * 0.02),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      stressColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: stressColor.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'How are you feeling right now?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Stress indicator
                    Row(
                      children: [
                        Text(
                          'Current stress: ',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        Text(
                          '$stressLevel / 10',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: stressColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppTheme.getStressEmoji(stressLevel),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Main CTA Button
                    _TalkButton(
                      onTap: onTalkTap,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Subtext
                    Text(
                      "Say what's on your mind — I'm listening.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TalkButton extends StatefulWidget {
  final VoidCallback onTap;

  const _TalkButton({required this.onTap});

  @override
  State<_TalkButton> createState() => _TalkButtonState();
}

class _TalkButtonState extends State<_TalkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) {
      _tapController.reverse();
      widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tapController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 - (_tapController.value * 0.05),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.pastelTeal,
                      AppTheme.pastelTeal.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.pastelTeal.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🧠',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Talk it out',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// SECTION 3: Calm Insight Strip
class _CalmInsightStrip extends StatelessWidget {
  final double animationValue;

  const _CalmInsightStrip({required this.animationValue});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: animationValue,
      duration: AppTheme.mediumAnimation,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - animationValue)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.pastelTeal.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "You've had ups and downs — that's okay.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to stress graph/details
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View details →',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.pastelTeal,
                        fontWeight: FontWeight.w500,
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

// SECTION 4: Secondary Actions Grid (2x2 - Only 4 features)
class _SecondaryActionsGrid extends StatelessWidget {
  final double animationValue;
  final Function(String, String, String) onTap;

  const _SecondaryActionsGrid({
    required this.animationValue,
    required this.onTap,
  });

  final List<Map<String, String>> _actions = const [
    {
      'title': 'Study Helper',
      'emoji': '📘',
      'description': "We'll break things into small steps.",
    },
    {
      'title': 'Stress Patterns',
      'emoji': '📊',
      'description': 'See your stress patterns over time.',
    },
    {
      'title': 'To-Do List',
      'emoji': '📝',
      'description': 'Keep track of what matters to you.',
    },
    {
      'title': 'Exam Routine Planner',
      'emoji': '📅',
      'description': 'Plan your day with gentle reminders.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: animationValue,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: _actions.length,
        itemBuilder: (context, index) {
          final action = _actions[index];
          final delay = index * 0.15;
          final itemAnimation = ((animationValue - delay).clamp(0.0, 1.0) * (1.0 / (1.0 - delay))).clamp(0.0, 1.0);
          
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: itemAnimation),
            duration: AppTheme.mediumAnimation,
            curve: AppTheme.softCurve,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _SecondaryActionCard(
                    title: action['title']!,
                    emoji: action['emoji']!,
                    onTap: () => onTap(
                      action['title']!,
                      action['emoji']!,
                      action['description']!,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SecondaryActionCard extends StatefulWidget {
  final String title;
  final String emoji;
  final VoidCallback onTap;

  const _SecondaryActionCard({
    required this.title,
    required this.emoji,
    required this.onTap,
  });

  @override
  State<_SecondaryActionCard> createState() => _SecondaryActionCardState();
}

class _SecondaryActionCardState extends State<_SecondaryActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) {
      _tapController.reverse();
      widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tapController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 - (_tapController.value * 0.03),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.pastelTeal.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// SECTION 5: Campus Counselor Card
class _CampusCounselorCard extends StatelessWidget {
  final double animationValue;

  const _CampusCounselorCard({required this.animationValue});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: animationValue,
      duration: AppTheme.mediumAnimation,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - animationValue)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.softBlue.withOpacity(0.3),
                AppTheme.pastelTeal.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.pastelTeal.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need human support?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can reach out to your campus counselor anytime.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _CounselorButton(
                      icon: Icons.phone_outlined,
                      label: 'Call',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CounselorButton(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CounselorButton(
                      icon: Icons.info_outline,
                      label: 'Info',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounselorButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CounselorButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppTheme.pastelTeal,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
