import 'package:animaltracker/app/data/models/device.dart';
import 'package:animaltracker/app/modules/weight_measurement/weight_measurement_bluetooth.dart';
import 'package:get/get.dart';

class DevicesController extends GetxController {
  final WeightMeasurementBluetooth weightMeasurementBluetooth;

  DevicesController({
    required this.weightMeasurementBluetooth,
  });

  // Cihaz listesi filtreleme için değişkenler
  final selectedFilter = 'all'.obs;

  // Cihaz filtresini değiştirme metodu
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Filtrelenmiş cihaz listesi
  List<Device> get filteredDevices {
    final devices = weightMeasurementBluetooth.availableDevices;

    switch (selectedFilter.value) {
      case 'connected':
        return devices
            .where((device) =>
                weightMeasurementBluetooth.deviceConnectionStatus[device.id] ??
                false)
            .toList();
      case 'disconnected':
        return devices
            .where((device) => !(weightMeasurementBluetooth
                    .deviceConnectionStatus[device.id] ??
                false))
            .toList();
      case 'all':
      default:
        return devices;
    }
  }
}
