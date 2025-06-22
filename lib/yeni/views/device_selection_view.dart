import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/base_measurement_controller.dart';
import '../models/user_device.dart';

class DeviceSelectionView<T extends BaseMeasurementController> extends GetView<T> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cihaz Seçimi')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: controller.updateDeviceStatus,
            child: Text('Cihazları Yenile'),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.userDevices.length,
              itemBuilder: (context, index) {
                UserDevice device = controller.userDevices[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.isOnline ? 'Çevrimiçi' : 'Çevrimdışı'),
                  trailing: ElevatedButton(
                    onPressed: device.isOnline
                        ? () async {
                      bool connected = await controller.connectToDevice(device);
                      if (connected) {
                        Get.back();
                      } else {
                        Get.snackbar('Hata', 'Cihaza bağlanılamadı');
                      }
                    }
                        : null,
                    child: Text('Bağlan'),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}