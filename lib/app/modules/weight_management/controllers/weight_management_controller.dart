import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:animaltracker/app/data/models/weight_measurement.dart';
import 'package:animaltracker/app/data/models/birth_weight_measurement.dart';
import 'package:animaltracker/app/data/models/weaning_weight_measurement.dart';
import 'package:animaltracker/app/services/api/weight_service.dart';

enum WeightMeasurementType { normal, weaning, birth }

class WeightManagementController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final WeightService _weightService = Get.find<WeightService>();

  late TabController tabController;

  // Observable lists for measurements
  final RxList<WeightMeasurement> normalWeightMeasurements =
      <WeightMeasurement>[].obs;
  final RxList<WeaningWeightMeasurement> weaningWeightMeasurements =
      <WeaningWeightMeasurement>[].obs;
  final RxList<BirthWeightMeasurement> birthWeightMeasurements =
      <BirthWeightMeasurement>[].obs;

  // Copy of the original data for filtering
  final List<WeightMeasurement> _originalNormalMeasurements =
      <WeightMeasurement>[];
  final List<WeaningWeightMeasurement> _originalWeaningMeasurements =
      <WeaningWeightMeasurement>[];
  final List<BirthWeightMeasurement> _originalBirthMeasurements =
      <BirthWeightMeasurement>[];

  // Loading state
  final RxBool isLoading = false.obs;

  // Offline measurements to be synchronized
  final List<WeightMeasurement> _offlineNormalMeasurements =
      <WeightMeasurement>[];
  final List<WeaningWeightMeasurement> _offlineWeaningMeasurements =
      <WeaningWeightMeasurement>[];
  final List<BirthWeightMeasurement> _offlineBirthMeasurements =
      <BirthWeightMeasurement>[];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    loadAllData();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Load all data
  Future<void> loadAllData() async {
    isLoading.value = true;

    await refreshNormalWeightData();
    await refreshWeaningWeightData();
    await refreshBirthWeightData();

    isLoading.value = false;
  }

  // Normal weight data operations
  Future<void> refreshNormalWeightData() async {
    final response = await _weightService.getNormalWeightMeasurements();
    if (response.data != null) {
      normalWeightMeasurements.value = response.data!;
      _originalNormalMeasurements.clear();
      _originalNormalMeasurements.addAll(response.data!);
    } else {
      Get.snackbar(
          'Hata', 'Ağırlık ölçümleri alınamadı: ${response.error?.message}');
    }
  }

  Future<void> addNormalWeightMeasurement(WeightMeasurement measurement) async {
    isLoading.value = true;

    // Check for internet connection
    final bool isOnline = await checkInternetConnection();

    if (isOnline) {
      final response =
          await _weightService.addNormalWeightMeasurement(measurement);
      if (response.data != null) {
        normalWeightMeasurements.add(response.data!);
        _originalNormalMeasurements.add(response.data!);
        Get.back(); // Close dialog
        Get.snackbar('Başarılı', 'Ağırlık ölçümü başarıyla kaydedildi');
      } else {
        Get.snackbar(
            'Hata', 'Ağırlık ölçümü kaydedilemedi: ${response.error?.message}');
      }
    } else {
      // Store for later synchronization
      _offlineNormalMeasurements.add(measurement);
      normalWeightMeasurements.add(measurement);
      _originalNormalMeasurements.add(measurement);
      Get.back(); // Close dialog
      Get.snackbar('Bilgi',
          'Ağırlık ölçümü çevrimdışı kaydedildi. İnternet bağlantısı olduğunda senkronize edilecek.');
    }

    isLoading.value = false;
  }

  Future<void> updateNormalWeightMeasurement(
      int id, WeightMeasurement measurement) async {
    isLoading.value = true;

    final response =
        await _weightService.updateNormalWeightMeasurement(id, measurement);
    if (response.data != null) {
      final index =
          normalWeightMeasurements.indexWhere((item) => item.id == id);
      if (index != -1) {
        normalWeightMeasurements[index] = response.data!;

        final origIndex =
            _originalNormalMeasurements.indexWhere((item) => item.id == id);
        if (origIndex != -1) {
          _originalNormalMeasurements[origIndex] = response.data!;
        }
      }
      Get.back(); // Close dialog
      Get.snackbar('Başarılı', 'Ağırlık ölçümü başarıyla güncellendi');
    } else {
      Get.snackbar(
          'Hata', 'Ağırlık ölçümü güncellenemedi: ${response.error?.message}');
    }

    isLoading.value = false;
  }

  Future<void> deleteNormalWeightMeasurement(int id) async {
    isLoading.value = true;

    final response = await _weightService.deleteNormalWeightMeasurement(id);
    if (response.data == true) {
      normalWeightMeasurements.removeWhere((item) => item.id == id);
      _originalNormalMeasurements.removeWhere((item) => item.id == id);
      Get.snackbar('Başarılı', 'Ağırlık ölçümü başarıyla silindi');
    } else {
      Get.snackbar(
          'Hata', 'Ağırlık ölçümü silinemedi: ${response.error?.message}');
    }

    isLoading.value = false;
  }

  // Weaning weight data operations
  Future<void> refreshWeaningWeightData() async {
    final response = await _weightService.getWeaningWeightMeasurements();
    if (response.data != null) {
      weaningWeightMeasurements.value = response.data!;
      _originalWeaningMeasurements.clear();
      _originalWeaningMeasurements.addAll(response.data!);
    } else {
      Get.snackbar('Hata',
          'Sütten kesim ağırlık ölçümleri alınamadı: ${response.error?.message}');
    }
  }

  Future<void> addWeaningWeightMeasurement(
      WeaningWeightMeasurement measurement) async {
    isLoading.value = true;

    // Check for internet connection
    final bool isOnline = await checkInternetConnection();

    if (isOnline) {
      final response =
          await _weightService.addWeaningWeightMeasurement(measurement);
      if (response.data != null) {
        weaningWeightMeasurements.add(response.data!);
        _originalWeaningMeasurements.add(response.data!);
        Get.back(); // Close dialog
        Get.snackbar(
            'Başarılı', 'Sütten kesim ağırlık ölçümü başarıyla kaydedildi');
      } else {
        Get.snackbar('Hata',
            'Sütten kesim ağırlık ölçümü kaydedilemedi: ${response.error?.message}');
      }
    } else {
      // Store for later synchronization
      _offlineWeaningMeasurements.add(measurement);
      weaningWeightMeasurements.add(measurement);
      _originalWeaningMeasurements.add(measurement);
      Get.back(); // Close dialog
      Get.snackbar('Bilgi',
          'Sütten kesim ağırlık ölçümü çevrimdışı kaydedildi. İnternet bağlantısı olduğunda senkronize edilecek.');
    }

    isLoading.value = false;
  }

  Future<void> updateWeaningWeightMeasurement(
      int id, WeaningWeightMeasurement measurement) async {
    isLoading.value = true;

    final response =
        await _weightService.updateWeaningWeightMeasurement(id, measurement);
    if (response.data != null) {
      final index =
          weaningWeightMeasurements.indexWhere((item) => item.id == id);
      if (index != -1) {
        weaningWeightMeasurements[index] = response.data!;

        final origIndex =
            _originalWeaningMeasurements.indexWhere((item) => item.id == id);
        if (origIndex != -1) {
          _originalWeaningMeasurements[origIndex] = response.data!;
        }
      }
      Get.back(); // Close dialog
      Get.snackbar(
          'Başarılı', 'Sütten kesim ağırlık ölçümü başarıyla güncellendi');
    } else {
      Get.snackbar('Hata',
          'Sütten kesim ağırlık ölçümü güncellenemedi: ${response.error?.message}');
    }

    isLoading.value = false;
  }

  Future<void> deleteWeaningWeightMeasurement(int id) async {
    isLoading.value = true;

    final response = await _weightService.deleteWeaningWeightMeasurement(id);
    if (response.data == true) {
      weaningWeightMeasurements.removeWhere((item) => item.id == id);
      _originalWeaningMeasurements.removeWhere((item) => item.id == id);
      Get.snackbar('Başarılı', 'Sütten kesim ağırlık ölçümü başarıyla silindi');
    } else {
      Get.snackbar('Hata',
          'Sütten kesim ağırlık ölçümü silinemedi: ${response.error?.message}');
    }

    isLoading.value = false;
  }

  // Birth weight data operations
  Future<void> refreshBirthWeightData() async {
    final response = await _weightService.getBirthWeightMeasurements();
    if (response.data != null) {
      birthWeightMeasurements.value = response.data!;
      _originalBirthMeasurements.clear();
      _originalBirthMeasurements.addAll(response.data!);
    } else {
      Get.snackbar('Hata',
          'Doğum ağırlık ölçümleri alınamadı: ${response.error?.message}');
    }
  }

  Future<void> addBirthWeightMeasurement(
      BirthWeightMeasurement measurement) async {
    isLoading.value = true;

    // Check for internet connection
    final bool isOnline = await checkInternetConnection();

    if (isOnline) {
      final response =
          await _weightService.addBirthWeightMeasurement(measurement);
      if (response.data != null) {
        birthWeightMeasurements.add(response.data!);
        _originalBirthMeasurements.add(response.data!);
        Get.back(); // Close dialog
        Get.snackbar('Başarılı', 'Doğum ağırlık ölçümü başarıyla kaydedildi');
      } else {
        Get.snackbar('Hata',
            'Doğum ağırlık ölçümü kaydedilemedi: ${response.error?.message}');
      }
    } else {
      // Store for later synchronization
      _offlineBirthMeasurements.add(measurement);
      birthWeightMeasurements.add(measurement);
      _originalBirthMeasurements.add(measurement);
      Get.back(); // Close dialog
      Get.snackbar('Bilgi',
          'Doğum ağırlık ölçümü çevrimdışı kaydedildi. İnternet bağlantısı olduğunda senkronize edilecek.');
    }

    isLoading.value = false;
  }

  Future<void> updateBirthWeightMeasurement(
      int id, BirthWeightMeasurement measurement) async {
    isLoading.value = true;

    final response =
        await _weightService.updateBirthWeightMeasurement(id, measurement);
    if (response.data != null) {
      final index = birthWeightMeasurements.indexWhere((item) => item.id == id);
      if (index != -1) {
        birthWeightMeasurements[index] = response.data!;

        final origIndex =
            _originalBirthMeasurements.indexWhere((item) => item.id == id);
        if (origIndex != -1) {
          _originalBirthMeasurements[origIndex] = response.data!;
        }
      }
      Get.back(); // Close dialog
      Get.snackbar('Başarılı', 'Doğum ağırlık ölçümü başarıyla güncellendi');
    } else {
      Get.snackbar('Hata',
          'Doğum ağırlık ölçümü güncellenemedi: ${response.error?.message}');
    }

    isLoading.value = false;
  }

  Future<void> deleteBirthWeightMeasurement(int id) async {
    isLoading.value = true;

    final response = await _weightService.deleteBirthWeightMeasurement(id);
    if (response.data == true) {
      birthWeightMeasurements.removeWhere((item) => item.id == id);
      _originalBirthMeasurements.removeWhere((item) => item.id == id);
      Get.snackbar('Başarılı', 'Doğum ağırlık ölçümü başarıyla silindi');
    } else {
      Get.snackbar('Hata',
          'Doğum ağırlık ölçümü silinemedi: ${response.error?.message}');
    }

    isLoading.value = false;
  }

  // Synchronize offline data
  Future<void> synchronizeData() async {
    if (_offlineNormalMeasurements.isEmpty &&
        _offlineWeaningMeasurements.isEmpty &&
        _offlineBirthMeasurements.isEmpty) {
      Get.snackbar('Bilgi', 'Senkronize edilecek veri yok');
      return;
    }

    isLoading.value = true;

    final response = await _weightService.synchronizeOfflineMeasurements(
        _offlineNormalMeasurements,
        _offlineWeaningMeasurements,
        _offlineBirthMeasurements);

    if (response.data == true) {
      _offlineNormalMeasurements.clear();
      _offlineWeaningMeasurements.clear();
      _offlineBirthMeasurements.clear();

      await loadAllData();

      Get.snackbar('Başarılı', 'Veriler başarıyla senkronize edildi');
    } else {
      Get.snackbar('Hata', 'Senkronizasyon hatası: ${response.error?.message}');
    }

    isLoading.value = false;
  }

  // Helper methods for internet connectivity
  Future<bool> checkInternetConnection() async {
    // Placeholder - in a real app, implement connectivity check
    return true;
  }

  // Helper methods for UI
  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String getAnimalNameById(int? animalId) {
    if (animalId == null) return 'Bilinmeyen';
    // In a real app, this would fetch the animal name from a repository
    return 'Hayvan #$animalId';
  }

  // Filter and sort methods
  void filterByDate() {
    // Implement date filtering - show a date picker and filter lists
    Get.dialog(
      AlertDialog(
        title: const Text('Tarih Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  _filterBySelectedDate(picked);
                  Get.back();
                }
              },
              child: const Text('Tarih Seç'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _filterBySelectedDate(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Filter normal measurements
    normalWeightMeasurements.value = _originalNormalMeasurements.where((m) {
      final measurementDate =
          DateFormat('yyyy-MM-dd').format(m.measurementDate);
      return measurementDate == formattedDate;
    }).toList();

    // Filter weaning measurements
    weaningWeightMeasurements.value = _originalWeaningMeasurements.where((m) {
      final measurementDate =
          DateFormat('yyyy-MM-dd').format(m.measurementDate);
      return measurementDate == formattedDate;
    }).toList();

    // Filter birth measurements
    birthWeightMeasurements.value = _originalBirthMeasurements.where((m) {
      final measurementDate =
          DateFormat('yyyy-MM-dd').format(m.measurementDate);
      return measurementDate == formattedDate;
    }).toList();
  }

  void filterByAnimal() {
    // In a real app, show a list of animals to select
    Get.dialog(
      AlertDialog(
        title: const Text('Hayvan Seçin'),
        content: const Text('Bu özellik henüz uygulanmadı.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void sortByWeightAscending() {
    normalWeightMeasurements.sort((a, b) => a.weight.compareTo(b.weight));
    weaningWeightMeasurements.sort((a, b) => a.weight.compareTo(b.weight));
    birthWeightMeasurements.sort((a, b) => a.weight.compareTo(b.weight));
  }

  void sortByWeightDescending() {
    normalWeightMeasurements.sort((a, b) => b.weight.compareTo(a.weight));
    weaningWeightMeasurements.sort((a, b) => b.weight.compareTo(a.weight));
    birthWeightMeasurements.sort((a, b) => b.weight.compareTo(a.weight));
  }

  void clearFilters() {
    normalWeightMeasurements.value = List.from(_originalNormalMeasurements);
    weaningWeightMeasurements.value = List.from(_originalWeaningMeasurements);
    birthWeightMeasurements.value = List.from(_originalBirthMeasurements);
  }
}
