import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/weight_measurement_view.dart';
import 'views/milk_measurement_view.dart';
import 'controllers/weight_controller.dart';
import 'controllers/milk_controller.dart';

class HomeViewTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ana Sayfa')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.lazyPut(() => WeightController());
                Get.to(() => WeightMeasurementView());
              },
              child: Text('Ağırlık Ölçümü'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.lazyPut(() => MilkController());
                Get.to(() => MilkMeasurementView());
              },
              child: Text('Süt Ölçümü'),
            ),
          ],
        ),
      ),
    );
  }
}