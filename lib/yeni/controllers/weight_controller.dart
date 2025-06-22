import 'dart:typed_data';

import 'package:get/get.dart';
import 'base_measurement_controller.dart';

class WeightController extends BaseMeasurementController {
  final weight = 0.0.obs;
  final measurements = <double>[].obs;

  @override
  String get deviceType => 'weight';

  @override
  void processMeasurementData(List<int> data) {
    if (data.length >= 4) {
      final bytes = Uint8List.fromList(data.sublist(0, 4));
      final value = ByteData.sublistView(bytes).getFloat32(0, Endian.little);
      weight.value = value;
      measurements.add(value);
    }
  }

  void clearMeasurements() {
    measurements.clear();
  }
}