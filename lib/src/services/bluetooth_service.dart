// -*- coding: utf-8 -*-
// AI-GENERATED :: DO NOT EDIT

import 'dart:async';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/user_device.dart';

/// Bluetooth service for weight measurement device management
class TartimBluetoothService extends GetxService {
  final isScanning = false.obs;
  final discoveredDevices = <BluetoothDevice>[].obs;
  final connectedDevices = <BluetoothDevice>[].obs;
  final isConnecting = false.obs;
  final connectingDeviceId = ''.obs;
  final connectionStatus = <String, bool>{}.obs;
  final deviceSignalStrength = <String, int>{}.obs;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  final Map<String, StreamSubscription> _characteristicSubscriptions = {};

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initialize();
  }

  @override
  void onClose() {
    _scanSubscription?.cancel();
    _characteristicSubscriptions.values.forEach((sub) => sub.cancel());
    super.onClose();
  }

  /// Initialize Bluetooth service
  Future<void> _initialize() async {
    try {
      // Check if Bluetooth is available
      if (await FlutterBluePlus.isAvailable == false) {
        throw Exception("Bluetooth not available on this device");
      }

      // Listen for adapter state changes
      FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // Clear discovered devices if Bluetooth is turned off
          discoveredDevices.clear();
        }
      });
    } catch (e) {
      print('Bluetooth initialization error: $e');
    }
  }

  /// Start scanning for Bluetooth devices
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (isScanning.value) return;

    try {
      // Clear previous results
      discoveredDevices.clear();
      isScanning.value = true;

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: false,
      );

      // Listen for scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final device = result.device;

          // Avoid duplicates
          if (!discoveredDevices.any((d) => d.remoteId == device.remoteId)) {
            discoveredDevices.add(device);

            // Store signal strength
            deviceSignalStrength[device.remoteId.str] = result.rssi;
          }
        }
      });

      // Auto-stop scanning after timeout
      Timer(timeout, () {
        stopScan();
      });
    } catch (e) {
      print('Scan start error: $e');
      isScanning.value = false;
    }
  }

  /// Stop scanning for devices
  void stopScan() {
    try {
      FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
      isScanning.value = false;
    } catch (e) {
      print('Stop scan error: $e');
    }
  }

  /// Connect to a Bluetooth device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (isConnecting.value) return false;

    isConnecting.value = true;
    connectingDeviceId.value = device.remoteId.str;

    try {
      // Stop scanning before connecting
      await FlutterBluePlus.stopScan();

      // Connect to device with timeout
      await device.connect(timeout: const Duration(seconds: 15));

      // Add to connected devices
      if (!connectedDevices.contains(device)) {
        connectedDevices.add(device);
      }

      connectionStatus[device.remoteId.str] = true;

      // Setup disconnect listener
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          connectedDevices.remove(device);
          connectionStatus[device.remoteId.str] = false;
        }
      });

      return true;
    } catch (e) {
      print('Connection error: $e');
      connectionStatus[device.remoteId.str] = false;
      return false;
    } finally {
      isConnecting.value = false;
      connectingDeviceId.value = '';
    }
  }

  /// Disconnect from a device
  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      // Cancel any subscriptions for this device
      final deviceSubscriptions = _characteristicSubscriptions.entries.where(
        (entry) => entry.key.startsWith(device.remoteId.str),
      );

      for (var entry in deviceSubscriptions) {
        await entry.value.cancel();
        _characteristicSubscriptions.remove(entry.key);
      }

      // Disconnect the device
      await device.disconnect();

      // Remove from connected devices
      connectedDevices.remove(device);
      connectionStatus[device.remoteId.str] = false;
    } catch (e) {
      print('Disconnect error: $e');
    }
  }

  /// Cancel current connection attempt
  void cancelConnection() {
    if (isConnecting.value && connectingDeviceId.value.isNotEmpty) {
      final device = discoveredDevices.firstWhereOrNull(
        (d) => d.remoteId.str == connectingDeviceId.value,
      );

      if (device != null) {
        device.disconnect();
      }

      isConnecting.value = false;
      connectingDeviceId.value = '';
    }
  }

  /// Setup notifications for weight measurement characteristics
  Future<void> setupWeightMeasurementNotifications(
    BluetoothDevice device,
    Function(List<int>) onDataReceived,
  ) async {
    try {
      final services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.notify ||
              characteristic.properties.indicate) {
            await characteristic.setNotifyValue(true);

            final subscriptionKey =
                '${device.remoteId.str}_${characteristic.uuid}';
            _characteristicSubscriptions[subscriptionKey] = characteristic
                .onValueReceived
                .listen(onDataReceived);
          }
        }
      }
    } catch (e) {
      print('Setup notifications error: $e');
    }
  }

  /// Generic characteristic subscription
  Stream<List<int>> subscribeToCharacteristic(
    BluetoothDevice device,
    BluetoothCharacteristic characteristic,
  ) {
    return characteristic.onValueReceived;
  }

  /// Check if device is online (discovered in scan)
  bool isDeviceOnline(UserDevice userDevice) {
    return discoveredDevices.any(
      (device) => device.remoteId.str == userDevice.macAddress,
    );
  }

  /// Get Bluetooth device by UserDevice
  BluetoothDevice? getBluetoothDevice(UserDevice userDevice) {
    return discoveredDevices.firstWhereOrNull(
      (device) => device.remoteId.str == userDevice.macAddress,
    );
  }

  /// Check if device is connected
  bool isDeviceConnected(UserDevice userDevice) {
    return connectedDevices.any(
      (device) => device.remoteId.str == userDevice.macAddress,
    );
  }

  /// Get signal strength for device
  int getDeviceSignalStrength(String deviceId) {
    return deviceSignalStrength[deviceId] ?? -100;
  }

  /// Process weight measurement data
  WeightMeasurementData? processWeightData(List<int> data) {
    try {
      // Standard weight scale data format (16 bytes)
      if (data.length >= 16 && data[0] == 0x05) {
        // Extract weight from bytes [1-4] as float
        final weightBytes = Uint8List.fromList(data.sublist(1, 5));
        final byteBuffer = ByteData.sublistView(weightBytes);
        final weight = byteBuffer.getFloat32(0, Endian.little);

        // Extract RFID from bytes [5-14] and clean up
        final rfidBytes = data.sublist(5, 15);
        final rfid = String.fromCharCodes(rfidBytes).replaceAll('?', '').trim();

        return WeightMeasurementData(
          weight: weight,
          rfid: rfid,
          timestamp: DateTime.now(),
          rawData: data,
        );
      }

      return null;
    } catch (e) {
      print('Weight data processing error: $e');
      return null;
    }
  }

  /// Get connected device count
  int get connectedDeviceCount => connectedDevices.length;

  /// Get discovered device count
  int get discoveredDeviceCount => discoveredDevices.length;

  /// Check if any device is connected
  bool get hasConnectedDevices => connectedDevices.isNotEmpty;
}

/// Data class for processed weight measurement
class WeightMeasurementData {
  final double weight;
  final String rfid;
  final DateTime timestamp;
  final List<int> rawData;

  WeightMeasurementData({
    required this.weight,
    required this.rfid,
    required this.timestamp,
    required this.rawData,
  });

  @override
  String toString() {
    return 'WeightMeasurementData(weight: $weight, rfid: $rfid, timestamp: $timestamp)';
  }
}

/// Module-Summary:
/// TartimBluetoothService Bluetooth ağırlık ölçüm cihazlarının yönetimini sağlar. Cihaz tarama, bağlantı kurma, veri alma ve bağlantı kesme işlevlerini içerir. Ağırlık verilerini parse eder ve sinyal gücü takibi yapar. GetX tabanlı reaktif state management kullanır.
