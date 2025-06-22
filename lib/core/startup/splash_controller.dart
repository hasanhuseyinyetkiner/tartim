import 'package:animaltracker/app/data/repositories/auth_repository.dart';
import 'package:animaltracker/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  var loadingText = 'Yükleniyor...'.obs;
  final AuthRepository authRepository;

  SplashController({required this.authRepository});

  @override
  void onInit() {
    super.onInit();
    checkFirstRun();
  }

  void checkFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    await Future.delayed(const Duration(seconds: 2)); // Simüle edilmiş yükleme süresi

    if (isFirstRun) {
      Get.offAllNamed(Routes.INTRODUCTION);
    } else if (authRepository.getLoginStatus()) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}