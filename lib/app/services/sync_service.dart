import 'dart:async';
import 'package:tartim/app/data/models/animal.dart';
import 'package:tartim/app/data/models/weight_measurement.dart';
import 'package:tartim/app/services/api/api_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Çevrimdışı işlemleri saklayan ve senkronize eden servis
class SyncService extends GetxService {
  final RxBool isSyncing = false.obs;
  final RxList<Map<String, dynamic>> pendingOperations =
      <Map<String, dynamic>>[].obs;
  late final DotNetApiService apiService;

  // Yerel depolama için
  final storage = GetStorage();
  final String storageKey = 'pending_operations';

  @override
  void onInit() {
    super.onInit();
    apiService = Get.find<DotNetApiService>();
    _loadPendingOperations();

    // Senkronizasyon durumu değiştiğinde kaydet
    ever(pendingOperations, (_) => _savePendingOperations());
  }

  /// Senkronizasyon servisini başlat
  Future<SyncService> init() async {
    await GetStorage.init();
    _loadPendingOperations();
    return this;
  }

  /// Yerel depolamadan bekleyen işlemleri yükle
  void _loadPendingOperations() {
    try {
      final List<dynamic>? savedOps = storage.read(storageKey);
      if (savedOps != null) {
        pendingOperations.value = savedOps.cast<Map<String, dynamic>>();
        print('Bekleyen ${pendingOperations.length} işlem yüklendi');
      }
    } catch (e) {
      print('Bekleyen işlemler yüklenirken hata: $e');
      pendingOperations.value = [];
    }
  }

  /// Bekleyen işlemleri yerel depolamaya kaydet
  void _savePendingOperations() {
    try {
      storage.write(storageKey, pendingOperations.toList());
      print('${pendingOperations.length} bekleyen işlem kaydedildi');
    } catch (e) {
      print('Bekleyen işlemler kaydedilirken hata: $e');
    }
  }

  /// Yeni bir bekleyen işlem ekle
  void addPendingOperation(String type, dynamic data, {int? id}) {
    final operation = {
      "type": type,
      "data": data,
      "id": id,
      "timestamp": DateTime.now().toIso8601String()
    };

    pendingOperations.add(operation);
    _savePendingOperations();

    // Bildirim göster
    Get.snackbar(
      'Çevrimdışı İşlem',
      'İşlem kaydedildi ve internet bağlantısı sağlandığında senkronize edilecek.',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  /// Bekleyen işlem sayısını döndür
  int getPendingOperationsCount() {
    return pendingOperations.length;
  }

  /// İnternet bağlantısını kontrol et
  Future<bool> checkConnection() async {
    try {
      final response = await apiService.getAnimals();
      return response.error == null;
    } catch (e) {
      print('API bağlantı kontrolünde hata: $e');
      return false;
    }
  }

  /// Bekleyen ağırlık ölçümlerini toplu olarak gönder
  Future<bool> _syncPendingWeightMeasurements(
      List<Map<String, dynamic>> operations) async {
    try {
      final List<Map<String, dynamic>> measurements = [];

      for (final operation in operations) {
        if (operation["type"] == "add_measurement") {
          final measurement = WeightMeasurement.fromJson(operation["data"]);
          measurements.add(measurement.toJson());
        }
      }

      if (measurements.isEmpty) return true;

      final response =
          await apiService.createWeightMeasurementsBulk(measurements);
      return response.error == null;
    } catch (e) {
      print('Toplu ölçüm senkronizasyon hatası: $e');
      return false;
    }
  }

  /// Bekleyen işlemleri senkronize et
  Future<bool> syncPendingOperations() async {
    if (pendingOperations.isEmpty) return true;
    if (isSyncing.value) return false;

    isSyncing.value = true;
    bool success = true;
    int successCount = 0;
    int failureCount = 0;

    try {
      // İnternet bağlantısını kontrol et
      final isConnected = await checkConnection();
      if (!isConnected) {
        isSyncing.value = false;
        Get.snackbar(
          'Bağlantı Hatası',
          'İnternet bağlantısı olmadığından senkronizasyon yapılamıyor.',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
        return false;
      }

      // Zaman sırasına göre işlemleri sırala (en eski ilk)
      pendingOperations.sort((a, b) => DateTime.parse(a["timestamp"].toString())
          .compareTo(DateTime.parse(b["timestamp"].toString())));

      // Her işlemi sırayla senkronize et
      final operations = pendingOperations.toList(); // Kopyasını al

      // Ağırlık ölçümlerini toplu işle
      List<Map<String, dynamic>> pendingMeasurements =
          operations.where((op) => op["type"] == "add_measurement").toList();

      if (pendingMeasurements.isNotEmpty) {
        final measurementSuccess =
            await _syncPendingWeightMeasurements(pendingMeasurements);
        if (measurementSuccess) {
          successCount += pendingMeasurements.length;
          pendingOperations
              .removeWhere((op) => op["type"] == "add_measurement");
        } else {
          failureCount += pendingMeasurements.length;
        }
      }

      // Diğer işlemleri tek tek işle
      for (final operation in operations) {
        if (operation["type"] == "add_measurement") {
          // Bu işlemi zaten toplu olarak işledik
          continue;
        }

        try {
          final type = operation["type"] as String;

          switch (type) {
            case "add_animal":
              final animal = Animal.fromJson(operation["data"]);
              final response = await apiService.createAnimal(animal.toJson());
              if (response.error == null) {
                successCount++;
                pendingOperations.remove(operation);
              } else {
                failureCount++;
              }
              break;

            case "update_animal":
              final animal = Animal.fromJson(operation["data"]);
              final response =
                  await apiService.updateAnimal(animal.id!, animal.toJson());
              if (response.error == null) {
                successCount++;
                pendingOperations.remove(operation);
              } else {
                failureCount++;
              }
              break;

            case "delete_animal":
              final id = operation["id"] as int;
              final response = await apiService.deleteAnimal(id);
              if (response.error == null) {
                successCount++;
                pendingOperations.remove(operation);
              } else {
                failureCount++;
              }
              break;

            case "update_measurement":
              final measurement = WeightMeasurement.fromJson(operation["data"]);
              final response = await apiService.updateWeightMeasurement(
                  measurement.id!, measurement.toJson());
              if (response.error == null) {
                successCount++;
                pendingOperations.remove(operation);
              } else {
                failureCount++;
              }
              break;

            case "delete_measurement":
              final id = operation["id"] as int;
              final response = await apiService.deleteWeightMeasurement(id);
              if (response.error == null) {
                successCount++;
                pendingOperations.remove(operation);
              } else {
                failureCount++;
              }
              break;
          }
        } catch (e) {
          print('Senkronizasyon işleminde hata: $e');
          failureCount++;
          success = false;
        }
      }
    } catch (e) {
      print('Senkronizasyon sırasında hata: $e');
      success = false;
    } finally {
      isSyncing.value = false;
      _savePendingOperations();

      // Sonuç bildirimi göster
      if (successCount > 0 || failureCount > 0) {
        Get.snackbar(
          'Senkronizasyon Tamamlandı',
          'Başarılı: $successCount, Başarısız: $failureCount işlem',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      }
    }

    return success;
  }

  /// Periyodik senkronizasyon başlat
  void startPeriodicSync(Duration period) {
    Timer.periodic(period, (_) async {
      if (!isSyncing.value && pendingOperations.isNotEmpty) {
        await syncPendingOperations();
      }
    });
  }
}
