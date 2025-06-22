import 'package:intl/intl.dart';

class BirthWeightMeasurement {
  final int? id;
  final int? animalId;
  final double weight;
  final DateTime measurementDate;
  final DateTime? birthDate;
  final String? birthPlace;
  final String? rfid;
  final String? motherRfid;
  final String? notes;
  final int? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BirthWeightMeasurement({
    this.id,
    this.animalId,
    required this.weight,
    required this.measurementDate,
    this.birthDate,
    this.birthPlace,
    this.rfid,
    this.motherRfid,
    this.notes,
    this.userId,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BirthWeightMeasurement.fromJson(Map<String, dynamic> json) {
    return BirthWeightMeasurement(
      id: json['id'],
      animalId: json['animalId'],
      weight: (json['weight'] as num).toDouble(),
      measurementDate: DateTime.parse(json['measurementDate']),
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      birthPlace: json['birthPlace'],
      rfid: json['rfid'],
      motherRfid: json['motherRfid'],
      notes: json['notes'],
      userId: json['userId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');

    return {
      'id': id,
      'animalId': animalId,
      'weight': weight,
      'measurementDate': dateFormat.format(measurementDate),
      'birthDate': birthDate != null ? dateFormat.format(birthDate!) : null,
      'birthPlace': birthPlace,
      'rfid': rfid,
      'motherRfid': motherRfid,
      'notes': notes,
      'userId': userId,
      'createdAt': dateFormat.format(createdAt),
      'updatedAt': updatedAt != null ? dateFormat.format(updatedAt!) : null,
    };
  }

  // For validation
  String? validate() {
    if (weight <= 0) {
      return 'Ağırlık değeri pozitif olmalıdır';
    }
    return null;
  }
}
