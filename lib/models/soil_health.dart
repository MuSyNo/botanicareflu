class SoilHealth {
  /// pH value of the soil
  final double pH;

  /// Nitrogen (N) level
  final int nitrogen;

  /// Phosphorus (P) level
  final int phosphorus;

  /// Potassium (K) level
  final int potassium;

  /// Timestamp of entry (milliseconds since epoch)
  final int timestamp;

  /// Soil health status label (e.g., Good, Moderate)
  final String status;

  /// Suggested recommendation for soil improvement
  final String recommendation;

  /// Optional crop associated with this soil entry
  final String? crop;

  SoilHealth({
    required this.pH,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.timestamp,
    required this.status,
    required this.recommendation,
    this.crop,
  });

  /// Create from Firebase map or JSON
  factory SoilHealth.fromMap(Map<String, dynamic> map) {
    return SoilHealth(
      pH: (map['pH'] as num?)?.toDouble() ?? 0.0,
      nitrogen: (map['nitrogen'] as int?) ?? 0,
      phosphorus: (map['phosphorus'] as int?) ?? 0,
      potassium: (map['potassium'] as int?) ?? 0,
      timestamp: (map['timestamp'] as int?) ?? 0,
      status: map['status'] as String? ?? '',
      recommendation: map['recommendation'] as String? ?? '',
      crop: map['crop'] as String?,
    );
  }

  /// Alias for fromMap
  factory SoilHealth.fromJson(Map<String, dynamic> json) => SoilHealth.fromMap(json);

  /// Convert to Firebase-compatible map
  Map<String, dynamic> toMap() {
    return {
      'pH': pH,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'timestamp': timestamp,
      'status': status,
      'recommendation': recommendation,
      if (crop != null) 'crop': crop,
    };
  }

  /// Alias for toMap
  Map<String, dynamic> toJson() => toMap();

  /// Returns the entry timestamp as a DateTime object
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  /// Returns a copy with optional overrides
  SoilHealth copyWith({
    double? pH,
    int? nitrogen,
    int? phosphorus,
    int? potassium,
    int? timestamp,
    String? status,
    String? recommendation,
    String? crop,
  }) {
    return SoilHealth(
      pH: pH ?? this.pH,
      nitrogen: nitrogen ?? this.nitrogen,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      recommendation: recommendation ?? this.recommendation,
      crop: crop ?? this.crop,
    );
  }
}
