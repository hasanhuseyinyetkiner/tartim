import 'package:animaltracker/app/data/models/olcum_tipi.dart';

class HayvanAgirlik {
  final String rfid;
  final String hayvanAdi;
  final Map<OlcumTipi, OlcumDetay?> olcumler;

  HayvanAgirlik({
    required this.rfid,
    required this.hayvanAdi,
    required this.olcumler,
  });

  factory HayvanAgirlik.fromMap(Map<String, dynamic> map) {
    // Ölçüm tiplerinden oluşan Map'i oluştur
    Map<OlcumTipi, OlcumDetay?> olcumlerMap = {};

    // Normal ağırlık ölçümü
    if (map['normalAgirlik'] != null) {
      olcumlerMap[OlcumTipi.normal] =
          OlcumDetay.fromMap(map['normalAgirlik'] as Map<String, dynamic>);
    } else {
      olcumlerMap[OlcumTipi.normal] = null;
    }

    // Sütten kesim ağırlık ölçümü
    if (map['suttenKesimAgirlik'] != null) {
      olcumlerMap[OlcumTipi.suttenKesim] =
          OlcumDetay.fromMap(map['suttenKesimAgirlik'] as Map<String, dynamic>);
    } else {
      olcumlerMap[OlcumTipi.suttenKesim] = null;
    }

    // Yeni doğmuş ağırlık ölçümü
    if (map['yeniDogmusAgirlik'] != null) {
      olcumlerMap[OlcumTipi.yeniDogmus] =
          OlcumDetay.fromMap(map['yeniDogmusAgirlik'] as Map<String, dynamic>);
    } else {
      olcumlerMap[OlcumTipi.yeniDogmus] = null;
    }

    return HayvanAgirlik(
      rfid: map['rfid'] as String,
      hayvanAdi: map['hayvanAdi'] as String? ?? 'İsimsiz Hayvan',
      olcumler: olcumlerMap,
    );
  }

  // Belirtilen ölçüm tipine göre ağırlık değerini getir
  double? getAgirlik(OlcumTipi olcumTipi) {
    return olcumler[olcumTipi]?.agirlik;
  }
}

class OlcumDetay {
  final double agirlik;
  final DateTime tarih;
  final String? not;

  OlcumDetay({
    required this.agirlik,
    required this.tarih,
    this.not,
  });

  factory OlcumDetay.fromMap(Map<String, dynamic> map) {
    return OlcumDetay(
      agirlik: (map['agirlik'] as num).toDouble(),
      tarih: DateTime.parse(map['tarih'] as String),
      not: map['not'] as String?,
    );
  }
}
