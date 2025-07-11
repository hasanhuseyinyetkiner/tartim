import 'package:intl/intl.dart';
import 'package:tartim/app/data/models/measurement.dart';
import 'package:tartim/app/data/models/olcum_tipi.dart';

class WeightMeasurement {
  final int? id;
  final int? animalId; // Karşılık: HayvanId - nullable yapıldı
  final double weight; // Karşılık: Weight
  final DateTime measurementDate; // Karşılık: Tarih
  final String rfid; // Karşılık: Rfid
  final String? notes; // Karşılık: Notlar
  final int measurementType; // Karşılık: OlcumTipi/AmacId
  final int? userId; // Karşılık: UserId
  final DateTime createdAt; // Karşılık: CreateAt
  final DateTime? updatedAt; // Karşılık: UpdatedAt

  WeightMeasurement({
    this.id,
    this.animalId,
    required this.weight,
    required this.measurementDate,
    required this.rfid,
    this.notes,
    this.measurementType = 0,
    this.userId,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // SQLite için
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'animal_id': animalId,
      'weight': weight,
      'measurement_date': measurementDate.toIso8601String(),
      'rfid': rfid,
      'notes': notes,
      'measurement_type': measurementType,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // SQLite için
  factory WeightMeasurement.fromMap(Map<String, dynamic> map) {
    return WeightMeasurement(
      id: map['id'],
      animalId: map['animal_id'],
      weight: map['weight'],
      measurementDate: DateTime.parse(map['measurement_date']),
      rfid: map['rfid'],
      notes: map['notes'],
      measurementType: map['measurement_type'] ?? 0,
      userId: map['user_id'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // API için - Backend ile uyumlu
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'Id': id,
      'HayvanId': animalId,
      'Weight': weight,
      'Tarih': measurementDate.toIso8601String(),
      'Rfid': rfid,
      'Amac': notes,
      'AmacId': measurementType,
      'CihazId': userId ?? 0,
    };
  }

  // API için
  factory WeightMeasurement.fromJson(Map<String, dynamic> json) {
    return WeightMeasurement(
      id: json['Id'] ?? json['id'],
      animalId: json['HayvanId'] ?? json['hayvanId'] ?? json['animal_id'],
      weight: (json['Weight'] ??
                  json['weight'] ??
                  json['Agirlik'] ??
                  json['agirlik'])
              ?.toDouble() ??
          0.0,
      measurementDate: json['Tarih'] != null
          ? DateTime.parse(json['Tarih'])
          : (json['tarih'] != null
              ? DateTime.parse(json['tarih'])
              : (json['OlcumTarihi'] != null
                  ? DateTime.parse(json['OlcumTarihi'])
                  : (json['olcumTarihi'] != null
                      ? DateTime.parse(json['olcumTarihi'])
                      : (json['measurement_date'] != null
                          ? DateTime.parse(json['measurement_date'])
                          : DateTime.now())))),
      rfid: json['Rfid'] ?? json['rfid'] ?? '',
      notes: json['Amac'] ??
          json['amac'] ??
          json['Notlar'] ??
          json['notlar'] ??
          json['notes'],
      measurementType: json['AmacId'] ??
          json['amacId'] ??
          json['OlcumTipiId'] ??
          json['olcumTipiId'] ??
          json['measurement_type'] ??
          0,
      userId: json['CihazId'] ??
          json['cihazId'] ??
          json['UserId'] ??
          json['userId'] ??
          json['user_id'],
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'])
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : (json['created_at'] != null
                  ? DateTime.parse(json['created_at'])
                  : DateTime.now())),
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.parse(json['UpdatedAt'])
          : (json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : (json['updated_at'] != null
                  ? DateTime.parse(json['updated_at'])
                  : null)),
    );
  }

  // Measurement sınıfından WeightMeasurement oluştur
  factory WeightMeasurement.fromMeasurement(Measurement measurement) {
    return WeightMeasurement(
      id: measurement.id,
      animalId: 0, // animalId için varsayılan değer - RFID'den bulunabilir
      weight: measurement.weight,
      measurementDate: measurement.measurementDateTime,
      rfid: measurement.animalRfid,
      notes: measurement.notes,
      measurementType: measurement.olcumTipi.value,
      userId: measurement.deviceId != null ? int.tryParse(measurement.deviceId!) : null,
      createdAt: measurement.createdAt != null 
          ? DateTime.parse(measurement.createdAt!)
          : DateTime.now(),
      updatedAt: measurement.updatedAt != null 
          ? DateTime.parse(measurement.updatedAt!)
          : null,
    );
  }

  // WeightMeasurement'ı Measurement'a dönüştür
  Measurement toMeasurement() {
    return Measurement(
      id: id,
      animalRfid: rfid,
      weight: weight,
      timestamp: measurementDate.toIso8601String(),
      olcumTipi: OlcumTipi.fromValue(measurementType),
      deviceId: userId?.toString(),
      notes: notes,
      isSynced: false,
      createdAt: createdAt.toIso8601String(),
      updatedAt: updatedAt?.toIso8601String(),
    );
  }

  // For validation
  String? validate() {
    if (weight <= 0) {
      return 'Ağırlık değeri pozitif olmalıdır';
    }
    return null;
  }

  // Yardımcı metodlar
  String get formattedWeight => '${weight.toStringAsFixed(1)} kg';
  
  String get formattedDate => DateFormat('dd.MM.yyyy HH:mm').format(measurementDate);
  
  String get measurementTypeName => OlcumTipi.fromValue(measurementType).displayName;

  // Kopya oluştur
  WeightMeasurement copyWith({
    int? id,
    int? animalId,
    double? weight,
    DateTime? measurementDate,
    String? rfid,
    String? notes,
    int? measurementType,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightMeasurement(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      weight: weight ?? this.weight,
      measurementDate: measurementDate ?? this.measurementDate,
      rfid: rfid ?? this.rfid,
      notes: notes ?? this.notes,
      measurementType: measurementType ?? this.measurementType,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WeightMeasurement{id: $id, animalId: $animalId, weight: $weight, rfid: $rfid, measurementDate: $measurementDate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightMeasurement &&
        other.id == id &&
        other.animalId == animalId &&
        other.weight == weight &&
        other.rfid == rfid &&
        other.measurementDate == measurementDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        animalId.hashCode ^
        weight.hashCode ^
        rfid.hashCode ^
        measurementDate.hashCode;
  }
}
