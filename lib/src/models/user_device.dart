class UserDevice {
  final String id;
  final String name;
  final String type;
  final String macAddress;
  bool isOnline;
  bool isConnected;

  UserDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.macAddress,
    this.isOnline = false,
    this.isConnected = false,
  });

  factory UserDevice.fromJson(Map<String, dynamic> json) {
    return UserDevice(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      macAddress: json['macAddress'],
    );
  }
}