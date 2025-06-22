import 'dart:typed_data';

import 'package:animaltracker/app/data/models/device.dart';
import 'package:animaltracker/app/data/models/measurement.dart';
import 'package:animaltracker/app/data/models/olcum_tipi.dart';
import 'package:animaltracker/app/data/repositories/measurement_repository.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class WeightMeasurementBluetooth extends GetxController {
  final MeasurementRepository measurementRepository;

  WeightMeasurementBluetooth({required this.measurementRepository});

  RxList<Device> availableDevices = <Device>[].obs;
  Rx<Device?> connectedDevice = Rx<Device?>(null);
  RxBool isDeviceConnected = false.obs;
  RxDouble currentWeight = 0.0.obs;
  RxDouble currentMedianWeight = 0.0.obs;
  RxString currentRfid = ''.obs;
  RxList<Measurement> measurementHistory = <Measurement>[].obs;
  RxMap<String, bool> deviceConnectionStatus = <String, bool>{}.obs;
  RxBool isConnecting = false.obs;
  RxString connectingDeviceId = ''.obs;
  RxBool isScanning = false.obs;
  RxBool isMeasuring = false.obs;

  // Default ölçüm tipi
  final Rx<OlcumTipi> currentOlcumTipi = OlcumTipi.normal.obs;

  // RFID okuma için yeni değişkenler
  final RxBool isReadingRfid = false.obs;

  BluetoothDevice? _device;

  Future<void> startScan() async {
    availableDevices.clear();
    isScanning.value = true;
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          final device = Device(
            id: r.device.remoteId.str,
            name: r.device.name.isNotEmpty ? r.device.name : 'Unknown Device',
            rssi: r.rssi,
          );
          if (!availableDevices.any((d) => d.id == device.id)) {
            availableDevices.add(device);
          }
        }
      });
    } catch (e) {
      print('Error starting scan: $e');
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> connectToDevice(Device device) async {
    isConnecting.value = true;
    connectingDeviceId.value = device.id;
    try {
      await FlutterBluePlus.stopScan();
      _device = BluetoothDevice.fromId(device.id);
      await _device!.connect();
      connectedDevice.value = device;
      isDeviceConnected.value = true;
      deviceConnectionStatus[device.id] = true;
      _setupNotifications();
    } catch (e) {
      print('Error connecting to device: $e');
      connectedDevice.value = null;
      isDeviceConnected.value = false;
      deviceConnectionStatus[device.id] = false;
      rethrow;
    } finally {
      isConnecting.value = false;
      connectingDeviceId.value = '';
    }
  }

  Future<void> disconnectDevice() async {
    if (_device != null) {
      await _device!.disconnect();
    }
    if (connectedDevice.value != null) {
      deviceConnectionStatus[connectedDevice.value!.id] = false;
    }
    connectedDevice.value = null;
    isDeviceConnected.value = false;
    _device = null;
    isMeasuring.value = false;
  }

  void cancelConnection() {
    if (isConnecting.value && _device != null) {
      _device!.disconnect();
      isConnecting.value = false;
      connectingDeviceId.value = '';
    }
  }

  // Bağlı cihazla bağlantıyı yeniden başlatma metodu
  Future<void> restartConnection() async {
    if (isDeviceConnected.value && connectedDevice.value != null) {
      final device = connectedDevice.value!;
      await disconnectDevice();
      // Kısa bir gecikme ekle
      await Future.delayed(const Duration(milliseconds: 500));
      // Cihaza yeniden bağlan
      await connectToDevice(device);
    }
  }

  void _setupNotifications() async {
    currentRfid.value = "";
    List<BluetoothService> services = await _device!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          await characteristic.setNotifyValue(true);
          characteristic.onValueReceived.listen(_processReceivedData);
        }
      }
    }
  }

  void _processReceivedData(List<int> data) async {
    if (data.length == 16 && data[0] == 0x05) {
      // Kilo değerini [1] - [4] arasından al ve float'a çevir
      ByteData byteBuffer =
          ByteData.sublistView(Uint8List.fromList(data.sublist(1, 5)));

      double weightInKg = byteBuffer.getFloat32(0, Endian.little);

      // RFID değerini [5] - [14] arasından al ve soru işaretlerini kaldır
      String rfid =
          String.fromCharCodes(data.sublist(5, 15)).replaceAll('?', '');

      // Geçici ölçümü kaydet
      await measurementRepository.insertTempMeasurement(Measurement(
        weight: weightInKg,
        rfid: rfid,
        timestamp: DateTime.now().toIso8601String(),
        olcumTipi: currentOlcumTipi.value,
      ));

      // Medyan ağırlığı hesapla ve göster
      double? medianWeight =
          await measurementRepository.getMedianTempMeasurementByRfid(rfid);

      currentWeight.value = weightInKg;
      currentMedianWeight.value = medianWeight ?? weightInKg;
      currentRfid.value = rfid;
    }
  }

  Future<void> startMeasurement() async {
    isMeasuring.value = true;
    await measurementRepository.clearTempMeasurements();
  }

  Future<void> finalizeMeasurement(OlcumTipi olcumTipi) async {
    if (isMeasuring.value) {
      // Mevcut ölçüm tipini güncelle
      currentOlcumTipi.value = olcumTipi;

      await measurementRepository.finalizeMeasurements(olcumTipi);
      isMeasuring.value = false;
      await fetchRecentMeasurements();
    }
  }

  Future<void> updateDeviceStatus() async {
    if (_device != null) {
      isDeviceConnected.value =
          await _device!.state.first == BluetoothDeviceState.connected;
    } else {
      isDeviceConnected.value = false;
    }
  }

  Future<void> fetchRecentMeasurements() async {
    measurementHistory.value =
        await measurementRepository.getRecentMeasurements(10);
  }

  // RFID okuma metodu
  Future<String?> readRfid() async {
    if (!isDeviceConnected.value) {
      throw Exception('Bluetooth cihazına bağlı değil');
    }

    try {
      isReadingRfid.value = true;
      // Burada cihazdan RFID okuma işlemi yapılacak
      // Örnek implementasyon:
      await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş okuma
      final rfid = 'TEST123456'; // Gerçek implementasyonda cihazdan okunacak
      currentRfid.value = rfid;
      return rfid;
    } catch (e) {
      rethrow;
    } finally {
      isReadingRfid.value = false;
    }
  }
}
