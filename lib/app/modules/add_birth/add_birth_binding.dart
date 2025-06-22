import 'package:get/get.dart';
import 'package:animaltracker/app/modules/add_birth/add_birth_controller.dart';
import 'package:animaltracker/app/data/repositories/animal_repository.dart';
import 'package:animaltracker/app/data/repositories/animal_type_repository.dart';
import 'package:animaltracker/app/data/repositories/measurement_repository.dart';
import 'package:animaltracker/app/modules/weight_measurement/weight_measurement_bluetooth.dart';

class AddBirthBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<AnimalRepository>(() => AnimalRepository());
    Get.lazyPut<AnimalTypeRepository>(() => AnimalTypeRepository());
    Get.lazyPut<MeasurementRepository>(() => MeasurementRepository());

    // Bluetooth Controller (if not already initialized)
    if (!Get.isRegistered<WeightMeasurementBluetooth>()) {
      Get.lazyPut<WeightMeasurementBluetooth>(() => WeightMeasurementBluetooth(
            measurementRepository: Get.find(),
          ));
    }

    // Main Controller
    Get.lazyPut<AddBirthController>(() => AddBirthController(
          animalRepository: Get.find<AnimalRepository>(),
          animalTypeRepository: Get.find<AnimalTypeRepository>(),
          measurementRepository: Get.find<MeasurementRepository>(),
          bluetoothController: Get.find<WeightMeasurementBluetooth>(),
        ));
  }
}
