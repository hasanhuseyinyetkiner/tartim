import 'package:animaltracker/app/data/repositories/measurement_repository.dart';
import 'package:animaltracker/app/modules/weight_measurement/weight_measurement_bluetooth.dart';
import 'package:get/get.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MeasurementRepository());
    Get.lazyPut(() => WeightMeasurementBluetooth(
          measurementRepository: Get.find<MeasurementRepository>(),
        ));
  }
}
