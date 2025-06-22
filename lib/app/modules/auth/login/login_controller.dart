import 'package:get/get.dart';
import 'package:animaltracker/app/services/api/auth/auth_service.dart';

class LoginController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final RxBool isLoading = false.obs;

  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    try {
      return await authService.login(username, password);
    } finally {
      isLoading.value = false;
    }
  }
}
