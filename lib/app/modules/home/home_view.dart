import 'package:tartim/app/modules/home/home_controller.dart';
import 'package:tartim/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('title'.tr),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () => Get.toNamed(Routes.DEVICES),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(Routes.SETTINGS),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(context),
                  const SizedBox(height: 16),
                  _buildBluetoothStatus(context),
                  const SizedBox(height: 20),
                  _buildDashboardGrid(context),
                  const SizedBox(height: 20),
                  _buildRecentMeasurements(context),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_animals'.tr,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.7),
                ),
              ),
              onSubmitted: (value) {
                // İleri aşamada arama işlevi eklenecek
                Get.snackbar('Bilgi', 'Arama özelliği yakında eklenecek');
              },
            ),
          ),
        ],
      ),
    );
  }

  // Dil değiştirme dialog'u
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('settings'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text('change_language'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _showLanguageDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: Text('change_theme'.tr),
                onTap: () {
                  Navigator.pop(context);
                  // İleride tema değiştirme özelliği eklenebilir
                  Get.snackbar(
                      'Bilgi', 'Tema değiştirme özelliği yakında eklenecek');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('close'.tr),
              onPressed: () => Navigator.pop(context),
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
                onTap: () {
                  Get.updateLocale(const Locale('tr', 'TR'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  Get.updateLocale(const Locale('en', 'US'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Deutsch'),
                onTap: () {
                  Get.updateLocale(const Locale('de', 'DE'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBluetoothStatus(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: controller.weightMeasurementBluetooth.isDeviceConnected.value
                ? colorScheme.primaryContainer
                : colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  controller.weightMeasurementBluetooth.isDeviceConnected.value
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  key: ValueKey(controller
                      .weightMeasurementBluetooth.isDeviceConnected.value),
                  color: controller
                          .weightMeasurementBluetooth.isDeviceConnected.value
                      ? colorScheme.primary
                      : colorScheme.error,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  controller.weightMeasurementBluetooth.isDeviceConnected.value
                      ? '${'bluetooth_connected'.tr} ${controller.weightMeasurementBluetooth.connectedDevice.value?.name ?? ""}'
                      : 'bluetooth_disconnected'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: controller
                        .weightMeasurementBluetooth.isDeviceConnected.value
                    ? controller.weightMeasurementBluetooth.disconnectDevice
                    : () => Get.toNamed(Routes.DEVICES),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller
                          .weightMeasurementBluetooth.isDeviceConnected.value
                      ? colorScheme.error
                      : colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  controller.weightMeasurementBluetooth.isDeviceConnected.value
                      ? 'disconnect'.tr
                      : 'connect'.tr,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildDashboardGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [/*
        Text(
          'Ana Sayfa'.tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),*/
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildDashboardCard(
              context,
              'animals'.tr,
              Icons.pets,
              () => Get.toNamed(Routes.ANIMALS),
              color: colorScheme.primary,
            ),
            _buildDashboardCard(
              context,
              'weight_measurement'.tr,
              Icons.monitor_weight,
              () => Get.toNamed(Routes.WEIGHT_MEASUREMENT),
              color: colorScheme.secondary,
            ),
            _buildDashboardCard(
              context,
              'add_animal'.tr,
              Icons.add_circle,
              () => Get.toNamed(Routes.ANIMAL_ADD),
              color: Colors.green,
            ),
            _buildDashboardCard(
              context,
              'add_birth'.tr,
              Icons.child_care,
              () => Get.toNamed(Routes.ADD_BIRTH),
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, String title, IconData icon, VoidCallback onPressed,
      {required Color color}) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMeasurements(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'recent_measurements'.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(Routes.AGIRLIK_OLCUM),
              child: Text('Göster'.tr),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            );
          }

          final measurements = controller.recentMeasurements;
          if (measurements.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/animations/empty_list.json',
                    width: 200,
                    height: 200,
                  ),
                  Text('no_measurements'.tr),
                ],
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: measurements.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final measurement = measurements[index];
              return Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.scale,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(
                    '${measurement.weight.toStringAsFixed(2)} kg',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  subtitle: Text(
                    'RFID: ${measurement.animalRfid}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(measurement.timestamp),
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12),
                      ),
                      Text(
                        _formatTime(measurement.timestamp),
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() => BottomNavigationBar(
          currentIndex: controller.tabIndex.value,
          onTap: (index) {
            if (index == 3) {
              // Navigate to Settings page
              Get.toNamed(Routes.SETTINGS);
            } else {
              controller.changeTabIndex(index);
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.pets),
              label: 'animals'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.monitor_weight),
              label: 'weight'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: 'settings'.tr,
            ),
          ],
        ));
  }

  String _formatDate(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return "${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}";
    } catch (e) {
      print('Error parsing date: $e');
      return 'Geçersiz Tarih';
    }
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      print('Error parsing time: $e');
      return 'Geçersiz Saat';
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text panoya kopyalandı'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('logout'.tr),
          content: Text('logout_confirmation'.tr),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('confirm_logout'.tr),
              onPressed: () {
                Navigator.of(context).pop();
                controller.logout();
              },
            ),
          ],
        );
      },
    );
  }
}
