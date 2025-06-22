import 'package:animaltracker/app/data/models/olcum_tipi.dart';
import 'package:animaltracker/app/modules/weight_measurement/weight_measurement_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:animaltracker/routes/app_pages.dart';

class WeightMeasurementView extends GetView<WeightMeasurementController> {
  const WeightMeasurementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('weight_measurement'.tr),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Get.toNamed(Routes.WEIGHT_ANALYSIS),
            tooltip: 'Ağırlık Analizi',
          ),
          Obx(() => controller.isDeviceConnected
              ? IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterBottomSheet(context),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (!controller.isDeviceConnected) {
            return _buildNoDeviceConnectedView(context);
          } else {
            return _buildMeasurementView(context);
          }
        }),
      ),
    );
  }

  Widget _buildNoDeviceConnectedView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/no_device_connected.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'bluetooth_disconnected'.tr,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.bluetooth_searching),
            label: Text('connect'.tr),
            onPressed: () => Get.toNamed('/devices'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMeasurementStepIndicator(context),
            const SizedBox(height: 16),
            _buildConnectedDeviceInfo(context),
            const SizedBox(height: 24),
            _buildCurrentMeasurementCard(context),
            const SizedBox(height: 24),
            _buildAnimalInfo(),
            const SizedBox(height: 24),
            _buildMeasurementTypeSelection(context),
            const SizedBox(height: 24),
            _buildControlButtons(context),
            const SizedBox(height: 24),
            _buildWeightChart(context),
            const SizedBox(height: 24),
            _buildMeasurementHistory(context),
            if (controller.filteredMeasurements.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildFilteredMeasurements(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementStepIndicator(BuildContext context) {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStepIndicator(context, 1, 'Hazırlanma',
                  controller.currentMeasurementStep.value >= 1),
              _buildStepConnector(
                  context, controller.currentMeasurementStep.value >= 2),
              _buildStepIndicator(context, 2, 'Ölçüm',
                  controller.currentMeasurementStep.value >= 2),
              _buildStepConnector(
                  context, controller.currentMeasurementStep.value >= 3),
              _buildStepIndicator(context, 3, 'Kaydet',
                  controller.currentMeasurementStep.value >= 3),
            ],
          ),
        ));
  }

  Widget _buildStepIndicator(
      BuildContext context, int step, String label, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isActive
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.5),
          child: Text(
            '$step',
            style: TextStyle(
              color: isActive
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(BuildContext context, bool isActive) {
    return Container(
      width: 25,
      height: 2,
      color: isActive
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.outline.withOpacity(0.5),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _buildFilterContent(context);
      },
    );
  }

  Widget _buildFilterContent(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ölçüm Filtreleme',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Ölçüm Tipi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildMeasurementTypeChips(context),
              const SizedBox(height: 16),
              Text(
                'Sıralama',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildSortingOptions(context),
              const SizedBox(height: 16),
              Text(
                'Tarih Aralığı',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildDateRangeSelector(context),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  controller.fetchFilteredMeasurements();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Filtreleri Uygula'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  controller.resetFilters();
                  Navigator.pop(context);
                },
                child: const Text('Filtreleri Sıfırla'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeasurementTypeChips(BuildContext context) {
    return Obx(() => Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: OlcumTipi.values.map((type) {
            final isSelected = controller.selectedOlcumTipi.value == type;
            return FilterChip(
              label: Text(type.displayName),
              selected: isSelected,
              selectedColor:
                  Color(controller.olcumTipiColors[type] ?? 0xFF000000)
                      .withOpacity(0.2),
              checkmarkColor:
                  Color(controller.olcumTipiColors[type] ?? 0xFF000000),
              labelStyle: TextStyle(
                color: isSelected
                    ? Color(controller.olcumTipiColors[type] ?? 0xFF000000)
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  controller.changeOlcumTipi(type);
                }
              },
            );
          }).toList(),
        ));
  }

  Widget _buildSortingOptions(BuildContext context) {
    return Obx(() => Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ChoiceChip(
              label: const Text('Ağırlık ↓'),
              selected: controller.selectedSorting.value == 'agirlik_azalan',
              onSelected: (selected) {
                if (selected) {
                  controller.changeSorting('agirlik_azalan');
                }
              },
            ),
            ChoiceChip(
              label: const Text('Ağırlık ↑'),
              selected: controller.selectedSorting.value == 'agirlik_artan',
              onSelected: (selected) {
                if (selected) {
                  controller.changeSorting('agirlik_artan');
                }
              },
            ),
            ChoiceChip(
              label: const Text('Tarih (Yeni-Eski)'),
              selected: controller.selectedSorting.value == 'tarih',
              onSelected: (selected) {
                if (selected) {
                  controller.changeSorting('tarih');
                }
              },
            ),
          ],
        ));
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: controller.startDate.value ??
                          DateTime.now().subtract(const Duration(days: 30)),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.setDateFilters(date, controller.endDate.value);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Başlangıç',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            controller.startDate.value != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(controller.startDate.value!)
                                : 'Seçilmedi',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
          const SizedBox(width: 16),
          const Text('—', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() => InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: controller.endDate.value ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.setDateFilters(
                          controller.startDate.value, date);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bitiş',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            controller.endDate.value != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(controller.endDate.value!)
                                : 'Seçilmedi',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMeasurementCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ölçüm Değeri',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Obx(() {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              controller.weightMeasurementBluetooth
                                  .currentWeight.value
                                  .toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'kg',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 80,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'RFID',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                            controller.weightMeasurementBluetooth.currentRfid
                                    .value.isEmpty
                                ? 'RFID Bekleniyor'
                                : controller.weightMeasurementBluetooth
                                    .currentRfid.value,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: controller.weightMeasurementBluetooth
                                      .currentRfid.value.isEmpty
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => LinearProgressIndicator(
                  value: controller.isMeasuring.value ? null : 0,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  color: Theme.of(context).colorScheme.primary,
                )),
            const SizedBox(height: 8),
            Obx(() => Text(
                  controller.measurementStatus.value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDeviceInfo(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bluetooth_connected,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'bluetooth_connected'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              controller.connectedDevice?.name ?? 'unknown_device'.tr,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.bluetooth_disabled),
              label: Text('disconnect'.tr),
              onPressed: controller.disconnectDevice,
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onError,
                backgroundColor: Theme.of(context).colorScheme.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalInfo() {
    return Obx(() {
      final animal = controller.currentAnimal.value;
      if (animal == null) {
        return const SizedBox.shrink();
      }
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('animal_info'.tr, style: Get.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('${'name'.tr}: ${animal.name}'),
              Text('${'type'.tr}: ${controller.animalTypeName.value}'),
              Text('${'ear_tag'.tr}: ${animal.earTag}'),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildControlButtons(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(controller.isMeasuring.value
                    ? Icons.stop
                    : Icons.play_arrow),
                label: Text(controller.isMeasuring.value
                    ? 'end_measurement'.tr
                    : 'start_measurement'.tr),
                onPressed: controller.isMeasuring.value
                    ? controller.finalizeMeasurement
                    : controller.startMeasurement,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: controller.isMeasuring.value
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: controller.resetMeasurement,
              child: const Icon(Icons.refresh),
              style: ElevatedButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ));
  }

  Widget _buildWeightChart(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('last_seven_measurements_chart'.tr,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() => LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: true),
                      minX: 0,
                      maxX: 6,
                      minY: 0,
                      maxY: controller.getMaxWeight(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: controller.getChartData(),
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1)),
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementHistory(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('recent_measurements'.tr,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.measurementHistory.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'no_measurements'.tr,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.measurementHistory.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  final measurement = controller.measurementHistory[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text('${index + 1}'),
                    ),
                    title: Text('${measurement.weight.toStringAsFixed(2)} kg'),
                    subtitle: Text('RFID: ${measurement.rfid}'),
                    trailing: Text(measurement.timestamp),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredMeasurements(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrelenmiş Ölçümler',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Obx(() => controller.isSyncing.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: controller.fetchFilteredMeasurements,
                      )),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.filteredMeasurements.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('Filtrelenmiş ölçüm bulunamadı'),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.filteredMeasurements.length.clamp(0, 10),
                itemBuilder: (context, index) {
                  final measurement = controller.filteredMeasurements[index];
                  final date = DateTime.parse(measurement.timestamp);
                  final formattedDate =
                      DateFormat('dd/MM/yyyy HH:mm').format(date);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(
                          controller.olcumTipiColors[measurement.olcumTipi] ??
                              0xFF000000),
                      child: Text('${index + 1}'),
                    ),
                    title: Text('${measurement.weight.toStringAsFixed(1)} kg'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RFID: ${measurement.rfid}'),
                        Text('Tarih: $formattedDate'),
                        Text('Tip: ${measurement.olcumTipi.displayName}'),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementTypeSelection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ölçüm Tipi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() => Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: OlcumTipi.values.map((type) {
                    final isSelected =
                        controller.selectedOlcumTipi.value == type;
                    return ChoiceChip(
                      label: Text(type.displayName),
                      selected: isSelected,
                      selectedColor:
                          Color(controller.olcumTipiColors[type] ?? 0xFF000000)
                              .withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Color(
                                controller.olcumTipiColors[type] ?? 0xFF000000)
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          controller.changeOlcumTipi(type);
                        }
                      },
                    );
                  }).toList(),
                )),
          ],
        ),
      ),
    );
  }
}
