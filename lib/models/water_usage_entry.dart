class WaterUsageEntry {
  final int timestamp;
  final double liters;

  WaterUsageEntry({
    required this.timestamp,
    required this.liters,
  });

  factory WaterUsageEntry.fromMap(Map<String, dynamic> map) {
    return WaterUsageEntry(
      timestamp: map['timestamp'] ?? 0,
      liters: (map['liters'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'liters': liters,
    };
  }

  WaterUsageEntry copyWith({
    int? timestamp,
    double? liters,
  }) {
    return WaterUsageEntry(
      timestamp: timestamp ?? this.timestamp,
      liters: liters ?? this.liters,
    );
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
}
