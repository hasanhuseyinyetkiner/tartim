import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tartim/app/data/models/weight_measurement.dart';
import 'package:tartim/app/data/models/birth_weight_measurement.dart';
import 'package:tartim/app/data/models/weaning_weight_measurement.dart';
import '../controllers/weight_management_controller.dart';
import '../widgets/weight_list_item.dart';
import '../widgets/add_weight_dialog.dart';

class WeightManagementView extends GetView<WeightManagementController> {
  const WeightManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ağırlık Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: controller.synchronizeData,
            tooltip: 'Senkronize Et',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context),
            tooltip: 'Filtrele',
          ),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          tabs: const [
            Tab(text: 'Normal'),
            Tab(text: 'Sütten Kesim'),
            Tab(text: 'Doğum'),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _buildNormalWeightTab(),
          _buildWeaningWeightTab(),
          _buildBirthWeightTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Yeni Ölçüm Ekle',
      ),
    );
  }

  Widget _buildNormalWeightTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.normalWeightMeasurements.isEmpty) {
        return const Center(child: Text('Henüz ağırlık ölçümü yok.'));
      }

      return RefreshIndicator(
        onRefresh: controller.refreshNormalWeightData,
        child: ListView.builder(
          itemCount: controller.normalWeightMeasurements.length,
          itemBuilder: (context, index) {
            final measurement = controller.normalWeightMeasurements[index];
            return WeightListItem(
              weight: measurement.weight,
              date: measurement.measurementDate,
              animalId: measurement.animalId,
              animalName: controller.getAnimalNameById(measurement.animalId),
              notes: measurement.notes,
              onTap: () =>
                  _showMeasurementDetails(context, measurement: measurement),
              onEdit: () =>
                  _showEditDialog(context, normalMeasurement: measurement),
              onDelete: () =>
                  controller.deleteNormalWeightMeasurement(measurement.id!),
            );
          },
        ),
      );
    });
  }

  Widget _buildWeaningWeightTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.weaningWeightMeasurements.isEmpty) {
        return const Center(
            child: Text('Henüz sütten kesim ağırlık ölçümü yok.'));
      }

      return RefreshIndicator(
        onRefresh: controller.refreshWeaningWeightData,
        child: ListView.builder(
          itemCount: controller.weaningWeightMeasurements.length,
          itemBuilder: (context, index) {
            final measurement = controller.weaningWeightMeasurements[index];
            return WeightListItem(
              weight: measurement.weight,
              date: measurement.measurementDate,
              animalId: measurement.animalId,
              animalName: controller.getAnimalNameById(measurement.animalId),
              notes: measurement.notes,
              subtitle: measurement.weaningDate != null
                  ? 'Sütten Kesim: ${controller.formatDate(measurement.weaningDate!)}'
                  : null,
              onTap: () => _showMeasurementDetails(context,
                  weaningMeasurement: measurement),
              onEdit: () =>
                  _showEditDialog(context, weaningMeasurement: measurement),
              onDelete: () =>
                  controller.deleteWeaningWeightMeasurement(measurement.id!),
            );
          },
        ),
      );
    });
  }

  Widget _buildBirthWeightTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.birthWeightMeasurements.isEmpty) {
        return const Center(child: Text('Henüz doğum ağırlık ölçümü yok.'));
      }

      return RefreshIndicator(
        onRefresh: controller.refreshBirthWeightData,
        child: ListView.builder(
          itemCount: controller.birthWeightMeasurements.length,
          itemBuilder: (context, index) {
            final measurement = controller.birthWeightMeasurements[index];
            return WeightListItem(
              weight: measurement.weight,
              date: measurement.measurementDate,
              animalId: measurement.animalId,
              animalName: controller.getAnimalNameById(measurement.animalId),
              notes: measurement.notes,
              subtitle: measurement.birthDate != null
                  ? 'Doğum: ${controller.formatDate(measurement.birthDate!)}'
                  : null,
              onTap: () => _showMeasurementDetails(context,
                  birthMeasurement: measurement),
              onEdit: () =>
                  _showEditDialog(context, birthMeasurement: measurement),
              onDelete: () =>
                  controller.deleteBirthWeightMeasurement(measurement.id!),
            );
          },
        ),
      );
    });
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filtreleme Seçenekleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Tarihe Göre'),
              onTap: () {
                Navigator.pop(context);
                controller.filterByDate();
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Hayvana Göre'),
              onTap: () {
                Navigator.pop(context);
                controller.filterByAnimal();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Ağırlığa Göre (Artan)'),
              onTap: () {
                Navigator.pop(context);
                controller.sortByWeightAscending();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Ağırlığa Göre (Azalan)'),
              onTap: () {
                Navigator.pop(context);
                controller.sortByWeightDescending();
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Filtreyi Temizle'),
              onTap: () {
                Navigator.pop(context);
                controller.clearFilters();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final currentTab = controller.tabController.index;

    showDialog(
      context: context,
      builder: (context) => AddWeightDialog(
        initialOlcumTipi: currentTab == 0
            ? OlcumTipi.normal
            : currentTab == 1
                ? OlcumTipi.suttenKesim
                : OlcumTipi.yeniDogmus,
        onSave: (data, olcumTipi) {
          if (currentTab == 0) {
            controller.addNormalWeightMeasurement(data as WeightMeasurement);
          } else if (currentTab == 1) {
            controller
                .addWeaningWeightMeasurement(data as WeaningWeightMeasurement);
          } else {
            controller
                .addBirthWeightMeasurement(data as BirthWeightMeasurement);
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context,
      {WeightMeasurement? normalMeasurement,
      WeaningWeightMeasurement? weaningMeasurement,
      BirthWeightMeasurement? birthMeasurement}) {
    Object? data;

    if (normalMeasurement != null) {
      data = normalMeasurement;
    } else if (weaningMeasurement != null) {
      data = weaningMeasurement;
    } else if (birthMeasurement != null) {
      data = birthMeasurement;
    }

    showDialog(
      context: context,
      builder: (context) => AddWeightDialog(
        initialOlcumTipi: normalMeasurement != null
            ? OlcumTipi.normal
            : weaningMeasurement != null
                ? OlcumTipi.suttenKesim
                : OlcumTipi.yeniDogmus,
        initialData: data,
        onSave: (data, olcumTipi) {
          if (normalMeasurement != null) {
            controller.updateNormalWeightMeasurement(
                normalMeasurement.id!, data as WeightMeasurement);
          } else if (weaningMeasurement != null) {
            controller.updateWeaningWeightMeasurement(
                weaningMeasurement.id!, data as WeaningWeightMeasurement);
          } else if (birthMeasurement != null) {
            controller.updateBirthWeightMeasurement(
                birthMeasurement.id!, data as BirthWeightMeasurement);
          }
        },
      ),
    );
  }

  void _showMeasurementDetails(BuildContext context,
      {WeightMeasurement? measurement,
      WeaningWeightMeasurement? weaningMeasurement,
      BirthWeightMeasurement? birthMeasurement}) {
    String title;
    List<Widget> content = [];

    if (measurement != null) {
      title = 'Normal Ağırlık Ölçümü';
      content = [
        _detailItem('Ağırlık', '${measurement.weight} kg'),
        _detailItem(
            'Ölçüm Tarihi', controller.formatDate(measurement.measurementDate)),
        if (measurement.animalId != null)
          _detailItem(
              'Hayvan', controller.getAnimalNameById(measurement.animalId)),
        if (measurement.rfid != null) _detailItem('RFID', measurement.rfid!),
        if (measurement.notes != null && measurement.notes!.isNotEmpty)
          _detailItem('Notlar', measurement.notes!),
      ];
    } else if (weaningMeasurement != null) {
      title = 'Sütten Kesim Ağırlık Ölçümü';
      content = [
        _detailItem('Ağırlık', '${weaningMeasurement.weight} kg'),
        _detailItem('Ölçüm Tarihi',
            controller.formatDate(weaningMeasurement.measurementDate)),
        if (weaningMeasurement.weaningDate != null)
          _detailItem('Sütten Kesim Tarihi',
              controller.formatDate(weaningMeasurement.weaningDate!)),
        if (weaningMeasurement.weaningAge != null)
          _detailItem(
              'Sütten Kesim Yaşı', '${weaningMeasurement.weaningAge} gün'),
        if (weaningMeasurement.animalId != null)
          _detailItem('Hayvan',
              controller.getAnimalNameById(weaningMeasurement.animalId)),
        if (weaningMeasurement.rfid != null)
          _detailItem('RFID', weaningMeasurement.rfid!),
        if (weaningMeasurement.motherRfid != null)
          _detailItem('Anne RFID', weaningMeasurement.motherRfid!),
        if (weaningMeasurement.notes != null &&
            weaningMeasurement.notes!.isNotEmpty)
          _detailItem('Notlar', weaningMeasurement.notes!),
      ];
    } else if (birthMeasurement != null) {
      title = 'Doğum Ağırlık Ölçümü';
      content = [
        _detailItem('Ağırlık', '${birthMeasurement.weight} kg'),
        _detailItem('Ölçüm Tarihi',
            controller.formatDate(birthMeasurement.measurementDate)),
        if (birthMeasurement.birthDate != null)
          _detailItem('Doğum Tarihi',
              controller.formatDate(birthMeasurement.birthDate!)),
        if (birthMeasurement.birthPlace != null)
          _detailItem('Doğum Yeri', birthMeasurement.birthPlace!),
        if (birthMeasurement.animalId != null)
          _detailItem('Hayvan',
              controller.getAnimalNameById(birthMeasurement.animalId)),
        if (birthMeasurement.rfid != null)
          _detailItem('RFID', birthMeasurement.rfid!),
        if (birthMeasurement.motherRfid != null)
          _detailItem('Anne RFID', birthMeasurement.motherRfid!),
        if (birthMeasurement.notes != null &&
            birthMeasurement.notes!.isNotEmpty)
          _detailItem('Notlar', birthMeasurement.notes!),
      ];
    } else {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: content,
          ),
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

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
