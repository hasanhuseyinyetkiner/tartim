import 'package:animaltracker/app/services/api/auth/auth_service.dart';
import 'package:animaltracker/app/services/api/api_service.dart';
import 'package:animaltracker/app/services/connectivity_service.dart';
import 'package:animaltracker/app/services/sync_service.dart';
import 'package:animaltracker/core/theme/app_theme.dart';
import 'package:animaltracker/routes/app_pages.dart';
import 'package:animaltracker/translations/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/data/database/database_helper.dart';

void main() async {
  //FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;

  await GetStorage.init(); // GetStorage'i başlat

  // Servisleri başlat
  Get.put(DotNetApiService());
  Get.put(AuthService()); // AuthService başlat

  // Senkronizasyon ve bağlantı servisleri
  await Get.putAsync(() => SyncService().init());
  await Get.putAsync(() => ConnectivityService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Akıllı Tartım",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      translations: AppTranslations(), // Çok dilli yapı
      locale: const Locale('tr', 'TR'), // Varsayılan dil
      fallbackLocale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
