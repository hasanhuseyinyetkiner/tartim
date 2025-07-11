import 'package:get/get.dart';
import 'package:tartim/app/services/api/auth/auth_service.dart';

class LoginController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final RxBool isLoading = false.obs;

  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    try {
      final response = await authService.login(username, password);
      return response.success;
    } finally {
      isLoading.value = false;
    }
  }
}
