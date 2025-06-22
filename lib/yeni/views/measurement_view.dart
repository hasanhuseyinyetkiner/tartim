// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/base_measurement_controller.dart';
// import 'device_selection_view.dart';
//
// class MeasurementView<T extends BaseMeasurementController> extends GetView<T> {
//   final String title;
//   final String measurementLabel;
//
//   const MeasurementView({Key? key, required this.title, required this.measurementLabel}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: Obx(() => Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (!controller.isDeviceConnected.value)
//             ElevatedButton(
//               onPressed: () => Get.to(() => DeviceSelectionView<T>()),
//               child: Text('Cihaz Seç'),
//             )
//           else
//             Column(
//               children: [
//                 Text('Bağlı Cihaz: ${controller.selectedDevice.value?.name}'),
//                 ElevatedButton(
//                   onPressed: controller.disconnectDevice,
//                   child: Text('Bağlantıyı Kes'),
//                 ),
//               ],
//             ),
//           SizedBox(height: 20),
//           Text('$measurementLabel: ${controller.measurements.lastOrNull ?? 0.0}'),
//           SizedBox(height: 20),
//           Expanded(
//             child: ListView.builder(
//               itemCount: controller.measurements.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text('Ölçüm ${index + 1}: ${controller.measurements[index]}'),
//                 );
//               },
//             ),
//           ),
//         ],
//       )),
//     );
//   }
// }