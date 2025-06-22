import 'package:animaltracker/app/data/models/measurement.dart';
import 'package:animaltracker/app/data/repositories/measurement_repository.dart';
import 'package:get/get.dart';
import 'package:animaltracker/app/data/models/animal.dart';
import 'package:animaltracker/app/data/models/animal_type.dart';
import 'package:animaltracker/app/data/repositories/animal_repository.dart';
import 'package:animaltracker/app/data/repositories/animal_type_repository.dart';
import 'package:animaltracker/app/services/sync_service.dart';
import 'package:animaltracker/app/services/connectivity_service.dart';
import 'package:animaltracker/app/services/api/api_service.dart';
import 'package:animaltracker/app/services/api/api_error_handler.dart';
import 'package:animaltracker/app/data/api/models/api_error.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:animaltracker/app/data/models/weight_measurement.dart';

extension WeightMeasurementConverter on WeightMeasurement {
  Measurement toMeasurement() {
    return Measurement(
      weight: weight,
      rfid: rfid,
      timestamp: measurementDate.toIso8601String(),
    );
  }
}

enum SortOption {
  nameAsc,
  nameDesc,
  weightAsc,
  weightDesc,
  latest,
  oldest,
  weightGain,
}

class AnimalsController extends GetxController {
  final AnimalRepository animalRepository;
  final AnimalTypeRepository animalTypeRepository;
  final MeasurementRepository measurementRepository;
  final DotNetApiService apiService = Get.find<DotNetApiService>();
  late final SyncService syncService;
  late final ConnectivityService connectivityService;

  // API bağlantı durumu
  final RxBool isOnline = true.obs;
  final RxBool isSyncing = false.obs;

  AnimalsController({
    required this.animalRepository,
    required this.animalTypeRepository,
    required this.measurementRepository,
  });

  final RxList<Animal> animals = <Animal>[].obs;
  final RxList<AnimalType> animalTypes = <AnimalType>[].obs;
  final RxInt selectedTypeId = 0.obs;
  final RxMap<String, Measurement?> lastMeasurements =
      <String, Measurement?>{}.obs;

  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final Rx<SortOption> currentSortOption = SortOption.nameAsc.obs;

  // Grafik verilerini önbellekte tutmak için
  final RxMap<String, List<FlSpot>> _chartDataCache =
      <String, List<FlSpot>>{}.obs;

  @override
  void onInit() {
    super.onInit();

    // Servis enjeksiyonu
    try {
      if (Get.isRegistered<SyncService>()) {
        syncService = Get.find<SyncService>();
      }

      if (Get.isRegistered<ConnectivityService>()) {
        connectivityService = Get.find<ConnectivityService>();
        // Bağlantı durumunu takip et
        ever(connectivityService.isConnected, (connected) {
          isOnline.value = connected;
          if (connected) {
            // Bağlantı varsa bekleyen işlemleri senkronize et
            syncPendingOperations();
          }
        });
      }
    } catch (e) {
      print('Servis enjeksiyonu sırasında hata: $e');
    }

    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchAnimals(),
        fetchAnimalTypes(),
      ]);
    } catch (e) {
      print('Veri yükleme hatası: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterAnimals(String query) {
    searchQuery.value = query;
    update();
  }

  List<Animal> get filteredAnimals {
    final filtered = animals.where((animal) {
      final matchesSearch = animal.name
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          animal.earTag
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          animal.rfid.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesType =
          selectedTypeId.value == 0 || animal.typeId == selectedTypeId.value;
      return matchesSearch && matchesType;
    }).toList();

    return sortAnimals(filtered);
  }

  List<Animal> sortAnimals(List<Animal> animalList) {
    switch (currentSortOption.value) {
      case SortOption.nameAsc:
        animalList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        animalList.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.weightAsc:
        animalList.sort((a, b) {
          final weightA = lastMeasurements[a.rfid]?.weight ?? 0;
          final weightB = lastMeasurements[b.rfid]?.weight ?? 0;
          return weightA.compareTo(weightB);
        });
        break;
      case SortOption.weightDesc:
        animalList.sort((a, b) {
          final weightA = lastMeasurements[a.rfid]?.weight ?? 0;
          final weightB = lastMeasurements[b.rfid]?.weight ?? 0;
          return weightB.compareTo(weightA);
        });
        break;
      case SortOption.latest:
        animalList.sort((a, b) {
          final dateA = lastMeasurements[a.rfid]?.timestamp ?? '';
          final dateB = lastMeasurements[b.rfid]?.timestamp ?? '';
          return dateB.compareTo(dateA);
        });
        break;
      case SortOption.oldest:
        animalList.sort((a, b) {
          final dateA = lastMeasurements[a.rfid]?.timestamp ?? '';
          final dateB = lastMeasurements[b.rfid]?.timestamp ?? '';
          return dateA.compareTo(dateB);
        });
        break;
      case SortOption.weightGain:
        fetchAnimalsByWeightGain();
        break;
    }
    return animalList;
  }

  void changeSortOption(SortOption option) {
    currentSortOption.value = option;
    update();
  }

  Future<void> fetchAnimalsByLastWeight() async {
    try {
      isLoading.value = true;
      // Bu metod AnimalRepository'de tanımlı değilse, normal getAllAnimals kullanıp manuel sıralama yapalım
      animals.value = await animalRepository.getAllAnimals();
      await _fetchLastMeasurements();

      // Son ağırlıklarına göre manuel sıralama
      animals.sort((a, b) {
        final weightA = lastMeasurements[a.rfid]?.weight ?? 0;
        final weightB = lastMeasurements[b.rfid]?.weight ?? 0;
        return weightB.compareTo(weightA); // Ağırlığa göre azalan sıralama
      });
    } catch (e) {
      print('Ağırlığa göre sıralanmış hayvan verisi yüklenirken hata: $e');
      _handleApiError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAnimalsByWeightGain() async {
    try {
      isLoading.value = true;
      animals.value = await animalRepository.getAllAnimalsWithWeightGain();
      await _fetchLastMeasurements();
    } catch (e) {
      print('Kilo artışına göre hayvan verisi yüklenirken hata: $e');
      _handleApiError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchLastMeasurements() async {
    for (var animal in animals) {
      final weightMeasurement =
          await measurementRepository.getLastMeasurementByRfid(animal.rfid);
      lastMeasurements[animal.rfid] = weightMeasurement?.toMeasurement();
    }
  }

  Future<void> refreshAnimals() async {
    try {
      isLoading.value = true;

      // Bağlantı kontrolü
      final hasConnection = await checkConnection();

      if (hasConnection) {
        // Çevrimiçi: Sunucudan en güncel verileri al
        await fetchData();
        Get.snackbar(
          'Güncelleme Başarılı',
          'Veriler sunucudan güncellendi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        // Çevrimdışı: Yerel verilerle devam et
        await fetchData();
        Get.snackbar(
          'Çevrimdışı Mod',
          'İnternet bağlantısı yok. Yerel veriler gösteriliyor.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      _handleApiError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAnimals() async {
    try {
      final animalsResult = await animalRepository.fetchAndSaveAnimals();
      animals.value = animalsResult;

      // Bağlantı durumunu güncelle
      isOnline.value = true;

      // Son ölçümleri yükle
      await _fetchLastMeasurements();
    } catch (e) {
      // API bağlantı hatası durumunda yerel veritabanından al
      isOnline.value = false;
      print('API\'den hayvanlar alınamadı, yerel veritabanı kullanılıyor: $e');

      animals.value = await animalRepository.getAllAnimals();
      await _fetchLastMeasurements();
    }
  }

  Future<void> fetchAnimalTypes() async {
    try {
      animalTypes.value = await animalTypeRepository.getAllAnimalTypes();
    } catch (e) {
      print('Hayvan türleri yüklenirken hata: $e');
      _handleApiError(e);
    }
  }

  Future<bool> addAnimal(Animal animal, {BuildContext? context}) async {
    isLoading.value = true;
    try {
      // Önce API üzerinden eklemeyi dene
      final result = await animalRepository.addAnimalToApi(animal);
      isOnline.value = true;

      if (result != null) {
        animals.add(result);
        return true;
      }
      return false;
    } catch (e) {
      // API bağlantı hatası durumunda yerel veritabanına ekle
      isOnline.value = false;
      print('API\'ye hayvan eklenirken hata: $e');

      if (context != null) {
        // Çevrimdışı mod için kullanıcıya sor
        bool saveOffline = false;

        await ApiErrorDialog.show(
          context: context,
          title: 'Bağlantı Hatası',
          message:
              'İnternet bağlantısı sağlanamadı. Hayvanı çevrimdışı olarak kaydetmek ister misiniz?',
          canSaveOffline: true,
          onOfflineMode: () {
            saveOffline = true;
          },
        );

        if (!saveOffline) return false;
      }

      // Offline işlem kaydı
      if (Get.isRegistered<SyncService>()) {
        final id = await animalRepository.insertAnimal(animal);
        animal.id = id;
        animals.add(animal);

        // Senkronizasyon için işlemi kaydet
        syncService.addPendingOperation("add_animal", animal.toJson());

        return id > 0;
      } else {
        // SyncService yoksa normal yerel ekleme yap
        final id = await animalRepository.insertAnimal(animal);
        animal.id = id;
        animals.add(animal);
        return id > 0;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateAnimal(Animal animal, {BuildContext? context}) async {
    isLoading.value = true;
    try {
      // Önce API üzerinden güncellemeyi dene
      final result = await animalRepository.updateAnimalToApi(animal);
      isOnline.value = true;

      // Yerel listeyi güncelle
      final index = animals.indexWhere((element) => element.id == animal.id);
      if (index != -1) {
        animals[index] = animal;
      }

      return result;
    } catch (e) {
      // API hatası durumunda yerel güncelleme yap
      isOnline.value = false;
      print('API\'de hayvan güncellenirken hata: $e');

      if (context != null) {
        // Çevrimdışı mod için kullanıcıya sor
        bool saveOffline = false;

        await ApiErrorDialog.show(
          context: context,
          title: 'Bağlantı Hatası',
          message:
              'İnternet bağlantısı sağlanamadı. Değişiklikleri çevrimdışı olarak kaydetmek ister misiniz?',
          canSaveOffline: true,
          onOfflineMode: () {
            saveOffline = true;
          },
        );

        if (!saveOffline) return false;
      }

      // Offline işlem kaydı
      if (Get.isRegistered<SyncService>()) {
        await animalRepository.updateAnimal(animal);

        // Yerel listeyi güncelle
        final index = animals.indexWhere((element) => element.id == animal.id);
        if (index != -1) {
          animals[index] = animal;
        }

        // Senkronizasyon için işlemi kaydet
        syncService.addPendingOperation("update_animal", animal.toJson());

        return true;
      } else {
        // SyncService yoksa normal yerel güncelleme yap
        final result = await animalRepository.updateAnimal(animal);

        // Yerel listeyi güncelle
        final index = animals.indexWhere((element) => element.id == animal.id);
        if (index != -1) {
          animals[index] = animal;
        }

        return result > 0;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteAnimal(int id, {BuildContext? context}) async {
    isLoading.value = true;
    try {
      // Önce API'den silmeyi dene
      final result = await animalRepository.deleteAnimalFromApi(id);
      isOnline.value = true;

      if (result) {
        // Yerel listeden kaldır
        animals.removeWhere((animal) => animal.id == id);
        return true;
      }
      return false;
    } catch (e) {
      // API hatası durumunda offline işlem kaydet
      isOnline.value = false;
      print('API\'den hayvan silinirken hata: $e');

      if (context != null) {
        // Çevrimdışı mod için kullanıcıya sor
        bool processOffline = false;

        await ApiErrorDialog.show(
          context: context,
          title: 'Bağlantı Hatası',
          message:
              'İnternet bağlantısı sağlanamadı. Silme işlemini daha sonra gerçekleştirmek üzere kaydetmek ister misiniz?',
          canSaveOffline: true,
          onOfflineMode: () {
            processOffline = true;
          },
        );

        if (!processOffline) return false;
      }

      if (Get.isRegistered<SyncService>()) {
        // Silme işlemini bekleyen işlemlere ekle
        syncService.addPendingOperation("delete_animal", null, id: id);

        // Yerel görünümden kaldır ama veritabanından silme
        animals.removeWhere((animal) => animal.id == id);
        return true;
      } else {
        // Yerel silme işlemini yap
        final result = await animalRepository.deleteAnimal(id);
        animals.removeWhere((animal) => animal.id == id);
        return result > 0;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<FlSpot>> getAnimalWeightData(String rfid) async {
    if (_chartDataCache.containsKey(rfid)) {
      return _chartDataCache[rfid]!;
    }

    try {
      final measurements =
          await measurementRepository.getMeasurementsByRfid(rfid);
      final spots = measurements.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          entry.value.weight,
        );
      }).toList();

      _chartDataCache[rfid] = spots;
      return spots;
    } catch (e) {
      print('Grafik verisi yüklenirken hata: $e');
      return [];
    }
  }

  // Bekleyen işlemleri senkronize et
  Future<void> syncPendingOperations() async {
    if (!Get.isRegistered<SyncService>() || isSyncing.value) return;

    isSyncing.value = true;
    try {
      final success = await syncService.syncPendingOperations();

      if (success && syncService.getPendingOperationsCount() == 0) {
        // Güncel verileri yeniden yükle
        await fetchData();
      }
    } catch (e) {
      print('Senkronizasyon sırasında hata: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  // Bağlantı durumunu kontrol et
  Future<bool> checkConnection() async {
    try {
      if (Get.isRegistered<ConnectivityService>()) {
        final isConnected = await connectivityService.checkConnection();
        isOnline.value = isConnected;
        return isConnected;
      } else if (Get.isRegistered<SyncService>()) {
        final isConnected = await syncService.checkConnection();
        isOnline.value = isConnected;
        return isConnected;
      } else {
        // API'ye test isteği gönder
        final response = await apiService.getAnimals();
        isOnline.value = response.error == null;
        return isOnline.value;
      }
    } catch (e) {
      print('Bağlantı kontrolü sırasında hata: $e');
      isOnline.value = false;
      return false;
    }
  }

  // API hatalarını işle
  void _handleApiError(dynamic error, {BuildContext? context}) {
    if (context == null) {
      // Context yoksa basit bir snackbar göster
      Get.snackbar(
        'Hata',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // ApiError türünde ise özel işlem yap
    if (error is ApiError) {
      ApiErrorHandler.handleApiError(
        context,
        error,
        onRetry: () => fetchData(),
      );
    } else {
      // Genel hata
      Get.snackbar(
        'Hata',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
