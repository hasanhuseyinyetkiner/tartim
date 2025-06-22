import 'package:get/get.dart';
import 'package:animaltracker/app/modules/settings/settings_controller.dart';
import 'package:animaltracker/app/modules/weight_measurement/weight_measurement_bluetooth.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController(
          weightMeasurementBluetooth: Get.find<WeightMeasurementBluetooth>(),
        ));
  }
}
