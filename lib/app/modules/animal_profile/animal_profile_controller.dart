import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:animaltracker/app/data/models/animal.dart';
import 'package:animaltracker/app/data/models/animal_type.dart';
import 'package:animaltracker/app/data/repositories/animal_repository.dart';
import 'package:animaltracker/app/data/repositories/animal_type_repository.dart';
import 'package:animaltracker/app/data/repositories/measurement_repository.dart';
import 'package:animaltracker/app/modules/weight_measurement/weight_measurement_bluetooth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animaltracker/app/data/models/device.dart';

// Ağırlık grafiği için filtre seçenekleri
enum WeightChartFilter {
  last7Days,
  last30Days,
  last90Days,
  last6Months,
  lastYear,
  custom
}

// Hayvan türleri için enum oluşturma
enum AnimalTypeEnum {
  inek,
  buzagi,
  dana,
  tosun,
  duve,
  boga,
  koyun,
  kuzu,
  keci,
  oglak,
}

// Enum extension
extension AnimalTypeExtension on AnimalTypeEnum {
  String get displayName {
    switch (this) {
      case AnimalTypeEnum.inek:
        return 'İnek';
      case AnimalTypeEnum.buzagi:
        return 'Buzağı';
      case AnimalTypeEnum.dana:
        return 'Dana';
      case AnimalTypeEnum.tosun:
        return 'Tosun';
      case AnimalTypeEnum.duve:
        return 'Düve';
      case AnimalTypeEnum.boga:
        return 'Boğa';
      case AnimalTypeEnum.koyun:
        return 'Koyun';
      case AnimalTypeEnum.kuzu:
        return 'Kuzu';
      case AnimalTypeEnum.keci:
        return 'Keçi';
      case AnimalTypeEnum.oglak:
        return 'Oğlak';
    }
  }

  int get id {
    return this.index + 1; // 1'den başlayarak id ata
  }
}

class AnimalProfileController extends GetxController {
  final AnimalRepository animalRepository;
  final AnimalTypeRepository animalTypeRepository;
  final MeasurementRepository measurementRepository;
  final WeightMeasurementBluetooth? bluetoothController;

  AnimalProfileController({
    required this.animalRepository,
    required this.animalTypeRepository,
    required this.measurementRepository,
    this.bluetoothController,
  });

  final Rx<Animal?> animal = Rx<Animal?>(null);
  final RxString animalTypeName = ''.obs;
  final RxList<AnimalType> animalTypes = <AnimalType>[].obs;
  final RxInt selectedTypeId = 0.obs;
  final Rx<File?> animalImage = Rx<File?>(null);
  final RxList<WeightMeasurement> weightHistory = <WeightMeasurement>[].obs;
  final RxString notes = ''.obs;

  // Parent animal information
  final Rx<Animal?> motherAnimal = Rx<Animal?>(null);
  final Rx<Animal?> fatherAnimal = Rx<Animal?>(null);

  // Child animals
  final RxList<Animal> offspring = <Animal>[].obs;

  // For weight display toggle
  final RxBool showWeightAsChart = true.obs;

  // Bluetooth RFID okuma için yeni değişkenler
  final RxBool isBluetoothScanning = false.obs;
  final RxBool isBluetoothConnecting = false.obs;
  final RxString scannedRfid = ''.obs;
  final RxList<Device> availableDevices = <Device>[].obs;
  final RxBool isDeviceConnected = false.obs;
  final Rx<Device?> connectedDevice = Rx<Device?>(null);

  final Rx<WeightChartFilter> selectedFilter = WeightChartFilter.last7Days.obs;
  final Rx<DateTime?> customStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> customEndDate = Rx<DateTime?>(null);

  final RxMap<String, List<AnimalType>> categorizedTypes =
      <String, List<AnimalType>>{}.obs;
  final RxList<String> categories = <String>[].obs;

  // Filtrelenmiş ağırlık verileri
  RxList<WeightMeasurement> get filteredWeightHistory {
    final now = DateTime.now();
    final measurements = weightHistory.toList();

    switch (selectedFilter.value) {
      case WeightChartFilter.last7Days:
        final cutoff = now.subtract(const Duration(days: 7));
        return measurements.where((m) => m.date.isAfter(cutoff)).toList().obs;
      case WeightChartFilter.last30Days:
        final cutoff = now.subtract(const Duration(days: 30));
        return measurements.where((m) => m.date.isAfter(cutoff)).toList().obs;
      case WeightChartFilter.last90Days:
        final cutoff = now.subtract(const Duration(days: 90));
        return measurements.where((m) => m.date.isAfter(cutoff)).toList().obs;
      case WeightChartFilter.last6Months:
        final cutoff = DateTime(now.year, now.month - 6, now.day);
        return measurements.where((m) => m.date.isAfter(cutoff)).toList().obs;
      case WeightChartFilter.lastYear:
        final cutoff = DateTime(now.year - 1, now.month, now.day);
        return measurements.where((m) => m.date.isAfter(cutoff)).toList().obs;
      case WeightChartFilter.custom:
        if (customStartDate.value != null && customEndDate.value != null) {
          return measurements
              .where((m) =>
                  m.date.isAfter(customStartDate.value!) &&
                  m.date.isBefore(
                      customEndDate.value!.add(const Duration(days: 1))))
              .toList()
              .obs;
        }
        return measurements.obs;
    }
  }

  // Ağırlık değişim istatistikleri
  Map<String, double> getWeightStats() {
    final measurements = filteredWeightHistory;
    if (measurements.isEmpty) {
      return {
        'minWeight': 0,
        'maxWeight': 0,
        'avgWeight': 0,
        'totalChange': 0,
        'avgChange': 0,
      };
    }

    final weights = measurements.map((m) => m.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final avgWeight = weights.reduce((a, b) => a + b) / weights.length;

    double totalChange = 0;
    double avgChange = 0;

    if (measurements.length > 1) {
      for (int i = 1; i < measurements.length; i++) {
        totalChange += measurements[i].weight - measurements[i - 1].weight;
      }
      avgChange = totalChange / (measurements.length - 1);
    }

    return {
      'minWeight': minWeight,
      'maxWeight': maxWeight,
      'avgWeight': avgWeight,
      'totalChange': totalChange,
      'avgChange': avgChange,
    };
  }

  // Filtre değiştirme
  void changeFilter(WeightChartFilter filter) {
    selectedFilter.value = filter;
    update();
  }

  // Özel tarih aralığı ayarlama
  void setCustomDateRange(DateTime start, DateTime end) {
    customStartDate.value = start;
    customEndDate.value = end;
    selectedFilter.value = WeightChartFilter.custom;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    animal.value = Get.arguments as Animal;
    _loadAnimalData();
    _setupBluetoothListeners();
  }

  void _setupBluetoothListeners() {
    if (bluetoothController != null) {
      // Bluetooth controller'dan RFID değişimlerini dinle
      ever(bluetoothController!.currentRfid, (rfid) {
        if (rfid.isNotEmpty) {
          scannedRfid.value = rfid;
        }
      });

      // Cihaz bağlantı durumunu takip et
      ever(bluetoothController!.isDeviceConnected, (connected) {
        isDeviceConnected.value = connected;
      });

      // Tarama durumunu takip et
      ever(bluetoothController!.isScanning, (scanning) {
        isBluetoothScanning.value = scanning;
      });

      // Bağlanma durumunu takip et
      ever(bluetoothController!.isConnecting, (connecting) {
        isBluetoothConnecting.value = connecting;
      });

      // Cihaz listesini takip et
      ever(bluetoothController!.availableDevices, (devices) {
        availableDevices.value = devices;
      });

      // Bağlı cihazı takip et
      ever(bluetoothController!.connectedDevice, (device) {
        connectedDevice.value = device;
      });
    }
  }

  // Bluetooth cihazlarını tara
  Future<void> scanBluetoothDevices() async {
    if (bluetoothController != null) {
      await bluetoothController!.startScan();
    }
  }

  // Bluetooth cihazına bağlan
  Future<void> connectToDevice(Device device) async {
    if (bluetoothController != null) {
      try {
        await bluetoothController!.connectToDevice(device);
        Get.snackbar('Başarılı', 'Cihaza bağlandı: ${device.name}');
      } catch (e) {
        Get.snackbar('Hata', 'Cihaza bağlanırken hata oluştu: $e');
      }
    }
  }

  // Bluetooth cihazı bağlantısını kes
  Future<void> disconnectDevice() async {
    if (bluetoothController != null && isDeviceConnected.value) {
      await bluetoothController!.disconnectDevice();
      Get.snackbar('Bilgi', 'Cihaz bağlantısı kesildi');
    }
  }

  // RFID doğruluğunu kontrol et (en az 8 karakter olmalı)
  bool isValidRfid(String rfid) {
    return rfid.length >= 8;
  }

  Future<void> _loadAnimalData() async {
    await Future.wait([
      _loadAnimalTypeName(),
      _loadAnimalTypes(),
      _loadAnimalImage(),
      _loadWeightHistory(),
      _loadNotes(),
      _loadParentAnimals(),
      _loadOffspringAnimals(),
    ]);
  }

  Future<void> _loadAnimalTypeName() async {
    final animalType =
        await animalTypeRepository.getAnimalTypeById(animal.value!.typeId);
    animalTypeName.value = animalType?.name ?? 'Bilinmeyen Tür';
  }

  Future<void> _loadAnimalTypes() async {
    try {
      // Kategorilere göre hayvan türlerini al
      categorizedTypes.value =
          await animalTypeRepository.getAnimalTypesByCategories();
      categories.value = categorizedTypes.keys.toList();

      // Tüm türleri de al
      animalTypes.value = await animalTypeRepository.getAllAnimalTypes();
      selectedTypeId.value = animal.value!.typeId;
    } catch (e) {
      print('Hayvan türleri yüklenirken hata: $e');
      Get.snackbar(
        'Hata',
        'Hayvan türleri yüklenirken bir hata oluştu',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  Future<void> _loadAnimalImage() async {
    // Implement image loading logic here
    // For example, you might load the image from a file or a network location
    // animalImage.value = File('path/to/image');
  }

  Future<void> _loadWeightHistory() async {
    final measurements = await measurementRepository
        .getMeasurementsByAnimalId(animal.value!.id!);
    weightHistory.value = measurements
        .map((m) => WeightMeasurement(
            weight: m.weight,
            date: DateTime.parse(m.measurementDate.toIso8601String())))
        .toList();
    // Sort measurements by date in descending order (newest first)
    weightHistory.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _loadNotes() async {
    // Implement notes loading logic here
    // notes.value = await notesRepository.getNotesByAnimalId(animal.value!.id!);
  }

  Future<void> _loadParentAnimals() async {
    if (animal.value?.motherRfid != null &&
        animal.value!.motherRfid!.isNotEmpty) {
      motherAnimal.value =
          await animalRepository.getAnimalByRfid(animal.value!.motherRfid!);
    }

    if (animal.value?.fatherRfid != null &&
        animal.value!.fatherRfid!.isNotEmpty) {
      fatherAnimal.value =
          await animalRepository.getAnimalByRfid(animal.value!.fatherRfid!);
    }
  }

  Future<void> _loadOffspringAnimals() async {
    if (animal.value?.rfid != null) {
      offspring.value =
          await animalRepository.getOffspringByParentRfid(animal.value!.rfid);
    }
  }

  Future<void> updateAnimal({
    required String name,
    required String earTag,
    required String rfid,
    required int typeId,
    String? motherRfid,
    String? fatherRfid,
  }) async {
    // RFID doğrulama kontrolü
    if (!isValidRfid(rfid)) {
      Get.snackbar('Hata', 'Geçersiz RFID değeri. En az 8 karakter olmalıdır.');
      return;
    }

    final updatedAnimal = Animal(
      id: animal.value!.id,
      name: name,
      earTag: earTag,
      rfid: rfid,
      typeId: typeId,
      motherRfid: motherRfid,
      fatherRfid: fatherRfid,
    );
    await animalRepository.updateAnimal(updatedAnimal);
    animal.value = updatedAnimal;
    await _loadAnimalData();
    Get.snackbar('Başarılı', 'Hayvan bilgileri güncellendi');
  }

  Future<void> deleteAnimal() async {
    await animalRepository.deleteAnimal(animal.value!.id!);
    Get.back();
    Get.snackbar('Başarılı', 'Hayvan silindi');
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      animalImage.value = File(pickedFile.path);
      // Implement image saving logic here
    }
  }

  String calculateAge() {
    // Implement age calculation logic here
    return 'N/A';
  }

  void addWeightMeasurement(double weight) {
    final measurement = WeightMeasurement(weight: weight, date: DateTime.now());
    weightHistory.add(measurement);
    // Implement saving logic here
    // measurementRepository.insertMeasurement(Measurement(...));
  }

  // Grafik verilerini güncelleme
  List<FlSpot> getWeightChartData() {
    return filteredWeightHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();
  }

  // Grafik için maksimum ağırlık değeri
  double getMaxWeight() {
    if (filteredWeightHistory.isEmpty) return 100;
    return filteredWeightHistory
            .map((m) => m.weight)
            .reduce((a, b) => a > b ? a : b) *
        1.2;
  }

  void updateNotes(String newNotes) {
    notes.value = newNotes;
    // Implement saving logic here
    // notesRepository.updateNotes(animal.value!.id!, newNotes);
  }

  void toggleWeightDisplay() {
    showWeightAsChart.value = !showWeightAsChart.value;
  }

  // Ebeveyn hayvan isimlerini getirme metodları
  String get motherName => motherAnimal.value?.name ?? 'Bilinmiyor';
  String get fatherName => fatherAnimal.value?.name ?? 'Bilinmiyor';

  // Hayvan türüne göre renk ve simge getiren metodlar
  Color getAnimalTypeColor() {
    switch (animal.value!.typeId) {
      case 1:
        return const Color(0xFF4C6EF5); // İnek - Mavi
      case 2:
        return const Color(0xFF82C3EC); // Buzağı - Açık Mavi
      case 3:
        return const Color(0xFF748DA6); // Dana - Gri Mavi
      case 4:
        return const Color(0xFF4682A9); // Tosun - Deniz Mavisi
      case 5:
        return const Color(0xFF9376E0); // Düve - Mor
      case 6:
        return const Color(0xFF554994); // Boğa - Koyu Mor
      case 7:
        return const Color(0xFF94A684); // Koyun - Yeşil
      case 8:
        return const Color(0xFFB5CB99); // Kuzu - Açık Yeşil
      case 9:
        return const Color(0xFFF29727); // Keçi - Turuncu
      case 10:
        return const Color(0xFFFFB84C); // Oğlak - Açık Turuncu
      default:
        return const Color(0xFF6C757D); // Varsayılan - Gri
    }
  }

  IconData getAnimalTypeIcon() {
    switch (animal.value!.typeId) {
      case 1:
        return Icons.pets; // İnek
      case 2:
        return Icons.child_friendly; // Buzağı
      case 3:
        return Icons.pets; // Dana
      case 4:
        return Icons.pets; // Tosun
      case 5:
        return Icons.pets; // Düve
      case 6:
        return Icons.pets; // Boğa
      case 7:
        return Icons.pets; // Koyun
      case 8:
        return Icons.child_friendly; // Kuzu
      case 9:
        return Icons.pets; // Keçi
      case 10:
        return Icons.child_friendly; // Oğlak
      default:
        return Icons.help_outline; // Varsayılan
    }
  }

  List<AnimalType> getAnimalTypesByCategory(String category) {
    return categorizedTypes[category] ?? [];
  }

  @override
  void onClose() {
    if (bluetoothController != null && isDeviceConnected.value) {
      bluetoothController!.disconnectDevice();
    }
    super.onClose();
  }
}

class WeightMeasurement {
  final double weight;
  final DateTime date;

  WeightMeasurement({required this.weight, required this.date});
}
