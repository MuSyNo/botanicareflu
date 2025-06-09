class AppNotification {
  final String id;
  final String title;
  final String body;
  final int timestamp;
  final bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.read,
  });

  /// Factory from Firebase or Map
  factory AppNotification.fromMap(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      title: data['title'] as String? ?? 'No Title',
      body: data['body'] as String? ?? '',
      timestamp: data['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      read: data['read'] as bool? ?? false,
    );
  }

  /// Converts instance to map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'read': read,
    };
  }

  /// Converts to JSON (optional alias)
  Map<String, dynamic> toJson() => toMap();

  /// Creates a copy with optional override
  AppNotification copyWith({
    String? title,
    String? body,
    int? timestamp,
    bool? read,
  }) {
    return AppNotification(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
    );
  }

  /// Returns human-readable datetime
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
}
