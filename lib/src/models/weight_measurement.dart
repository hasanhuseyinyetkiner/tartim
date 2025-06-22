// -*- coding: utf-8 -*-
// AI-GENERATED :: DO NOT EDIT

import 'package:intl/intl.dart';

/// WeightMeasurement model for managing weight measurement data
class WeightMeasurement {
  final int? id;
  final int? animalId; // Animal ID for livestock management
  final double weight; // Weight in kg
  final DateTime measurementDate; // Date and time of measurement
  final String? rfid; // RFID tag identifier
  final String? notes; // Additional notes
  final int
  measurementType; // Type of measurement (normal, weaning, birth, etc.)
  final int? userId; // User who performed the measurement
  final DateTime createdAt; // Creation timestamp
  final DateTime? updatedAt; // Last update timestamp
  final String? deviceId; // Device used for measurement

  WeightMeasurement({
    this.id,
    this.animalId,
    required this.weight,
    required this.measurementDate,
    this.rfid,
    this.notes,
    this.measurementType = 0,
    this.userId,
    DateTime? createdAt,
    this.updatedAt,
    this.deviceId,
  }) : createdAt = createdAt ?? DateTime.now();

  /// SQLite serialization
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
      'device_id': deviceId,
    };
  }

  /// SQLite deserialization
  factory WeightMeasurement.fromMap(Map<String, dynamic> map) {
    return WeightMeasurement(
      id: map['id'],
      animalId: map['animal_id'],
      weight: (map['weight'] ?? 0.0).toDouble(),
      measurementDate: DateTime.parse(map['measurement_date']),
      rfid: map['rfid'],
      notes: map['notes'],
      measurementType: map['measurement_type'] ?? 0,
      userId: map['user_id'],
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'])
              : DateTime.now(),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deviceId: map['device_id'],
    );
  }

  /// API serialization - Backend compatible
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'Id': id,
      'HayvanId': animalId,
      'Weight': weight,
      'Tarih': measurementDate.toIso8601String(),
      'Rfid': rfid,
      'Notlar': notes,
      'AmacId': measurementType,
      'CihazId': userId ?? 0,
      'CreateAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
      'DeviceId': deviceId,
    };
  }

  /// API deserialization with multiple field name support
  factory WeightMeasurement.fromJson(Map<String, dynamic> json) {
    return WeightMeasurement(
      id: json['Id'] ?? json['id'],
      animalId: json['HayvanId'] ?? json['hayvanId'] ?? json['animal_id'],
      weight:
          (json['Weight'] ??
                  json['weight'] ??
                  json['Agirlik'] ??
                  json['agirlik'] ??
                  0.0)
              .toDouble(),
      measurementDate:
          _parseDate(json, [
            'Tarih',
            'tarih',
            'OlcumTarihi',
            'olcumTarihi',
            'measurement_date',
          ]) ??
          DateTime.now(),
      rfid: json['Rfid'] ?? json['rfid'],
      notes:
          json['Notlar'] ??
          json['notlar'] ??
          json['notes'] ??
          json['Amac'] ??
          json['amac'],
      measurementType:
          json['AmacId'] ??
          json['amacId'] ??
          json['OlcumTipiId'] ??
          json['olcumTipiId'] ??
          json['measurement_type'] ??
          0,
      userId:
          json['CihazId'] ??
          json['cihazId'] ??
          json['UserId'] ??
          json['userId'] ??
          json['user_id'],
      createdAt:
          _parseDate(json, [
            'CreatedAt',
            'createdAt',
            'created_at',
            'CreateAt',
          ]) ??
          DateTime.now(),
      updatedAt: _parseDate(json, ['UpdatedAt', 'updatedAt', 'updated_at']),
      deviceId: json['DeviceId'] ?? json['deviceId'] ?? json['device_id'],
    );
  }

  /// Helper method to parse dates from different field names
  static DateTime? _parseDate(Map<String, dynamic> json, List<String> fields) {
    for (String field in fields) {
      if (json[field] != null) {
        try {
          return DateTime.parse(json[field]);
        } catch (e) {
          continue;
        }
      }
    }
    return null;
  }

  /// Validation method
  String? validate() {
    if (weight <= 0) {
      return 'Ağırlık değeri pozitif olmalıdır';
    }
    if (weight > 10000) {
      return 'Ağırlık değeri çok yüksek';
    }
    if (measurementDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return 'Ölçüm tarihi gelecekte olamaz';
    }
    return null;
  }

  /// Copy with method for immutable updates
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
    String? deviceId,
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
      deviceId: deviceId ?? this.deviceId,
    );
  }

  /// Formatted weight string
  String get formattedWeight => '${weight.toStringAsFixed(2)} kg';

  /// Formatted date string
  String get formattedDate =>
      DateFormat('dd.MM.yyyy HH:mm').format(measurementDate);

  @override
  String toString() {
    return 'WeightMeasurement(id: $id, weight: $weight, rfid: $rfid, date: $measurementDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightMeasurement &&
        other.id == id &&
        other.weight == weight &&
        other.measurementDate == measurementDate &&
        other.rfid == rfid;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        weight.hashCode ^
        measurementDate.hashCode ^
        rfid.hashCode;
  }
}

// Module-Summary:
// WeightMeasurement modeli ağırlık ölçümü verilerini yönetir. SQLite ve API entegrasyonu için serialization metodları, validasyon, tarih/ağırlık formatlaması ve immutable güncellemeler sağlar. Çoklu alan adı desteği ile farklı backend API'larla uyumludur.
