import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/user_device.dart';

class BluetoothServ extends GetxService {
  final isScanning = false.obs;
  final discoveredDevices = <BluetoothDevice>[].obs;
  final connectedDevices = <BluetoothDevice>[].obs;
  final isConnecting = false.obs;
  final connectingDeviceId = ''.obs;

  Future<BluetoothServ> init() async {
    // Bluetooth başlatma işlemleri
    return this;
  }

  Future<void> startScan() async {
    if (isScanning.value) return;

    discoveredDevices.clear();
    isScanning.value = true;

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (!discoveredDevices.any((d) => d.remoteId == r.device.remoteId)) {
            discoveredDevices.add(r.device);
          }
        }
      });
    } catch (e) {
      print('Tarama başlatma hatası: $e');
    } finally {
      await Future.delayed(const Duration(seconds: 4));
      stopScan();
    }
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    isScanning.value = false;
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    isConnecting.value = true;
    connectingDeviceId.value = device.remoteId.str;
    try {
      await FlutterBluePlus.stopScan();
      await device.connect();
      connectedDevices.add(device);
      return true;
    } catch (e) {
      print('Cihaza bağlanma hatası: $e');
      return false;
    } finally {
      isConnecting.value = false;
      connectingDeviceId.value = '';
    }
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      connectedDevices.remove(device);
    } catch (e) {
      print('Cihaz bağlantısını kesme hatası: $e');
    }
  }

  void cancelConnection() {
    if (isConnecting.value) {
      BluetoothDevice? device = discoveredDevices.firstWhereOrNull(
              (d) => d.remoteId.str == connectingDeviceId.value
      );
      if (device != null) {
        device.disconnect();
      }
      isConnecting.value = false;
      connectingDeviceId.value = '';
    }
  }

  Stream<List<int>> subscribeToCharacteristic(BluetoothDevice device, BluetoothCharacteristic characteristic) {
    return characteristic.onValueReceived;
  }

  bool isDeviceOnline(UserDevice userDevice) {
    //return true;
    return discoveredDevices.any((device) => device.remoteId.str == userDevice.macAddress);
  }

  BluetoothDevice? getBluetoothDevice(UserDevice userDevice) {
    //return discoveredDevices.first;
    return discoveredDevices.firstWhereOrNull((device) => device.remoteId.str == userDevice.macAddress);
  }

  Future<void> setupNotifications(BluetoothDevice device, Function(List<int>) onDataReceived) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          await characteristic.setNotifyValue(true);
          characteristic.onValueReceived.listen(onDataReceived);
        }
      }
    }
  }
}