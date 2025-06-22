import 'package:get/get.dart';
import 'package:animaltracker/app/data/repositories/animal_repository.dart';
import 'package:animaltracker/app/data/repositories/animal_type_repository.dart';
import 'package:animaltracker/app/data/repositories/measurement_repository.dart';
import 'package:animaltracker/app/modules/animal_profile/animal_profile_controller.dart';

class AnimalProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<AnimalRepository>(() => AnimalRepository());
    Get.lazyPut<AnimalTypeRepository>(() => AnimalTypeRepository());
    Get.lazyPut<MeasurementRepository>(() => MeasurementRepository());

    // Controller
    Get.lazyPut<AnimalProfileController>(() => AnimalProfileController(
      animalRepository: Get.find<AnimalRepository>(),
      animalTypeRepository: Get.find<AnimalTypeRepository>(),
      measurementRepository: Get.find<MeasurementRepository>(),
    ));
  }
}