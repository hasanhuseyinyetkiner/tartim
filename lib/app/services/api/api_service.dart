import 'package:animaltracker/app/data/api/api_base.dart';
import 'package:animaltracker/app/data/api/models/api_response.dart';
import 'package:animaltracker/app/data/api/models/api_error.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DotNetApiService extends ApiBase {
  // API temel URL'si
  DotNetApiService({String baseUrl = 'http://82.25.101.117:5000/api'})
      : super(baseUrl);

  final RxBool isLoading = false.obs;
  final RxString token = ''.obs;

  // Token'ı ayarlamak için
  Future<void> setToken(String newToken) async {
    token.value = newToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', newToken);

    // Headers'ı güncelle
    setHeaders({
      'Authorization': 'Bearer $newToken',
      'Content-Type': 'application/json',
    });
  }

  // Token'ı almak için
  Future<String?> getToken() async {
    if (token.value.isNotEmpty) {
      return token.value;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
      setHeaders({
        'Authorization': 'Bearer $savedToken',
        'Content-Type': 'application/json',
      });
    }
    return token.value.isEmpty ? null : token.value;
  }

  // Token tabanlı kimlik doğrulama için
  Future<ApiResponse<Map<String, dynamic>>> login(
      String username, String password) async {
    isLoading.value = true;
    try {
      final response = await post<Map<String, dynamic>>('/Login',
          body: {'Username': username, 'Password': password});

      if (response.error == null && response.data != null) {
        // Token'ı al ve ayarla
        final token = response.data!['token'] as String?;
        if (token != null) {
          await setToken(token);
        }
      }

      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Hayvanlar için API istekleri
  Future<ApiResponse<List<dynamic>>> getAnimals() async {
    isLoading.value = true;
    try {
      final response = await get<List<dynamic>>('/HayvanApi');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getAnimal(int id) async {
    isLoading.value = true;
    try {
      final response = await get<Map<String, dynamic>>('/HayvanApi/$id');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getAnimalByRfid(String rfid) async {
    isLoading.value = true;
    try {
      final response =
          await get<Map<String, dynamic>>('/HayvanApi/ByRfid/$rfid');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createAnimal(
      Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response =
          await post<Map<String, dynamic>>('/HayvanApi', body: data);
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateAnimal(
      int id, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response =
          await put<Map<String, dynamic>>('/HayvanApi/$id', body: data);
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  Future<ApiResponse<void>> deleteAnimal(int id) async {
    isLoading.value = true;
    try {
      final response = await delete<void>('/HayvanApi/$id');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Ağırlık ölçümleri için API istekleri - MobilOlcum endpoint'i kullanılıyor
  Future<ApiResponse<List<dynamic>>> getWeightMeasurements() async {
    isLoading.value = true;
    try {
      final response = await get<List<dynamic>>('/MobilOlcum');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  Future<ApiResponse<List<dynamic>>> getWeightMeasurementsByAnimalId(
      int animalId) async {
    isLoading.value = true;
    try {
      final response =
          await get<List<dynamic>>('/MobilOlcum/listele?rfid=$animalId');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  Future<ApiResponse<List<dynamic>>> getWeightMeasurementsByRfid(
      String rfid) async {
    isLoading.value = true;
    try {
      final response = await get<List<dynamic>>('/MobilOlcum/byRfid/$rfid');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createWeightMeasurement(
      Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response =
          await post<Map<String, dynamic>>('/MobilOlcum', body: data);
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createWeightMeasurementsBulk(
      List<Map<String, dynamic>> measurements) async {
    isLoading.value = true;
    try {
      final response = await post<Map<String, dynamic>>('/MobilOlcum/bulk',
          body: {"Measurements": measurements});
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateWeightMeasurement(
      int id, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response =
          await put<Map<String, dynamic>>('/MobilOlcum/$id', body: data);
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  Future<ApiResponse<void>> deleteWeightMeasurement(int id) async {
    isLoading.value = true;
    try {
      final response = await delete<void>('/MobilOlcum/$id');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Doğum kayıtları için API istekleri
  Future<ApiResponse<List<dynamic>>> getBirthRecords() async {
    isLoading.value = true;
    try {
      final response = await get<List<dynamic>>('/Dogum');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createBirthRecord(
      Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await post<Map<String, dynamic>>('/Dogum', body: data);
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Senkronizasyon için API istekleri
  Future<ApiResponse<Map<String, dynamic>>> syncData(
      Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response =
          await post<Map<String, dynamic>>('/Sync/toplu-gonder', body: data);
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }
}

// .NET Core'un özel döndürdüğü cevaplar için ek model
class DotNetApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  DotNetApiResponse({required this.success, this.message, this.data});

  factory DotNetApiResponse.fromJson(Map<String, dynamic> json) {
    return DotNetApiResponse(
      success: json['Success'] ?? json['success'] ?? false,
      message: json['Message'] ?? json['message'],
      data: json['Data'] ?? json['data'],
    );
  }
}
