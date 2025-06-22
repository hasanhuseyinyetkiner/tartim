<<<<<<< HEAD
// -*- coding: utf-8 -*-
// AI-GENERATED :: DO NOT EDIT

/// UserDevice model for managing Bluetooth weight measurement devices

=======
>>>>>>> 1bd7916f9bd6ef60ede69608114a2b1b32add4fe
class UserDevice {
  final String id;
  final String name;
  final String type;
  final String macAddress;
  bool isOnline;
  bool isConnected;
<<<<<<< HEAD
  final DateTime? lastSeen;
  final String? deviceModel;
  final String? firmwareVersion;
  final int? batteryLevel;
=======
>>>>>>> 1bd7916f9bd6ef60ede69608114a2b1b32add4fe

  UserDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.macAddress,
    this.isOnline = false,
    this.isConnected = false,
<<<<<<< HEAD
    this.lastSeen,
    this.deviceModel,
    this.firmwareVersion,
    this.batteryLevel,
  });

  /// Factory constructor from JSON for API responses
  factory UserDevice.fromJson(Map<String, dynamic> json) {
    return UserDevice(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'weight',
      macAddress: json['macAddress'] ?? '',
      isOnline: json['isOnline'] ?? false,
      isConnected: json['isConnected'] ?? false,
      lastSeen:
          json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      deviceModel: json['deviceModel'],
      firmwareVersion: json['firmwareVersion'],
      batteryLevel: json['batteryLevel'],
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'macAddress': macAddress,
      'isOnline': isOnline,
      'isConnected': isConnected,
      'lastSeen': lastSeen?.toIso8601String(),
      'deviceModel': deviceModel,
      'firmwareVersion': firmwareVersion,
      'batteryLevel': batteryLevel,
    };
  }

  /// Copy with method for immutable updates
  UserDevice copyWith({
    String? id,
    String? name,
    String? type,
    String? macAddress,
    bool? isOnline,
    bool? isConnected,
    DateTime? lastSeen,
    String? deviceModel,
    String? firmwareVersion,
    int? batteryLevel,
  }) {
    return UserDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      macAddress: macAddress ?? this.macAddress,
      isOnline: isOnline ?? this.isOnline,
      isConnected: isConnected ?? this.isConnected,
      lastSeen: lastSeen ?? this.lastSeen,
      deviceModel: deviceModel ?? this.deviceModel,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      batteryLevel: batteryLevel ?? this.batteryLevel,
    );
  }

  /// Validation method
  String? validate() {
    if (id.isEmpty) return 'Device ID cannot be empty';
    if (name.isEmpty) return 'Device name cannot be empty';
    if (macAddress.isEmpty) return 'MAC address cannot be empty';

    // Basic MAC address format validation
    final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    if (!macRegex.hasMatch(macAddress)) {
      return 'Invalid MAC address format';
    }

    return null;
  }

  /// Check if device is a weight measurement device
  bool get isWeightDevice => type.toLowerCase() == 'weight';

  /// Get device status as string
  String get statusText {
    if (isConnected) return 'Connected';
    if (isOnline) return 'Online';
    return 'Offline';
  }

  /// Get display name with model if available
  String get displayName {
    if (deviceModel != null && deviceModel!.isNotEmpty) {
      return '$name ($deviceModel)';
    }
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDevice &&
        other.id == id &&
        other.macAddress == macAddress;
  }

  @override
  int get hashCode => id.hashCode ^ macAddress.hashCode;

  @override
  String toString() {
    return 'UserDevice(id: $id, name: $name, type: $type, macAddress: $macAddress, isConnected: $isConnected)';
  }
}

// Module-Summary:
// UserDevice modeli Bluetooth ağırlık ölçüm cihazlarını yönetmek için kullanılır. JSON serialization, validasyon, durum kontrolü ve utility metodları içerir. MAC adres formatını doğrular, cihaz durumunu takip eder ve API entegrasyonu için gerekli dönüşümleri sağlar.
=======
  });

  factory UserDevice.fromJson(Map<String, dynamic> json) {
    return UserDevice(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      macAddress: json['macAddress'],
    );
  }
}
>>>>>>> 1bd7916f9bd6ef60ede69608114a2b1b32add4fe
