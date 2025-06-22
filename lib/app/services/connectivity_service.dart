import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:animaltracker/app/services/sync_service.dart';

/// İnternet bağlantısını takip eden ve durumu güncelleyen servis
class ConnectivityService extends GetxService {
  final RxBool isConnected = true.obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _subscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<ConnectivityService> init() async {
    await _initConnectivity();
    return this;
  }

  Future<void> _initConnectivity() async {
    try {
      final status = await Connectivity().checkConnectivity();
      _updateConnectionStatus(status);
    } catch (e) {
      isConnected.value = false;
      print('Bağlantı kontrolünde hata: $e');
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final previous = isConnected.value;
    isConnected.value = result != ConnectivityResult.none;

    // Bağlantı durumu değiştiğinde bildirim göster
    if (previous != isConnected.value) {
      if (isConnected.value) {
        Get.snackbar(
          'Bağlantı Sağlandı',
          'İnternet bağlantısı yeniden kuruldu. Veriler senkronize ediliyor.',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );

        // Burada senkronizasyon servisini çağırabiliriz
        try {
          if (Get.isRegistered<SyncService>()) {
            Get.find<SyncService>().syncPendingOperations();
          }
        } catch (e) {
          print('Senkronizasyon servisine erişilemiyor: $e');
        }
      } else {
        Get.snackbar(
          'Bağlantı Kesildi',
          'İnternet bağlantısı kesildi. Veriler yerel olarak saklanacak.',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      }
    }
  }

  // Bağlantıyı kontrol eden fonksiyon
  Future<bool> checkConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      final connected = result != ConnectivityResult.none;
      isConnected.value = connected;
      return connected;
    } catch (e) {
      isConnected.value = false;
      return false;
    }
  }
}
