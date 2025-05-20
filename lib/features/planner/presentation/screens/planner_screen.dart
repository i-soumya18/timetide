import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import 'package:timetide/features/planner/providers/planner_provider.dart';
import '../../data/models/chat_message_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/suggestion_card.dart';
import 'conversation_history_screen.dart';
import 'package:intl/intl.dart';

// Premium modern color palette
class AppColors {
  // Primary colors
  static const primary = Color(0xFF613DC1); // Deep Indigo
  static const primaryLight = Color(0xFF7752E3); // Royal Purple
  static const primaryDark = Color(0xFF4C2F9B); // Dark Indigo

  // Secondary colors
  static const secondary = Color(0xFF121214); // Near Black
  static const secondaryLight = Color(0xFF1E1E24); // Dark Charcoal
  static const secondaryDark = Color(0xFF2D2D34); // Slate Gray

  // Accent colors
  static const accent = Color(0xFF00C2CB); // Teal
  static const accentSecondary = Color(0xFFA23B72); // Rose
  static const accentTertiary = Color(0xFFFFBF49); // Amber

  // Background colors
  static const backgroundDark = Color(0xFF121214); // Dark background
  static const backgroundMedium = Color(0xFF1E1E24); // Medium dark background
  static const cardBackground = Color(0xFF2D2D34); // Card background

  // Text colors
  static const textLight = Color(0xFFF7F7F9); // Light text
  static const textMedium = Color(0xFFBBBBC9); // Medium text
  static const textDark = Color(0xFF81818E); // Dark text

  // Status colors
  static const success = Color(0xFF4AC16B); // Success green
  static const warning = Color(0xFFFFBF49); // Warning amber
  static const error = Color(0xFFF45866); // Error red
  static const info = Color(0xFF3DA9FC); // Info blue
}

// Add this extension to create gradient effects
extension ColorExtension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _sendButtonController;
  late AnimationController _typingController;
  late AnimationController _inputFocusController;
  late AnimationController _screenTransitionController;

  // Focus node for input field
  final FocusNode _inputFocusNode = FocusNode();

  bool _isComposing = false;
  bool _isThinking = false;

  // Track if input field is focused
  bool _isInputFocused = false;

  @override
  void initState() {
    super.initState();
    final plannerProvider =
        Provider.of<PlannerProvider>(context, listen: false);

    // Animated transition when screen loads
    _screenTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Send button animation controller
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Typing indicator animation controller
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Input field focus animation controller
    _inputFocusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

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

    // Track input field focus
    _inputFocusNode.addListener(() {
      setState(() {
        _isInputFocused = _inputFocusNode.hasFocus;
      });

      if (_isInputFocused) {
        _inputFocusController.forward();
      } else {
        _inputFocusController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _sendButtonController.dispose();
    _typingController.dispose();
    _inputFocusController.dispose();
    _screenTransitionController.dispose();
    _inputFocusNode.dispose();
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
        backgroundColor: AppColors.error.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        elevation: 6,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: AppColors.success.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        elevation: 6,
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final plannerProvider = Provider.of<PlannerProvider>(context);

    // Set system UI overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Apply screen transition animation
    return AnimatedBuilder(
      animation: _screenTransitionController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _screenTransitionController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _screenTransitionController,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: _buildAppBar(),
        drawer: _buildConversationHistoryDrawer(authProvider, plannerProvider),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.backgroundDark,
                AppColors.backgroundMedium.withOpacity(0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Subtle background pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: Image.asset(
                    'assets/images/pattern.png',
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              Column(
                children: [
                  // Welcome card - only show if there are no messages
                  StreamBuilder<List<ChatMessageModel>>(
                    stream:
                        plannerProvider.getChatHistory(authProvider.user!.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return _buildWelcomeCard();
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Chat messages
                  Expanded(
                    child: StreamBuilder<List<ChatMessageModel>>(
                      stream: plannerProvider.getChatHistory(
                          authProvider.user!.id,
                          conversationId:
                              plannerProvider.currentConversationId),
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

                        return _buildChatList(
                            messages, authProvider, plannerProvider);
                      },
                    ),
                  ),

                  // "AI is typing" indicator
                  if (_isThinking) _buildTypingIndicator(),

                  // Chat input
                  _buildChatInput(authProvider, plannerProvider),
                ],
              ),
            ],
          ),
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
            height: MediaQuery.of(context).size.width * 0.09,
            width: MediaQuery.of(context).size.width * 0.09,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accent.darken(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * 0.03),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: MediaQuery.of(context).size.width * 0.055,
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          Flexible(
            child: Text(
              'AI Planner',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width * 0.048,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, color: AppColors.textLight),
          tooltip: 'Conversation History',
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ConversationHistoryScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 350),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textLight),
          tooltip: 'New conversation',
          onPressed: () {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            final plannerProvider =
                Provider.of<PlannerProvider>(context, listen: false);

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.secondaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  'Start New Conversation',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 18,
                  ),
                ),
                content: Text(
                  'This will start a new conversation while preserving your history. Continue?',
                  style: GoogleFonts.poppins(
                    color: AppColors.textLight,
                    fontSize: 15,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      plannerProvider
                          .startNewConversation(authProvider.user!.id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    child: Text(
                      'Start New',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
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
    final plannerProvider = Provider.of<PlannerProvider>(context);
    final selectedCount = plannerProvider.selectedTasks.length;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02, vertical: screenWidth * 0.02),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selectedCount > 0
                ? [
                    AppColors.success,
                    AppColors.success.darken(0.1),
                  ]
                : [
                    AppColors.primaryLight.withOpacity(0.8),
                    AppColors.primary.withOpacity(0.8),
                  ],
          ),
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: selectedCount > 0
              ? [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: ElevatedButton.icon(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              selectedCount > 0
                  ? Icons.checklist_rounded
                  : Icons.checklist_outlined,
              size: 18,
              key: ValueKey<bool>(selectedCount > 0),
            ),
          ),
          label: Text(
            selectedCount > 0 ? 'Finalize ($selectedCount)' : 'Finalize',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: selectedCount > 0
              ? () => _showFinalizationDialog()
              : () => _showSelectionInstructions(),
        ),
      ),
    );
  }

  void _showSelectionInstructions() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: AppColors.info.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Select tasks by clicking the checkbox next to them before finalizing',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
  }

  void _showFinalizationDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final plannerProvider =
        Provider.of<PlannerProvider>(context, listen: false);
    final selectedTasks = plannerProvider.finalizedTasks;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Finalize Selected Tasks',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add these tasks to your checklist:',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16),
              ...selectedTasks.entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.task_alt,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${entry.value['title']} (${entry.value['priority']})',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textDark),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              plannerProvider
                  .finalizeSelectedTasks(authProvider.user!.id)
                  .then((_) {
                _showSuccessSnackBar('Tasks added to your checklist');
                // Navigate to checklist after finalization
                Navigator.pushNamed(context, '/checklist');
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Add to Checklist',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.04;
    final verticalPadding = screenSize.height * 0.02;

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      padding: EdgeInsets.all(screenSize.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.7),
            AppColors.primaryDark.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(screenSize.width * 0.04),
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
            'Chat with me to plan your day or create tasks. You can continue our conversation to refine your plan, then select and finalize tasks to add to your checklist.',
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
              _buildSuggestionChip(
                  'Create a workout plan', Icons.fitness_center_rounded),
              _buildSuggestionChip(
                  'Help with meal planning', Icons.restaurant_rounded),
              _buildSuggestionChip(
                  'Organize work tasks', Icons.work_outline_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Adjust font and padding based on screen width
    final fontSize = screenWidth < 360 ? 10.0 : 12.0;
    final horizontalPadding = screenWidth * 0.03;
    final verticalPadding = screenWidth * 0.02;
    final iconSize = screenWidth * 0.04;

    return InkWell(
      onTap: () {
        _controller.text = text;
        setState(() {
          _isComposing = true;
        });
        _sendButtonController.forward();
      },
      borderRadius: BorderRadius.circular(screenWidth * 0.08),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(screenWidth * 0.08),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.textLight,
              size: iconSize,
            ),
            SizedBox(width: screenWidth * 0.015),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: fontSize,
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
      // Generate a unique ID for this task using message ID and task title
      final taskId = '${message.id}_${task['title']}';

      // Check if this task is selected
      final isSelected = plannerProvider.selectedTasks.containsKey(taskId);
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SuggestionCard(
          task: task,
          isSelected: isSelected,
          isFinalized: false,
          onSelectionChanged: (selected) {
            // Toggle task selection
            plannerProvider.toggleTaskSelection(taskId, task);
          },
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
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.04;
    final verticalPaddingTop = screenSize.height * 0.015;
    final verticalPaddingBottom = screenSize.height * 0.025;

    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPaddingTop,
          horizontalPadding, verticalPaddingBottom),
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
                    color:
                        _isComposing ? AppColors.primary : AppColors.textDark,
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
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
              backgroundColor:
                  _isComposing ? AppColors.primary : AppColors.textDark,
              elevation: _isComposing ? 2 : 0,
              mini: !_isComposing,
              onPressed: () {
                if (_controller.text.trim().isEmpty) return;

                // Send message
                final messageText = _controller.text.trim();
                _controller.clear();
                setState(() {
                  _isComposing = false;
                });
                _sendButtonController.reverse();

                // Check if there are existing messages to determine if this is a new conversation
                plannerProvider
                    .getChatHistory(authProvider.user!.id)
                    .first
                    .then((messages) {
                  plannerProvider.sendMessage(
                    authProvider.user!.id,
                    messageText,
                    isNewConversation: messages.isEmpty,
                  );
                });
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
          const SizedBox(
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
            child: const Icon(
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
              'Ask me to help organize your schedule, create task lists, or suggest activities. We can have a conversation to refine your plan, and you can finalize selected tasks when ready.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textMedium,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          ElevatedButton.icon(
            icon: const Icon(Icons.lightbulb_outline),
            label: const Text('Try a suggestion'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.06,
                vertical: MediaQuery.of(context).size.height * 0.015,
              ),
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
            const Icon(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildConversationHistoryDrawer(
      AuthProvider authProvider, PlannerProvider plannerProvider) {
    return Drawer(
      backgroundColor: AppColors.backgroundDark,
      child: Column(
        children: [
          // Drawer header
          Container(
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
            ),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Conversation History',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textLight),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Divider
          Container(
            height: 1,
            color: AppColors.secondaryDark,
          ),
          const SizedBox(height: 8),
          // Conversation list
          Expanded(
            child: StreamBuilder<List<String>>(
              stream:
                  plannerProvider.getUserConversations(authProvider.user!.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading conversations',
                      style: GoogleFonts.poppins(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                final conversationIds = snapshot.data!;

                if (conversationIds.isEmpty) {
                  return Center(
                    child: Text(
                      'No conversation history',
                      style: GoogleFonts.poppins(
                        color: AppColors.textMedium,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: conversationIds.length,
                  itemBuilder: (context, index) {
                    final conversationId = conversationIds[index];
                    return FutureBuilder<List<ChatMessageModel>>(
                      future: plannerProvider
                          .getChatHistory(
                            authProvider.user!.id,
                            conversationId: conversationId,
                          )
                          .first,
                      builder: (context, messageSnapshot) {
                        if (!messageSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final messages = messageSnapshot.data!;
                        if (messages.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        // Get the first and last message
                        final firstMessage = messages.first;
                        final lastMessage =
                            messages.last; // Format the timestamp
                        final formatter = DateFormat('MMM d');
                        final formattedDate =
                            formatter.format(firstMessage.timestamp);

                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                // Load selected conversation
                                plannerProvider.loadConversation(
                                    authProvider.user!.id, conversationId);
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Conversation on $formattedDate',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.textLight,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            lastMessage.isUser
                                                ? 'You: ${lastMessage.message}'
                                                : lastMessage.message,
                                            style: GoogleFonts.poppins(
                                              color: AppColors.textMedium,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.secondaryDark,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Add "Start New" button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                plannerProvider.startNewConversation(authProvider.user!.id);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add),
              label: Text(
                'Start New Conversation',
                style: GoogleFonts.poppins(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
