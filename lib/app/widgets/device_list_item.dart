import 'package:flutter/material.dart';

import '../data/models/device.dart';

class DeviceListItem extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;

  const DeviceListItem({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('RSSI: ${device.rssi} - ID: ${device.id}'),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: device.lastData.isEmpty ? Colors.green : Colors.red,
          ),
          child: Text(device.lastData.isEmpty ? 'Bağlan' : 'Bağlantıyı Kes'),
        ),
        onTap: onTap,
      ),
    );
  }
}