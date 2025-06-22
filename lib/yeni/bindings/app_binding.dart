// import 'package:get/get.dart';
// import '../services/bluetooth_service.dart';
// import '../services/api_service.dart';
// import '../controllers/weight_controller.dart';
// import '../controllers/milk_controller.dart';
//
// class AppBinding extends Bindings {
//   @override
//   void dependencies() {
//     // Servisler
//     Get.putAsync(() => BluetoothServ().init());
//     Get.put(ApiService());
//
//     // Controller'lar
//     Get.lazyPut(() => WeightController(), fenix: true);
//     Get.lazyPut(() => MilkController(), fenix: true);
//   }
// }