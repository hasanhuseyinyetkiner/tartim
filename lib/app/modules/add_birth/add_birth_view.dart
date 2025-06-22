import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animaltracker/app/modules/add_birth/add_birth_controller.dart';
import 'package:animaltracker/app/modules/animals/animals_controller.dart';
import 'package:animaltracker/app/data/models/device.dart';
import 'package:animaltracker/app/data/models/animal.dart';
import 'package:animaltracker/app/data/repositories/animal_repository.dart';

class AddBirthView extends GetView<AddBirthController> {
  const AddBirthView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final earTagController = TextEditingController();
    final rfidController = TextEditingController();
    final motherRfidController = TextEditingController();
    final fatherRfidController = TextEditingController();
    final birthWeightController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // RFID otomatik olarak alındığında TextFormField'a ekle
    ever(controller.scannedRfid, (rfid) {
      if (rfid.isNotEmpty) {
        rfidController.text = rfid;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('add_new_birth'.tr),
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
                        decoration: const InputDecoration(
                          labelText: 'RFID (İsteğe Bağlı)',
                          helperText: 'Boş bırakabilirsiniz',
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
                              ? () => _showBluetoothReadDialog(context, 'RFID',
                                      (rfid) {
                                    rfidController.text = rfid;
                                  })
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
                // Doğum ağırlığı için yeni alan
                TextFormField(
                  controller: birthWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Doğum Ağırlığı (kg)',
                    helperText: 'Doğum anında ölçülen ağırlık',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),

                const SizedBox(height: 16),
                // Anne RFID alanı - zorunlu
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: motherRfidController,
                        decoration: InputDecoration(
                          labelText: 'Anne RFID',
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
                                            duration:
                                                const Duration(seconds: 2),
                                          );
                                          await controller.readMotherRfid();
                                          if (controller.scannedMotherRfid.value
                                              .isNotEmpty) {
                                            motherRfidController.text =
                                                controller
                                                    .scannedMotherRfid.value;
                                            await controller.validateMotherRfid(
                                                controller
                                                    .scannedMotherRfid.value);
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
                        validator: (value) =>
                            value!.isEmpty ? 'Anne RFID gereklidir' : null,
                      ),
                    ),
                  ],
                ),
                // Anne RFID değeri doğru mu gösterge
                Obx(() => Visibility(
                      visible: motherRfidController.text.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          controller.isMotherValid.value
                              ? 'Anne RFID doğrulandı'
                              : 'Geçersiz Anne RFID',
                          style: TextStyle(
                            color: controller.isMotherValid.value
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )),

                const SizedBox(height: 16),
                // Baba RFID alanı - zorunlu
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: fatherRfidController,
                        decoration: InputDecoration(
                          labelText: 'Baba RFID',
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
                                            duration:
                                                const Duration(seconds: 2),
                                          );
                                          await controller.readFatherRfid();
                                          if (controller.scannedFatherRfid.value
                                              .isNotEmpty) {
                                            fatherRfidController.text =
                                                controller
                                                    .scannedFatherRfid.value;
                                            await controller.validateFatherRfid(
                                                controller
                                                    .scannedFatherRfid.value);
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
                        validator: (value) =>
                            value!.isEmpty ? 'Baba RFID gereklidir' : null,
                      ),
                    ),
                  ],
                ),
                // Baba RFID değeri doğru mu gösterge
                Obx(() => Visibility(
                      visible: fatherRfidController.text.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          controller.isFatherValid.value
                              ? 'Baba RFID doğrulandı'
                              : 'Geçersiz Baba RFID',
                          style: TextStyle(
                            color: controller.isFatherValid.value
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // RFID'lerin veritabanında var olup olmadığını kontrol et
                      final isMotherValid = await controller
                          .validateMotherRfid(motherRfidController.text);
                      final isFatherValid = await controller
                          .validateFatherRfid(fatherRfidController.text);

                      if (!isMotherValid || !isFatherValid) {
                        if (!isMotherValid) {
                          Get.snackbar('Hata',
                              'Anne RFID veritabanında bulunamadı. Lütfen geçerli bir RFID girin.');
                        }
                        if (!isFatherValid) {
                          Get.snackbar('Hata',
                              'Baba RFID veritabanında bulunamadı. Lütfen geçerli bir RFID girin.');
                        }
                        return;
                      }

                      // Doğum ağırlığını kontrol et ve dönüştür
                      double? birthWeight;
                      if (birthWeightController.text.isNotEmpty) {
                        birthWeight =
                            double.tryParse(birthWeightController.text);
                        if (birthWeight == null || birthWeight <= 0) {
                          Get.snackbar(
                            'Hata',
                            'Geçerli bir doğum ağırlığı giriniz',
                            backgroundColor: Colors.red.withOpacity(0.1),
                          );
                          return;
                        }
                      }

                      await controller.addAnimal(
                        nameController.text,
                        earTagController.text,
                        rfidController.text.isEmpty
                            ? null
                            : rfidController.text,
                        motherRfidController.text,
                        fatherRfidController.text,
                        birthWeight,
                      );

                      try {
                        final animalsController = Get.find<AnimalsController>();
                        await animalsController.refreshAnimals();
                      } catch (e) {
                        // AnimalsController bulunmadıysa görmezden gel
                      }

                      Get.back(result: true);
                    }
                  },
                  child: Text('add_birth'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
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
            'Yavru Türü',
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
                hint: const Text('Yavru türünü seçin'),
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
                      final devices = controller.availableDevices;
                      if (devices.isEmpty) {
                        return const Center(
                          child: Text('Cihaz bulunamadı'),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return ListTile(
                            title: Text(device.name),
                            subtitle: Text(device.id),
                            trailing: Obx(() {
                              final connectedDevice =
                                  controller.connectedDevice.value;
                              final isConnected = connectedDevice != null &&
                                  connectedDevice.id == device.id;
                              final isConnecting =
                                  controller.isBluetoothConnecting.value;

                              if (isConnected) {
                                return const Icon(Icons.bluetooth_connected,
                                    color: Colors.blue);
                              } else if (isConnecting) {
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              } else {
                                return const Icon(Icons.bluetooth);
                              }
                            }),
                            onTap: () {
                              if (controller.connectedDevice.value?.id !=
                                  device.id) {
                                controller.connectToDevice(device);
                              }
                            },
                          );
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

  // Bluetooth ile RFID okuma dialog'u
  void _showBluetoothReadDialog(
      BuildContext context, String title, Function(String) onRfidRead) {
    final animalRepository = Get.find<AnimalRepository>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$title Oku'),
          content: Obx(() {
            if (controller.scannedRfid.value.isNotEmpty) {
              return FutureBuilder<Animal?>(
                future: animalRepository
                    .getAnimalByRfid(controller.scannedRfid.value),
                builder: (context, snapshot) {
                  String infoText = 'RFID: ${controller.scannedRfid.value}';

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 48),
                        const SizedBox(height: 16),
                        Text(infoText),
                        const SizedBox(height: 8),
                        const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        const Text('Hayvan bilgileri alınıyor...'),
                      ],
                    );
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    final animal = snapshot.data!;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 48),
                        const SizedBox(height: 16),
                        Text(infoText,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Hayvan Adı: ${animal.name}'),
                        const SizedBox(height: 4),
                        Text('Kulak Küpe No: ${animal.earTag}'),
                        if (animal.motherRfid != null &&
                            animal.motherRfid!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Anne RFID: ${animal.motherRfid}'),
                          ),
                        if (animal.fatherRfid != null &&
                            animal.fatherRfid!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Baba RFID: ${animal.fatherRfid}'),
                          ),
                      ],
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 48),
                      const SizedBox(height: 16),
                      Text(infoText),
                      const SizedBox(height: 8),
                      const Text('Hayvan bilgisi bulunamadı',
                          style: TextStyle(color: Colors.orange)),
                    ],
                  );
                },
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(),
                ),
                SizedBox(height: 16),
                Text('RFID bekleniyor...'),
              ],
            );
          }),
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
                          onRfidRead(controller.scannedRfid.value);
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
