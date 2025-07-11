import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tartim/app/modules/settings/settings_controller.dart';
import 'package:tartim/app/data/models/device.dart';
import 'package:lottie/lottie.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGeneralSettings(context),
            _buildDevicesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Genel Ayarlar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(),
            _buildLanguageSelector(context),
            const Divider(),
            _buildThemeToggle(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text('change_language'.tr),
      subtitle: Obx(() {
        String langName = '';
        switch (controller.currentLanguage.value) {
          case 'tr_TR':
            langName = 'Türkçe';
            break;
          case 'en_US':
            langName = 'English';
            break;
          case 'de_DE':
            langName = 'Deutsch';
            break;
        }
        return Text(langName);
      }),
      onTap: () => _showLanguageDialog(context),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.color_lens),
      title: Text('change_theme'.tr),
      subtitle: Obx(
          () => Text(controller.isDarkMode.value ? 'Koyu Tema' : 'Açık Tema')),
      trailing: Obx(() => Switch(
            value: controller.isDarkMode.value,
            onChanged: (value) => controller.toggleTheme(),
          )),
      onTap: () => controller.toggleTheme(),
    );
  }

  Widget _buildDevicesSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'bluetooth_devices'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'scan_nearby_devices'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          _buildScanButton(context),
          _buildStatusFilter(context),
          _buildDeviceList(context),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.bluetooth_searching),
              label: Text('scan_devices'.tr),
              onPressed: () {
                controller.startScan();
                _showScanningDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() {
            if (controller.isScanning) {
              return _buildScanningIndicator(context);
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildScanningIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'scanning_devices'.tr,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              context,
              'Tümü',
              controller.selectedFilter.value == 'all',
              () => controller.changeFilter('all'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              'Bağlı',
              controller.selectedFilter.value == 'connected',
              () => controller.changeFilter('connected'),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              'Bağlı Değil',
              controller.selectedFilter.value == 'disconnected',
              () => controller.changeFilter('disconnected'),
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, bool isSelected, VoidCallback onTap,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.2)
              : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? Theme.of(context).colorScheme.primary)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (color ?? Theme.of(context).colorScheme.primary)
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context) {
    return Obx(() {
      final devices = _filterDevices(controller.availableDevices);

      if (devices.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/empty_list.json',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 16),
                Text(
                  'no_devices_found'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'no_devices_hint'.tr,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return _buildDeviceListItem(context, device);
        },
      );
    });
  }

  List<Device> _filterDevices(List<Device> devices) {
    final filter = controller.selectedFilter.value;

    if (filter == 'all') {
      return devices;
    } else if (filter == 'connected') {
      return devices.where((device) {
        return controller.connectedDevice?.id == device.id;
      }).toList();
    } else {
      // disconnected
      return devices.where((device) {
        return controller.connectedDevice?.id != device.id;
      }).toList();
    }
  }

  Widget _buildDeviceListItem(BuildContext context, Device device) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          device.name.isEmpty ? 'unknown_device'.tr : device.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(device.id),
        trailing: Obx(() {
          final isConnected = controller.connectedDevice?.id == device.id;
          final isConnecting = controller.isConnecting;

          if (isConnected) {
            return ElevatedButton.icon(
              icon: const Icon(Icons.link_off, size: 16),
              label: Text('disconnect'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () {
                _showDisconnectDialog(context, device);
              },
            );
          } else if (isConnecting) {
            return const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          } else {
            return ElevatedButton.icon(
              icon: const Icon(Icons.bluetooth_connected, size: 16),
              label: Text('connect'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              onPressed: () async {
                try {
                  await controller.connectToDevice(device);
                  Get.snackbar(
                    'successful_connection'.tr,
                    device.name,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } catch (e) {
                  Get.snackbar(
                    'connection_failed'.tr,
                    e.toString(),
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            );
          }
        }),
        onTap: () {
          // Open device details dialog or screen
        },
      ),
    );
  }

  void _showScanningDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('scanning_devices'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 24),
              Text('scan_nearby_devices'.tr),
            ],
          ),
          actions: [
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () {
                controller.stopScan();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Automatically close after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  void _showDisconnectDialog(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('disconnect_confirmation'.tr),
          content: Text(device.name),
          actions: [
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('confirm'.tr),
              onPressed: () async {
                Navigator.of(context).pop();
                await controller.disconnectDevice();
                Get.snackbar(
                  'disconnected'.tr,
                  device.name,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('select_language'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Türkçe'),
                trailing: controller.currentLanguage.value == 'tr_TR'
                    ? Icon(Icons.check,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  controller.changeLanguage('tr_TR');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
                trailing: controller.currentLanguage.value == 'en_US'
                    ? Icon(Icons.check,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  controller.changeLanguage('en_US');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Deutsch'),
                trailing: controller.currentLanguage.value == 'de_DE'
                    ? Icon(Icons.check,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  controller.changeLanguage('de_DE');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
