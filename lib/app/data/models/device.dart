class Device {
  final String id;
  final String name;
  final int rssi;
  String lastData;

  Device({
    required this.id,
    required this.name,
    required this.rssi,
    this.lastData = '',
  });

  @override
  String toString() {
    return 'Device(id: $id, name: $name, rssi: $rssi, lastData: $lastData)';
  }
}