import 'package:get/get.dart';
import 'package:tartim/app/modules/auth/login/login_controller.dart';
import 'package:tartim/app/services/api/auth/auth_service.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthService());
    Get.lazyPut(() => LoginController());
  }
}
