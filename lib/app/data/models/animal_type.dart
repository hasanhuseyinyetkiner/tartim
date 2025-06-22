class AnimalType {
  int? id;
  String name;
  String category;
  int sortOrder;

  AnimalType({
    this.id,
    required this.name,
    required this.category,
    required this.sortOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'sort_order': sortOrder,
    };
  }

  factory AnimalType.fromMap(Map<String, dynamic> map) {
    return AnimalType(
      id: map['id'],
      name: map['name'],
      category: map['category'] ?? '',
      sortOrder: map['sort_order'] ?? 0,
    );
  }
}

// Hayvan kategorileri
enum AnimalCategory {
  cattle,
  sheep,
  goat,
}

extension AnimalCategoryExtension on AnimalCategory {
  String get displayName {
    switch (this) {
      case AnimalCategory.cattle:
        return 'Büyükbaş';
      case AnimalCategory.sheep:
        return 'Koyun';
      case AnimalCategory.goat:
        return 'Keçi';
    }
  }
}

// Hayvan türleri
enum AnimalTypeEnum {
  // Büyükbaş
  cow,
  calf,
  heifer,
  bull,
  steer,
  // Koyun
  sheep,
  lamb,
  ram,
  // Keçi
  goat,
  kid,
  billyGoat,
}

extension AnimalTypeEnumExtension on AnimalTypeEnum {
  String get displayName {
    switch (this) {
      // Büyükbaş
      case AnimalTypeEnum.cow:
        return 'İnek';
      case AnimalTypeEnum.calf:
        return 'Buzağı';
      case AnimalTypeEnum.heifer:
        return 'Düve';
      case AnimalTypeEnum.bull:
        return 'Boğa';
      case AnimalTypeEnum.steer:
        return 'Tosun';
      // Koyun
      case AnimalTypeEnum.sheep:
        return 'Koyun';
      case AnimalTypeEnum.lamb:
        return 'Kuzu';
      case AnimalTypeEnum.ram:
        return 'Koç';
      // Keçi
      case AnimalTypeEnum.goat:
        return 'Keçi';
      case AnimalTypeEnum.kid:
        return 'Oğlak';
      case AnimalTypeEnum.billyGoat:
        return 'Teke';
    }
  }

  AnimalCategory get category {
    switch (this) {
      case AnimalTypeEnum.cow:
      case AnimalTypeEnum.calf:
      case AnimalTypeEnum.heifer:
      case AnimalTypeEnum.bull:
      case AnimalTypeEnum.steer:
        return AnimalCategory.cattle;
      case AnimalTypeEnum.sheep:
      case AnimalTypeEnum.lamb:
      case AnimalTypeEnum.ram:
        return AnimalCategory.sheep;
      case AnimalTypeEnum.goat:
      case AnimalTypeEnum.kid:
      case AnimalTypeEnum.billyGoat:
        return AnimalCategory.goat;
    }
  }

  int get sortOrder {
    return index;
  }
}
