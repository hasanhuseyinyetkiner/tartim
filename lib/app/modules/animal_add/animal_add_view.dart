import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tartim/app/modules/animal_add/animal_add_controller.dart';
import 'package:tartim/app/modules/animals/animals_controller.dart';
import 'package:tartim/app/data/models/device.dart';
import 'package:tartim/app/data/models/animal.dart';
import 'package:tartim/app/data/repositories/animal_repository.dart';

class AnimalAddView extends GetView<AnimalAddController> {
  const AnimalAddView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final earTagController = TextEditingController();
    final rfidController = TextEditingController();
    final motherRfidController = TextEditingController();
    final fatherRfidController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // RFID otomatik olarak alındığında TextFormField'a ekle
    ever(controller.scannedRfid, (rfid) {
      if (rfid.isNotEmpty) {
        rfidController.text = rfid;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('add_new_animal'.tr),
        actions: [
          // Bluetooth bağlantı durumunu gösteren icon
          Obx(() => IconButton(
                icon: Icon(
                  controller.isDeviceConnected.value
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  color: controller.isDeviceConnected.value
                      ? Colors.blue
                      : Colors.grey,
                ),
                onPressed: () => _showBluetoothDeviceSheet(context),
                tooltip: 'Bluetooth Cihazları',
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'animal_name'.tr),
                  validator: (value) =>
                      value!.isEmpty ? 'field_required'.tr : null,
                ),
                const SizedBox(height: 16),
                _buildAnimalTypeDropdown(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: earTagController,
                  decoration: InputDecoration(labelText: 'ear_tag_number'.tr),
                  validator: (value) =>
                      value!.isEmpty ? 'field_required'.tr : null,
                ),
                const SizedBox(height: 16),

                // RFID girişi ve Bluetooth okuma butonu
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: rfidController,
                        decoration: const InputDecoration(labelText: 'RFID'),
                        validator: (value) =>
                            value!.isEmpty ? 'field_required'.tr : null,
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
                              ? () => _showBluetoothReadDialog(context)
                              : () => Get.snackbar(
                                    'Uyarı',
                                    'RFID okumak için önce bir Bluetooth cihazına bağlanın',
                                    snackPosition: SnackPosition.BOTTOM,
                                  ),
                          tooltip: 'RFID Oku',
                        )),
                  ],
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: motherRfidController,
                  decoration: InputDecoration(
                    labelText: 'Anne RFID (İsteğe Bağlı)',
                    helperText: 'Hayvanın annesinin RFID numarası',
                    prefixIcon: const Icon(Icons.female),
                    suffixIcon: Obx(() => IconButton(
                          icon: Icon(
                            Icons.nfc,
                            color: controller.isDeviceConnected.value
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          onPressed: controller.isDeviceConnected.value
                              ? () async {
                                  try {
                                    Get.snackbar(
                                      'Bilgi',
                                      'Anne RFID okunuyor...',
                                      duration: const Duration(seconds: 2),
                                    );
                                    await controller.readMotherRfid();
                                    if (controller
                                        .scannedMotherRfid.value.isNotEmpty) {
                                      motherRfidController.text =
                                          controller.scannedMotherRfid.value;
                                    }
                                  } catch (e) {
                                    Get.snackbar(
                                      'Hata',
                                      'RFID okuma hatası: $e',
                                      backgroundColor:
                                          Colors.red.withOpacity(0.1),
                                    );
                                  }
                                }
                              : () => Get.snackbar(
                                    'Uyarı',
                                    'RFID okumak için önce bir Bluetooth cihazına bağlanın',
                                    snackPosition: SnackPosition.BOTTOM,
                                  ),
                          tooltip: 'Anne RFID Oku',
                        )),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: fatherRfidController,
                  decoration: InputDecoration(
                    labelText: 'Baba RFID (İsteğe Bağlı)',
                    helperText: 'Hayvanın babasının RFID numarası',
                    prefixIcon: const Icon(Icons.male),
                    suffixIcon: Obx(() => IconButton(
                          icon: Icon(
                            Icons.nfc,
                            color: controller.isDeviceConnected.value
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          onPressed: controller.isDeviceConnected.value
                              ? () async {
                                  try {
                                    Get.snackbar(
                                      'Bilgi',
                                      'Baba RFID okunuyor...',
                                      duration: const Duration(seconds: 2),
                                    );
                                    await controller.readFatherRfid();
                                    if (controller
                                        .scannedFatherRfid.value.isNotEmpty) {
                                      fatherRfidController.text =
                                          controller.scannedFatherRfid.value;
                                    }
                                  } catch (e) {
                                    Get.snackbar(
                                      'Hata',
                                      'RFID okuma hatası: $e',
                                      backgroundColor:
                                          Colors.red.withOpacity(0.1),
                                    );
                                  }
                                }
                              : () => Get.snackbar(
                                    'Uyarı',
                                    'RFID okumak için önce bir Bluetooth cihazına bağlanın',
                                    snackPosition: SnackPosition.BOTTOM,
                                  ),
                          tooltip: 'Baba RFID Oku',
                        )),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await controller.addAnimal(
                        nameController.text,
                        earTagController.text,
                        rfidController.text,
                        motherRfid: motherRfidController.text.isNotEmpty
                            ? motherRfidController.text
                            : null,
                        fatherRfid: fatherRfidController.text.isNotEmpty
                            ? fatherRfidController.text
                            : null,
                      );
                      final animalsController = Get.find<AnimalsController>();
                      await animalsController.refreshAnimals();
                      Get.back();
                    }
                  },
                  child: Text('add_animal'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bluetooth cihazlarını gösteren bottom sheet
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

  // Bluetooth cihaz listesi öğesi
  Widget _buildDeviceListTile(Device device, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.bluetooth, color: Colors.blue),
        title: Text(device.name),
        subtitle: Text('Signal: ${device.rssi} dBm'),
        trailing: Obx(() {
          // Bağlı cihaz ise bağlantıyı kes butonu göster
          if (controller.connectedDevice.value?.id == device.id) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Bağlantıyı Kes'),
              onPressed: () => controller.disconnectDevice(),
            );
          }

          // Bağlanma işlemi devam ediyorsa yükleme göster
          if (controller.isBluetoothConnecting.value) {
            return const CircularProgressIndicator();
          }

          // Bağlanma butonu göster
          return ElevatedButton(
            child: const Text('Bağlan'),
            onPressed: () {
              controller.connectToDevice(device);
              Navigator.pop(context); // Bottom sheet'i kapat
            },
          );
        }),
      ),
    );
  }

  // RFID okuma diyaloğu
  void _showBluetoothReadDialog(BuildContext context) {
    final animalRepository = Get.find<AnimalRepository>();

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
                  ? FutureBuilder<Animal?>(
                      future: animalRepository
                          .getAnimalByRfid(controller.scannedRfid.value),
                      builder: (context, snapshot) {
                        String infoText =
                            'Okunan RFID: ${controller.scannedRfid.value}';

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(infoText,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                              const Text('Hayvan bilgileri alınıyor...'),
                            ],
                          );
                        }

                        if (snapshot.hasData && snapshot.data != null) {
                          final animal = snapshot.data!;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(infoText,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Hayvan Adı: ${animal.name}'),
                              const SizedBox(height: 4),
                              Text('Kulak Küpe No: ${animal.earTag}'),
                              if (animal.motherRfid != null &&
                                  animal.motherRfid!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child:
                                      Text('Anne RFID: ${animal.motherRfid}'),
                                ),
                              if (animal.fatherRfid != null &&
                                  animal.fatherRfid!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child:
                                      Text('Baba RFID: ${animal.fatherRfid}'),
                                ),
                            ],
                          );
                        }

                        return Text(
                          infoText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        );
                      })
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

  Widget _buildAnimalTypeDropdown() {
    return Obx(() {
      if (controller.animalTypes.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hayvan Türü',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
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
                items: controller.animalTypes
                    .map(
                      (type) => DropdownMenuItem<int>(
                        value: type.id,
                        child: Text(type.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedTypeId.value = value;
                  }
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}
