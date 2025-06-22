import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/user_device.dart';
import '../services/bluetooth_service.dart';

abstract class BaseMeasurementController extends GetxController {
  final BluetoothServ _bluetoothService = Get.find<BluetoothServ>();
  final ApiService _apiService = Get.find<ApiService>();
  final userDevices = <UserDevice>[].obs;
  final isDeviceConnected = false.obs;
  final selectedDevice = Rx<UserDevice?>(null);

  String get deviceType;

  @override
  void onInit() {
    super.onInit();
    loadUserDevices();
  }

  Future<void> loadUserDevices() async {
    List<UserDevice> devices = await _apiService.getUserDevices(deviceType);
    userDevices.value = devices;
    await updateDeviceStatus();
  }

  Future<void> updateDeviceStatus() async {
    await _bluetoothService.startScan();
    for (var device in userDevices) {
      device.isOnline = _bluetoothService.isDeviceOnline(device);
    }
    userDevices.refresh();
  }

  Future<bool> connectToDevice(UserDevice device) async {
    BluetoothDevice? bluetoothDevice = _bluetoothService.getBluetoothDevice(device);

    if (bluetoothDevice != null) {
      bool connected = await _bluetoothService.connectToDevice(bluetoothDevice);
      if (connected) {
        selectedDevice.value = device;
        device.isConnected = true;
        isDeviceConnected.value = true;
        _subscribeToDevice(bluetoothDevice);
        return true;
      }
    }
    return false;
  }

  Future<void> _subscribeToDevice(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.properties.notify) {
          await c.setNotifyValue(true);
          _bluetoothService.subscribeToCharacteristic(device, c).listen((data) {
            processMeasurementData(data);
          });
        }
      }
    }
  }

  void processMeasurementData(List<int> data);

  Future<void> disconnectDevice() async {
    if (selectedDevice.value != null) {
      BluetoothDevice? bluetoothDevice = _bluetoothService.getBluetoothDevice(selectedDevice.value!);
      if (bluetoothDevice != null) {
        await _bluetoothService.disconnectDevice(bluetoothDevice);
      }
      selectedDevice.value!.isConnected = false;
      selectedDevice.value = null;
      isDeviceConnected.value = false;
    }
  }
}