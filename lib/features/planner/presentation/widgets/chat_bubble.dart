import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timetide/core/colors.dart';

/// A chat bubble widget for displaying user or AI messages in the planner interface.
/// Supports long-press actions and adaptive styling for light/dark modes.
class ChatBubble extends StatefulWidget {
  final String message;
  final bool isUser;
  final DateTime? timestamp;
  final bool isEdited;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
    this.isEdited = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  void initState() {
    super.initState();
    // No animations to initialize
  }

  /// Handles long-press actions (copy, delete).
  void _handleLongPress(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.copy_rounded, color: AppColors.textLight),
              title: Text(
                'Copy Message',
                style: GoogleFonts.poppins(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.message));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    backgroundColor: AppColors.success.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Text(
                      'Message copied to clipboard',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            if (widget.isUser)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error),
                title: Text(
                  'Delete Message',
                  style: GoogleFonts.poppins(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement delete functionality via PlannerProvider
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      backgroundColor: AppColors.info.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      content: Text(
                        'Delete functionality not yet implemented',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () => _handleLongPress(context),
      child: Align(
        alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isUser
                  ? [
                      AppColors.primary.withOpacity(0.9),
                      AppColors.primaryLight.withOpacity(0.8),
                    ]
                  : [
                      const Color(0xFF613DC1)
                          .withOpacity(0.8), // Deep Indigo/Violet
                      const Color(0xFF7752E3).withOpacity(0.7), // Royal Purple
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight:
                  widget.isUser ? Radius.zero : const Radius.circular(20),
              bottomLeft:
                  widget.isUser ? const Radius.circular(20) : Radius.zero,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.message.isEmpty ? ' ' : widget.message,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: widget.isUser
                      ? AppColors.textLight
                      : Colors
                          .white, // Always white text for AI messages for better contrast
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
                softWrap: true,
              ),
              if (widget.timestamp != null || widget.isEdited) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.timestamp != null)
                      Text(
                        _formatTimestamp(widget.timestamp!),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: widget.isUser
                              ? AppColors.textLight.withOpacity(0.7)
                              : Colors.white.withOpacity(
                                  0.8), // Brighter for violet background
                        ),
                      ),
                    if (widget.isEdited) ...[
                      const SizedBox(width: 6),
                      Text(
                        'Edited',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: widget.isUser
                              ? AppColors.textLight.withOpacity(0.7)
                              : Colors.white.withOpacity(
                                  0.8), // Brighter for violet background
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Formats the timestamp for display.
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);
    final timeFormat = DateFormat('h:mm a');

    if (messageDate == today) {
      return timeFormat.format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${timeFormat.format(timestamp)}';
    } else {
      final dateFormat = DateFormat('MMM d');
      return '${dateFormat.format(timestamp)} ${timeFormat.format(timestamp)}';
    }
  }
}
