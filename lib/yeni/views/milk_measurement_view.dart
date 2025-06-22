import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/milk_controller.dart';
import 'device_selection_view.dart';

class MilkMeasurementView extends GetView<MilkController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Süt Ölçümü')),
      body: Obx(() => Column(
        children: [
          if (!controller.isDeviceConnected.value)
            ElevatedButton(
              onPressed: () => Get.to(() => DeviceSelectionView<MilkController>()),
              child: Text('Cihaz Seç'),
            )
          else
            Column(
              children: [
                Text('Bağlı Cihaz: ${controller.selectedDevice.value?.name}'),
                ElevatedButton(
                  onPressed: controller.disconnectDevice,
                  child: Text('Bağlantıyı Kes'),
                ),
              ],
            ),
          SizedBox(height: 20),
          Text('Süt Miktarı: ${controller.milkAmount.value} L', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: controller.measurements.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Ölçüm ${index + 1}: ${controller.measurements[index]} L'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: controller.clearMeasurements,
            child: Text('Ölçümleri Temizle'),
          ),
        ],
      )),
    );
  }
}