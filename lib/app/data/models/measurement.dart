import 'package:tartim/app/data/models/olcum_tipi.dart';

class Measurement {
  final int? id;
  final String animalRfid;
  final double weight;
  final String timestamp;
  final OlcumTipi olcumTipi;
  final String? deviceId;
  final String? notes;
  final bool isSynced;
  final String? createdAt;
  final String? updatedAt;

  Measurement({
    this.id,
    required this.animalRfid,
    required this.weight,
    required this.timestamp,
    this.olcumTipi = OlcumTipi.normal,
    this.deviceId,
    this.notes,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  // Map'e dönüştür (SQLite için)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_rfid': animalRfid,
      'weight': weight,
      'timestamp': timestamp,
      'olcum_tipi': olcumTipi.value,
      'device_id': deviceId,
      'notes': notes,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Map'ten oluştur (SQLite'dan)
  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      id: map['id'],
      animalRfid: map['animal_rfid'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      timestamp: map['timestamp'] ?? '',
      olcumTipi: OlcumTipi.fromValue(map['olcum_tipi'] ?? 0),
      deviceId: map['device_id'],
      notes: map['notes'],
      isSynced: (map['is_synced'] ?? 0) == 1,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  // JSON'a dönüştür (API için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animalRfid': animalRfid,
      'weight': weight,
      'timestamp': timestamp,
      'measurementType': olcumTipi.value,
      'deviceId': deviceId,
      'notes': notes,
      'isSynced': isSynced,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // JSON'dan oluştur (API'den)
  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'],
      animalRfid: json['animalRfid'] ?? json['animal_rfid'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      olcumTipi: OlcumTipi.fromValue(json['measurementType'] ?? json['olcum_tipi'] ?? 0),
      deviceId: json['deviceId'] ?? json['device_id'],
      notes: json['notes'],
      isSynced: json['isSynced'] ?? json['is_synced'] ?? false,
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
    );
  }

  // Kopya oluştur
  Measurement copyWith({
    int? id,
    String? animalRfid,
    double? weight,
    String? timestamp,
    OlcumTipi? olcumTipi,
    String? deviceId,
    String? notes,
    bool? isSynced,
    String? createdAt,
    String? updatedAt,
  }) {
    return Measurement(
      id: id ?? this.id,
      animalRfid: animalRfid ?? this.animalRfid,
      weight: weight ?? this.weight,
      timestamp: timestamp ?? this.timestamp,
      olcumTipi: olcumTipi ?? this.olcumTipi,
      deviceId: deviceId ?? this.deviceId,
      notes: notes ?? this.notes,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Measurement{id: $id, animalRfid: $animalRfid, weight: $weight, timestamp: $timestamp, olcumTipi: $olcumTipi, deviceId: $deviceId, notes: $notes, isSynced: $isSynced}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Measurement &&
        other.id == id &&
        other.animalRfid == animalRfid &&
        other.weight == weight &&
        other.timestamp == timestamp &&
        other.olcumTipi == olcumTipi &&
        other.deviceId == deviceId &&
        other.notes == notes &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        animalRfid.hashCode ^
        weight.hashCode ^
        timestamp.hashCode ^
        olcumTipi.hashCode ^
        deviceId.hashCode ^
        notes.hashCode ^
        isSynced.hashCode;
  }

  // Yardımcı metodlar
  DateTime get measurementDateTime {
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return DateTime.now();
    }
  }

  // measurementDate getter - measurementDateTime ile aynı
  DateTime get measurementDate => measurementDateTime;

  // toMeasurement metodu - kendisini döndürür
  Measurement toMeasurement() => this;

  String get formattedWeight => '${weight.toStringAsFixed(1)} kg';

  String get measurementTypeName => olcumTipi.displayName;

  bool get isRecent {
    final now = DateTime.now();
    final measurementTime = measurementDateTime;
    final difference = now.difference(measurementTime);
    return difference.inHours < 24; // Son 24 saat içinde
  }

  // Validasyon
  bool get isValid {
    return animalRfid.isNotEmpty && 
           weight > 0 && 
           timestamp.isNotEmpty;
  }

  // FlSpot için chart data (fl_chart paketi için)
  static List<Map<String, dynamic>> toChartData(List<Measurement> measurements) {
    final sortedMeasurements = List<Measurement>.from(measurements);
    sortedMeasurements.sort((a, b) => a.measurementDateTime.compareTo(b.measurementDateTime));
    
    return sortedMeasurements.asMap().entries.map((entry) {
      final index = entry.key;
      final measurement = entry.value;
      return {
        'x': index.toDouble(),
        'y': measurement.weight,
        'timestamp': measurement.timestamp,
        'date': measurement.measurementDateTime,
      };
    }).toList();
  }
}
