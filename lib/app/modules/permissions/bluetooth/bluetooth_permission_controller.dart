import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPermissionController extends GetxController {
  var isPermissionGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkBluetoothPermission();
  }

  Future<void> checkBluetoothPermission() async {
    PermissionStatus status = await Permission.bluetooth.status;
    if (status.isGranted) {
      isPermissionGranted.value = true;
    }
  }

  Future<void> requestBluetoothPermission() async {
    // PermissionStatus status = await Permission.bluetooth.request();
    // if (status.isGranted) {
    //   isPermissionGranted.value = true;
    //   Get.back(result: true);
    // } else if (status.isPermanentlyDenied) {
    //   Get.snackbar(
    //     'İzin Gerekli',
    //     'Bluetooth iznini cihaz ayarlarından vermelisiniz.',
    //     snackPosition: SnackPosition.BOTTOM,
    //     mainButton: TextButton(
    //       onPressed: () {
    //         openAppSettings();
    //       },
    //       child: Text('Ayarlar'),
    //     ),
    //   );
    // } else {
    //   Get.snackbar(
    //     'İzin Reddedildi',
    //     'Bluetooth izni olmadan bu özelliği kullanamazsınız.',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // }
  }
}
