class Crop {
  /// Unique Firestore document ID
  final String id;

  /// Name of the crop (e.g., "Tomato")
  final String name;

  /// Type/category of the crop (e.g., "Vegetable")
  final String type;

  /// Zone assigned for planting (e.g., "Zone A")
  final String zone;

  /// Optional description
  final String? description;

  /// Optional ESP32 device IP for this crop
  final String? deviceIp;

  Crop({
    required this.id,
    required this.name,
    required this.type,
    required this.zone,
    this.description,
    this.deviceIp,
  });

  /// Factory constructor from Firestore map
  factory Crop.fromMap(String id, Map<String, dynamic> map) {
    return Crop(
      id: id,
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? '',
      zone: map['zone'] as String? ?? '',
      description: map['description'] as String?,
      deviceIp: map['deviceIp'] as String?,
    );
  }

  /// Factory from raw JSON (alias)
  factory Crop.fromJson(String id, Map<String, dynamic> json) => Crop.fromMap(id, json);

  /// Converts to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'zone': zone,
      if (description != null) 'description': description,
      if (deviceIp != null) 'deviceIp': deviceIp,
    };
  }

  /// Converts to JSON (alias)
  Map<String, dynamic> toJson() => toMap();

  /// Creates a new instance with optional overrides
  Crop copyWith({
    String? name,
    String? type,
    String? zone,
    String? description,
    String? deviceIp,
  }) {
    return Crop(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      zone: zone ?? this.zone,
      description: description ?? this.description,
      deviceIp: deviceIp ?? this.deviceIp,
    );
  }
}
