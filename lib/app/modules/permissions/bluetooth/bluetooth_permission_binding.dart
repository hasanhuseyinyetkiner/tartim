import 'package:get/get.dart';
import 'bluetooth_permission_controller.dart';

class BluetoothPermissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BluetoothPermissionController>(() => BluetoothPermissionController());
  }
}
