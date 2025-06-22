import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bluetooth_permission_controller.dart';

class BluetoothPermissionView extends GetView<BluetoothPermissionController> {
  const BluetoothPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth İzni'),
      ),
      body: Center(
        child: Obx(() {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.isPermissionGranted.value
                    ? 'Bluetooth izni verildi!'
                    : 'Bu uygulama için Bluetooth izni gereklidir.',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.isPermissionGranted.value
                    ? null
                    : controller.requestBluetoothPermission,
                child: Text(
                  controller.isPermissionGranted.value
                      ? 'İzin Verildi'
                      : 'İzin Ver',
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
