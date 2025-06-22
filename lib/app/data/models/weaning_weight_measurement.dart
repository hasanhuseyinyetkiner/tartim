import 'package:intl/intl.dart';

class WeaningWeightMeasurement {
  final int? id;
  final int? animalId;
  final double weight;
  final DateTime measurementDate;
  final DateTime? weaningDate;
  final int? weaningAge;
  final String? rfid;
  final String? motherRfid;
  final String? notes;
  final int? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WeaningWeightMeasurement({
    this.id,
    this.animalId,
    required this.weight,
    required this.measurementDate,
    this.weaningDate,
    this.weaningAge,
    this.rfid,
    this.motherRfid,
    this.notes,
    this.userId,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WeaningWeightMeasurement.fromJson(Map<String, dynamic> json) {
    return WeaningWeightMeasurement(
      id: json['id'],
      animalId: json['animalId'],
      weight: (json['weight'] as num).toDouble(),
      measurementDate: DateTime.parse(json['measurementDate']),
      weaningDate: json['weaningDate'] != null
          ? DateTime.parse(json['weaningDate'])
          : null,
      weaningAge: json['weaningAge'],
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
      'weaningDate':
          weaningDate != null ? dateFormat.format(weaningDate!) : null,
      'weaningAge': weaningAge,
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
    if (weaningAge != null && weaningAge! < 0) {
      return 'Sütten kesim yaşı negatif olamaz';
    }
    return null;
  }
}
