<<<<<<< HEAD
# Tartım - Weight Measurement Package

[![pub package](https://img.shields.io/pub/v/tartim.svg)](https://pub.dev/packages/tartim)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter package for weight measurement functionality with Bluetooth integration, data synchronization, and local storage capabilities.

## Features

🔗 **Bluetooth Integration**
- Bluetooth Low Energy (BLE) device scanning and connection
- Real-time weight data reception from smart scales
- Automatic device reconnection and connection management
- Signal strength monitoring

📊 **Weight Measurement Management**
- Weight measurement data models with SQLite and API serialization
- Multiple measurement types support (normal, weaning, birth weights)
- Automatic data validation and formatting
- Local storage with automatic synchronization

💾 **Data Management**
- SQLite local storage for offline functionality
- API integration for cloud synchronization
- Data export and import capabilities
- Measurement history and analytics

🎯 **RFID Support**
- RFID tag reading from weight measurements
- Animal identification and tracking
- Automatic data association

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  tartim: ^0.0.1
```

## Usage

### Basic Setup

```dart
import 'package:tartim/tartim.dart';
import 'package:get/get.dart';

// Initialize the Bluetooth service
void main() {
  runApp(MyApp());
  
  // Register the Bluetooth service
  Get.put(TartimBluetoothService());
}
```

### Bluetooth Device Management

```dart
// Get the Bluetooth service
final bluetoothService = Get.find<TartimBluetoothService>();

// Start scanning for devices
await bluetoothService.startScan();

// Connect to a device
final device = bluetoothService.discoveredDevices.first;
bool connected = await bluetoothService.connectToDevice(device);

// Setup weight measurement notifications
if (connected) {
  await bluetoothService.setupWeightMeasurementNotifications(
    device,
    (data) {
      final weightData = bluetoothService.processWeightData(data);
      if (weightData != null) {
        print('Weight: ${weightData.weight} kg, RFID: ${weightData.rfid}');
      }
    },
  );
}
```

### Weight Measurement Models

```dart
// Create a weight measurement
final measurement = WeightMeasurement(
  weight: 75.5,
  measurementDate: DateTime.now(),
  rfid: 'ABC123456789',
  notes: 'Normal measurement',
  measurementType: 0,
  userId: 1,
);

// Validate the measurement
final validation = measurement.validate();
if (validation != null) {
  print('Validation error: $validation');
}

// Convert to SQLite format
final map = measurement.toMap();

// Convert to API format
final json = measurement.toJson();

// Get formatted values
print('Formatted weight: ${measurement.formattedWeight}');
print('Formatted date: ${measurement.formattedDate}');
```

### Device Management

```dart
// Create a user device
final device = UserDevice(
  id: '1',
  name: 'Smart Scale Pro',
  type: 'weight',
  macAddress: '00:11:22:33:44:55',
);

// Validate device data
final validation = device.validate();
if (validation == null) {
  print('Device is valid');
}

// Check if it's a weight device
if (device.isWeightDevice) {
  print('This is a weight measurement device');
}
```

## Models

### WeightMeasurement

Comprehensive weight measurement data model supporting:
- SQLite and API serialization/deserialization
- Multiple field name compatibility
- Data validation and formatting
- Immutable updates with `copyWith()`

**Key Properties:**
- `weight`: Weight value in kilograms
- `measurementDate`: Date and time of measurement
- `rfid`: RFID tag identifier
- `animalId`: Animal ID for livestock management
- `measurementType`: Type of measurement (0=normal, 1=weaning, 2=birth)
- `notes`: Additional notes
- `deviceId`: Device used for measurement

### UserDevice

Bluetooth device management model featuring:
- JSON serialization for API integration
- MAC address validation
- Connection status tracking
- Device type categorization

**Key Properties:**
- `id`: Unique device identifier
- `name`: Device display name
- `type`: Device type ('weight', etc.)
- `macAddress`: Bluetooth MAC address
- `isOnline`: Device discovery status
- `isConnected`: Connection status

## Services

### TartimBluetoothService

Comprehensive Bluetooth management service providing:
- Device scanning and discovery
- Connection management with auto-reconnection
- Real-time data reception and processing
- Signal strength monitoring
- Characteristic subscription management

**Key Methods:**
- `startScan()`: Start Bluetooth device scanning
- `connectToDevice()`: Connect to specific device
- `setupWeightMeasurementNotifications()`: Setup data reception
- `processWeightData()`: Parse received weight data
- `disconnectDevice()`: Disconnect from device

## Requirements

- Flutter SDK: >=1.17.0
- Dart SDK: >=3.7.2

### Dependencies

- `flutter_blue_plus`: Bluetooth Low Energy functionality
- `get`: State management and dependency injection
- `http`: HTTP requests for API communication
- `shared_preferences`: Simple local storage
- `get_storage`: Fast local storage
- `sqflite`: SQLite database
- `intl`: Date formatting and internationalization
- `path`: File system path manipulation

## Platform Support

- ✅ Android
- ✅ iOS
- ❌ Web (Bluetooth limitations)
- ❌ Windows/Linux/macOS (Bluetooth limitations)

## Permissions

### Android
Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### iOS
Add to `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to connect to weight measurement devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth to connect to weight measurement devices</string>
```

## Migration Guide

This package extracts weight measurement functionality from larger farm management systems. Key components migrated:

1. **Models**: WeightMeasurement, UserDevice
2. **Services**: Bluetooth management and data processing
3. **Controllers**: Weight measurement logic (coming soon)
4. **Views**: UI components for weight measurement (coming soon)

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our [GitHub repository](https://github.com/hasanhuseyinyetkiner/tartim).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and feature requests, please visit our [GitHub Issues](https://github.com/hasanhuseyinyetkiner/tartim/issues) page.

---

**Made with ❤️ for livestock management and weight measurement automation**
=======
# tartim
>>>>>>> 1bd7916f9bd6ef60ede69608114a2b1b32add4fe
