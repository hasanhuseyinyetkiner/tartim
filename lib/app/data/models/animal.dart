class Animal {
  int? id;
  String name;
  int typeId;
  String earTag;
  String rfid;
  String? motherRfid;
  String? fatherRfid;
  DateTime? birthDate;
  String? gender;
  bool isActive = true;
  int? userId;
  DateTime? createdAt;
  DateTime? updatedAt;

  Animal({
    this.id,
    required this.name,
    required this.typeId,
    required this.earTag,
    required this.rfid,
    this.motherRfid,
    this.fatherRfid,
    this.birthDate,
    this.gender,
    this.isActive = true,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

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
      'gender': gender,
      'is_active': isActive ? 1 : 0,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      name: map['name'],
      typeId: map['type_id'],
      earTag: map['ear_tag'],
      rfid: map['rfid'],
      motherRfid: map['mother_rfid'],
      fatherRfid: map['father_rfid'],
      birthDate:
          map['birth_date'] != null ? DateTime.parse(map['birth_date']) : null,
      gender: map['gender'],
      isActive: map['is_active'] == 1,
      userId: map['user_id'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['Id'] ?? json['id'],
      name: json['Isim'] ?? json['isim'] ?? json['name'],
      typeId: json['KategoriId'] ?? json['kategoriId'] ?? json['type_id'],
      earTag: json['KupeNo'] ?? json['kupeNo'] ?? json['ear_tag'],
      rfid: json['RfidKodu'] ?? json['rfidKodu'] ?? json['rfid'],
      motherRfid: json['AnneRfid'] ?? json['anneRfid'] ?? json['mother_rfid'],
      fatherRfid: json['BabaRfid'] ?? json['babaRfid'] ?? json['father_rfid'],
      birthDate: json['DogumTarihi'] != null
          ? DateTime.parse(json['DogumTarihi'])
          : (json['dogumTarihi'] != null
              ? DateTime.parse(json['dogumTarihi'])
              : (json['birth_date'] != null
                  ? DateTime.parse(json['birth_date'])
                  : null)),
      gender: json['Cinsiyet'] ?? json['cinsiyet'] ?? json['gender'],
      isActive: json['Aktif'] ?? json['aktif'] ?? json['is_active'] ?? true,
      userId: json['UserId'] ?? json['userId'] ?? json['user_id'],
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'])
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : null),
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.parse(json['UpdatedAt'])
          : (json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Isim': name,
      'KategoriId': typeId,
      'KupeNo': earTag,
      'RfidKodu': rfid,
      'AnneRfid': motherRfid,
      'BabaRfid': fatherRfid,
      'DogumTarihi': birthDate?.toIso8601String(),
      'Cinsiyet': gender,
      'Aktif': isActive,
      'UserId': userId,
      'CreatedAt': createdAt?.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
    };
  }
}
