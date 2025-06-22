import 'package:animaltracker/app/data/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthRepository());
    Get.lazyPut(() => SplashController(
      authRepository: Get.find<AuthRepository>(),
    ));
  }
}