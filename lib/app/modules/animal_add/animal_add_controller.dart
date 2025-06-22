import 'package:get/get.dart';
import 'package:animaltracker/app/data/models/animal.dart';
import 'package:animaltracker/app/data/models/animal_type.dart';
import 'package:animaltracker/app/data/repositories/animal_repository.dart';
import 'package:animaltracker/app/data/repositories/animal_type_repository.dart';
import 'package:animaltracker/app/modules/weight_measurement/weight_measurement_bluetooth.dart';
import 'package:animaltracker/app/data/models/device.dart';
import 'package:flutter/material.dart';

class AnimalAddController extends GetxController {
  final AnimalRepository animalRepository;
  final AnimalTypeRepository animalTypeRepository;
  final WeightMeasurementBluetooth? bluetoothController;

  AnimalAddController({
    required this.animalRepository,
    required this.animalTypeRepository,
    this.bluetoothController,
  });

  final RxList<AnimalType> animalTypes = <AnimalType>[].obs;
  final RxInt selectedTypeId = 0.obs;

  // Bluetooth RFID okuma için yeni değişkenler
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

  Future<void> fetchAnimalTypes() async {
    try {
      // Get all animal types in a single list
      animalTypes.value = await animalTypeRepository.getAllAnimalTypes();

      // Set default selection if available
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

  Future<void> addAnimal(String name, String earTag, String rfid,
      {String? motherRfid, String? fatherRfid}) async {
    if (selectedTypeId.value == 0) {
      Get.snackbar('Hata', 'Lütfen bir hayvan türü seçin');
      return;
    }

    // RFID doğrulama kontrolü
    if (!isValidRfid(rfid)) {
      Get.snackbar('Hata', 'Geçersiz RFID değeri. En az 8 karakter olmalıdır.');
      return;
    }

    final animal = Animal(
      name: name,
      typeId: selectedTypeId.value,
      earTag: earTag,
      rfid: rfid,
      motherRfid: motherRfid,
      fatherRfid: fatherRfid,
    );

    try {
      await animalRepository.insertAnimal(animal);
      Get.back(result: true);
      Get.snackbar('Başarılı', 'Yeni hayvan eklendi');
    } catch (e) {
      Get.snackbar('Hata', 'Hayvan eklenirken bir hata oluştu: $e');
    }
  }

  Future<Animal?> getAnimalByRfid(String rfid) async {
    if (rfid.isEmpty) return null;
    return await animalRepository.getAnimalByRfid(rfid);
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
