import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tartim/app/modules/animal_profile/animal_profile_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tartim/app/data/models/animal.dart';
import 'package:tartim/app/data/models/device.dart';

class AnimalProfileView extends GetView<AnimalProfileController> {
  const AnimalProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.animal.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfo(context),
                    const SizedBox(height: 24),
                    _buildParentInfo(context),
                    const SizedBox(height: 24),
                    _buildWeightSection(),
                    const SizedBox(height: 24),
                    _buildNotes(context),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(() => FloatingActionButton(
                mini: true,
                backgroundColor: controller.isDeviceConnected.value
                    ? Colors.blue
                    : Colors.grey,
                onPressed: () => _showBluetoothDeviceSheet(context),
                tooltip: 'Bluetooth RFID',
                child: Icon(
                  controller.isDeviceConnected.value
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth,
                  color: Colors.white,
                ),
              )),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () => _showEditDialog(context),
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(controller.animal.value!.name),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'animal_${controller.animal.value!.id}',
              child: controller.animalImage.value != null
                  ? Image.file(controller.animalImage.value!, fit: BoxFit.cover)
                  : Image.asset('assets/images/default_animal.png',
                      fit: BoxFit.cover),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    controller.getAnimalTypeColor().withOpacity(0.3),
                    controller.getAnimalTypeColor().withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Icon(controller.getAnimalTypeIcon(),
            color: controller.getAnimalTypeColor()),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.camera_alt),
          onPressed: () => controller.pickImage(),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showDeleteConfirmation(context),
        ),
      ],
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Temel Bilgiler',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildInfoRow('Tür', controller.animalTypeName.value),
            _buildInfoRow('Kulak Küpe', controller.animal.value!.earTag),
            _buildInfoRow('RFID', controller.animal.value!.rfid),
            _buildInfoRow('Yaş', controller.calculateAge()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildParentInfo(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soy Bilgisi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: [
                    // Anne bilgisi
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.female, color: Colors.pink),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Anne',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                if (controller.motherAnimal.value != null) ...[
                                  Text(
                                      'RFID: ${controller.motherAnimal.value!.rfid}'),
                                  Text(
                                      'İsim: ${controller.motherAnimal.value!.name}'),
                                ] else
                                  const Text('Bilgi yok',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Baba bilgisi
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.male, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Baba',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                if (controller.fatherAnimal.value != null) ...[
                                  Text(
                                      'RFID: ${controller.fatherAnimal.value!.rfid}'),
                                  Text(
                                      'İsim: ${controller.fatherAnimal.value!.name}'),
                                ] else
                                  const Text('Bilgi yok',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightSection() {
    return Card(
      elevation: 2,
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
                  'Ağırlık Geçmişi',
                  style: Get.textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(
                    '/weight-measurement',
                    arguments: {'rfid': controller.animal.value!.rfid},
                  ),
                  icon: const Icon(Icons.scale),
                  label: const Text('Ağırlık Ölç'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Get.theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Filtre seçenekleri
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip(WeightChartFilter.last7Days, 'Son 7 Gün'),
                _filterChip(WeightChartFilter.last30Days, 'Son 30 Gün'),
                _filterChip(WeightChartFilter.last90Days, 'Son 90 Gün'),
                _filterChip(WeightChartFilter.last6Months, 'Son 6 Ay'),
                _filterChip(WeightChartFilter.lastYear, 'Son 1 Yıl'),
                _filterChip(WeightChartFilter.custom, 'Özel'),
              ],
            ),
            // Özel tarih seçimi
            if (controller.selectedFilter.value == WeightChartFilter.custom)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Obx(() => Text(
                              controller.customStartDate.value != null
                                  ? DateFormat('dd.MM.yyyy')
                                      .format(controller.customStartDate.value!)
                                  : 'Başlangıç',
                            )),
                        onPressed: () => _selectDate(true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Obx(() => Text(
                              controller.customEndDate.value != null
                                  ? DateFormat('dd.MM.yyyy')
                                      .format(controller.customEndDate.value!)
                                  : 'Bitiş',
                            )),
                        onPressed: () => _selectDate(false),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // İstatistikler
            Obx(() {
              final stats = controller.getWeightStats();
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCard(
                        'Min',
                        '${stats['minWeight']?.toStringAsFixed(1)} kg',
                        Colors.blue,
                      ),
                      _statCard(
                        'Maks',
                        '${stats['maxWeight']?.toStringAsFixed(1)} kg',
                        Colors.red,
                      ),
                      _statCard(
                        'Ort',
                        '${stats['avgWeight']?.toStringAsFixed(1)} kg',
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCard(
                        'Toplam Değişim',
                        '${stats['totalChange']?.toStringAsFixed(1)} kg',
                        Colors.orange,
                      ),
                      _statCard(
                        'Ort. Değişim',
                        '${stats['avgChange']?.toStringAsFixed(1)} kg',
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            // Grafik veya tablo görünümü
            Obx(() {
              if (controller.showWeightAsChart.value) {
                return _buildWeightChart();
              } else {
                return _buildWeightTable();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    return SizedBox(
      height: 300,
      child: Obx(() {
        final measurements = controller.filteredWeightHistory;
        if (measurements.isEmpty) {
          return const Center(
            child: Text('Bu dönem için ölçüm bulunmuyor'),
          );
        }

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < measurements.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('dd/MM')
                              .format(measurements[value.toInt()].date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            minX: 0,
            maxX: measurements.length.toDouble() - 1,
            minY: 0,
            maxY: controller.getMaxWeight(),
            lineBarsData: [
              LineChartBarData(
                spots: measurements
                    .asMap()
                    .entries
                    .map((e) => FlSpot(
                          e.key.toDouble(),
                          e.value.weight,
                        ))
                    .toList(),
                isCurved: true,
                color: Theme.of(Get.context!).primaryColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: Theme.of(Get.context!).primaryColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpots) =>
                    Colors.blueGrey.withOpacity(0.8),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final measurement = measurements[touchedSpot.x.toInt()];
                    return LineTooltipItem(
                      '${DateFormat('dd/MM/yyyy').format(measurement.date)}\n${measurement.weight.toStringAsFixed(1)} kg',
                      const TextStyle(color: Colors.white),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWeightTable() {
    return Obx(() {
      final measurements = controller.filteredWeightHistory;
      if (measurements.isEmpty) {
        return const Center(
          child: Text('Bu dönem için ölçüm bulunmuyor'),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Tarih')),
            DataColumn(label: Text('Ağırlık (kg)')),
            DataColumn(label: Text('Değişim (kg)')),
            DataColumn(label: Text('% Değişim')),
          ],
          rows: List.generate(measurements.length, (index) {
            final measurement = measurements[index];
            double? change;
            double? percentChange;

            if (index > 0) {
              change = measurement.weight - measurements[index - 1].weight;
              percentChange = (change / measurements[index - 1].weight) * 100;
            }

            return DataRow(
              cells: [
                DataCell(
                    Text(DateFormat('dd/MM/yyyy').format(measurement.date))),
                DataCell(Text(measurement.weight.toStringAsFixed(1))),
                DataCell(change != null
                    ? Text(
                        '${change.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: change >= 0 ? Colors.green : Colors.red,
                        ),
                      )
                    : const Text('-')),
                DataCell(percentChange != null
                    ? Text(
                        '${percentChange.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: percentChange >= 0 ? Colors.green : Colors.red,
                        ),
                      )
                    : const Text('-')),
              ],
            );
          }),
        ),
      );
    });
  }

  Widget _filterChip(WeightChartFilter filter, String label) {
    return Obx(() => FilterChip(
          selected: controller.selectedFilter.value == filter,
          label: Text(label),
          onSelected: (selected) {
            if (selected) {
              controller.changeFilter(filter);
            }
          },
        ));
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      if (isStart) {
        controller.customStartDate.value = picked;
      } else {
        controller.customEndDate.value = picked;
      }
      if (controller.customStartDate.value != null &&
          controller.customEndDate.value != null) {
        controller.setCustomDateRange(
          controller.customStartDate.value!,
          controller.customEndDate.value!,
        );
      }
    }
  }

  Widget _buildNotes(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notlar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(controller.notes.value),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showEditNotesDialog(context),
              child: const Text('Notları Düzenle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController =
        TextEditingController(text: controller.animal.value!.name);
    final earTagController =
        TextEditingController(text: controller.animal.value!.earTag);
    final rfidController =
        TextEditingController(text: controller.animal.value!.rfid);
    final motherRfidController =
        TextEditingController(text: controller.animal.value?.motherRfid ?? '');
    final fatherRfidController =
        TextEditingController(text: controller.animal.value?.fatherRfid ?? '');

    ever(controller.scannedRfid, (rfid) {
      if (rfid.isNotEmpty) {
        rfidController.text = rfid;
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hayvan Bilgilerini Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'İsim'),
                ),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: controller.selectedTypeId.value,
                        items: controller.animalTypes
                            .map((type) => DropdownMenuItem<int>(
                                  value: type.id!,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Text(type.name!),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedTypeId.value = value;
                          }
                        },
                      ),
                    )),
                const SizedBox(height: 8),
                TextField(
                  controller: earTagController,
                  decoration: const InputDecoration(labelText: 'Kulak Küpe No'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: rfidController,
                        decoration: const InputDecoration(labelText: 'RFID'),
                      ),
                    ),
                    Obx(() => IconButton(
                          icon: Icon(
                            Icons.nfc,
                            color: controller.isDeviceConnected.value
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          onPressed: controller.isDeviceConnected.value
                              ? () {
                                  controller.scannedRfid.value = '';
                                  _showBluetoothReadDialog(context);
                                }
                              : () => Get.snackbar(
                                    'Uyarı',
                                    'RFID okumak için önce bir Bluetooth cihazına bağlanın',
                                    snackPosition: SnackPosition.BOTTOM,
                                  ),
                          tooltip: 'RFID Oku',
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: motherRfidController,
                        decoration: InputDecoration(
                          labelText: 'Anne RFID',
                          prefixIcon: const Icon(Icons.female),
                        ),
                      ),
                    ),
                    Obx(() => IconButton(
                          icon: Icon(
                            Icons.nfc,
                            color: controller.isDeviceConnected.value
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          onPressed: controller.isDeviceConnected.value
                              ? () {
                                  controller.scannedRfid.value = '';
                                  _showBluetoothReadDialog(context);
                                }
                              : null,
                          tooltip: 'Anne RFID Oku',
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fatherRfidController,
                        decoration: InputDecoration(
                          labelText: 'Baba RFID',
                          prefixIcon: const Icon(Icons.male),
                        ),
                      ),
                    ),
                    Obx(() => IconButton(
                          icon: Icon(
                            Icons.nfc,
                            color: controller.isDeviceConnected.value
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          onPressed: controller.isDeviceConnected.value
                              ? () {
                                  controller.scannedRfid.value = '';
                                  _showBluetoothReadDialog(context);
                                }
                              : null,
                          tooltip: 'Baba RFID Oku',
                        )),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.updateAnimal(
                  name: nameController.text,
                  earTag: earTagController.text,
                  rfid: rfidController.text,
                  typeId: controller.selectedTypeId.value,
                  motherRfid: motherRfidController.text.isNotEmpty
                      ? motherRfidController.text
                      : null,
                  fatherRfid: fatherRfidController.text.isNotEmpty
                      ? fatherRfidController.text
                      : null,
                );
                Get.back();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hayvanı Sil'),
        content: const Text('Bu hayvanı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteAnimal();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    final weightController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Yeni Ağırlık Ölçümü Ekle'),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Ağırlık (kg)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (weightController.text.isNotEmpty) {
                controller
                    .addWeightMeasurement(double.parse(weightController.text));
                Get.back();
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showEditNotesDialog(BuildContext context) {
    final notesController = TextEditingController(text: controller.notes.value);
    Get.dialog(
      AlertDialog(
        title: const Text('Notları Düzenle'),
        content: TextField(
          controller: notesController,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Notlar'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateNotes(notesController.text);
              Get.back();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showBluetoothDeviceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bluetooth Cihazları',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => controller.isBluetoothScanning.value
                          ? const CircularProgressIndicator()
                          : Container()),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text('Cihazları Tara'),
                        onPressed: () => controller.scanBluetoothDevices(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Obx(() {
                      if (controller.availableDevices.isEmpty) {
                        return const Center(
                          child: Text('Cihaz bulunamadı. Tarama yapın.'),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: controller.availableDevices.length,
                        itemBuilder: (context, index) {
                          final device = controller.availableDevices[index];
                          return _buildDeviceListTile(device, context);
                        },
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDeviceListTile(Device device, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.bluetooth, color: Colors.blue),
        title: Text(device.name),
        subtitle: Text('Signal: ${device.rssi} dBm'),
        trailing: Obx(() {
          if (controller.connectedDevice.value?.id == device.id) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Bağlantıyı Kes'),
              onPressed: () => controller.disconnectDevice(),
            );
          }

          if (controller.isBluetoothConnecting.value) {
            return const CircularProgressIndicator();
          }

          return ElevatedButton(
            child: const Text('Bağlan'),
            onPressed: () {
              controller.connectToDevice(device);
              Navigator.pop(context);
            },
          );
        }),
      ),
    );
  }

  void _showBluetoothReadDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('RFID Okuma'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Lütfen RFID etiketini cihaza yaklaştırın...'),
              const SizedBox(height: 16),
              Obx(() => controller.scannedRfid.value.isNotEmpty
                  ? Text(
                      'Okunan RFID: ${controller.scannedRfid.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Container()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            Obx(() => ElevatedButton(
                  onPressed: controller.scannedRfid.value.isNotEmpty
                      ? () {
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Kullan'),
                )),
          ],
        );
      },
    );
  }
}
