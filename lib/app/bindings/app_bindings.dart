import 'package:tartim/app/data/repositories/animal_repository.dart';
import 'package:tartim/app/data/repositories/animal_type_repository.dart';
// import 'package:tartim/app/data/repositories/device_repository.dart'; // Boş dosya
import 'package:tartim/app/data/repositories/measurement_repository.dart';
import 'package:tartim/app/data/repositories/user_repository.dart';
import 'package:tartim/app/services/api/api_service.dart';
// import 'package:tartim/app/services/bluetooth_service.dart'; // Kullanılmıyor
import 'package:get/get.dart';

/// Uygulama başlangıcında servisleri, depoları ve bağımlılıkları kaydeden binding sınıfı
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Servisler
    // Get.lazyPut<BluetoothService>(() => BluetoothService(), fenix: true); // Kullanılmıyor
    Get.lazyPut<DotNetApiService>(() => DotNetApiService(), fenix: true);

    // Depolar
    Get.lazyPut<AnimalRepository>(() => AnimalRepository(), fenix: true);
    Get.lazyPut<AnimalTypeRepository>(() => AnimalTypeRepository(),
        fenix: true);
    Get.lazyPut<MeasurementRepository>(() => MeasurementRepository(),
        fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);
    // Get.lazyPut<DeviceRepository>(() => DeviceRepository(), fenix: true); // Boş sınıf
  }
}
