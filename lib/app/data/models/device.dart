class Device {
  final String id;
  final String name;
  final String address;
  final DeviceType type;
  final DeviceStatus status;
  final int? rssi;
  final bool isConnected;
  final DateTime? lastConnected;
  final Map<String, dynamic>? characteristics;

  Device({
    required this.id,
    required this.name,
    required this.address,
    this.type = DeviceType.unknown,
    this.status = DeviceStatus.disconnected,
    this.rssi,
    this.isConnected = false,
    this.lastConnected,
    this.characteristics,
  });

  // Map'e dönüştür (SQLite için)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'type': type.value,
      'status': status.value,
      'rssi': rssi,
      'is_connected': isConnected ? 1 : 0,
      'last_connected': lastConnected?.toIso8601String(),
      'characteristics': characteristics != null 
          ? characteristics.toString() 
          : null,
    };
  }

  // Map'ten oluştur (SQLite'dan)
  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      type: DeviceType.fromValue(map['type'] ?? 0),
      status: DeviceStatus.fromValue(map['status'] ?? 0),
      rssi: map['rssi'],
      isConnected: (map['is_connected'] ?? 0) == 1,
      lastConnected: map['last_connected'] != null 
          ? DateTime.tryParse(map['last_connected'])
          : null,
      characteristics: map['characteristics'] != null
          ? {'raw': map['characteristics']}
          : null,
    );
  }

  // JSON'a dönüştür (API için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'type': type.name,
      'status': status.name,
      'rssi': rssi,
      'isConnected': isConnected,
      'lastConnected': lastConnected?.toIso8601String(),
      'characteristics': characteristics,
    };
  }

  // JSON'dan oluştur (API'den)
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      type: DeviceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DeviceType.unknown,
      ),
      status: DeviceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DeviceStatus.disconnected,
      ),
      rssi: json['rssi'],
      isConnected: json['isConnected'] ?? false,
      lastConnected: json['lastConnected'] != null
          ? DateTime.tryParse(json['lastConnected'])
          : null,
      characteristics: json['characteristics'],
    );
  }

  // Kopya oluştur
  Device copyWith({
    String? id,
    String? name,
    String? address,
    DeviceType? type,
    DeviceStatus? status,
    int? rssi,
    bool? isConnected,
    DateTime? lastConnected,
    Map<String, dynamic>? characteristics,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      type: type ?? this.type,
      status: status ?? this.status,
      rssi: rssi ?? this.rssi,
      isConnected: isConnected ?? this.isConnected,
      lastConnected: lastConnected ?? this.lastConnected,
      characteristics: characteristics ?? this.characteristics,
    );
  }

  @override
  String toString() {
    return 'Device{id: $id, name: $name, address: $address, type: $type, status: $status, isConnected: $isConnected}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Device &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.type == type &&
        other.status == status &&
        other.isConnected == isConnected;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        type.hashCode ^
        status.hashCode ^
        isConnected.hashCode;
  }

  // Yardımcı metodlar
  String get displayName => name.isNotEmpty ? name : 'Bilinmeyen Cihaz';
  
  String get shortAddress {
    if (address.length >= 6) {
      return address.substring(address.length - 6);
    }
    return address;
  }

  String get signalStrengthText {
    if (rssi == null) return 'Bilinmiyor';
    if (rssi! >= -50) return 'Çok İyi';
    if (rssi! >= -70) return 'İyi';
    if (rssi! >= -80) return 'Orta';
    return 'Zayıf';
  }

  bool get isWeightScale => type == DeviceType.weightScale;
  bool get isMilkMeter => type == DeviceType.milkMeter;
  bool get isGenericDevice => type == DeviceType.generic;
  
  bool get canConnect => status == DeviceStatus.available;
  bool get isConnecting => status == DeviceStatus.connecting;
  bool get isDisconnected => status == DeviceStatus.disconnected;

  // Connection durumu kontrolü
  bool get hasRecentConnection {
    if (lastConnected == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastConnected!);
    return difference.inMinutes < 30; // Son 30 dakika içinde
  }

  DateTime get lastSeenDateTime => lastConnected ?? DateTime.now();

  String get lastData => 'No data'; // Placeholder getter
}

// Cihaz türleri
enum DeviceType {
  unknown(0, 'Bilinmeyen'),
  weightScale(1, 'Tartı'),
  milkMeter(2, 'Süt Ölçer'),
  generic(3, 'Genel Bluetooth');

  final int value;
  final String displayName;

  const DeviceType(this.value, this.displayName);

  static DeviceType fromValue(int value) {
    return DeviceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => DeviceType.unknown,
    );
  }
}

// Cihaz durumları
enum DeviceStatus {
  disconnected(0, 'Bağlantı Yok'),
  connecting(1, 'Bağlanıyor'),
  connected(2, 'Bağlı'),
  available(3, 'Kullanılabilir'),
  unavailable(4, 'Kullanılamaz'),
  error(5, 'Hata');

  final int value;
  final String displayName;

  const DeviceStatus(this.value, this.displayName);

  static DeviceStatus fromValue(int value) {
    return DeviceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DeviceStatus.disconnected,
    );
  }
}