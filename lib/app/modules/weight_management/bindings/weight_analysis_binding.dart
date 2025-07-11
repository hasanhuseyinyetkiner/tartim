import 'package:get/get.dart';
import 'package:tartim/app/data/repositories/animal_repository.dart';
import 'package:tartim/app/data/repositories/measurement_repository.dart';
import '../controllers/weight_analysis_controller.dart';

class WeightAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnimalRepository>(() => AnimalRepository());
    Get.lazyPut<MeasurementRepository>(() => MeasurementRepository());
    Get.lazyPut<WeightAnalysisController>(() => WeightAnalysisController(
          animalRepository: Get.find<AnimalRepository>(),
          measurementRepository: Get.find<MeasurementRepository>(),
        ));
  }
}
