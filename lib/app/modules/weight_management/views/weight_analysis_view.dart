import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tartim/app/data/models/measurement.dart';
import '../controllers/weight_analysis_controller.dart';

class WeightAnalysisView extends GetView<WeightAnalysisController> {
  const WeightAnalysisView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ağırlık Kazanım Analizi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.weightGainAnalysis.isEmpty) {
          return const Center(
            child: Text('Analiz için yeterli veri bulunamadı.'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadWeightGainAnalysis(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTimeRangeChips(),
              const SizedBox(height: 16),
              ...controller.weightGainAnalysis.map((analysis) {
                return _buildAnimalAnalysisCard(context, analysis);
              }).toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTimeRangeChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('all', 'Tümü'),
          _buildFilterChip('last7Days', 'Son 7 Gün'),
          _buildFilterChip('last30Days', 'Son 30 Gün'),
          _buildFilterChip('last90Days', 'Son 90 Gün'),
          _buildFilterChip('last6Months', 'Son 6 Ay'),
          _buildFilterChip('lastYear', 'Son 1 Yıl'),
          _buildFilterChip('custom', 'Özel'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Obx(() {
        final isSelected = controller.selectedTimeRange.value == value;
        return FilterChip(
          selected: isSelected,
          label: Text(label),
          onSelected: (selected) {
            if (value == 'custom') {
              _showDateRangePicker(Get.context!);
            } else {
              controller.changeTimeRange(value);
            }
          },
        );
      }),
    );
  }

  Widget _buildAnimalAnalysisCard(
      BuildContext context, Map<String, dynamic> analysis) {
    final animal = analysis['animal'];
    final weightGain = analysis['weightGain'] as double;
    final dailyGainRate = analysis['dailyGainRate'] as double;
    final measurementPeriod = analysis['measurementPeriod'] as int;
    final measurements = analysis['measurements'] as List<Measurement>;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              animal.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('RFID: ${animal.rfid}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  context,
                  'Toplam Kazanım',
                  '${weightGain.toStringAsFixed(1)} kg',
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  'Günlük Ortalama',
                  '${dailyGainRate.toStringAsFixed(2)} kg/gün',
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  'Ölçüm Süresi',
                  '$measurementPeriod gün',
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  minX: 0,
                  maxX: measurements.length.toDouble() - 1,
                  minY: analysis['minWeight'] as double,
                  maxY: (analysis['maxWeight'] as double) * 1.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.getWeightChartData(measurements),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreleme Seçenekleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Özel Tarih Aralığı'),
              onTap: () {
                Navigator.pop(context);
                _showDateRangePicker(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
    );

    if (pickedDateRange != null) {
      controller.setCustomDateRange(
        pickedDateRange.start,
        pickedDateRange.end,
      );
    }
  }
}
