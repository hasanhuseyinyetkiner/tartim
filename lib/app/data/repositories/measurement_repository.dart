import 'package:animaltracker/app/data/database/database_helper.dart';
import 'package:animaltracker/app/data/models/measurement.dart';
import 'package:animaltracker/app/data/models/olcum_tipi.dart';
import 'package:animaltracker/app/data/models/weight_measurement.dart';
import 'package:intl/intl.dart';
import 'package:animaltracker/app/data/models/animal.dart';
import 'package:animaltracker/app/data/models/birth_weight_measurement.dart';
import 'package:animaltracker/app/data/models/weaning_weight_measurement.dart';
import 'package:animaltracker/app/services/api/api_service.dart';
import 'package:animaltracker/app/data/api/models/api_response.dart';
import 'package:get/get.dart';

class MeasurementRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final DotNetApiService _apiService = DotNetApiService();

  // Geçici ölçüm ekleme
  Future<int> insertTempMeasurement(Measurement measurement) async {
    return await _databaseHelper.insert(
        'temp_measurements', measurement.toMap());
  }

  // Geçici ölçümleri RFID'ye göre getirme
  Future<List<Measurement>> getTempMeasurementsByRfid(String rfid) async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.queryWhere(
      'temp_measurements',
      'rfid = ?',
      [rfid],
    );

    return List.generate(maps.length, (i) {
      return Measurement.fromMap(maps[i]);
    });
  }

  // Ölçümleri sonlandırma ve ana tabloya kaydetme
  Future<void> finalizeMeasurements(OlcumTipi olcumTipi) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // Tüm benzersiz RFID'leri temp_measurements tablosundan al
      final List<Map<String, dynamic>> rfids =
          await txn.rawQuery('SELECT DISTINCT rfid FROM temp_measurements');

      for (var rfidMap in rfids) {
        String rfid = rfidMap['rfid'];

        // Her RFID için medyan ağırlığı hesapla
        final List<Map<String, dynamic>> weights = await txn.rawQuery(
            'SELECT weight FROM temp_measurements WHERE rfid = ? ORDER BY weight',
            [rfid]);

        double medianWeight;
        int count = weights.length;
        if (count % 2 == 0) {
          medianWeight = (weights[count ~/ 2 - 1]['weight'] +
                  weights[count ~/ 2]['weight']) /
              2;
        } else {
          medianWeight = weights[count ~/ 2]['weight'];
        }

        // Son ölçümü ana measurements tablosuna ekle
        await txn.insert('measurements', {
          'weight': medianWeight,
          'rfid': rfid,
          'timestamp': DateTime.now().toIso8601String(),
          'olcumTipi': olcumTipi.value,
        });
      }

      // temp_measurements tablosunu temizle
      await txn.execute('DELETE FROM temp_measurements');
    });
  }

  // Ana ölçüm ekleme
  Future<int> insertMeasurement(WeightMeasurement measurement) async {
    return await _databaseHelper.insert('measurements', measurement.toMap());
  }

  // Son ölçümleri getirme
  Future<List<Measurement>> getRecentMeasurements(int limit) async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.query(
      'measurements',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return Measurement.fromMap(maps[i]);
    });
  }

  Future<Measurement?> getLastMeasurement() async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.query(
      'measurements',
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Measurement.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Measurement>> getLastMeasurementsByRfid(
      String rfid, int limit) async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.query(
      'measurements',
      where: 'rfid = ?',
      whereArgs: [rfid],
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return Measurement.fromMap(maps[i]);
    });
  }

  // Belirli bir hayvanın ölçümlerini getirme
  Future<List<WeightMeasurement>> getMeasurementsByAnimalId(
      int animalId) async {
    try {
      // Önce API'den veri almayı dene
      return await fetchAndSaveMeasurementsByAnimalId(animalId);
    } catch (e) {
      // API'den alınamazsa SQLite'dan al
      final List<Map<String, dynamic>> maps = await _databaseHelper
          .queryWhere('measurements', 'animal_id = ?', [animalId]);
      return List.generate(maps.length, (i) {
        return WeightMeasurement.fromMap(maps[i]);
      });
    }
  }

  // Belirli bir RFID'ye ait son ölçümü getirme
  Future<WeightMeasurement?> getLastMeasurementByRfid(String rfid) async {
    final maps = await _databaseHelper.queryWhere(
      'measurements',
      'rfid = ?',
      [rfid],
      orderBy: 'measurement_date DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return WeightMeasurement.fromMap(maps.first);
    }
    return null;
  }

  // Geçici ölçümlerin medyanını hesaplama
  Future<double?> getMedianTempMeasurementByRfid(String rfid) async {
    final db = await _databaseHelper.database;

    // Son 5 dakika öncesinin timestamp'ini hesapla
    final fiveMinutesAgo = DateTime.now().subtract(Duration(minutes: 3));
    final fiveMinutesAgoStr =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(fiveMinutesAgo);

    // Sorgu: son 5 dakika içinde alınan en fazla 5 kaydı al
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT weight 
    FROM temp_measurements 
    WHERE rfid = ? AND timestamp >= ? 
    ORDER BY timestamp DESC 
    LIMIT 5
    ''', [rfid, fiveMinutesAgoStr]);

    if (result.isEmpty) return null;

    // Ağırlıkları listeye ekleyip sıralama işlemi
    final weights = result.map((e) => e['weight'] as double).toList();
    weights.sort();

    // Medyanı hesapla
    if (weights.length % 2 == 0) {
      return (weights[weights.length ~/ 2 - 1] + weights[weights.length ~/ 2]) /
          2;
    } else {
      return weights[weights.length ~/ 2];
    }
  }

  // Tüm geçici ölçümleri temizleme
  Future<int> clearTempMeasurements() async {
    return await _databaseHelper.delete('temp_measurements', null, null);
  }

  Future<List<WeightMeasurement>> getMeasurementsByRfid(String rfid) async {
    final maps = await _databaseHelper.queryWhere(
      'measurements',
      'rfid = ?',
      [rfid],
      orderBy: 'measurement_date ASC',
    );
    return maps.map((map) => WeightMeasurement.fromMap(map)).toList();
  }

  Future<List<WeightMeasurement>> getMeasurementsByDateRange(
    String rfid,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final maps = await _databaseHelper.queryWhere(
      'measurements',
      'rfid = ? AND measurement_date BETWEEN ? AND ?',
      [rfid, startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'measurement_date ASC',
    );
    return maps.map((map) => WeightMeasurement.fromMap(map)).toList();
  }

  // Toplam ölçüm sayısını getirme metodu
  Future<int> getTotalMeasurementCount() async {
    try {
      final result = await _databaseHelper.queryAllRows('measurements');
      return result.length;
    } catch (e) {
      print('Error getting total measurement count: $e');
      return 0;
    }
  }

  // Normal Ölçümler

  // Ölçümleri API'den al ve SQLite'a kaydet
  Future<List<WeightMeasurement>> fetchAndSaveMeasurements() async {
    try {
      final response = await _apiService.getWeightMeasurements();

      if (response.error == null && response.data != null) {
        final List<WeightMeasurement> measurements = [];
        for (var item in response.data!) {
          final measurement = WeightMeasurement.fromJson(item);
          measurements.add(measurement);

          // SQLite'a kaydet veya güncelle
          await upsertMeasurement(measurement);
        }
        return measurements;
      }

      // API başarısız olursa yerel veritabanından al
      return await getAllMeasurements();
    } catch (e) {
      print('API\'den ölçümler getirilirken hata: $e');
      return await getAllMeasurements(); // Hata durumunda yerel veritabanını kullan
    }
  }

  // Hayvan ID'sine göre ölçümleri API'den al ve SQLite'a kaydet
  Future<List<WeightMeasurement>> fetchAndSaveMeasurementsByAnimalId(
      int animalId) async {
    try {
      final response =
          await _apiService.getWeightMeasurementsByAnimalId(animalId);

      if (response.error == null && response.data != null) {
        final List<WeightMeasurement> measurements = [];
        for (var item in response.data!) {
          final measurement = WeightMeasurement.fromJson(item);
          measurements.add(measurement);

          // SQLite'a kaydet veya güncelle
          await upsertMeasurement(measurement);
        }
        return measurements;
      }

      // API başarısız olursa yerel veritabanından al
      final List<Map<String, dynamic>> maps = await _databaseHelper
          .queryWhere('measurements', 'animal_id = ?', [animalId]);
      return List.generate(maps.length, (i) {
        return WeightMeasurement.fromMap(maps[i]);
      });
    } catch (e) {
      print('API\'den ölçümler getirilirken hata: $e');
      final List<Map<String, dynamic>> maps = await _databaseHelper
          .queryWhere('measurements', 'animal_id = ?', [animalId]);
      return List.generate(maps.length, (i) {
        return WeightMeasurement.fromMap(maps[i]);
      });
    }
  }

  // SQLite'a ölçümü ekle veya güncelle
  Future<int> upsertMeasurement(WeightMeasurement measurement) async {
    if (measurement.id != null) {
      final existingMeasurement = await getMeasurementById(measurement.id!);

      if (existingMeasurement != null) {
        return await updateMeasurement(measurement);
      }
    }
    return await insertMeasurement(measurement);
  }

  // Tüm ölçümleri getir (önce API'den, sonra SQLite'dan)
  Future<List<WeightMeasurement>> getAllMeasurements() async {
    try {
      // Önce API'den veri almayı dene (recursive çağrıyı düzeltmek için API çağrısı burada kaldırıldı)
      final List<Map<String, dynamic>> maps =
          await _databaseHelper.queryAllRows('measurements');
      return List.generate(maps.length, (i) {
        return WeightMeasurement.fromMap(maps[i]);
      });
    } catch (e) {
      // API'den alınamazsa SQLite'dan al
      final List<Map<String, dynamic>> maps =
          await _databaseHelper.queryAllRows('measurements');
      return List.generate(maps.length, (i) {
        return WeightMeasurement.fromMap(maps[i]);
      });
    }
  }

  // ID'ye göre ölçümü getir
  Future<WeightMeasurement?> getMeasurementById(int id) async {
    final List<Map<String, dynamic>> maps =
        await _databaseHelper.queryWhere('measurements', 'id = ?', [id]);
    if (maps.length > 0) {
      return WeightMeasurement.fromMap(maps.first);
    }
    return null;
  }

  // API'ye yeni ölçüm ekle ve başarılı olursa SQLite'a da ekle
  Future<WeightMeasurement?> addMeasurementToApi(
      WeightMeasurement measurement) async {
    try {
      final response =
          await _apiService.createWeightMeasurement(measurement.toJson());

      if (response.error == null && response.data != null) {
        // API'den dönen veriyi kullan
        final createdMeasurement = WeightMeasurement.fromJson(response.data!);

        // SQLite'a kaydet
        await insertMeasurement(createdMeasurement);

        return createdMeasurement;
      }
      return null;
    } catch (e) {
      print('API\'ye ölçüm eklenirken hata: $e');
      // Çevrimdışı modda çalış: Sadece SQLite'a ekle, senkronizasyon sonra yapılacak
      final id = await insertMeasurement(measurement);
      return measurement;
    }
  }

  // API'de ölçümü güncelle ve başarılı olursa SQLite'ı da güncelle
  Future<bool> updateMeasurementToApi(WeightMeasurement measurement) async {
    try {
      final response = await _apiService.updateWeightMeasurement(
          measurement.id!, measurement.toJson());

      if (response.error == null) {
        // SQLite'ı da güncelle
        await updateMeasurement(measurement);
        return true;
      }
      return false;
    } catch (e) {
      print('API\'de ölçüm güncellenirken hata: $e');
      // Çevrimdışı modda çalış: Sadece SQLite'ı güncelle, senkronizasyon sonra yapılacak
      await updateMeasurement(measurement);
      return true;
    }
  }

  // Ölçümü güncelle (SQLite)
  Future<int> updateMeasurement(WeightMeasurement measurement) async {
    return await _databaseHelper.update(
        'measurements', measurement.toMap(), 'id = ?', [measurement.id]);
  }

  // Ölçümü API'den ve SQLite'dan sil
  Future<bool> deleteMeasurementFromApi(int id) async {
    try {
      final response = await _apiService.deleteWeightMeasurement(id);

      if (response.error == null) {
        // SQLite'dan da sil
        await deleteMeasurement(id);
        return true;
      }
      return false;
    } catch (e) {
      print('API\'den ölçüm silinirken hata: $e');
      // Çevrimdışı modda çalış: Sadece SQLite'dan silme, senkronizasyon sonra yapılacak
      return false;
    }
  }

  // Ölçümü sil (SQLite)
  Future<int> deleteMeasurement(int id) async {
    return await _databaseHelper.delete('measurements', 'id = ?', [id]);
  }

  // Hayvanın son ölçümünü getir
  Future<WeightMeasurement?> getLastMeasurementByAnimalId(int animalId) async {
    final measurements = await getMeasurementsByAnimalId(animalId);
    if (measurements.isNotEmpty) {
      return measurements.reduce(
          (a, b) => a.measurementDate.isAfter(b.measurementDate) ? a : b);
    }
    return null;
  }

  // Hayvanın ilk ölçümünü getir
  Future<WeightMeasurement?> getFirstMeasurementByAnimalId(int animalId) async {
    final measurements = await getMeasurementsByAnimalId(animalId);
    if (measurements.isNotEmpty) {
      return measurements.reduce(
          (a, b) => a.measurementDate.isBefore(b.measurementDate) ? a : b);
    }
    return null;
  }

  // Hayvanın kilo kaybı/artışını hesapla
  Future<Map<String, dynamic>> calculateWeightGain(int animalId) async {
    final firstMeasurement = await getFirstMeasurementByAnimalId(animalId);
    final lastMeasurement = await getLastMeasurementByAnimalId(animalId);

    if (firstMeasurement != null && lastMeasurement != null) {
      final weightGain = lastMeasurement.weight - firstMeasurement.weight;
      final percentageGain = (weightGain / firstMeasurement.weight) * 100;
      final daysElapsed = lastMeasurement.measurementDate
          .difference(firstMeasurement.measurementDate)
          .inDays;
      final gainPerDay = daysElapsed > 0 ? weightGain / daysElapsed : 0;

      return {
        'initialWeight': firstMeasurement.weight,
        'latestWeight': lastMeasurement.weight,
        'weightGain': weightGain,
        'percentageGain': percentageGain,
        'daysElapsed': daysElapsed,
        'gainPerDay': gainPerDay,
      };
    }

    return {};
  }

  // Tüm hayvanlar için günlük ortalama kilo kazancı
  Future<List<Map<String, dynamic>>> getAverageDailyGainForAllAnimals() async {
    final allAnimalIds = await _getAllAnimalIds();
    final List<Map<String, dynamic>> result = [];

    for (final animalId in allAnimalIds) {
      final animal = await _getAnimalName(animalId);
      final weightGainInfo = await calculateWeightGain(animalId);

      if (weightGainInfo.isNotEmpty) {
        result.add({
          'animalId': animalId,
          'name': animal,
          ...weightGainInfo,
        });
      }
    }

    // Günlük kazanca göre sırala
    result.sort((a, b) =>
        (b['gainPerDay'] as double).compareTo(a['gainPerDay'] as double));
    return result;
  }

  // Tüm hayvan ID'lerini getir (yardımcı metod)
  Future<List<int>> _getAllAnimalIds() async {
    final List<Map<String, dynamic>> maps = await _databaseHelper
        .rawQuery('SELECT DISTINCT animal_id FROM measurements');
    return List.generate(maps.length, (i) => maps[i]['animal_id'] as int);
  }

  // Hayvan adını getir (yardımcı metod)
  Future<String> _getAnimalName(int animalId) async {
    final List<Map<String, dynamic>> maps =
        await _databaseHelper.queryWhere('animals', 'id = ?', [animalId]);

    if (maps.isNotEmpty) {
      return maps.first['name'] as String;
    }
    return 'Unknown';
  }

  // Son X gün içindeki ölçümleri getir
  Future<List<WeightMeasurement>> getMeasurementsInLastDays(int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final List<Map<String, dynamic>> maps = await _databaseHelper.rawQuery(
        'SELECT * FROM measurements WHERE measurement_date >= ?',
        [cutoffDate.toIso8601String()]);

    return List.generate(maps.length, (i) {
      return WeightMeasurement.fromMap(maps[i]);
    });
  }

  // Bir tarih aralığındaki ölçümleri getir
  Future<List<WeightMeasurement>> getMeasurementsBetweenDates(
      DateTime startDate, DateTime endDate) async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.rawQuery(
        'SELECT * FROM measurements WHERE measurement_date BETWEEN ? AND ?',
        [startDate.toIso8601String(), endDate.toIso8601String()]);

    return List.generate(maps.length, (i) {
      return WeightMeasurement.fromMap(maps[i]);
    });
  }

  // Ölçüm tiplerine göre getir
  Future<List<WeightMeasurement>> getMeasurementsByType(
      int measurementType) async {
    final List<Map<String, dynamic>> maps = await _databaseHelper
        .queryWhere('measurements', 'measurement_type = ?', [measurementType]);

    return List.generate(maps.length, (i) {
      return WeightMeasurement.fromMap(maps[i]);
    });
  }
}
