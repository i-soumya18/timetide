import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import 'package:timetide/features/planner/providers/planner_provider.dart';
import '../../data/models/chat_message_model.dart';
import 'package:intl/intl.dart';

class ConversationHistoryScreen extends StatelessWidget {
  const ConversationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final plannerProvider = Provider.of<PlannerProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text(
          'Conversation History',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<String>>(
        stream: plannerProvider.getUserConversations(authProvider.user!.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading conversations',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final conversationIds = snapshot.data!;

          if (conversationIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversation history yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start planning with AI to create history',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
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
                  final lastMessage = messages.last;

                  // Format the timestamp
                  final formatter = DateFormat('MMM d, yyyy');
                  final formattedDate =
                      formatter.format(firstMessage.timestamp);

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: const Color(0xFF252525),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Load the conversation and navigate back
                        plannerProvider.loadConversation(
                          authProvider.user!.id,
                          conversationId,
                        );
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C5CE7)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.chat_rounded,
                                    color: Color(0xFF6C5CE7),
                                    size: 20,
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '${messages.length} messages',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.grey),
                                  onPressed: () {
                                    // Show confirmation dialog
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          'Delete Conversation',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Text(
                                          'Are you sure you want to delete this conversation?',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                              'Cancel',
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Delete conversation
                                              plannerProvider.clearConversation(
                                                authProvider.user!.id,
                                                conversationId,
                                              );
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: Text(
                                              'Delete',
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFF3D4548), height: 24),
                            Text(
                              'First message:',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              firstMessage.message,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Latest response:',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lastMessage.isUser
                                  ? 'You: ${lastMessage.message}'
                                  : lastMessage.message,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C5CE7),
        onPressed: () {
          plannerProvider.startNewConversation(authProvider.user!.id);
          Navigator.pop(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
