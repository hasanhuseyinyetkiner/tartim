import 'package:animaltracker/app/data/repositories/auth_repository.dart';
import 'package:animaltracker/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroductionController extends GetxController {
  final PageController pageController = PageController();
  final currentPage = 0.obs;
  final AuthRepository authRepository;

  IntroductionController({required this.authRepository});

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Splash screen'in görünme süresi
    await Future.delayed(const Duration(seconds: 3));

    // Ana sayfaya yönlendir
    Get.offNamed(Routes.HOME);
  }

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void nextPage() {
    pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void skip() {
    goToHome();
  }

  void goToHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);
    if (authRepository.getLoginStatus()) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
