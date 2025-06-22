import 'package:animaltracker/app/data/repositories/auth_repository.dart';
import 'package:animaltracker/app/data/repositories/measurement_repository.dart';
import 'package:animaltracker/app/data/repositories/user_repository.dart';
import 'package:animaltracker/app/modules/home/home_controller.dart';
import 'package:animaltracker/app/modules/weight_measurement/weight_measurement_bluetooth.dart';
import 'package:get/get.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut(() => MeasurementRepository());
    Get.lazyPut(() => UserRepository());
    Get.lazyPut(() => AuthRepository());

    // Services
    Get.lazyPut(() => WeightMeasurementBluetooth(
      measurementRepository: Get.find<MeasurementRepository>(),
    ));

    // Controller
    Get.put(HomeController(
      userRepository: Get.find<UserRepository>(),
      authRepository: Get.find<AuthRepository>(),
      weightMeasurementBluetooth: Get.find<WeightMeasurementBluetooth>(),
      measurementRepository: Get.find<MeasurementRepository>(),
    ));
  }
}