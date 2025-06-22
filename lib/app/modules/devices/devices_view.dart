import 'package:animaltracker/app/data/models/device.dart';
import 'package:animaltracker/app/modules/devices/devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class DevicesView extends GetView<DevicesController> {
  const DevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('device_management'.tr),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            _buildScanButton(context),
            _buildStatusFilter(context),
            _buildDeviceList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'bluetooth_devices'.tr,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'scan_nearby_devices'.tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                ),
          ),
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
                controller.weightMeasurementBluetooth.startScan();
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
            if (controller.weightMeasurementBluetooth.isScanning.value) {
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
            'Taranıyor...',
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

  void _showScanningDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/bluetooth_scanning.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text('scanning_devices'.tr),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pop();
    });
  }

  Widget _buildDeviceList(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (controller.weightMeasurementBluetooth.availableDevices.isEmpty) {
          return _buildEmptyState(context);
        }

        final filteredDevices = controller.filteredDevices;

        if (filteredDevices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_alt_off,
                  size: 48,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bu filtreye uygun cihaz bulunamadı',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDevices.length,
          itemBuilder: (context, index) {
            final device = filteredDevices[index];
            return Obx(() {
              final isConnected = controller.weightMeasurementBluetooth
                      .deviceConnectionStatus[device.id] ??
                  false;
              final isConnecting =
                  controller.weightMeasurementBluetooth.isConnecting.value &&
                      controller.weightMeasurementBluetooth.connectingDeviceId
                              .value ==
                          device.id;

              return Dismissible(
                key: Key(device.id),
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isConnected
                        ? Icons.bluetooth_disabled
                        : Icons.bluetooth_connected,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    if (isConnected) {
                      controller.weightMeasurementBluetooth.disconnectDevice();
                    } else {
                      _connectToDevice(context, device);
                    }
                  } else {
                    if (isConnected) {
                      controller.weightMeasurementBluetooth.restartConnection();
                    }
                  }
                },
                confirmDismiss: (direction) async {
                  if (isConnecting) return false;
                  if (direction == DismissDirection.endToStart &&
                      !isConnected) {
                    return false;
                  }
                  return true;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isConnected
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3)
                            : Colors.transparent,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: isConnected ? 4 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isConnected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: _buildDeviceIcon(
                              context, isConnected, isConnecting),
                          title: Text(
                            device.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${device.id}'),
                              Row(
                                children: [
                                  _buildSignalStrengthIndicator(
                                      context, device.rssi),
                                  const SizedBox(width: 8),
                                  Text('${device.rssi} dBm'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _buildStatusBadge(
                                  context, isConnected, isConnecting),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: _buildConnectionButton(
                              context, device, isConnected, isConnecting),
                        ),
                        if (isConnected) _buildQuickActions(context, device),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildSignalStrengthIndicator(BuildContext context, int rssi) {
    int bars = 0;
    if (rssi > -60) {
      bars = 3;
    } else if (rssi > -70) {
      bars = 2;
    } else if (rssi > -80) {
      bars = 1;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 3,
          height: 6 + (index * 3),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: index < bars
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  Widget _buildStatusBadge(
      BuildContext context, bool isConnected, bool isConnecting) {
    Color badgeColor;
    String status;
    IconData icon;

    if (isConnecting) {
      badgeColor = Colors.amber;
      status = 'Bağlanıyor';
      icon = Icons.pending;
    } else if (isConnected) {
      badgeColor = Colors.green;
      status = 'Bağlı';
      icon = Icons.check_circle;
    } else {
      badgeColor = Colors.red;
      status = 'Bağlı Değil';
      icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: badgeColor,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Device device) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildActionButton(
            context,
            Icons.refresh,
            'yeniden_baslat'.tr,
            Theme.of(context).colorScheme.secondary,
            () => controller.weightMeasurementBluetooth.restartConnection(),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context,
            Icons.bluetooth_disabled,
            'baglanti_kes'.tr,
            Theme.of(context).colorScheme.error,
            () => _showDisconnectionDialog(context, device),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String tooltip,
      Color color, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.1),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/bluetooth_empty.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          Text(
            'no_devices_found'.tr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'no_devices_hint'.tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceIcon(
      BuildContext context, bool isConnected, bool isConnecting) {
    if (isConnecting) {
      return SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary),
        ),
      );
    }
    return CircleAvatar(
      backgroundColor: isConnected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: Icon(
        isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
        color: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }

  Widget _buildConnectionButton(BuildContext context, Device device,
      bool isConnected, bool isConnecting) {
    if (isConnecting) {
      return ElevatedButton(
        onPressed: () =>
            controller.weightMeasurementBluetooth.cancelConnection(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text('cancel'.tr),
      );
    }
    return ElevatedButton(
      onPressed: () => isConnected
          ? _showDisconnectionDialog(context, device)
          : _connectToDevice(context, device),
      style: ElevatedButton.styleFrom(
        backgroundColor: isConnected
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(isConnected ? 'disconnect'.tr : 'connect'.tr),
    );
  }

  void _connectToDevice(BuildContext context, Device device) {
    controller.weightMeasurementBluetooth.connectToDevice(device);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Obx(() {
            if (controller.weightMeasurementBluetooth.isConnecting.value) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('connecting_to_device'.tr),
                ],
              );
            } else {
              Future.delayed(Duration.zero, () {
                Navigator.of(context).pop();
              });
              return const SizedBox.shrink();
            }
          }),
        );
      },
    );
  }

  void _showDisconnectionDialog(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('disconnect_device'.tr),
          content: Text('disconnect_confirmation'.tr + ' ${device.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text('disconnect'.tr),
              onPressed: () {
                controller.weightMeasurementBluetooth.disconnectDevice();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('device_disconnected'.tr),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
