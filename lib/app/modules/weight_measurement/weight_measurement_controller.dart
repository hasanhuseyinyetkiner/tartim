import 'package:tartim/app/data/models/animal.dart';
import 'package:tartim/app/data/models/device.dart';
import 'package:tartim/app/data/models/measurement.dart';
import 'package:tartim/app/data/models/olcum_tipi.dart';
import 'package:tartim/app/data/repositories/animal_repository.dart';
import 'package:tartim/app/data/repositories/animal_type_repository.dart';
import 'package:tartim/app/modules/weight_measurement/weight_measurement_bluetooth.dart';
import 'package:tartim/app/services/api/weight_measurement_service.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get_storage/get_storage.dart';

class WeightMeasurementController extends GetxController {
  final WeightMeasurementBluetooth weightMeasurementBluetooth;
  final AnimalRepository animalRepository;
  final AnimalTypeRepository animalTypeRepository;
  final WeightMeasurementApiService weightMeasurementApiService;
  final GetStorage storage = GetStorage();

  WeightMeasurementController({
    required this.weightMeasurementBluetooth,
    required this.animalRepository,
    required this.animalTypeRepository,
    required this.weightMeasurementApiService,
  });

  final Rx<Animal?> currentAnimal = Rx<Animal?>(null);
  final RxString animalTypeName = ''.obs;
  final RxBool isMeasuring = false.obs;
  RxList<Measurement> lastFiveMeasurements = <Measurement>[].obs;
  final RxBool isSyncing = false.obs;
  final RxBool syncSuccess = false.obs;
  final RxString syncErrorMessage = ''.obs;

  // Ölçüm tipi için yeni değişkenler
  final Rx<OlcumTipi> selectedOlcumTipi = OlcumTipi.normal.obs;
  final RxList<Measurement> filteredMeasurements = <Measurement>[].obs;

  // Filtreleme için değişkenler
  final RxString selectedSorting = 'agirlik_azalan'.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  // Ölçüm adımı için değişken
  final RxInt currentMeasurementStep = 1.obs;

  // Ölçüm durumu mesajı
  final RxString measurementStatus = 'Ölçüm bekleniyor...'.obs;

  @override
  void onInit() {
    super.onInit();
    ever(weightMeasurementBluetooth.currentRfid, (_) {
      _fetchAnimalByRfid();
      fetchLastFiveMeasurements();
    });

    // Kullanıcı tercihlerini yükle
    _loadUserPreferences();
  }

  // Kullanıcı tercihlerini kaydet
  void _saveUserPreferences() {
    storage.write('selectedOlcumTipi', selectedOlcumTipi.value.value);
    storage.write('selectedSorting', selectedSorting.value);
  }

  // Kullanıcı tercihlerini yükle
  void _loadUserPreferences() {
    if (storage.hasData('selectedOlcumTipi')) {
      int savedOlcumTipi = storage.read('selectedOlcumTipi');
      selectedOlcumTipi.value = OlcumTipi.fromValue(savedOlcumTipi);
    }

    if (storage.hasData('selectedSorting')) {
      selectedSorting.value = storage.read('selectedSorting');
    }
  }

  // Ölçüm tipini değiştir
  void changeOlcumTipi(OlcumTipi type) {
    selectedOlcumTipi.value = type;
    _saveUserPreferences();
  }

  // Sıralama tercihini değiştir
  void changeSorting(String sorting) {
    selectedSorting.value = sorting;
    _saveUserPreferences();

    // Eğer RFID varsa, filtrelenmiş ölçümleri yeniden yükle
    if (weightMeasurementBluetooth.currentRfid.isNotEmpty) {
      fetchFilteredMeasurements();
    }
  }

  // Tarih filtrelerini ayarla
  void setDateFilters(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;

    // Eğer RFID varsa, filtrelenmiş ölçümleri yeniden yükle
    if (weightMeasurementBluetooth.currentRfid.isNotEmpty) {
      fetchFilteredMeasurements();
    }
  }

  // Filtreleme kriterlerine göre ölçümleri getir
  Future<void> fetchFilteredMeasurements() async {
    if (weightMeasurementBluetooth.currentRfid.isEmpty) {
      filteredMeasurements.clear();
      return;
    }

    isSyncing.value = true;

    try {
      final response = await weightMeasurementApiService.listMeasurementsByRfid(
        weightMeasurementBluetooth.currentRfid.value,
        olcumTipi: selectedOlcumTipi.value,
        siralama: selectedSorting.value,
        baslangicTarihi: startDate.value,
        bitisTarihi: endDate.value,
      );

      if (response.error == null && response.data != null) {
        final List<dynamic> jsonList = response.data!;
        filteredMeasurements.value = jsonList
            .map((json) => Measurement.fromMap(json as Map<String, dynamic>))
            .toList();
      } else {
        filteredMeasurements.clear();
        Get.snackbar(
            'Hata', 'Ölçümler yüklenemedi: ${response.error?.message}');
      }
    } catch (e) {
      filteredMeasurements.clear();
      Get.snackbar('Hata', 'Ölçümler yüklenemedi: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> fetchLastFiveMeasurements() async {
    if (weightMeasurementBluetooth.currentRfid.isNotEmpty) {
      lastFiveMeasurements.value = await weightMeasurementBluetooth
          .measurementRepository
          .getLastMeasurementsByRfid(
              weightMeasurementBluetooth.currentRfid.value, 5);
    } else {
      lastFiveMeasurements.clear();
    }
  }

  Future<void> refreshData() async {
    await weightMeasurementBluetooth.updateDeviceStatus();
    await _fetchAnimalByRfid();
    await weightMeasurementBluetooth.fetchRecentMeasurements();
    await fetchLastFiveMeasurements();
    await fetchFilteredMeasurements();
  }

  Future<void> _fetchAnimalByRfid() async {
    final rfid = weightMeasurementBluetooth.currentRfid.value;
    if (rfid.isNotEmpty) {
      final animal = await animalRepository.getAnimalByRfid(rfid);
      currentAnimal.value = animal;
      if (animal != null) {
        final animalType =
            await animalTypeRepository.getAnimalTypeById(animal.typeId);
        animalTypeName.value = animalType?.name ?? 'Bilinmeyen Tür';
      } else {
        animalTypeName.value = '';
      }
    } else {
      currentAnimal.value = null;
      animalTypeName.value = '';
    }
  }

  Future<void> startMeasurement() async {
    isMeasuring.value = true;
    currentMeasurementStep.value = 2;
    measurementStatus.value = 'Ölçüm yapılıyor...';
    await weightMeasurementBluetooth.startMeasurement();
  }

  Future<void> finalizeMeasurement() async {
    if (isMeasuring.value) {
      currentMeasurementStep.value = 3;
      measurementStatus.value = 'Ölçüm kaydediliyor...';
      await weightMeasurementBluetooth
          .finalizeMeasurement(selectedOlcumTipi.value);
      isMeasuring.value = false;

      // Son ölçümü sunucuya gönder
      await sendLatestMeasurementToServer();

      Get.snackbar('Başarılı', 'Ölçüm sonlandırıldı ve kaydedildi');

      // İşlem tamamlandıktan sonra adımı sıfırla
      Future.delayed(const Duration(seconds: 2), () {
        currentMeasurementStep.value = 1;
        measurementStatus.value = 'Ölçüm bekleniyor...';
      });
    }
  }

  // Son ölçümü sunucuya gönder
  Future<void> sendLatestMeasurementToServer() async {
    if (weightMeasurementBluetooth.measurementHistory.isNotEmpty) {
      final latestMeasurement =
          weightMeasurementBluetooth.measurementHistory.first;
      await sendMeasurementToServer(latestMeasurement);
    }
  }

  // Ölçümü sunucuya gönder
  Future<void> sendMeasurementToServer(Measurement measurement) async {
    isSyncing.value = true;
    syncSuccess.value = false;
    syncErrorMessage.value = '';

    try {
      final response =
          await weightMeasurementApiService.sendWeightMeasurement(measurement);

      if (response.error == null) {
        syncSuccess.value = true;
        Get.snackbar('Başarılı', 'Ölçüm sunucuya gönderildi');
      } else {
        syncErrorMessage.value = response.error!.message;
        Get.snackbar(
            'Hata', 'Sunucuya gönderilemedi: ${response.error!.message}');
      }
    } catch (e) {
      syncErrorMessage.value = e.toString();
      Get.snackbar('Hata', 'Sunucuya gönderilemedi: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  void resetMeasurement() {
    weightMeasurementBluetooth.currentWeight.value = 0.0;
    weightMeasurementBluetooth.currentRfid.value = '';
    currentAnimal.value = null;
    animalTypeName.value = '';
    isMeasuring.value = false;
    currentMeasurementStep.value = 1;
    measurementStatus.value = 'Ölçüm bekleniyor...';
  }

  Future<String> getAnimalTypeName(int typeId) async {
    final animalType = await animalTypeRepository.getAnimalTypeById(typeId);
    return animalType?.name ?? 'Bilinmeyen Tür';
  }

  List<FlSpot> getChartData() {
    final history = weightMeasurementBluetooth.measurementHistory;
    return List.generate(history.length.clamp(0, 7), (index) {
      return FlSpot(index.toDouble(), history[index].weight);
    }).reversed.toList();
  }

  double getMaxWeight() {
    final history = weightMeasurementBluetooth.measurementHistory;
    if (history.isEmpty) return 100; // Default max if no data
    return history.map((m) => m.weight).reduce((a, b) => a > b ? a : b) *
        1.2; // 20% higher than max for padding
  }

  Future<void> connectToDevice(Device device) async {
    await weightMeasurementBluetooth.connectToDevice(device);
  }

  Future<void> disconnectDevice() async {
    await weightMeasurementBluetooth.disconnectDevice();
  }

  Future<void> startScan() async {
    await weightMeasurementBluetooth.startScan();
  }

  void cancelConnection() {
    weightMeasurementBluetooth.cancelConnection();
  }

  bool get isDeviceConnected =>
      weightMeasurementBluetooth.isDeviceConnected.value;
  bool get isConnecting => weightMeasurementBluetooth.isConnecting.value;
  bool get isScanning => weightMeasurementBluetooth.isScanning.value;
  String get connectingDeviceId =>
      weightMeasurementBluetooth.connectingDeviceId.value;
  List<Device> get availableDevices =>
      weightMeasurementBluetooth.availableDevices;
  Device? get connectedDevice =>
      weightMeasurementBluetooth.connectedDevice.value;
  double get currentWeight => weightMeasurementBluetooth.currentWeight.value;
  String get currentRfid => weightMeasurementBluetooth.currentRfid.value;
  List<Measurement> get measurementHistory =>
      weightMeasurementBluetooth.measurementHistory;

  // Her bir ölçüm tipi için renk kodu
  Map<OlcumTipi, int> get olcumTipiColors => {
        OlcumTipi.normal: 0xFF2196F3, // Mavi
        OlcumTipi.suttenKesim: 0xFF4CAF50, // Yeşil
        OlcumTipi.yeniDogmus: 0xFFF44336, // Kırmızı
      };

  // Filtreleri sıfırla
  void resetFilters() {
    selectedOlcumTipi.value = OlcumTipi.normal;
    selectedSorting.value = 'agirlik_azalan';
    startDate.value = null;
    endDate.value = null;
    _saveUserPreferences();
    filteredMeasurements.clear();
  }
}
