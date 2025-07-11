import 'package:tartim/app/data/repositories/measurement_repository.dart';
import 'package:tartim/app/modules/devices/devices_controller.dart';
import 'package:tartim/app/modules/weight_measurement/weight_measurement_bluetooth.dart';
import 'package:get/get.dart';

class DevicesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MeasurementRepository());
    Get.lazyPut(() => WeightMeasurementBluetooth(
          measurementRepository: Get.find<MeasurementRepository>(),
        ));
    Get.put(DevicesController(
      weightMeasurementBluetooth: Get.find<WeightMeasurementBluetooth>(),
    ));
  }
}
