import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahaay/theme/app_theme.dart';
import 'package:sahaay/providers/chat_provider.dart';
import 'package:sahaay/providers/stress_provider.dart';
import 'package:sahaay/models/chat_message.dart';

/// Chatbot screen with beautiful UI matching app theme
class ChatbotScreen extends StatefulWidget {
  final int? initialStressLevel;

  const ChatbotScreen({super.key, this.initialStressLevel});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppTheme.softCurve,
      ),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      final stressProvider = context.read<StressProvider>();
      
      // Sync stress level from StressProvider or use initial level
      int initialLevel = widget.initialStressLevel ?? stressProvider.currentStressLevel;
      if (initialLevel == 0) initialLevel = 5; // Default if no level set
      
      chatProvider.updateStressLevel(initialLevel);
      
      // Set callback to sync stress level changes with StressProvider
      chatProvider.setStressLevelCallback((level) {
        stressProvider.updateStressLevel(level);
      });
      
      chatProvider.initializeChat();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppTheme.mediumAnimation,
          curve: AppTheme.softCurve,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;

    _textController.clear();
    context.read<ChatProvider>().sendMessage(text);
    _scrollToBottom();
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
                // Header with stress indicator
                _ChatHeader(onBack: _goBack),

                // Messages list
                Expanded(
                  child: Consumer<ChatProvider>(
                    builder: (context, chatProvider, child) {
                      // Auto-scroll to bottom when new messages arrive
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      final items = <Widget>[];
                      for (var msg in chatProvider.messages) {
                        items.add(_MessageBubble(message: msg));
                      }
                      if (chatProvider.isLoading) {
                        items.add(_MessageBubble(
                          message: ChatMessage(
                            id: 'loading',
                            text: '',
                            isUser: false,
                            timestamp: DateTime.now(),
                            isLoading: true,
                          ),
                        ));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return items[index];
                        },
                      );
                    },
                  ),
                ),

                // Input area
                _ChatInput(
                  controller: _textController,
                  onSend: _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chat header with back button and stress indicator
class _ChatHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _ChatHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pastelTeal.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBack,
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
              Container(
                width: 40,
                height: 40,
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
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/sahaay_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          '💙',
                          style: TextStyle(fontSize: 24),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Talk it out',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'I\'m here to listen',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              // Stress level indicator
              Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  final stressLevel = chatProvider.stressLevel;
                  final stressColor = AppTheme.getStressColor(stressLevel);
                  final stressEmoji = AppTheme.getStressEmoji(stressLevel);
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: stressColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: stressColor.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          stressEmoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$stressLevel/10',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Message bubble widget with animations
class _MessageBubble extends StatefulWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
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
      begin:
          widget.message.isUser ? const Offset(0.3, 0) : const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.softCurve),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.isLoading) {
      return _LoadingBubble();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: widget.message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.message.isUser) ...[
                Container(
                  width: 32,
                  height: 32,
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
                  ),
                  child: const Center(
                    child: Text(
                      '💙',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.message.isUser
                        ? AppTheme.pastelTeal
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft:
                          Radius.circular(widget.message.isUser ? 20 : 4),
                      bottomRight:
                          Radius.circular(widget.message.isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.message.isUser
                                ? AppTheme.pastelTeal
                                : Colors.black)
                            .withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.message.isUser
                              ? AppTheme.textPrimary
                              : AppTheme.textPrimary,
                          height: 1.4,
                        ),
                    softWrap: true, // Allow text to wrap to multiple lines
                    overflow: TextOverflow.visible, // Show full text, no truncation
                  ),
                ),
              ),
              if (widget.message.isUser) ...[
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.softPeach.withOpacity(0.3),
                        AppTheme.pastelTeal.withOpacity(0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '🐼',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading bubble animation
class _LoadingBubble extends StatefulWidget {
  @override
  State<_LoadingBubble> createState() => _LoadingBubbleState();
}

class _LoadingBubbleState extends State<_LoadingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
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
            ),
            child: const Center(
              child: Text(
                '💙',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LoadingDot(delay: 0.0, animation: _animation),
                    const SizedBox(width: 4),
                    _LoadingDot(delay: 0.3, animation: _animation),
                    const SizedBox(width: 4),
                    _LoadingDot(delay: 0.6, animation: _animation),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDot extends StatelessWidget {
  final double delay;
  final Animation<double> animation;

  const _LoadingDot({
    required this.delay,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: ((animation.value + delay) % 1.0) < 0.5 ? 0.3 : 1.0,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppTheme.pastelTeal,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Chat input area
class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pastelTeal.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.softBeige.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSend,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.pastelTeal,
                        AppTheme.pastelTeal.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.pastelTeal.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
