import 'package:tartim/app/data/api/models/api_error.dart';
import 'package:tartim/app/services/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// API hatalarını yönetmek için yardımcı sınıf
class ApiErrorHandler {
  /// API hatasını kullanıcıya göster
  static void handleApiError(
    BuildContext context,
    ApiError? error, {
    String? customTitle,
    String? customMessage,
    bool enableOfflineOption = true,
    VoidCallback? onRetry,
    VoidCallback? onOfflineMode,
  }) {
    if (error == null) return;

    String title = customTitle ?? 'Hata';
    String message = customMessage ?? error.message;
    Color backgroundColor = Colors.red;
    Duration duration = Duration(seconds: 5);
    bool canSaveOffline = enableOfflineOption && error.code == 'network_error';

    // Hata türüne göre mesajları özelleştir
    switch (error.code) {
      case 'network_error':
        title = 'Bağlantı Hatası';
        message =
            'İnternet bağlantınızı kontrol edin. ${canSaveOffline ? 'Veriler çevrimdışı olarak kaydedilebilir.' : ''}';
        backgroundColor = Colors.orange;
        break;

      case 'timeout':
        title = 'Zaman Aşımı';
        message = 'Sunucu yanıt vermiyor. Lütfen daha sonra tekrar deneyin.';
        backgroundColor = Colors.orange;
        break;

      case 'server_error':
      case 'internal_server_error':
        title = 'Sunucu Hatası';
        message =
            'Sunucu şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
        backgroundColor = Colors.red;
        break;

      case 'unauthorized':
      case 'unauthenticated':
        title = 'Yetkilendirme Hatası';
        message = 'Oturum süreniz dolmuş olabilir. Lütfen tekrar giriş yapın.';
        backgroundColor = Colors.red;
        duration = Duration(seconds: 5);
        onOfflineMode =
            null; // Oturum hatalarında çevrimdışı mod seçeneği sunma
        break;

      case 'validation_error':
        title = 'Doğrulama Hatası';
        message = 'Lütfen girdiğiniz bilgileri kontrol edin.';
        backgroundColor = Colors.amber.shade700;
        break;

      case 'not_found':
        title = 'Bulunamadı';
        message = 'İstediğiniz veri bulunamadı.';
        backgroundColor = Colors.amber.shade700;
        break;

      default:
        if (error.statusCode != null) {
          if (error.statusCode! >= 500) {
            title = 'Sunucu Hatası';
            message =
                'Sunucu şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
            backgroundColor = Colors.red;
          } else if (error.statusCode == 401 || error.statusCode == 403) {
            title = 'Yetkilendirme Hatası';
            message =
                'Oturum süreniz dolmuş olabilir. Lütfen tekrar giriş yapın.';
            backgroundColor = Colors.red;
            onOfflineMode =
                null; // Oturum hatalarında çevrimdışı mod seçeneği sunma
          } else if (error.statusCode == 404) {
            title = 'Bulunamadı';
            message = 'İstediğiniz veri bulunamadı.';
            backgroundColor = Colors.amber.shade700;
          } else if (error.statusCode == 422) {
            title = 'Doğrulama Hatası';
            message = 'Lütfen girdiğiniz bilgileri kontrol edin.';
            backgroundColor = Colors.amber.shade700;
          }
        }
    }

    // Snackbar'ı göster
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: duration,
      isDismissible: true,
      mainButton: _buildActionButtons(
        canSaveOffline: canSaveOffline,
        onRetry: onRetry,
        onOfflineMode: onOfflineMode,
      ),
    );

    // Yetkilendirme hatası durumunda oturum sayfasına yönlendir
    if ((error.code == 'unauthorized' ||
            error.code == 'unauthenticated' ||
            error.statusCode == 401 ||
            error.statusCode == 403) &&
        Get.currentRoute != '/login') {
      Future.delayed(Duration(seconds: 2), () {
        Get.offAllNamed('/login');
      });
    }
  }

  /// Aksiyon butonlarını oluştur
  static TextButton? _buildActionButtons({
    bool canSaveOffline = false,
    VoidCallback? onRetry,
    VoidCallback? onOfflineMode,
  }) {
    if (onRetry == null && (onOfflineMode == null || !canSaveOffline)) {
      return null;
    }

    return TextButton(
      onPressed: null, // Ana buton için basılabilirliği devre dışı bırak
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Tekrar Dene',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size(60, 24),
              ),
            ),
          if (onRetry != null && canSaveOffline && onOfflineMode != null)
            SizedBox(width: 8),
          if (canSaveOffline && onOfflineMode != null)
            TextButton(
              onPressed: onOfflineMode,
              child: Text(
                'Çevrimdışı Kaydet',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size(60, 24),
              ),
            ),
        ],
      ),
    );
  }

  /// İşlemi çevrimdışı olarak kaydet
  static void saveOperationOffline(String type, dynamic data, {int? id}) {
    if (Get.isRegistered<SyncService>()) {
      Get.find<SyncService>().addPendingOperation(type, data, id: id);
    } else {
      Get.snackbar(
        'Hata',
        'Çevrimdışı kayıt yapılamıyor. Senkronizasyon servisi başlatılmamış.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

/// Özelleştirilmiş API iletişim kutusu
class ApiErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onOfflineMode;
  final bool canSaveOffline;

  const ApiErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.onRetry,
    this.onOfflineMode,
    this.canSaveOffline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: Text('Tekrar Dene'),
          ),
        if (canSaveOffline && onOfflineMode != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onOfflineMode!();
            },
            child: Text('Çevrimdışı Kaydet'),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Kapat'),
        ),
      ],
    );
  }

  /// Diyaloğu göster
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onOfflineMode,
    bool canSaveOffline = false,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => ApiErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
        onOfflineMode: onOfflineMode,
        canSaveOffline: canSaveOffline,
      ),
    );
  }
}
