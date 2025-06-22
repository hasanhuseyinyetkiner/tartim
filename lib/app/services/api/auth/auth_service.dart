// class AuthService extends ApiBase {
//   AuthService() : super('https://your-api-endpoint.com');
//
//   final RxBool isLoading = false.obs;
//
//   Future<bool> login(String username, String password) async {
//     setBasicAuth(username, password);
//     // Burada bir login endpoint'ine istek atıp doğrulama yapabilirsiniz
//     final response = await get<void>('/login');
//     return response.error == null;
//   }
//
//   Future<ApiResponse<void>> sendData(Map<String, dynamic> data) async {
//     isLoading.value = true;
//     try {
//       final response = await post<void>('/data', body: data);
//       isLoading.value = false;
//
//       if (response.error == null) {
//         print('Veri başarıyla gönderildi');
//       } else {
//         print('Veri gönderme başarısız. Hata: ${response.error?.message}');
//       }
//
//       return response;
//     } catch (e) {
//       isLoading.value = false;
//       print('Veri gönderirken hata oluştu: $e');
//       return ApiResponse(error: ApiError(message: e.toString()));
//     }
//   }
//
//   Future<ApiResponse<List<Map<String, dynamic>>>> getUsers() async {
//     isLoading.value = true;
//     try {
//       final response = await get<List<Map<String, dynamic>>>('/users');
//       isLoading.value = false;
//
//       if (response.error == null) {
//         print('Kullanıcılar başarıyla alındı');
//       } else {
//         print('Kullanıcıları alma başarısız. Hata: ${response.error?.message}');
//       }
//
//       return response;
//     } catch (e) {
//       isLoading.value = false;
//       print('Kullanıcıları alırken hata oluştu: $e');
//       return ApiResponse(error: ApiError(message: e.toString()));
//     }
//   }
// }

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  final _storage = GetStorage();
  final RxBool _isAuthenticated = false.obs;

  // Varsayılan kullanıcı bilgileri
  final String _defaultUsername = 'admin';
  final String _defaultPassword = '1234';

  bool get isAuthenticated => _isAuthenticated.value;

  Future<bool> login(String username, String password) async {
    if (username == _defaultUsername && password == _defaultPassword) {
      _isAuthenticated.value = true;
      await _storage.write('isLoggedIn', true);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated.value = false;
    await _storage.remove('isLoggedIn');
  }

  // Uygulama başladığında oturum durumunu kontrol et
  Future<void> checkAuthStatus() async {
    _isAuthenticated.value = _storage.read('isLoggedIn') ?? false;
  }
}

// Kimlik doğrulama servisi
// - Giriş/çıkış işlemleri
// - Kullanıcı yönetimi
