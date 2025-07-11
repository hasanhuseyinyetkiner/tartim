import 'package:tartim/app/data/database/database_helper.dart';
import 'package:tartim/app/data/models/measurement.dart';
import 'package:tartim/app/data/models/weight_measurement.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class MeasurementRepository extends GetxService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeTables();
  }

  Future<void> _initializeTables() async {
    try {
      final db = await _databaseHelper.database;
      
      // Measurements tablosunu oluştur
      await db.execute('''
        CREATE TABLE IF NOT EXISTS measurements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          animal_rfid TEXT NOT NULL,
          weight REAL NOT NULL,
          timestamp TEXT NOT NULL,
          olcum_tipi INTEGER DEFAULT 0,
          device_id TEXT,
          notes TEXT,
          is_synced INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // Temp measurements tablosunu oluştur
      await db.execute('''
        CREATE TABLE IF NOT EXISTS temp_measurements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          animal_rfid TEXT NOT NULL,
          weight REAL NOT NULL,
          timestamp TEXT NOT NULL,
          olcum_tipi INTEGER DEFAULT 0,
          device_id TEXT,
          notes TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      print('Measurement tables initialized successfully');
    } catch (e) {
      print('Error initializing measurement tables: $e');
    }
  }

  // Measurement CRUD işlemleri
  Future<int> insertMeasurement(Measurement measurement) async {
    try {
      final now = DateTime.now().toIso8601String();
      final data = measurement.toMap();
      data['created_at'] = now;
      data['updated_at'] = now;
      data['is_synced'] = 0;

      return await _databaseHelper.insert('measurements', data);
    } catch (e) {
      print('Error inserting measurement: $e');
      rethrow;
    }
  }

  Future<int> insertWeightMeasurement(WeightMeasurement weightMeasurement) async {
    try {
      final measurement = weightMeasurement.toMeasurement();
      return await insertMeasurement(measurement);
    } catch (e) {
      print('Error inserting weight measurement: $e');
      rethrow;
    }
  }

  Future<List<Measurement>> getAllMeasurements() async {
    try {
      final maps = await _databaseHelper.queryAllRows('measurements');
      return maps.map((map) => Measurement.fromMap(map)).toList();
    } catch (e) {
      print('Error getting all measurements: $e');
      return [];
    }
  }

  Future<List<Measurement>> getMeasurementsByRfid(String animalRfid) async {
    try {
      final maps = await _databaseHelper.queryWhere(
      'measurements',
        'animal_rfid = ?',
        [animalRfid],
      orderBy: 'timestamp DESC',
      );
      return maps.map((map) => Measurement.fromMap(map)).toList();
    } catch (e) {
      print('Error getting measurements by RFID: $e');
      return [];
    }
  }

  Future<Measurement?> getLastMeasurementByRfid(String animalRfid) async {
    try {
      final maps = await _databaseHelper.queryWhere(
      'measurements',
        'animal_rfid = ?',
        [animalRfid],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Measurement.fromMap(maps.first);
    }
    return null;
    } catch (e) {
      print('Error getting last measurement by RFID: $e');
      return null;
    }
  }

  Future<WeightMeasurement?> getLastWeightMeasurementByRfid(String animalRfid) async {
    try {
      final measurement = await getLastMeasurementByRfid(animalRfid);
      if (measurement != null) {
        return WeightMeasurement.fromMeasurement(measurement);
    }
    return null;
    } catch (e) {
      print('Error getting last weight measurement by RFID: $e');
      return null;
    }
  }

  Future<List<Measurement>> getMeasurementsByDateRange(
    String animalRfid,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
    final maps = await _databaseHelper.queryWhere(
      'measurements',
        'animal_rfid = ? AND timestamp >= ? AND timestamp <= ?',
        [
          animalRfid,
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: 'timestamp ASC',
      );
      return maps.map((map) => Measurement.fromMap(map)).toList();
    } catch (e) {
      print('Error getting measurements by date range: $e');
      return [];
    }
  }

  Future<int> updateMeasurement(Measurement measurement) async {
    try {
      final data = measurement.toMap();
      data['updated_at'] = DateTime.now().toIso8601String();

      return await _databaseHelper.update(
        'measurements',
        data,
        'id = ?',
        [measurement.id],
      );
    } catch (e) {
      print('Error updating measurement: $e');
      rethrow;
    }
  }

  Future<int> deleteMeasurement(int id) async {
    try {
      return await _databaseHelper.delete('measurements', 'id = ?', [id]);
    } catch (e) {
      print('Error deleting measurement: $e');
      rethrow;
    }
  }

  // Senkronizasyon işlemleri
  Future<List<Measurement>> getUnsyncedMeasurements() async {
    try {
      final maps = await _databaseHelper.queryWhere(
        'measurements',
        'is_synced = ?',
        [0],
        orderBy: 'created_at ASC',
      );
      return maps.map((map) => Measurement.fromMap(map)).toList();
    } catch (e) {
      print('Error getting unsynced measurements: $e');
      return [];
    }
  }

  Future<void> markAsSynced(int measurementId) async {
    try {
      await _databaseHelper.update(
        'measurements',
        {'is_synced': 1, 'updated_at': DateTime.now().toIso8601String()},
        'id = ?',
        [measurementId],
      );
    } catch (e) {
      print('Error marking measurement as synced: $e');
      rethrow;
    }
  }

  Future<void> markMultipleAsSynced(List<int> measurementIds) async {
    try {
      await _databaseHelper.transaction((txn) async {
        for (final id in measurementIds) {
          await txn.update(
            'measurements',
            {'is_synced': 1, 'updated_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      });
    } catch (e) {
      print('Error marking multiple measurements as synced: $e');
      rethrow;
    }
  }

  // Geçici ölçümler (temp_measurements)
  Future<int> insertTempMeasurement(Measurement measurement) async {
    try {
      final data = measurement.toMap();
      data.remove('id'); // Temp tabloda ID otomatik
      data['created_at'] = DateTime.now().toIso8601String();

      return await _databaseHelper.insert('temp_measurements', data);
    } catch (e) {
      print('Error inserting temp measurement: $e');
      rethrow;
    }
  }

  Future<List<Measurement>> getAllTempMeasurements() async {
    try {
      final maps = await _databaseHelper.queryAllRows('temp_measurements');
      return maps.map((map) => Measurement.fromMap(map)).toList();
    } catch (e) {
      print('Error getting temp measurements: $e');
      return [];
    }
  }

  Future<void> moveTempToMain(int tempId) async {
    try {
      await _databaseHelper.transaction((txn) async {
        // Temp'ten veriyi al
        final tempMaps = await txn.query(
          'temp_measurements',
          where: 'id = ?',
          whereArgs: [tempId],
        );

        if (tempMaps.isNotEmpty) {
          final tempData = Map<String, dynamic>.from(tempMaps.first);
          tempData.remove('id'); // ID'yi kaldır, ana tabloda otomatik olacak
          tempData['is_synced'] = 0;
          tempData['updated_at'] = DateTime.now().toIso8601String();

          // Ana tabloya ekle
          await txn.insert('measurements', tempData);

          // Temp'ten sil
          await txn.delete(
            'temp_measurements',
            where: 'id = ?',
            whereArgs: [tempId],
          );
        }
      });
    } catch (e) {
      print('Error moving temp to main: $e');
      rethrow;
    }
  }

  Future<void> clearTempMeasurements() async {
    try {
      await _databaseHelper.delete('temp_measurements', '1 = 1', []);
    } catch (e) {
      print('Error clearing temp measurements: $e');
      rethrow;
    }
  }

  // Eksik metodlar - geçici çözüm
  Future<double?> getMedianTempMeasurementByRfid(String rfid) async {
    try {
      final measurements = await getAllTempMeasurements();
      final rfidMeasurements = measurements.where((m) => m.animalRfid == rfid).toList();
      
      if (rfidMeasurements.isEmpty) return null;
      
      final weights = rfidMeasurements.map((m) => m.weight).toList();
      weights.sort();
      
      if (weights.length % 2 == 0) {
        return (weights[weights.length ~/ 2 - 1] + weights[weights.length ~/ 2]) / 2;
      } else {
        return weights[weights.length ~/ 2];
      }
    } catch (e) {
      print('Error getting median temp measurement: $e');
      return null;
    }
  }

  Future<void> finalizeMeasurements(dynamic olcumTipi) async {
    try {
      final tempMeasurements = await getAllTempMeasurements();
      
      for (final temp in tempMeasurements) {
        await moveTempToMain(temp.id!);
      }
      
      await clearTempMeasurements();
    } catch (e) {
      print('Error finalizing measurements: $e');
      rethrow;
    }
  }

  Future<List<Measurement>> getRecentMeasurements(int limit) async {
    try {
      final maps = await _databaseHelper.queryWhere(
        'measurements',
        '1 = 1',
        [],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      return maps.map((map) => Measurement.fromMap(map)).toList();
    } catch (e) {
      print('Error getting recent measurements: $e');
      return [];
    }
  }

  Future<List<Measurement>> getLastMeasurementsByRfid(String rfid, int limit) async {
    try {
      final maps = await _databaseHelper.queryWhere(
        'measurements',
        'animal_rfid = ?',
        [rfid],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      return maps.map((map) => Measurement.fromMap(map)).toList();
    } catch (e) {
      print('Error getting last measurements by rfid: $e');
      return [];
    }
  }

  // İstatistikler
  Future<Map<String, dynamic>> getMeasurementStats(String animalRfid) async {
    try {
      final measurements = await getMeasurementsByRfid(animalRfid);
      
      if (measurements.isEmpty) {
        return {
          'count': 0,
          'averageWeight': 0.0,
          'minWeight': 0.0,
          'maxWeight': 0.0,
          'weightGain': 0.0,
        };
      }

      final weights = measurements.map((m) => m.weight).toList();
      final count = weights.length;
      final sum = weights.reduce((a, b) => a + b);
      final average = sum / count;
      final min = weights.reduce((a, b) => a < b ? a : b);
      final max = weights.reduce((a, b) => a > b ? a : b);
      
      // İlk ve son ölçüm arasındaki kilo artışı
      final firstWeight = measurements.last.weight; // Son elemanı al (tarih sırasında ilk)
      final lastWeight = measurements.first.weight; // İlk elemanı al (tarih sırasında son)
      final weightGain = lastWeight - firstWeight;

      return {
        'count': count,
        'averageWeight': average,
        'minWeight': min,
        'maxWeight': max,
        'weightGain': weightGain,
      };
    } catch (e) {
      print('Error getting measurement stats: $e');
      return {
        'count': 0,
        'averageWeight': 0.0,
        'minWeight': 0.0,
        'maxWeight': 0.0,
        'weightGain': 0.0,
      };
    }
  }

  Future<Measurement?> getLastMeasurement() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'measurements',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    return results.isNotEmpty ? Measurement.fromMap(results.first) : null;
  }

  Future<int> getTotalMeasurementCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM measurements');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Measurement>> getMeasurementsByAnimalId(int animalId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'measurements',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'created_at DESC',
    );
    return results.map((map) => Measurement.fromMap(map)).toList();
  }
}
