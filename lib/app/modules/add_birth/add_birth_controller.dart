import 'package:get/get.dart';
import 'package:animaltracker/app/data/models/animal.dart';
import 'package:animaltracker/app/data/models/animal_type.dart';
import 'package:animaltracker/app/data/models/weight_measurement.dart';
import 'package:animaltracker/app/data/repositories/animal_repository.dart';
import 'package:animaltracker/app/data/repositories/animal_type_repository.dart';
import 'package:animaltracker/app/data/repositories/measurement_repository.dart';
import 'package:animaltracker/app/modules/weight_measurement/weight_measurement_bluetooth.dart';
import 'package:animaltracker/app/data/models/device.dart';
import 'package:flutter/material.dart';

class AddBirthController extends GetxController {
  final AnimalRepository animalRepository;
  final AnimalTypeRepository animalTypeRepository;
  final MeasurementRepository measurementRepository;
  final WeightMeasurementBluetooth? bluetoothController;

  AddBirthController({
    required this.animalRepository,
    required this.animalTypeRepository,
    required this.measurementRepository,
    this.bluetoothController,
  });

  final RxList<AnimalType> animalTypes = <AnimalType>[].obs;
  final RxInt selectedTypeId = 0.obs;
  final RxMap<String, List<AnimalType>> categorizedTypes =
      <String, List<AnimalType>>{}.obs;
  final RxList<String> categories = <String>[].obs;

  // Bluetooth RFID okuma için değişkenler
  final RxBool isBluetoothScanning = false.obs;
  final RxBool isBluetoothConnecting = false.obs;
  final RxString scannedRfid = ''.obs;
  final RxString scannedMotherRfid = ''.obs;
  final RxString scannedFatherRfid = ''.obs;
  final RxList<Device> availableDevices = <Device>[].obs;
  final RxBool isDeviceConnected = false.obs;
  final Rx<Device?> connectedDevice = Rx<Device?>(null);

  // Anne ve baba kontrolü
  final RxBool isMotherValid = false.obs;
  final RxBool isFatherValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnimalTypes();
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

  // Anne RFID doğrulama
  Future<bool> validateMotherRfid(String rfid) async {
    if (rfid.isEmpty) {
      isMotherValid.value = false;
      return false;
    }

    final mother = await animalRepository.getAnimalByRfid(rfid);
    isMotherValid.value = mother != null;
    return isMotherValid.value;
  }

  // Baba RFID doğrulama
  Future<bool> validateFatherRfid(String rfid) async {
    if (rfid.isEmpty) {
      isFatherValid.value = false;
      return false;
    }

    final father = await animalRepository.getAnimalByRfid(rfid);
    isFatherValid.value = father != null;
    return isFatherValid.value;
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

  // RFID doğruluğunu kontrol et
  bool isValidRfid(String rfid) {
    if (rfid.isEmpty) return false;
    if (rfid.length < 8) return false;
    // Sadece alfanümerik karakterlere izin ver
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(rfid);
  }

  Future<void> fetchAnimalTypes() async {
    try {
      // Sadece yeni doğan hayvan türlerini al
      animalTypes.value = await animalTypeRepository.getNewbornAnimalTypes();

      // Varsayılan seçim
      if (animalTypes.isNotEmpty) {
        selectedTypeId.value = animalTypes.first.id!;
      }
    } catch (e) {
      print('Hayvan türleri yüklenirken hata: $e');
      Get.snackbar(
        'Hata',
        'Hayvan türleri yüklenirken bir hata oluştu',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  List<AnimalType> getAnimalTypesByCategory(String category) {
    return categorizedTypes[category] ?? [];
  }

  Future<void> addAnimal(
    String name,
    String earTag,
    String? rfid,
    String motherRfid,
    String fatherRfid,
    double? birthWeight,
  ) async {
    // Validate required fields
    if (name.isEmpty ||
        earTag.isEmpty ||
        motherRfid.isEmpty ||
        fatherRfid.isEmpty) {
      Get.snackbar(
        'Hata',
        'Lütfen tüm zorunlu alanları doldurun (İsim, Kulak Küpe No, Anne RFID, Baba RFID)',
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (selectedTypeId.value == 0) {
      Get.snackbar(
        'Hata',
        'Lütfen bir hayvan türü seçin',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
      return;
    }

    // RFID doğrulama kontrolü (eğer girilmişse)
    if (rfid != null && rfid.isNotEmpty && !isValidRfid(rfid)) {
      Get.snackbar(
        'Hata',
        'Geçersiz RFID değeri. RFID en az 8 karakter olmalıdır.',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
      return;
    }

    // RFID benzersizlik kontrolü (eğer girilmişse)
    if (rfid != null && rfid.isNotEmpty) {
      final existingAnimal = await animalRepository.getAnimalByRfid(rfid);
      if (existingAnimal != null) {
        Get.snackbar(
          'Hata',
          'Bu RFID numarası ile kayıtlı bir hayvan zaten var: ${existingAnimal.name}',
          backgroundColor: Colors.red.withOpacity(0.1),
        );
        return;
      }
    }

    // Anne RFID kontrolü
    final motherAnimal = await animalRepository.getAnimalByRfid(motherRfid);
    if (motherAnimal == null) {
      Get.snackbar(
        'Hata',
        'Belirtilen Anne RFID numarası ile kayıtlı bir hayvan bulunamadı',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
      return;
    }

    // Baba RFID kontrolü
    final fatherAnimal = await animalRepository.getAnimalByRfid(fatherRfid);
    if (fatherAnimal == null) {
      Get.snackbar(
        'Hata',
        'Belirtilen Baba RFID numarası ile kayıtlı bir hayvan bulunamadı',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
      return;
    }

    final animal = Animal(
      name: name,
      typeId: selectedTypeId.value,
      earTag: earTag,
      rfid: rfid ?? '',
      motherRfid: motherRfid,
      fatherRfid: fatherRfid,
    );

    try {
      final animalId = await animalRepository.insertAnimal(animal);

      // Doğum ağırlığı girilmişse, ölçüm kaydı oluşturalım
      if (birthWeight != null && birthWeight > 0) {
        final measurement = WeightMeasurement(
          animalId: animalId,
          weight: birthWeight,
          measurementDate: DateTime.now(),
          rfid: rfid ?? '',
          notes: 'Doğum sırasında ölçülen ağırlık',
          measurementType: 1, // 1: Doğum ağırlığı
        );

        await measurementRepository.insertMeasurement(measurement);
      }

      Get.back(result: true);
      Get.snackbar(
        'Başarılı',
        'Yeni doğum kaydı eklendi',
        backgroundColor: Colors.green.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Doğum kaydı eklenirken bir hata oluştu: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  // Anne RFID'sini Bluetooth ile oku
  Future<void> readMotherRfid() async {
    if (bluetoothController == null) {
      Get.snackbar('Hata', 'Bluetooth kontrolcüsü başlatılamadı');
      return;
    }

    try {
      isBluetoothScanning.value = true;
      Get.snackbar('Bilgi', 'Anne RFID okunuyor...');

      final rfid = await bluetoothController!.readRfid();
      if (rfid != null && rfid.isNotEmpty) {
        scannedMotherRfid.value = rfid;
        Get.snackbar('Başarılı', 'Anne RFID başarıyla okundu: $rfid');
      } else {
        Get.snackbar('Hata', 'RFID okunamadı');
      }
    } catch (e) {
      Get.snackbar('Hata', 'RFID okuma hatası: $e');
    } finally {
      isBluetoothScanning.value = false;
    }
  }

  // Baba RFID'sini Bluetooth ile oku
  Future<void> readFatherRfid() async {
    if (bluetoothController == null) {
      Get.snackbar('Hata', 'Bluetooth kontrolcüsü başlatılamadı');
      return;
    }

    try {
      isBluetoothScanning.value = true;
      Get.snackbar('Bilgi', 'Baba RFID okunuyor...');

      final rfid = await bluetoothController!.readRfid();
      if (rfid != null && rfid.isNotEmpty) {
        scannedFatherRfid.value = rfid;
        Get.snackbar('Başarılı', 'Baba RFID başarıyla okundu: $rfid');
      } else {
        Get.snackbar('Hata', 'RFID okunamadı');
      }
    } catch (e) {
      Get.snackbar('Hata', 'RFID okuma hatası: $e');
    } finally {
      isBluetoothScanning.value = false;
    }
  }

  @override
  void onClose() {
    if (bluetoothController != null && isDeviceConnected.value) {
      bluetoothController!.disconnectDevice();
    }
    super.onClose();
  }
}
