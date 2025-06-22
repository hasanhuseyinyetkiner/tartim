import 'package:get/get.dart';
import 'package:animaltracker/app/data/models/device.dart';
import 'package:animaltracker/app/modules/weight_measurement/weight_measurement_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SettingsController extends GetxController {
  final WeightMeasurementBluetooth weightMeasurementBluetooth;

  SettingsController({required this.weightMeasurementBluetooth});

  // Language and theme settings
  final RxString currentLanguage = 'tr_TR'.obs;
  final RxBool isDarkMode = false.obs;

  // Devices section
  final selectedFilter = 'all'.obs;

  // Convenience getters for bluetooth status
  bool get isScanning => weightMeasurementBluetooth.isScanning.value;
  bool get isConnecting => weightMeasurementBluetooth.isConnecting.value;
  Device? get connectedDevice =>
      weightMeasurementBluetooth.connectedDevice.value;
  bool get isDeviceConnected =>
      weightMeasurementBluetooth.isDeviceConnected.value;
  RxList<Device> get availableDevices =>
      weightMeasurementBluetooth.availableDevices;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Load language preference
    final lang = prefs.getString('language') ?? 'tr_TR';
    currentLanguage.value = lang;

    // Load theme preference
    final darkMode = prefs.getBool('darkMode') ?? false;
    isDarkMode.value = darkMode;
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', currentLanguage.value);
    await prefs.setBool('darkMode', isDarkMode.value);
  }

  void changeLanguage(String languageCode) {
    Locale locale;
    switch (languageCode) {
      case 'en_US':
        locale = const Locale('en', 'US');
        currentLanguage.value = 'en_US';
        break;
      case 'de_DE':
        locale = const Locale('de', 'DE');
        currentLanguage.value = 'de_DE';
        break;
      case 'tr_TR':
      default:
        locale = const Locale('tr', 'TR');
        currentLanguage.value = 'tr_TR';
    }
    Get.updateLocale(locale);
    saveSettings();
  }

  void toggleTheme() {
    isDarkMode.toggle();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    saveSettings();
  }

  // Device related methods
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> startScan() async {
    await weightMeasurementBluetooth.startScan();
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(Device device) async {
    await weightMeasurementBluetooth.connectToDevice(device);
  }

  Future<void> disconnectDevice() async {
    await weightMeasurementBluetooth.disconnectDevice();
  }
}
