import 'package:intl/intl.dart';

class ChatMessage {
  /// Message text content
  final String text;

  /// True if sent by the user, false if sent by the bot
  final bool isUser;

  /// Timestamp in milliseconds since epoch
  final int timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  /// Readable time string, e.g., 14:20
  String get timeFormatted => DateFormat.Hm().format(
    DateTime.fromMillisecondsSinceEpoch(timestamp),
  );

  /// Create ChatMessage from a map (e.g., Firebase snapshot)
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] as String? ?? '',
      isUser: map['isUser'] as bool? ?? false,
      timestamp: map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Create ChatMessage from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage.fromMap(json);

  /// Convert ChatMessage to map for Firebase or local storage
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp,
    };
  }

  /// Convert to JSON (alias)
  Map<String, dynamic> toJson() => toMap();

  /// Create a modified copy of this ChatMessage
  ChatMessage copyWith({
    String? text,
    bool? isUser,
    int? timestamp,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
