import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tartim/app/data/api/api_base.dart';
import 'package:tartim/app/data/api/models/api_response.dart';
import 'package:tartim/app/data/api/models/api_error.dart';

class AuthService extends GetxService {
  late final ApiBase _apiBase;
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;
  final RxString currentUser = ''.obs;
  final RxString token = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _apiBase = ApiBase();
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedUser = prefs.getString('current_user');
      
      if (savedToken != null && savedToken.isNotEmpty) {
        token.value = savedToken;
        currentUser.value = savedUser ?? '';
        isAuthenticated.value = true;
        
        // API headers'ını güncelle
        _apiBase.setHeaders({
          'Authorization': 'Bearer $savedToken',
          'Content-Type': 'application/json',
        });
      }
    } catch (e) {
      print('Auth durumu kontrol edilirken hata: $e');
    }
  }

  Future<ApiResponse> login(String username, String password) async {
    try {
      isLoading.value = true;
      
      final response = await _apiBase.post('/auth/login', body: {
        'username': username,
        'password': password,
      });

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final authToken = data['token'] as String?;
        final user = data['user'] as String?;

        if (authToken != null) {
          await _saveAuthData(authToken, user ?? username);
          isAuthenticated.value = true;
        }
      }

      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        error: ApiError(message: 'Giriş yaparken hata oluştu: $e'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveAuthData(String authToken, String username) async {
    try {
      token.value = authToken;
      currentUser.value = username;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', authToken);
      await prefs.setString('current_user', username);
      
      // API headers'ını güncelle
      _apiBase.setHeaders({
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      });
    } catch (e) {
      print('Auth verileri kaydedilirken hata: $e');
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      // Sunucuya logout isteği gönder
      await _apiBase.post('/auth/logout', body: {});
      
      // Yerel verileri temizle
      await _clearAuthData();
    } catch (e) {
      print('Logout yapılırken hata: $e');
      // Hata olsa bile yerel verileri temizle
      await _clearAuthData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _clearAuthData() async {
    try {
      token.value = '';
      currentUser.value = '';
      isAuthenticated.value = false;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('current_user');
      
      // API headers'ını temizle
      _apiBase.setHeaders({
        'Content-Type': 'application/json',
      });
    } catch (e) {
      print('Auth verileri temizlenirken hata: $e');
    }
  }

  Future<ApiResponse> register(String username, String email, String password) async {
    try {
      isLoading.value = true;
      
      final response = await _apiBase.post('/auth/register', body: {
        'username': username,
        'email': email,
        'password': password,
      });

      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        error: ApiError(message: 'Kayıt olurken hata oluştu: $e'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse> refreshToken() async {
    try {
      if (token.value.isEmpty) {
        return ApiResponse(
          success: false,
          error: ApiError(message: 'Token bulunamadı'),
        );
      }

      final response = await _apiBase.post('/auth/refresh', body: {
        'token': token.value,
      });

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newToken = data['token'] as String?;
        
        if (newToken != null) {
          await _saveAuthData(newToken, currentUser.value);
        }
      }

      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        error: ApiError(message: 'Token yenilenirken hata oluştu: $e'),
      );
    }
  }

  // Token geçerlilik kontrol
  bool get hasValidToken => token.value.isNotEmpty && isAuthenticated.value;

  // Kullanıcı bilgilerini getir
  Future<ApiResponse> getUserProfile() async {
    try {
      if (!hasValidToken) {
        return ApiResponse(
          success: false,
          error: ApiError(message: 'Kimlik doğrulaması gerekli'),
        );
      }

      final response = await _apiBase.get('/auth/profile');
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        error: ApiError(message: 'Profil bilgileri alınırken hata oluştu: $e'),
      );
    }
  }
}
