import 'package:get/get.dart';
import 'package:tartim/app/modules/animal_add/animal_add_binding.dart';
import 'package:tartim/app/modules/animal_add/animal_add_view.dart';
import 'package:tartim/app/modules/animal_profile/animal_profile_binding.dart';
import 'package:tartim/app/modules/animal_profile/animal_profile_view.dart';
import 'package:tartim/app/modules/animals/animals_binding.dart';
import 'package:tartim/app/modules/animals/animals_view.dart';
import 'package:tartim/app/modules/auth/login/login_binding.dart';
import 'package:tartim/app/modules/auth/login/login_view.dart';
import 'package:tartim/app/modules/devices/devices_binding.dart';
import 'package:tartim/app/modules/devices/devices_view.dart';
import 'package:tartim/app/modules/home/home_binding.dart';
import 'package:tartim/app/modules/home/home_view.dart';
import 'package:tartim/app/modules/introduction/introduction_binding.dart';
import 'package:tartim/app/modules/introduction/introduction_view.dart';
import 'package:tartim/app/modules/permissions/bluetooth/bluetooth_permission_binding.dart';
import 'package:tartim/app/modules/permissions/bluetooth/bluetooth_permission_view.dart';
import 'package:tartim/app/modules/weight_measurement/weight_measurement_binding.dart';
import 'package:tartim/app/modules/weight_measurement/weight_measurement_view.dart';
import 'package:tartim/app/modules/agirlik_olcum/agirlik_olcum_binding.dart';
import 'package:tartim/app/modules/agirlik_olcum/agirlik_olcum_view.dart';
import 'package:tartim/app/modules/add_birth/add_birth_binding.dart';
import 'package:tartim/app/modules/add_birth/add_birth_view.dart';
import 'package:tartim/app/modules/settings/settings_binding.dart';
import 'package:tartim/app/modules/settings/settings_view.dart';
import 'package:tartim/core/startup/splash_binding.dart';
import 'package:tartim/core/startup/splash_view.dart';
import 'package:tartim/middlewares/auth_middleware.dart';
import 'package:tartim/app/services/api/auth/auth_service.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.INTRODUCTION,
      page: () => const IntroductionView(),
      binding: IntroductionBinding(),
    ),
    // GetPage(
    //   name: Routes.LOGIN,
    //   page: () => LoginView(),
    //   binding: LoginBinding(),
    // ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()], // Auth kontrolü ekleniyor
    ),
    GetPage(
      name: Routes.WEIGHT_MEASUREMENT,
      page: () => const WeightMeasurementView(),
      binding: WeightMeasurementBinding(),
    ),
    GetPage(
      name: Routes.DEVICES,
      page: () => const DevicesView(),
      binding: DevicesBinding(),
    ),
    GetPage(
      name: Routes.BLUETOOTH_PERMISSION,
      page: () => const BluetoothPermissionView(),
      binding: BluetoothPermissionBinding(),
    ),
    GetPage(
      name: Routes.ANIMALS,
      page: () => const AnimalsView(),
      binding: AnimalsBinding(),
    ),
    GetPage(
      name: Routes.ANIMAL_PROFILE,
      page: () => const AnimalProfileView(),
      binding: AnimalProfileBinding(),
    ),
    GetPage(
      name: Routes.ANIMAL_ADD,
      page: () => const AnimalAddView(),
      binding: AnimalAddBinding(),
    ),
    GetPage(
      name: Routes.AGIRLIK_OLCUM,
      page: () => const AgirlikOlcumView(),
      binding: AgirlikOlcumBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ADD_BIRTH,
      page: () => const AddBirthView(),
      binding: AddBirthBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
