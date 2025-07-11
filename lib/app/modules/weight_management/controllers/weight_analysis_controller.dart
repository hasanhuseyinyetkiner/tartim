import 'package:get/get.dart';
import 'package:tartim/app/data/models/animal.dart';
import 'package:tartim/app/data/models/measurement.dart';
import 'package:tartim/app/data/models/weight_measurement.dart';
import 'package:tartim/app/data/repositories/animal_repository.dart';
import 'package:tartim/app/data/repositories/measurement_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

extension WeightMeasurementConverter on WeightMeasurement {
  Measurement toMeasurement() {
    return Measurement(
      weight: weight,
      animalRfid: rfid,
      timestamp: measurementDate.toIso8601String(),
    );
  }
}

class WeightAnalysisController extends GetxController {
  final AnimalRepository animalRepository;
  final MeasurementRepository measurementRepository;

  WeightAnalysisController({
    required this.animalRepository,
    required this.measurementRepository,
  });

  final RxList<Animal> animals = <Animal>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedTimeRange = 'all'.obs;
  final Rx<DateTime?> customStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> customEndDate = Rx<DateTime?>(null);

  // Weight gain analysis results
  final RxList<Map<String, dynamic>> weightGainAnalysis =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWeightGainAnalysis();
  }

  Future<void> loadWeightGainAnalysis() async {
    try {
      isLoading.value = true;

      // Get all animals with their weight gain data
      final animalList = await animalRepository.getAllAnimalsWithWeightGain();

      // Process each animal's measurements
      final analysisResults = <Map<String, dynamic>>[];

      for (final animal in animalList) {
        final weightMeasurements =
            await measurementRepository.getMeasurementsByRfid(animal.rfid);
        final measurements =
            weightMeasurements.map((m) => m.toMeasurement()).toList();
        if (measurements.isEmpty) continue;

        // Filter measurements based on selected time range
        final filteredMeasurements =
            _filterMeasurementsByTimeRange(measurements);
        if (filteredMeasurements.length < 2) continue;

        // Calculate weight gain metrics
        final firstWeight = filteredMeasurements.first.weight;
        final lastWeight = filteredMeasurements.last.weight;
        final weightGain = lastWeight - firstWeight;

        final firstDate = DateTime.parse(filteredMeasurements.first.timestamp);
        final lastDate = DateTime.parse(filteredMeasurements.last.timestamp);
        final daysDifference = lastDate.difference(firstDate).inDays;
        final dailyGainRate =
            daysDifference > 0 ? weightGain / daysDifference : 0;

        // Calculate additional statistics
        final stats = _calculateWeightStats(filteredMeasurements);

        analysisResults.add({
          'animal': animal,
          'firstWeight': firstWeight,
          'lastWeight': lastWeight,
          'weightGain': weightGain,
          'dailyGainRate': dailyGainRate,
          'measurementPeriod': daysDifference,
          'minWeight': stats['minWeight'],
          'maxWeight': stats['maxWeight'],
          'avgWeight': stats['avgWeight'],
          'measurements': filteredMeasurements,
        });
      }

      // Sort by weight gain (descending)
      analysisResults.sort((a, b) =>
          (b['weightGain'] as double).compareTo(a['weightGain'] as double));

      weightGainAnalysis.value = analysisResults;
    } catch (e) {
      print('Error loading weight gain analysis: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Measurement> _filterMeasurementsByTimeRange(
      List<Measurement> measurements) {
    if (selectedTimeRange.value == 'all') return measurements;

    final now = DateTime.now();
    final cutoffDate = switch (selectedTimeRange.value) {
      'last7Days' => now.subtract(const Duration(days: 7)),
      'last30Days' => now.subtract(const Duration(days: 30)),
      'last90Days' => now.subtract(const Duration(days: 90)),
      'last6Months' => DateTime(now.year, now.month - 6, now.day),
      'lastYear' => DateTime(now.year - 1, now.month, now.day),
      'custom' => customStartDate.value,
      _ => null
    };

    if (cutoffDate == null) return measurements;

    return measurements.where((m) {
      final measurementDate = DateTime.parse(m.timestamp);
      if (selectedTimeRange.value == 'custom' && customEndDate.value != null) {
        return measurementDate.isAfter(cutoffDate) &&
            measurementDate
                .isBefore(customEndDate.value!.add(const Duration(days: 1)));
      }
      return measurementDate.isAfter(cutoffDate);
    }).toList();
  }

  Map<String, double> _calculateWeightStats(List<Measurement> measurements) {
    if (measurements.isEmpty) {
      return {
        'minWeight': 0,
        'maxWeight': 0,
        'avgWeight': 0,
      };
    }

    final weights = measurements.map((m) => m.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final avgWeight = weights.reduce((a, b) => a + b) / weights.length;

    return {
      'minWeight': minWeight,
      'maxWeight': maxWeight,
      'avgWeight': avgWeight,
    };
  }

  List<FlSpot> getWeightChartData(List<Measurement> measurements) {
    return measurements.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();
  }

  void changeTimeRange(String range) {
    selectedTimeRange.value = range;
    loadWeightGainAnalysis();
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    customStartDate.value = start;
    customEndDate.value = end;
    selectedTimeRange.value = 'custom';
    loadWeightGainAnalysis();
  }

  String formatDate(String timestamp) {
    final date = DateTime.parse(timestamp);
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
