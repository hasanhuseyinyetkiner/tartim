import 'package:animaltracker/app/services/api/auth/auth_service.dart';
import 'package:animaltracker/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.isAuthenticated) {
      return RouteSettings(name: Routes.LOGIN); // Login sayfasına yönlendir
    }
    return null;
  }
}