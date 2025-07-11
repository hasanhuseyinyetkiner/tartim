import 'package:get/get.dart';
import 'package:tartim/app/modules/introduction/introduction_controller.dart';
import 'package:tartim/app/data/repositories/auth_repository.dart';

class IntroductionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<IntroductionController>(
      () => IntroductionController(authRepository: Get.find()),
    );
  }
}
