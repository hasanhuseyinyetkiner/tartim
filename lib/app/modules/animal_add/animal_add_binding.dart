import 'package:get/get.dart';
import 'package:tartim/app/data/repositories/animal_repository.dart';
import 'package:tartim/app/data/repositories/animal_type_repository.dart';
import 'package:tartim/app/modules/animal_add/animal_add_controller.dart';

class AnimalAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AnimalRepository());
    Get.lazyPut(() => AnimalTypeRepository());
    Get.lazyPut(() => AnimalAddController(
      animalRepository: Get.find<AnimalRepository>(),
      animalTypeRepository: Get.find<AnimalTypeRepository>(),
    ));
  }
}