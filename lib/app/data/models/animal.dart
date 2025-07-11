// SUMMARY: Hayvan varlığını temsil eder; kimlik, tür, yaş, ağırlık ve validasyon içerir.

import 'package:tartim/app/data/models/animal_type.dart';

// Hayvan sıralama seçenekleri
enum SortOption {
  nameAsc,
  nameDesc,
  weightAsc,
  weightDesc,
  latest,
  oldest,
  weightGain,
  ageAscending,
  ageDescending,
  weightAscending,
  weightDescending,
  nameAscending,
  nameDescending,
  dateAscending,
}

// Ağırlık grafik filtreleme seçenekleri
enum WeightChartFilter {
  last7Days,
  last30Days,
  last90Days,
  last6Months,
  lastYear,
  custom,
  lastWeek,
  lastMonth,
  lastThreeMonths,
  lastSixMonths,
  all,
}

class Animal {
  int? id;
  final String name;
  final int typeId;
  final String earTag;
  final String rfid;
  final String? motherRfid;
  final String? fatherRfid;
  final DateTime? birthDate;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Animal({
    this.id,
    required this.name,
    required this.typeId,
    required this.earTag,
    required this.rfid,
    this.motherRfid,
    this.fatherRfid,
    this.birthDate,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Map'e dönüştür (SQLite için)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type_id': typeId,
      'ear_tag': earTag,
      'rfid': rfid,
      'mother_rfid': motherRfid,
      'father_rfid': fatherRfid,
      'birth_date': birthDate?.toIso8601String(),
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Map'ten oluştur (SQLite'dan)
  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      name: map['name'] ?? '',
      typeId: map['type_id'] ?? 0,
      earTag: map['ear_tag'] ?? '',
      rfid: map['rfid'] ?? '',
      motherRfid: map['mother_rfid'],
      fatherRfid: map['father_rfid'],
      birthDate: map['birth_date'] != null 
          ? DateTime.tryParse(map['birth_date'])
          : null,
      notes: map['notes'],
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: map['created_at'] != null 
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.tryParse(map['updated_at'])
          : null,
    );
  }

  // JSON'a dönüştür (API için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'typeId': typeId,
      'earTag': earTag,
      'rfid': rfid,
      'motherRfid': motherRfid,
      'fatherRfid': fatherRfid,
      'birthDate': birthDate?.toIso8601String(),
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // JSON'dan oluştur (API'den)
  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] ?? json['Id'],
      name: json['name'] ?? json['Name'] ?? '',
      typeId: json['typeId'] ?? json['TypeId'] ?? json['type_id'] ?? 0,
      earTag: json['earTag'] ?? json['EarTag'] ?? json['ear_tag'] ?? '',
      rfid: json['rfid'] ?? json['Rfid'] ?? json['RFID'] ?? '',
      motherRfid: json['motherRfid'] ?? json['MotherRfid'] ?? json['mother_rfid'],
      fatherRfid: json['fatherRfid'] ?? json['FatherRfid'] ?? json['father_rfid'],
      birthDate: json['birthDate'] != null 
          ? DateTime.tryParse(json['birthDate']) 
          : (json['BirthDate'] != null 
              ? DateTime.tryParse(json['BirthDate'])
              : (json['birth_date'] != null 
                  ? DateTime.tryParse(json['birth_date'])
                  : null)),
      notes: json['notes'] ?? json['Notes'],
      isActive: json['isActive'] ?? json['IsActive'] ?? json['is_active'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'])
          : (json['CreatedAt'] != null 
              ? DateTime.tryParse(json['CreatedAt'])
              : (json['created_at'] != null 
                  ? DateTime.tryParse(json['created_at'])
                  : null)),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'])
          : (json['UpdatedAt'] != null 
              ? DateTime.tryParse(json['UpdatedAt'])
              : (json['updated_at'] != null 
                  ? DateTime.tryParse(json['updated_at'])
                  : null)),
    );
  }

  // Kopya oluştur
  Animal copyWith({
    int? id,
    String? name,
    int? typeId,
    String? earTag,
    String? rfid,
    String? motherRfid,
    String? fatherRfid,
    DateTime? birthDate,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Animal(
      id: id ?? this.id,
      name: name ?? this.name,
      typeId: typeId ?? this.typeId,
      earTag: earTag ?? this.earTag,
      rfid: rfid ?? this.rfid,
      motherRfid: motherRfid ?? this.motherRfid,
      fatherRfid: fatherRfid ?? this.fatherRfid,
      birthDate: birthDate ?? this.birthDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Animal{id: $id, name: $name, typeId: $typeId, earTag: $earTag, rfid: $rfid, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Animal &&
        other.id == id &&
        other.name == name &&
        other.typeId == typeId &&
        other.earTag == earTag &&
        other.rfid == rfid;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        typeId.hashCode ^
        earTag.hashCode ^
        rfid.hashCode;
  }

  // Yardımcı metodlar
  String get displayName => name.isNotEmpty ? name : 'Hayvan-${earTag.isNotEmpty ? earTag : rfid}';
  
  bool get hasMother => motherRfid != null && motherRfid!.isNotEmpty;
  bool get hasFather => fatherRfid != null && fatherRfid!.isNotEmpty;
  bool get hasParents => hasMother || hasFather;
  
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    final difference = now.difference(birthDate!);
    return (difference.inDays / 365).floor();
  }

  String get ageText {
    final animalAge = age;
    if (animalAge == null) return 'Bilinmiyor';
    if (animalAge == 0) return '1 yaşından küçük';
    return '$animalAge yaşında';
  }

  // Validasyon
  bool get isValid {
    return name.isNotEmpty && 
           earTag.isNotEmpty && 
           rfid.isNotEmpty && 
           typeId > 0;
  }

  String? validate() {
    if (name.isEmpty) return 'Hayvan adı gerekli';
    if (earTag.isEmpty) return 'Kulak etiketi gerekli';
    if (rfid.isEmpty) return 'RFID gerekli';
    if (typeId <= 0) return 'Hayvan türü seçilmeli';
    return null;
  }
}
