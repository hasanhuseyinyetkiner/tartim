/// Tartim - Weight Measurement Package
///
/// A comprehensive Flutter package for weight measurement functionality
/// with Bluetooth integration, data synchronization, and local storage.

library tartim;

// Core Models
export 'src/models/user_device.dart';
export 'src/models/weight_measurement.dart';

// Services
export 'src/services/bluetooth_service.dart';

// Controllers (to be implemented)
// export 'src/controllers/weight_controller.dart';
// export 'src/controllers/base_measurement_controller.dart';

// Views (to be implemented)
// export 'src/views/weight_measurement_view.dart';
// export 'src/views/device_selection_view.dart';

// Widgets (to be implemented)
// export 'src/widgets/weight_display_widget.dart';
// export 'src/widgets/device_list_item.dart';

// Utils (to be implemented)
// export 'src/utils/weight_calculator.dart';
// export 'src/utils/data_formatter.dart';

/// Package Version
const String packageVersion = '0.0.1';

/// Package Name
const String packageName = 'tartim';

/// Package Description
const String packageDescription =
    'A comprehensive Flutter package for weight measurement functionality '
    'with Bluetooth integration, data synchronization, and local storage capabilities.';

// REQUIRES: flutter_blue_plus, get, http, shared_preferences, get_storage, sqflite, intl, path
