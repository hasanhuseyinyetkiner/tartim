<<<<<<< HEAD
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2025-01-22

### Added
- Initial release of Tartım weight measurement package
- **Models**:
  - `WeightMeasurement`: Comprehensive weight measurement data model
    - SQLite and API serialization support
    - Multiple field name compatibility
    - Data validation and formatting
    - Immutable updates with copyWith()
  - `UserDevice`: Bluetooth device management model
    - JSON serialization for API integration
    - MAC address validation
    - Connection status tracking
    - Device type categorization

- **Services**:
  - `TartimBluetoothService`: Bluetooth management service
    - Device scanning and discovery
    - Connection management with auto-reconnection
    - Real-time data reception and processing
    - Signal strength monitoring
    - Weight data parsing from Bluetooth devices

- **Core Features**:
  - Bluetooth Low Energy (BLE) device integration
  - Real-time weight data reception from smart scales
  - RFID tag reading and animal identification
  - Local data storage with SQLite support
  - API integration for cloud synchronization
  - Multiple measurement types (normal, weaning, birth weights)
  - Automatic data validation and formatting

- **Dependencies**:
  - flutter_blue_plus: ^1.32.12
  - get: ^4.6.6
  - http: ^1.2.2
  - shared_preferences: ^2.3.2
  - get_storage: ^2.1.1
  - sqflite: ^2.4.1
  - intl: ^0.19.0
  - path: ^1.9.0

- **Platform Support**:
  - Android support with Bluetooth permissions
  - iOS support with Bluetooth permissions
  - Comprehensive documentation and usage examples

### Migration Notes
- Extracted weight measurement functionality from larger farm management systems
- Migrated core models: WeightMeasurement, UserDevice
- Migrated Bluetooth service and data processing logic
- Maintained compatibility with existing API structures
- Preserved SQLite database schema compatibility

### Coming Soon
- Weight measurement controllers
- UI components and views
- Device selection widgets
- Weight display widgets
- Data analysis utilities
- Advanced filtering and sorting
- Export/import functionality 
=======
## 0.0.1

* TODO: Describe initial release.
>>>>>>> 1bd7916f9bd6ef60ede69608114a2b1b32add4fe
