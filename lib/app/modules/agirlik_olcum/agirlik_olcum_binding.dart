import 'package:tartim/app/modules/agirlik_olcum/agirlik_olcum_controller.dart';
import 'package:tartim/app/services/api/weight_measurement_service.dart';
import 'package:get/get.dart';

class AgirlikOlcumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WeightMeasurementApiService());
    Get.lazyPut(() => AgirlikOlcumController(
          apiService: Get.find<WeightMeasurementApiService>(),
        ));
  }
}
