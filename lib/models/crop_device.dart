class CropDevice {
  /// Unique Firestore document ID
  final String id;

  /// Display name for the device (e.g., "Tomato Zone A")
  final String name;

  /// Assigned zone name
  final String zone;

  /// ESP32 IP address for the device
  final String ip;

  CropDevice({
    required this.id,
    required this.name,
    required this.zone,
    required this.ip,
  });

  /// Create from Firestore map
  factory CropDevice.fromMap(String id, Map<String, dynamic> map) {
    return CropDevice(
      id: id,
      name: map['name'] as String? ?? '',
      zone: map['zone'] as String? ?? '',
      ip: map['ip'] as String? ?? '',
    );
  }

  /// Create from JSON (alias)
  factory CropDevice.fromJson(String id, Map<String, dynamic> json) => CropDevice.fromMap(id, json);

  /// Convert to Firebase map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'zone': zone,
      'ip': ip,
    };
  }

  /// Convert to JSON (alias)
  Map<String, dynamic> toJson() => toMap();

  /// Create a modified copy
  CropDevice copyWith({
    String? name,
    String? zone,
    String? ip,
  }) {
    return CropDevice(
      id: id,
      name: name ?? this.name,
      zone: zone ?? this.zone,
      ip: ip ?? this.ip,
    );
  }
}
