import 'package:animaltracker/app/data/models/olcum_tipi.dart';

class Measurement {
  final int? id;
  final double weight;
  final String rfid;
  final String timestamp;
  final OlcumTipi olcumTipi;
  // int? animalId;

  Measurement({
    this.id,
    required this.weight,
    required this.rfid,
    required this.timestamp,
    this.olcumTipi = OlcumTipi.normal,
    // this.animalId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'rfid': rfid,
      'timestamp': timestamp,
      'olcumTipi': olcumTipi.value,
      // 'animal_id': animalId,
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      id: map['id'],
      weight: map['weight'],
      rfid: map['rfid'],
      timestamp: map['timestamp'],
      olcumTipi: map['olcumTipi'] != null
          ? OlcumTipi.fromValue(map['olcumTipi'])
          : OlcumTipi.normal,
      // animalId: map['animal_id'],
    );
  }
}
