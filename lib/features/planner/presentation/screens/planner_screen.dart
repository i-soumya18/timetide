import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import 'package:timetide/features/planner/providers/planner_provider.dart';
import '../../data/models/chat_message_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/suggestion_card.dart';
import 'package:flutter/services.dart';

// Using the same premium color palette from the HomeDashboardScreen
class AppColors {
  // Primary colors
  static const primary = Color(0xFF6C5CE7);       // Deep purple/indigo
  static const primaryLight = Color(0xFF8A7EED);  // Lighter purple
  static const primaryDark = Color(0xFF5549C7);   // Darker purple

  // Secondary colors
  static const secondary = Color(0xFF2D3436);     // Near black
  static const secondaryLight = Color(0xFF3D4548); // Dark grey
  static const secondaryDark = Color(0xFF1E2224); // Darker grey

  // Accent colors
  static const accent = Color(0xFFFD79A8);        // Pink
  static const accentLight = Color(0xFFFD9CB6);   // Light pink
  static const accentDark = Color(0xFFD66390);    // Dark pink

  // Background colors
  static const backgroundDark = Color(0xFF121212);// Dark background
  static const backgroundMedium = Color(0xFF1E1E1E); // Medium dark background
  static const cardBackground = Color(0xFF252525); // Card background

  // Text colors
  static const textLight = Color(0xFFF5F5F5);     // Light text
  static const textMedium = Color(0xFFBDBDBD);    // Medium text
  static const textDark = Color(0xFF757575);      // Dark text

  // Status colors
  static const success = Color(0xFF00B894);       // Success green
  static const warning = Color(0xFFFFD166);       // Warning yellow
  static const error = Color(0xFFFF6B6B);         // Error red
  static const info = Color(0xFF54A0FF);          // Info blue
}

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _sendButtonController;
  late AnimationController _typingController;
  bool _isComposing = false;
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    final plannerProvider = Provider.of<PlannerProvider>(context, listen: false);

    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Listen for errors
    plannerProvider.addListener(() {
      if (plannerProvider.errorMessage != null) {
        _showErrorSnackBar(plannerProvider.errorMessage!);
      }

      // Check if AI is thinking/responding
      if (plannerProvider.isProcessing) {
        setState(() => _isThinking = true);
      } else {
        setState(() => _isThinking = false);
        _scrollToBottom();
      }
    });

    // Listen for text changes
    _controller.addListener(() {
      setState(() {
        _isComposing = _controller.text.trim().isNotEmpty;
      });

      if (_isComposing && !_sendButtonController.isCompleted) {
        _sendButtonController.forward();
      } else if (!_isComposing && _sendButtonController.isCompleted) {
        _sendButtonController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _sendButtonController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // Wait for the list to be built before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: AppColors.error.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: AppColors.success.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final plannerProvider = Provider.of<PlannerProvider>(context);

    // Set system UI overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundMedium.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Welcome card
            _buildWelcomeCard(),

            // Chat messages
            Expanded(
              child: StreamBuilder<List<ChatMessageModel>>(
                stream: plannerProvider.getChatHistory(authProvider.user!.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  if (!snapshot.hasData) {
                    return _buildLoadingState();
                  }

                  final messages = snapshot.data!;

                  if (messages.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildChatList(messages, authProvider, plannerProvider);
                },
              ),
            ),

            // "AI is typing" indicator
            if (_isThinking) _buildTypingIndicator(),

            // Chat input
            _buildChatInput(authProvider, plannerProvider),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundDark.withOpacity(0.8),
      elevation: 0,
      title: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: AppColors.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'AI Planner',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
      actions: [
        _buildFinalizeButton(),
      ],
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Widget _buildFinalizeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ElevatedButton.icon(
        icon: const Icon(
          Icons.checklist_rounded,
          size: 18,
        ),
        label: Text(
          'Finalize',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => Navigator.pushNamed(context, '/checklist'),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.7),
            AppColors.primaryDark.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.smart_toy_rounded,
                color: AppColors.textLight.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Assistant',
                style: GoogleFonts.poppins(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like help planning today? You can ask me to help with your schedule, create a to-do list, or suggest activities.',
            style: GoogleFonts.poppins(
              color: AppColors.textLight.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Plan my day', Icons.today_rounded),
              _buildSuggestionChip('Create a workout plan', Icons.fitness_center_rounded),
              _buildSuggestionChip('Help with meal planning', Icons.restaurant_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text, IconData icon) {
    return InkWell(
      onTap: () {
        _controller.text = text;
        setState(() {
          _isComposing = true;
        });
        _sendButtonController.forward();
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.textLight,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(
      List<ChatMessageModel> messages,
      AuthProvider authProvider,
      PlannerProvider plannerProvider,
      ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: messages.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final message = messages[index];
        return Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Add timestamp for first message or when there's a significant time gap
            if (index == 0 || _shouldShowTimestamp(messages, index))
              _buildTimestampDivider(message.timestamp),

            // The chat message
            AnimatedBuilder(
              animation: Listenable.merge([_typingController]),
              builder: (context, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: message.isUser
                        ? const Offset(1, 0)
                        : const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _typingController,
                    curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
                  )),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _typingController,
                        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: _buildMessageBubble(message),
            ),

            // Task suggestions from AI if available
            if (!message.isUser && message.tasks != null)
              ..._buildTaskSuggestions(message, authProvider, plannerProvider),

            // Add spacing between message groups
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  bool _shouldShowTimestamp(List<ChatMessageModel> messages, int index) {
    if (index == 0) return true;

    final currentMsg = messages[index];
    final prevMsg = messages[index - 1];

    // Show timestamp if more than 10 minutes between messages
    final timeDiff = currentMsg.timestamp.difference(prevMsg.timestamp);
    return timeDiff.inMinutes > 10;
  }

  Widget _buildTimestampDivider(DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatTimestamp(timestamp),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return 'Today at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildMessageBubble(ChatMessageModel message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ChatBubble(
        message: message.message,
        isUser: message.isUser,
      ),
    );
  }

  List<Widget> _buildTaskSuggestions(
      ChatMessageModel message,
      AuthProvider authProvider,
      PlannerProvider plannerProvider,
      ) {
    return message.tasks!.map((task) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SuggestionCard(
          task: task,
          onAdd: () {
            plannerProvider.addTaskToChecklist(authProvider.user!.id, task);
            _showSuccessSnackBar('${task['title']} added to checklist');
          },
          onModify: (updatedTask) {
            plannerProvider.modifyTask(
              authProvider.user!.id,
              message.id,
              updatedTask,
            );
            _showSuccessSnackBar('${updatedTask['title']} modified');
          },
        ),
      );
    }).toList();
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.smart_toy_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _typingController,
                  builder: (context, child) {
                    return Row(
                      children: [
                        _buildTypingDot(0),
                        _buildTypingDot(1),
                        _buildTypingDot(2),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Planning...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: _typingController,
      builder: (context, child) {
        final begin = index * 0.2;
        final end = begin + 0.6;

        final opacity = Tween<double>(begin: 0.3, end: 1.0).evaluate(
          CurvedAnimation(
            parent: _typingController,
            curve: Interval(begin, end, curve: Curves.easeInOut),
          ),
        );

        final scale = Tween<double>(begin: 0.8, end: 1.0).evaluate(
          CurvedAnimation(
            parent: _typingController,
            curve: Interval(begin, end, curve: Curves.easeInOut),
          ),
        );

        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(opacity),
            borderRadius: BorderRadius.circular(3),
          ),
          transform: Matrix4.identity()..scale(scale),
        );
      },
    );
  }

  Widget _buildChatInput(
      AuthProvider authProvider,
      PlannerProvider plannerProvider,
      ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundMedium.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isComposing
                      ? AppColors.primary.withOpacity(0.5)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_rounded,
                    color: _isComposing
                        ? AppColors.primary
                        : AppColors.textDark,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: AppColors.textLight,
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Enter your goal...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _sendButtonController,
            builder: (context, child) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _sendButtonController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: child,
              );
            },
            child: FloatingActionButton(
              backgroundColor: _isComposing
                  ? AppColors.primary
                  : AppColors.textDark,
              elevation: _isComposing ? 2 : 0,
              mini: !_isComposing,
              onPressed: () {
                if (_controller.text.trim().isEmpty) return;

                plannerProvider.sendMessage(
                  authProvider.user!.id,
                  _controller.text.trim(),
                );

                _controller.clear();
                setState(() {
                  _isComposing = false;
                });
                _sendButtonController.reverse();
              },
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your conversations...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start Planning with AI',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Ask me to help organize your schedule, create task lists, or suggest activities for your day.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textMedium,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.lightbulb_outline),
            label: const Text('Try a suggestion'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              _controller.text = 'Help me plan my day';
              setState(() {
                _isComposing = true;
              });
              _sendButtonController.forward();
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Refresh data
                setState(() {});
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}