import 'package:animaltracker/app/data/models/animal_type.dart';
import 'package:animaltracker/app/data/database/database_helper.dart';

class AnimalTypeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<AnimalType>> getAllAnimalTypes() async {
    final maps =
        await _databaseHelper.query('animal_types', orderBy: 'sort_order ASC');
    return maps.map((map) => AnimalType.fromMap(map)).toList();
  }

  Future<List<AnimalType>> getAnimalTypesByCategory(String category) async {
    final maps = await _databaseHelper.queryWhere(
      'animal_types',
      'category = ?',
      [category],
    );
    final types = maps.map((map) => AnimalType.fromMap(map)).toList();
    // Sort by sort_order
    types.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return types;
  }

  Future<Map<String, List<AnimalType>>> getAnimalTypesByCategories() async {
    final allTypes = await getAllAnimalTypes();
    final Map<String, List<AnimalType>> groupedTypes = {};

    for (var type in allTypes) {
      if (!groupedTypes.containsKey(type.category)) {
        groupedTypes[type.category] = [];
      }
      groupedTypes[type.category]!.add(type);
    }

    // Sort each category's types by sort_order
    groupedTypes.forEach((key, types) {
      types.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });

    return groupedTypes;
  }

  Future<int> insertAnimalType(AnimalType animalType) async {
    return await _databaseHelper.insert('animal_types', animalType.toMap());
  }

  Future<AnimalType?> getAnimalTypeById(int id) async {
    final maps =
        await _databaseHelper.queryWhere('animal_types', 'id = ?', [id]);
    if (maps.isNotEmpty) {
      return AnimalType.fromMap(maps.first);
    }
    return null;
  }

  Future<List<AnimalType>> getNewbornAnimalTypes() async {
    // Get all animal types
    final allTypes = await getAllAnimalTypes();

    // Filter by name, case-insensitive, using contains instead of exact match
    final filteredTypes = allTypes.where((type) {
      final name = type.name.toLowerCase();
      return name.contains('buzağı') ||
          name.contains('kuzu') ||
          name.contains('oğlak');
    }).toList();

    // If no newborn types found, return all animal types
    if (filteredTypes.isEmpty) {
      print("Yavru hayvan türleri bulunamadı, tüm hayvan türleri gösteriliyor");
      return allTypes;
    }

    return filteredTypes;
  }
}
