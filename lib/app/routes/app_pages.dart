import 'package:get/get.dart';
import 'package:animaltracker/app/modules/weight_management/bindings/weight_analysis_binding.dart';
import 'package:animaltracker/app/modules/weight_management/views/weight_analysis_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    // ... existing routes ...
    GetPage(
      name: Routes.WEIGHT_ANALYSIS,
      page: () => const WeightAnalysisView(),
      binding: WeightAnalysisBinding(),
    ),
  ];
}
