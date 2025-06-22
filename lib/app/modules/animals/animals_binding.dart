import 'package:animaltracker/app/data/repositories/measurement_repository.dart';
import 'package:get/get.dart';
import 'package:animaltracker/app/data/repositories/animal_repository.dart';
import 'package:animaltracker/app/data/repositories/animal_type_repository.dart';
import 'package:animaltracker/app/modules/animals/animals_controller.dart';

class AnimalsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AnimalRepository());
    Get.lazyPut(() => AnimalTypeRepository());
    Get.lazyPut(() => MeasurementRepository());
    Get.lazyPut(() => AnimalsController(
      animalRepository: Get.find<AnimalRepository>(),
      animalTypeRepository: Get.find<AnimalTypeRepository>(),
      measurementRepository: Get.find<MeasurementRepository>(),
    ));
  }
}