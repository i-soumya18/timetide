import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/gemini_service.dart';
import '../models/chat_message_model.dart';

class PlannerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _geminiService = GeminiService();

  Stream<List<ChatMessageModel>> getChatHistory(String userId) {
    return _firestore
        .collection('plannerChats')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatMessageModel.fromJson(doc.data()))
        .toList());
  }

  Future<void> sendMessage(String userId, String message) async {
    try {
      final messageId = const Uuid().v4();
      final userMessage = ChatMessageModel(
        id: messageId,
        userId: userId,
        message: message,
        isUser: true,
        timestamp: DateTime.now(),
      );
      await _firestore
          .collection('plannerChats')
          .doc(messageId)
          .set(userMessage.toJson());

      // Call Gemini API to generate task plan
      final tasks = await _geminiService.generateTaskPlan(message);

      // Create AI response with tasks
      final aiMessageId = const Uuid().v4();
      final aiMessage = ChatMessageModel(
        id: aiMessageId,
        userId: userId,
        message: 'Here’s a suggested plan:',
        isUser: false,
        tasks: tasks,
        timestamp: DateTime.now(),
      );
      await _firestore
          .collection('plannerChats')
          .doc(aiMessageId)
          .set(aiMessage.toJson());
    } catch (e) {
      rethrow;
    }
  }
}