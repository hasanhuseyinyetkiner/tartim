import 'package:tartim/app/data/api/api_base.dart';
import 'package:tartim/app/data/api/models/api_response.dart';
import 'package:tartim/app/data/api/models/api_error.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API servisinin ana sınıfı
class ApiService extends GetxService {
  late final ApiBase _apiBase;

  @override
  Future<void> onInit() async {
    super.onInit();
    _apiBase = ApiBase();
    await _initializeService();
  }

  Future<void> _initializeService() async {
    // API servisini başlat
    print('ApiService initialized');
  }

  Future<ApiResponse> get(String endpoint) async {
    return await _apiBase.get(endpoint);
  }

  Future<ApiResponse> post(String endpoint, Map<String, dynamic> data) async {
    return await _apiBase.post(endpoint, body: data);
  }

  Future<ApiResponse> put(String endpoint, Map<String, dynamic> data) async {
    return await _apiBase.put(endpoint, body: data);
  }

  Future<ApiResponse> delete(String endpoint) async {
    return await _apiBase.delete(endpoint);
  }
}

/// .NET API servisi - DotNetApiService olarak alias
class DotNetApiService extends ApiService {
  static const String baseUrl = 'https://api.example.com/';
  
  @override
  Future<void> onInit() async {
    await super.onInit();
    _apiBase.baseUrl = baseUrl;
  }

  Future<ApiResponse> uploadMeasurement(Map<String, dynamic> data) async {
    return await post('/measurements', data);
  }

  Future<ApiResponse> getMeasurements({String? animalRfid}) async {
    String endpoint = '/measurements';
    if (animalRfid != null) {
      endpoint += '?animalRfid=$animalRfid';
    }
    return await get(endpoint);
  }

  Future<ApiResponse> getAnimals() async {
    return await get('/animals');
  }

  Future<ApiResponse> createAnimal(Map<String, dynamic> animalData) async {
    return await post('/animals', animalData);
  }

  Future<ApiResponse> updateAnimal(int id, Map<String, dynamic> animalData) async {
    return await put('/animals/$id', animalData);
  }

  Future<ApiResponse> deleteAnimal(int id) async {
    return await delete('/animals/$id');
  }

  Future<ApiResponse> createWeightMeasurementsBulk(List<Map<String, dynamic>> measurements) async {
    return await post('/weight-measurements/bulk', {'measurements': measurements});
  }

  Future<ApiResponse> updateWeightMeasurement(int id, Map<String, dynamic> data) async {
    return await put('/weight-measurements/$id', data);
  }

  Future<ApiResponse> deleteWeightMeasurement(int id) async {
    return await delete('/weight-measurements/$id');
  }

  Future<ApiResponse> getAnimalByRfid(String rfid) async {
    return await get('/animals/rfid/$rfid');
  }

  Future<ApiResponse> getAnimal(int id) async {
    return await get('/animals/$id');
  }
}

/// WeightMeasurementApiService sınıfı
class WeightMeasurementApiService extends DotNetApiService {
  Future<ApiResponse> submitWeightMeasurement(Map<String, dynamic> data) async {
    return await post('/weight-measurements', data);
  }

  Future<ApiResponse> getWeightHistory(String animalRfid) async {
    return await get('/weight-measurements/$animalRfid');
  }

  Future<ApiResponse> updateWeightMeasurement(int id, Map<String, dynamic> data) async {
    return await put('/weight-measurements/$id', data);
  }
}
