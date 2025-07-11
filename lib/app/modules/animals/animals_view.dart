import 'package:tartim/app/data/models/animal.dart';
import 'package:tartim/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tartim/app/modules/animals/animals_controller.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tartim/app/widgets/chart_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tartim/app/data/models/animal_type.dart';
import 'package:tartim/app/widgets/connection_status_widget.dart';

class AnimalsView extends GetView<AnimalsController> {
  const AnimalsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hayvanlar'),
        actions: [
          Obx(() => ConnectionStatusWidget(
                isOnline: controller.isOnline,
                isSyncing: controller.isSyncing,
                onSync: () => controller.syncPendingOperations(),
              )),
          SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showSortOptions(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(Routes.ANIMAL_ADD),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          _buildSortBar(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshAnimals,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.filteredAnimals.isEmpty) {
                  return _buildEmptyState();
                }
                return AnimationLimiter(
                  child: ListView.builder(
                    itemCount: controller.filteredAnimals.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildAnimalCard(
                                context, controller.filteredAnimals[index]),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.ANIMAL_ADD),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text(
                    'Sıralama Seçenekleri',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('İsim (A-Z)'),
                  onTap: () {
                    controller.changeSortOption(SortOption.nameAsc);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('İsim (Z-A)'),
                  onTap: () {
                    controller.changeSortOption(SortOption.nameDesc);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.monitor_weight),
                  title: const Text('Ağırlık (Artan)'),
                  onTap: () {
                    controller.changeSortOption(SortOption.weightAsc);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.monitor_weight),
                  title: const Text('Ağırlık (Azalan)'),
                  onTap: () {
                    controller.changeSortOption(SortOption.weightDesc);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('En Yeni Ölçüm'),
                  onTap: () {
                    controller.changeSortOption(SortOption.latest);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('En Eski Ölçüm'),
                  onTap: () {
                    controller.changeSortOption(SortOption.oldest);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.trending_up),
                  title: const Text('En Çok Kilo Alanlar'),
                  onTap: () {
                    controller.changeSortOption(SortOption.weightGain);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Text('Sıralama:',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(() {
              String sortText;
              IconData sortIcon;

              switch (controller.currentSortOption.value) {
                case SortOption.nameAsc:
                  sortText = 'İsim (A-Z)';
                  sortIcon = Icons.sort_by_alpha;
                  break;
                case SortOption.nameDesc:
                  sortText = 'İsim (Z-A)';
                  sortIcon = Icons.sort_by_alpha;
                  break;
                case SortOption.weightAsc:
                  sortText = 'Ağırlık (Artan)';
                  sortIcon = Icons.monitor_weight;
                  break;
                case SortOption.weightDesc:
                  sortText = 'Ağırlık (Azalan)';
                  sortIcon = Icons.monitor_weight;
                  break;
                case SortOption.latest:
                  sortText = 'En Yeni Ölçüm';
                  sortIcon = Icons.access_time;
                  break;
                case SortOption.oldest:
                  sortText = 'En Eski Ölçüm';
                  sortIcon = Icons.access_time;
                  break;
                case SortOption.weightGain:
                  sortText = 'En Çok Kilo Alanlar';
                  sortIcon = Icons.trending_up;
                  break;
                case SortOption.ageAscending:
                  sortText = 'Yaş (Artan)';
                  sortIcon = Icons.cake;
                  break;
                case SortOption.ageDescending:
                  sortText = 'Yaş (Azalan)';
                  sortIcon = Icons.cake;
                  break;
                case SortOption.weightAscending:
                  sortText = 'Ağırlık (Küçükten Büyüğe)';
                  sortIcon = Icons.monitor_weight;
                  break;
                case SortOption.weightDescending:
                  sortText = 'Ağırlık (Büyükten Küçüğe)';
                  sortIcon = Icons.monitor_weight;
                  break;
                case SortOption.nameAscending:
                  sortText = 'İsim (A-Z)';
                  sortIcon = Icons.sort_by_alpha;
                  break;
                case SortOption.nameDescending:
                  sortText = 'İsim (Z-A)';
                  sortIcon = Icons.sort_by_alpha;
                  break;
                case SortOption.dateAscending:
                  sortText = 'Tarih (Eskiden Yeniye)';
                  sortIcon = Icons.access_time;
                  break;
              }

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showSortOptions(context),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(sortIcon,
                            size: 16, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sortText,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down,
                            size: 16, color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: controller.filterAnimals,
            decoration: InputDecoration(
              hintText: 'search_animals'.tr,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.animalTypes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Kategorilere göre hayvan türlerini grupla
            final Map<String, List<AnimalType>> groupedTypes = {};
            for (var type in controller.animalTypes) {
              if (!groupedTypes.containsKey(type.category)) {
                groupedTypes[type.category] = [];
              }
              groupedTypes[type.category]!.add(type);
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: controller.selectedTypeId.value == 0
                      ? null
                      : controller.selectedTypeId.value,
                  hint: const Text('Hayvan türü seçin'),
                  items: [
                    const DropdownMenuItem<int>(
                      value: 0,
                      child: Text('Tüm Hayvanlar'),
                    ),
                    ...groupedTypes.entries
                        .expand((category) => [
                              DropdownMenuItem<int>(
                                enabled: false,
                                value: null,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    category.key,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              ...category.value
                                  .map((type) => DropdownMenuItem<int>(
                                        value: type.id!,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: Text(type.name!),
                                        ),
                                      )),
                              // Kategoriler arası ayırıcı
                              if (category.key != groupedTypes.keys.last)
                                const DropdownMenuItem<int>(
                                  enabled: false,
                                  value: null,
                                  child: Divider(),
                                ),
                            ])
                        .toList(),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedTypeId.value = value;
                    }
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnimalCard(BuildContext context, Animal animal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed(Routes.ANIMAL_PROFILE, arguments: animal),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  animal.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('${'ear_tag'.tr}: ${animal.earTag}'),
                    Text('RFID: ${animal.rfid}'),
                    Obx(() {
                      final lastMeasurement =
                          controller.lastMeasurements[animal.rfid];
                      if (lastMeasurement != null) {
                        return Column(
                          children: [
                            Text(
                              '${'last_measurement'.tr}: ${lastMeasurement.weight.toStringAsFixed(2)} kg',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              '${'date'.tr}: ${_formatDateTime(lastMeasurement.timestamp)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            FutureBuilder<List<FlSpot>>(
                              future:
                                  controller.getAnimalWeightData(animal.rfid),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 200,
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const SizedBox();
                                }

                                return ChartWidget(
                                  data: snapshot.data!,
                                  title: 'Ağırlık Değişimi',
                                );
                              },
                            ),
                          ],
                        );
                      } else {
                        return Text(
                          'no_measurement'.tr,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).disabledColor,
                          ),
                        );
                      }
                    }),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Çevrimdışı mod bildirimi
          Obx(() {
            if (!controller.isOnline.value) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Çevrimdışı moddasınız. İnternet bağlantısı sağlandığında veriler otomatik olarak senkronize edilecektir.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          }),
          Image.asset(
            'assets/images/empty_list.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz hiç hayvan eklenmemiş',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yeni bir hayvan eklemek için + düğmesine tıklayın',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
