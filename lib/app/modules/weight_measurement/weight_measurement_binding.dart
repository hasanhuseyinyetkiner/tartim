import 'package:tartim/app/data/repositories/measurement_repository.dart';
import 'package:tartim/app/modules/weight_measurement/weight_measurement_bluetooth.dart';
import 'package:tartim/app/services/api/weight_measurement_service.dart';
import 'package:get/get.dart';
import 'package:tartim/app/data/repositories/animal_repository.dart';
import 'package:tartim/app/data/repositories/animal_type_repository.dart';
import 'package:tartim/app/modules/weight_measurement/weight_measurement_controller.dart';

class WeightMeasurementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MeasurementRepository());
    Get.lazyPut(() => WeightMeasurementBluetooth(
          measurementRepository: Get.find<MeasurementRepository>(),
        ));
    Get.lazyPut(() => AnimalRepository());
    Get.lazyPut(() => AnimalTypeRepository());
    Get.lazyPut(() => WeightMeasurementApiService());
    Get.lazyPut(() => WeightMeasurementController(
          weightMeasurementBluetooth: Get.find<WeightMeasurementBluetooth>(),
          animalRepository: Get.find<AnimalRepository>(),
          animalTypeRepository: Get.find<AnimalTypeRepository>(),
          weightMeasurementApiService: Get.find<WeightMeasurementApiService>(),
        ));
  }
}
