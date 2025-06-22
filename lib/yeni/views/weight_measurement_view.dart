import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/weight_controller.dart';
import 'device_selection_view.dart';

class WeightMeasurementView extends GetView<WeightController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ağırlık Ölçümü')),
      body: Obx(() => Column(
        children: [
          if (!controller.isDeviceConnected.value)
            ElevatedButton(
              onPressed: () => Get.to(() => DeviceSelectionView<WeightController>()),
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
          Text('Ağırlık: ${controller.weight.value} kg', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: controller.measurements.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Ölçüm ${index + 1}: ${controller.measurements[index]} kg'),
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