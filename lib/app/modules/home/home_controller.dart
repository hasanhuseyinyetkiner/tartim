import 'package:animaltracker/app/data/models/measurement.dart';
import 'package:animaltracker/app/data/repositories/auth_repository.dart';
import 'package:animaltracker/app/data/repositories/measurement_repository.dart';
import 'package:animaltracker/app/data/repositories/user_repository.dart';
import 'package:animaltracker/app/modules/weight_measurement/weight_measurement_bluetooth.dart';
import 'package:animaltracker/routes/app_pages.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final UserRepository userRepository;
  final AuthRepository authRepository;
  final WeightMeasurementBluetooth weightMeasurementBluetooth;
  final MeasurementRepository measurementRepository;

  HomeController({
    required this.userRepository,
    required this.authRepository,
    required this.weightMeasurementBluetooth,
    required this.measurementRepository,
  });

  final Rx<Measurement?> lastMeasurement = Rx<Measurement?>(null);
  final RxList<Measurement> recentMeasurements = <Measurement>[].obs;
  final RxBool isLoading = true.obs;
  final totalAnimals = 0.obs;
  final totalMeasurements = 0.obs;
  final tabIndex = 0.obs; // Güncel sekme indeksi

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;

    switch (index) {
      case 0:
        // Ana sayfa
        break;
      case 1:
        // Hayvanlar
        Get.toNamed(Routes.ANIMALS);
        break;
      case 2:
        // Ağırlık ölçümü
        Get.toNamed(Routes.WEIGHT_MEASUREMENT);
        break;
      case 3:
        // Ayarlar
        // _showSettingsDialog metodu Scaffold context gerektirdiği için
        // burada direct çağıramıyoruz, boş bırakalım ve view'da halledeceğiz
        break;
    }
  }

  void logout() async {
    await userRepository.logout();
    await authRepository.saveLoginStatus(false);
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> fetchLastMeasurement() async {
    lastMeasurement.value = await measurementRepository.getLastMeasurement();
  }

  Future<void> fetchRecentMeasurements() async {
    final measurements = await measurementRepository.getRecentMeasurements(5);
    recentMeasurements.assignAll(measurements);
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchLastMeasurement(),
        fetchRecentMeasurements(),
      ]);

      if (recentMeasurements.isNotEmpty) {
        lastMeasurement.value = recentMeasurements.first;
      }

      totalAnimals.value = await userRepository.getTotalAnimalCount();
      totalMeasurements.value =
          await measurementRepository.getTotalMeasurementCount();
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
