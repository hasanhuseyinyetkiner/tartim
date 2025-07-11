import 'package:tartim/app/data/models/hayvan_agirlik.dart';
import 'package:tartim/app/data/models/olcum_tipi.dart';
import 'package:tartim/app/modules/agirlik_olcum/agirlik_olcum_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AgirlikOlcumView extends GetView<AgirlikOlcumController> {
  const AgirlikOlcumView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ağırlık Ölçüm Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDrawer(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchRfidListesi(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchRfidListesi(),
                  child: const Text('Yeniden Dene'),
                ),
              ],
            ),
          );
        }

        if (controller.hayvanListesi.isEmpty) {
          return const Center(
            child: Text('Veri bulunamadı veya erişiminiz yok.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.hayvanListesi.length,
          itemBuilder: (context, index) {
            final hayvan = controller.hayvanListesi[index];
            return _buildHayvanCard(context, hayvan);
          },
        );
      }),
    );
  }

  Widget _buildHayvanCard(BuildContext context, HayvanAgirlik hayvan) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showHayvanDetay(context, hayvan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hayvan.hayvanAdi,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'RFID: ${hayvan.rfid}',
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildMeasurementRow(hayvan),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementRow(HayvanAgirlik hayvan) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: OlcumTipi.values.map((tip) {
        final olcum = hayvan.olcumler[tip];
        final hasData = olcum != null;

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                tip.displayName,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                hasData ? '${olcum.agirlik.toStringAsFixed(1)} kg' : '-',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: hasData ? Colors.black : Colors.grey,
                ),
              ),
              if (hasData)
                Text(
                  DateFormat('dd.MM.yyyy').format(olcum.tarih),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showFilterDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildFilterDrawer(context),
    );
  }

  Widget _buildFilterDrawer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ağırlık Filtreleme',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ölçüm Tipi',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Obx(() => Column(
                children: OlcumTipi.values.map((type) {
                  return RadioListTile<OlcumTipi>(
                    title: Text(type.displayName),
                    value: type,
                    groupValue: controller.secilenOlcumTipi.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeOlcumTipi(value);
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              )),
          const SizedBox(height: 16),
          Text(
            'Sıralama',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Obx(() => Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Ağırlık (Büyükten Küçüğe)'),
                    value: 'agirlik_azalan',
                    groupValue: controller.secilenSiralama.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeSorting(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Ağırlık (Küçükten Büyüğe)'),
                    value: 'agirlik_artan',
                    groupValue: controller.secilenSiralama.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeSorting(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showHayvanDetay(BuildContext context, HayvanAgirlik hayvan) async {
    // Hayvan detaylarını getir
    await controller.getHayvanDetay(hayvan.rfid);

    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildHayvanDetaySheet(context, hayvan),
    );
  }

  Widget _buildHayvanDetaySheet(BuildContext context, HayvanAgirlik hayvan) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hayvan.hayvanAdi,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'RFID: ${hayvan.rfid}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: OlcumTipi.values.map((tip) {
                    return _buildOlcumDetayCard(context, hayvan, tip);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOlcumDetayCard(
      BuildContext context, HayvanAgirlik hayvan, OlcumTipi olcumTipi) {
    final olcum = hayvan.olcumler[olcumTipi];
    final hasData = olcum != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  olcumTipi.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasData)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final onayVerildi =
                          await controller.showDeleteConfirmation(
                              context, hayvan.rfid, olcumTipi);

                      if (onayVerildi) {
                        final success =
                            await controller.olcumSil(hayvan.rfid, olcumTipi);
                        if (success) {
                          Navigator.pop(context); // Detay sayfasını kapat
                        }
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            hasData
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ağırlık: ${olcum.agirlik.toStringAsFixed(1)} kg',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tarih: ${DateFormat('dd.MM.yyyy').format(olcum.tarih)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (olcum.not != null && olcum.not!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Not: ${olcum.not}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  )
                : const Text(
                    'Ölçüm kaydı bulunamadı.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showOlcumEkleGuncelleForm(
                  context, hayvan.rfid, olcumTipi, hasData ? olcum : null),
              icon: Icon(hasData ? Icons.edit : Icons.add),
              label: Text(hasData ? 'Güncelle' : 'Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasData ? Colors.orange : Colors.green,
                minimumSize: const Size.fromHeight(40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOlcumEkleGuncelleForm(BuildContext context, String rfid,
      OlcumTipi olcumTipi, OlcumDetay? mevcutOlcum) {
    final formKey = GlobalKey<FormState>();
    final agirlikController =
        TextEditingController(text: mevcutOlcum?.agirlik.toString() ?? '');
    final tarihController = TextEditingController(
        text: mevcutOlcum != null
            ? DateFormat('dd.MM.yyyy').format(mevcutOlcum.tarih)
            : DateFormat('dd.MM.yyyy').format(DateTime.now()));

    DateTime secilenTarih = mevcutOlcum?.tarih ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${mevcutOlcum != null ? 'Güncelle' : 'Ekle'}: ${olcumTipi.displayName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: agirlikController,
                  decoration: const InputDecoration(
                    labelText: 'Ağırlık (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ağırlık gerekli';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir ağırlık girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: secilenTarih,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      secilenTarih = picked;
                      tarihController.text =
                          DateFormat('dd.MM.yyyy').format(picked);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: tarihController,
                      decoration: const InputDecoration(
                        labelText: 'Tarih',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tarih gerekli';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => controller.isProcessing.value
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('İptal'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    final double agirlik =
                                        double.parse(agirlikController.text);

                                    final success =
                                        await controller.olcumEkleGuncelle(
                                      rfid,
                                      olcumTipi,
                                      agirlik,
                                      secilenTarih,
                                    );

                                    if (success) {
                                      Navigator.pop(context); // Form'u kapat
                                      Navigator.pop(
                                          context); // Detay sayfasını kapat
                                    }
                                  }
                                },
                                child: Text(
                                    mevcutOlcum != null ? 'Güncelle' : 'Ekle'),
                              ),
                            ),
                          ],
                        ),
                ),
                if (controller.errorMessage.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
