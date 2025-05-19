import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatelessWidget {
  final String content;
  final bool isUserMessage;

  const ChatBubble({
    super.key,
    required this.content,
    required this.isUserMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUserMessage
              ? const Color(0xFF8ECAE6)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16).copyWith(
            topLeft: isUserMessage ? const Radius.circular(16) : const Radius.circular(4),
            topRight: isUserMessage ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: isUserMessage ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }
}