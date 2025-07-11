import 'package:tartim/app/data/models/animal.dart';
import 'package:tartim/app/data/database/database_helper.dart';
import 'package:tartim/app/services/api/api_service.dart';
import 'package:tartim/app/data/api/models/api_response.dart';
import 'package:get/get.dart';

class AnimalRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final DotNetApiService _apiService = DotNetApiService();

  // Hayvanları API'den al ve SQLite'a kaydet
  Future<List<Animal>> fetchAndSaveAnimals() async {
    try {
      final response = await _apiService.getAnimals();

      if (response.error == null && response.data != null) {
        final List<Animal> animals = [];
        for (var item in response.data!) {
          final animal = Animal.fromJson(item);
          animals.add(animal);

          // SQLite'a kaydet veya güncelle
          await upsertAnimal(animal);
        }
        return animals;
      }

      // API başarısız olursa yerel veritabanından al
      return await getAllAnimals();
    } catch (e) {
      print('API\'den hayvanlar getirilirken hata: $e');
      return await getAllAnimals(); // Hata durumunda yerel veritabanını kullan
    }
  }

  // SQLite'a hayvanı ekle veya güncelle
  Future<int> upsertAnimal(Animal animal) async {
    final existingAnimal = await getAnimalById(animal.id!);

    if (existingAnimal != null) {
      return await updateAnimal(animal);
    } else {
      return await insertAnimal(animal);
    }
  }

  // SQLite'a hayvan ekle
  Future<int> insertAnimal(Animal animal) async {
    return await _databaseHelper.insert('animals', animal.toMap());
  }

  // Tüm hayvanları getir (önce API'den, sonra SQLite'dan)
  Future<List<Animal>> getAllAnimals() async {
    try {
      // Önce API'den veri almayı dene
      return await fetchAndSaveAnimals();
    } catch (e) {
      // API'den alınamazsa SQLite'dan al
      final maps = await _databaseHelper.queryAllRows('animals');
      return maps.map((map) => Animal.fromMap(map)).toList();
    }
  }

  // API'ye yeni hayvan ekle ve başarılı olursa SQLite'a da ekle
  Future<Animal?> addAnimalToApi(Animal animal) async {
    try {
      final response = await _apiService.createAnimal(animal.toJson());

      if (response.error == null && response.data != null) {
        // API'den dönen veriyi kullan
        final createdAnimal = Animal.fromJson(response.data!);

        // SQLite'a kaydet
        await insertAnimal(createdAnimal);

        return createdAnimal;
      }
      return null;
    } catch (e) {
      print('API\'ye hayvan eklenirken hata: $e');
      // Çevrimdışı modda çalış: Sadece SQLite'a ekle, senkronizasyon sonra yapılacak
      animal.id = await insertAnimal(animal);
      return animal;
    }
  }

  // API'de hayvanı güncelle ve başarılı olursa SQLite'ı da güncelle
  Future<bool> updateAnimalToApi(Animal animal) async {
    try {
      final response =
          await _apiService.updateAnimal(animal.id!, animal.toJson());

      if (response.error == null) {
        // SQLite'ı da güncelle
        await updateAnimal(animal);
        return true;
      }
      return false;
    } catch (e) {
      print('API\'de hayvan güncellenirken hata: $e');
      // Çevrimdışı modda çalış: Sadece SQLite'ı güncelle, senkronizasyon sonra yapılacak
      await updateAnimal(animal);
      return true;
    }
  }

  // RFID'ye göre hayvanı getir
  Future<Animal?> getAnimalByRfid(String rfid) async {
    try {
      // Önce API'den almayı dene
      final response = await _apiService.getAnimalByRfid(rfid);

      if (response.error == null && response.data != null) {
        final animal = Animal.fromJson(response.data!);
        // SQLite'a kaydet veya güncelle
        await upsertAnimal(animal);
        return animal;
      }

      // API başarısız olursa yerel veritabanından al
      final maps =
          await _databaseHelper.queryWhere('animals', 'rfid = ?', [rfid]);
      if (maps.isNotEmpty) {
        return Animal.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('API\'den hayvan getirilirken hata: $e');
      // Yerel veritabanından al
      final maps =
          await _databaseHelper.queryWhere('animals', 'rfid = ?', [rfid]);
      if (maps.isNotEmpty) {
        return Animal.fromMap(maps.first);
      }
      return null;
    }
  }

  // ID'ye göre hayvanı getir
  Future<Animal?> getAnimalById(int id) async {
    try {
      // Önce API'den almayı dene
      final response = await _apiService.getAnimal(id);

      if (response.error == null && response.data != null) {
        final animal = Animal.fromJson(response.data!);
        // SQLite'a kaydet veya güncelle
        await upsertAnimal(animal);
        return animal;
      }

      // API başarısız olursa yerel veritabanından al
      final maps = await _databaseHelper.queryWhere('animals', 'id = ?', [id]);
      if (maps.isNotEmpty) {
        return Animal.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('API\'den hayvan getirilirken hata: $e');
      // Yerel veritabanından al
      final maps = await _databaseHelper.queryWhere('animals', 'id = ?', [id]);
      if (maps.isNotEmpty) {
        return Animal.fromMap(maps.first);
      }
      return null;
    }
  }

  Future<Animal?> getMotherByRfid(String motherRfid) async {
    if (motherRfid.isEmpty) return null;
    return await getAnimalByRfid(motherRfid);
  }

  Future<Animal?> getFatherByRfid(String fatherRfid) async {
    if (fatherRfid.isEmpty) return null;
    return await getAnimalByRfid(fatherRfid);
  }

  Future<List<Animal>> getOffspringByParentRfid(String parentRfid) async {
    final maps = await _databaseHelper.queryWhere('animals',
        'mother_rfid = ? OR father_rfid = ?', [parentRfid, parentRfid]);
    return maps.map((map) => Animal.fromMap(map)).toList();
  }

  // SQLite'da hayvanı güncelle
  Future<int> updateAnimal(Animal animal) async {
    return await _databaseHelper
        .update('animals', animal.toMap(), 'id = ?', [animal.id]);
  }

  // Hayvanı API'den ve SQLite'dan sil
  Future<bool> deleteAnimalFromApi(int id) async {
    try {
      final response = await _apiService.deleteAnimal(id);

      if (response.error == null) {
        // SQLite'dan da sil
        await deleteAnimal(id);
        return true;
      }
      return false;
    } catch (e) {
      print('API\'den hayvan silinirken hata: $e');
      // Çevrimdışı modda: Şimdilik SQLite'dan silme, senkronizasyon sırasında tekrar denenecek
      return false;
    }
  }

  // SQLite'dan hayvanı sil
  Future<int> deleteAnimal(int id) async {
    return await _databaseHelper.delete('animals', 'id = ?', [id]);
  }

  // Kilo kazanımına göre tüm hayvanları getir
  Future<List<Animal>> getAllAnimalsWithWeightGain() async {
    final result = await _databaseHelper.rawQuery('''
      SELECT a.*, 
        first_m.weight as first_weight,
        last_m.weight as last_weight,
        (last_m.weight - first_m.weight) as weight_gain
      FROM animals a 
      LEFT JOIN (
        SELECT rfid, weight FROM measurements 
        WHERE id IN (SELECT MIN(id) FROM measurements GROUP BY rfid)
      ) first_m ON a.rfid = first_m.rfid
      LEFT JOIN (
        SELECT rfid, weight FROM measurements 
        WHERE id IN (SELECT MAX(id) FROM measurements GROUP BY rfid)
      ) last_m ON a.rfid = last_m.rfid
      WHERE first_m.weight IS NOT NULL AND last_m.weight IS NOT NULL
      ORDER BY weight_gain DESC
    ''');

    return result.map((map) => Animal.fromMap(map)).toList();
  }
}
