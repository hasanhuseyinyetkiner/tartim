import 'package:tartim/app/services/api/auth/auth_service.dart';
import 'package:tartim/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Geçici olarak auth kontrolü devre dışı - Login kaldırıldı
    return null;
    
    // final authService = Get.find<AuthService>();
    // if (authService.isAuthenticated.value == false) {
    //   return RouteSettings(name: Routes.LOGIN); // Login sayfasına yönlendir
    // }
    // return null;
  }
}