import 'package:firebase_database/firebase_database.dart';
import '../models/chat_message.dart';

class ChatService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  Future<void> sendMessage(String userId, String text) async {
    final message = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await _ref.child('chat_messages/$userId').push().set(message.toMap());

    // Simulate bot reply (static)
    await Future.delayed(const Duration(seconds: 1));
    await sendBotReply(userId, "🌿 That's a great question! Here's a tip: $text");
  }

  Future<void> sendBotReply(String userId, String text) async {
    final message = ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await _ref.child('chat_messages/$userId').push().set(message.toMap());
  }

  Stream<List<ChatMessage>> getMessages(String userId) {
    return _ref.child('chat_messages/$userId').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return [];

      return data.entries.map((e) {
        final id = e.key;
        final value = Map<String, dynamic>.from(e.value);
        return ChatMessage.fromMap(value..['id'] = id);
      }).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }
}
