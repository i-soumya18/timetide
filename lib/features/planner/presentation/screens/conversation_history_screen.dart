import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import 'package:timetide/features/planner/providers/planner_provider.dart';
import '../../data/models/chat_message_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class ConversationHistoryScreen extends StatelessWidget {
  const ConversationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final plannerProvider = Provider.of<PlannerProvider>(context);

    // Define our premium color scheme
    const Color primaryColor = Color(0xFF6564DB); // Main brand color
    const Color secondaryColor = Color(0xFFA23B72); // Secondary accent
    const Color bgDarkest = Color(0xFF121212); // Background darkest
    const Color bgDark = Color(0xFF1E1E24); // Background dark
    const Color bgCard = Color(0xFF252535); // Card background
    const Color textPrimary = Color(0xFFF2F2F2); // Primary text
    const Color textSecondary = Color(0xFFAFB3B6); // Secondary text
    const Color dividerColor = Color(0xFF3D3D56); // Divider color

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bgDarkest,
      ),
      child: Scaffold(
        backgroundColor: bgDarkest,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Conversation History',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
          leading: Hero(
            tag: 'back_button',
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
                onPressed: () => Navigator.pop(context),
                splashRadius: 24,
              ),
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  bgDarkest,
                  bgDarkest.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        body: StreamBuilder<List<String>>(
          stream: plannerProvider.getUserConversations(authProvider.user!.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading conversations',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.red[300],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Refresh the page
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const ConversationHistoryScreen(),
                            transitionDuration: const Duration(milliseconds: 300),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Loading your conversations...',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            final conversationIds = snapshot.data!;

            if (conversationIds.isEmpty) {
              return Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: bgCard.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Icon(
                          Icons.history_rounded,
                          size: 56,
                          color: primaryColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No conversation history yet',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Start planning with AI to create history',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          plannerProvider.startNewConversation(authProvider.user!.id);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Start New Conversation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 100, bottom: 100, left: 16, right: 16),
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: bgCard.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor.withOpacity(0.5)),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final messages = messageSnapshot.data!;
                    if (messages.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // Get the first and last message
                    final firstMessage = messages.first;
                    final lastMessage = messages.last;

                    // Format the timestamp
                    final formatter = DateFormat('MMM d, yyyy');
                    final formattedDate = formatter.format(firstMessage.timestamp);

                    // Time tween animation for staggered list items
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + (index * 80)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              bgCard,
                              bgCard.withBlue(bgCard.blue + 5).withRed(bgCard.red - 5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Add tap ripple effect animation
                                HapticFeedback.lightImpact();

                                // Load the conversation and navigate back with hero animation
                                plannerProvider.loadConversation(
                                  authProvider.user!.id,
                                  conversationId,
                                );

                                Navigator.pop(context);
                              },
                              splashColor: primaryColor.withOpacity(0.1),
                              highlightColor: primaryColor.withOpacity(0.05),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Animated conversation icon
                                        TweenAnimationBuilder<double>(
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.elasticOut,
                                          builder: (context, value, child) {
                                            return Transform.scale(
                                              scale: 0.5 + (0.5 * value),
                                              child: child,
                                            );
                                          },
                                          child: Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  primaryColor.withOpacity(0.2),
                                                  secondaryColor.withOpacity(0.2),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              Icons.chat_rounded,
                                              color: primaryColor,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Conversation on $formattedDate',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${messages.length} messages',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 13,
                                                  color: textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Delete button with hover effect
                                        Material(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(12),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(12),
                                            onTap: () {
                                              HapticFeedback.mediumImpact();
                                              // Show enhanced delete dialog
                                              showDialog(
                                                context: context,
                                                barrierColor: Colors.black87,
                                                builder: (context) => AlertDialog(
                                                  backgroundColor: bgDark,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  title: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.delete_rounded,
                                                        color: secondaryColor,
                                                        size: 24,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Delete Conversation',
                                                        style: GoogleFonts.outfit(
                                                          fontWeight: FontWeight.w500,
                                                          color: textPrimary,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to delete this conversation? This action cannot be undone.',
                                                    style: GoogleFonts.outfit(
                                                      color: textSecondary,
                                                      fontSize: 15,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: textSecondary,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                      ),
                                                      child: Text(
                                                        'Cancel',
                                                        style: GoogleFonts.outfit(
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        // Delete conversation with haptic feedback
                                                        HapticFeedback.mediumImpact();
                                                        plannerProvider.clearConversation(
                                                          authProvider.user!.id,
                                                          conversationId,
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: secondaryColor,
                                                        foregroundColor: Colors.white,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                      ),
                                                      child: Text(
                                                        'Delete',
                                                        style: GoogleFonts.outfit(
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.delete_outline_rounded,
                                                color: textSecondary,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: dividerColor,
                                      height: 32,
                                      thickness: 1,
                                    ),
                                    MessagePreview(
                                      label: 'First message:',
                                      message: firstMessage.message,
                                      textColor: textPrimary,
                                      labelColor: textSecondary,
                                    ),
                                    const SizedBox(height: 16),
                                    MessagePreview(
                                      label: 'Latest response:',
                                      message: lastMessage.isUser
                                          ? 'You: ${lastMessage.message}'
                                          : lastMessage.message,
                                      textColor: textPrimary,
                                      labelColor: textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: FloatingActionButton.extended(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            highlightElevation: 4,
            onPressed: () {
              // Add haptic feedback for better user experience
              HapticFeedback.mediumImpact();

              // Animation before navigation
              plannerProvider.startNewConversation(authProvider.user!.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'New Chat',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extracted widget for message previews to maintain consistency
class MessagePreview extends StatelessWidget {
  final String label;
  final String message;
  final Color textColor;
  final Color labelColor;

  const MessagePreview({
    Key? key,
    required this.label,
    required this.message,
    required this.textColor,
    required this.labelColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Text(
            message,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: textColor,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}