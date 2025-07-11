import 'package:tartim/app/data/api/api_base.dart';
import 'package:tartim/app/data/api/models/api_response.dart';
import 'package:tartim/app/data/api/models/api_error.dart';
import 'package:tartim/app/data/models/measurement.dart';
import 'package:tartim/app/data/models/olcum_tipi.dart';
import 'package:get/get.dart';

class WeightMeasurementApiService extends ApiBase {
  WeightMeasurementApiService()
      : super(baseUrl: 'http://82.25.101.117:5000/api');

  final RxBool isLoading = false.obs;

  // Tüm ölçümleri getir
  Future<ApiResponse<List<dynamic>>> getAllMeasurements() async {
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

  // Son ölçümleri getir (varsayılan olarak son 15 ölçüm)
  Future<ApiResponse<List<dynamic>>> getLatestMeasurements(
      {int limit = 15}) async {
    isLoading.value = true;
    try {
      final response =
          await get<List<dynamic>>('/MobilOlcum/GetLast20?limit=$limit');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Ağırlık ölçümünü sunucuya gönder
  Future<ApiResponse<Map<String, dynamic>>> sendWeightMeasurement(
      Measurement measurement) async {
    isLoading.value = true;
    try {
      final response = await post<Map<String, dynamic>>('/MobilOlcum', body: {
        'Weight': measurement.weight,
        'Rfid': measurement.animalRfid,
        'Tarih': measurement.timestamp,
        'OlcumTipi': measurement.olcumTipi.value,
        'Amac': measurement.olcumTipi.displayName,
      });

      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Toplu ölçüm gönder
  Future<ApiResponse<Map<String, dynamic>>> sendBulkMeasurements(
      List<Measurement> measurements) async {
    isLoading.value = true;
    try {
      final List<Map<String, dynamic>> measurementMaps = measurements
          .map((m) => {
                'Weight': m.weight,
                'Rfid': m.animalRfid,
                'Tarih': m.timestamp,
                'OlcumTipi': m.olcumTipi.value,
                'Amac': m.olcumTipi.displayName,
              })
          .toList();

      final response =
          await post<Map<String, dynamic>>('/MobilOlcum/bulk', body: {
        'Measurements': measurementMaps,
      });

      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // RFID'ye göre ölçümleri getir
  Future<ApiResponse<List<dynamic>>> getMeasurementsByRfid(String rfid,
      {int limit = 10}) async {
    isLoading.value = true;
    try {
      final response =
          await get<List<dynamic>>('/MobilOlcum/byRfid/$rfid?limit=$limit');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Tarih aralığına göre ölçümleri getir
  Future<ApiResponse<List<dynamic>>> getMeasurementsByDateRange(
      DateTime startDate, DateTime endDate) async {
    isLoading.value = true;
    try {
      final response = await get<List<dynamic>>(
          '/MobilOlcum/byDateRange?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // RFID'ye göre ölçümleri listeleme (filtreli ve sıralı)
  Future<ApiResponse<List<dynamic>>> listMeasurementsByRfid(
    String rfid, {
    OlcumTipi? olcumTipi,
    String siralama = 'agirlik_azalan',
    DateTime? baslangicTarihi,
    DateTime? bitisTarihi,
  }) async {
    isLoading.value = true;
    try {
      String endpoint = '/MobilOlcum/listele?rfid=$rfid';

      if (olcumTipi != null) {
        endpoint += '&olcumTipi=${olcumTipi.value}';
      }

      endpoint += '&siralama=$siralama';

      if (baslangicTarihi != null) {
        endpoint += '&baslangicTarihi=${baslangicTarihi.toIso8601String()}';
      }

      if (bitisTarihi != null) {
        endpoint += '&bitisTarihi=${bitisTarihi.toIso8601String()}';
      }

      final response = await get<List<dynamic>>(endpoint);
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Ölçüm tipine göre ölçümleri getir
  Future<ApiResponse<List<dynamic>>> getMeasurementsByType(
      OlcumTipi olcumTipi) async {
    isLoading.value = true;
    try {
      final response = await get<List<dynamic>>(
          '/MobilOlcum/tipler?olcumTipi=${olcumTipi.value}');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Kullanıcıya ait RFID listesini getir
  Future<ApiResponse<List<dynamic>>> getKullaniciRfidListesi(int userId) async {
    isLoading.value = true;
    try {
      final response =
          await get<List<dynamic>>('/AgirlikOlcum/rfid-listesi?userId=$userId');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Sıralı listeyi getir
  Future<ApiResponse<List<dynamic>>> getSiraliListele(
      int userId, String olcumTipi, String siralama) async {
    isLoading.value = true;
    try {
      final response = await get<List<dynamic>>(
          '/AgirlikOlcum/sirali-listele?userId=$userId&olcumTipi=$olcumTipi&siralama=$siralama');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Hayvan ölçümlerini getir
  Future<ApiResponse<Map<String, dynamic>>> getHayvanOlcumleri(
      String rfid) async {
    isLoading.value = true;
    try {
      final response = await get<Map<String, dynamic>>(
          '/AgirlikOlcum/hayvan-olcumleri?rfid=$rfid');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Ölçüm ekle veya güncelle
  Future<ApiResponse<Map<String, dynamic>>> olcumEkleGuncelle(
      String rfid, String olcumTipi, double agirlik, DateTime tarih) async {
    isLoading.value = true;
    try {
      final response = await post<Map<String, dynamic>>(
          '/AgirlikOlcum/olcum-ekle-guncelle',
          body: {
            'rfid': rfid,
            'olcumTipi': olcumTipi,
            'agirlik': agirlik,
            'tarih': tarih.toIso8601String(),
          });
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Ölçümü güncelle
  Future<ApiResponse<Map<String, dynamic>>> updateMeasurement(
      int id, Measurement measurement) async {
    isLoading.value = true;
    try {
      final response =
          await put<Map<String, dynamic>>('/MobilOlcum/$id', body: {
        'Id': id,
        'Weight': measurement.weight,
        'Rfid': measurement.animalRfid,
        'Tarih': measurement.timestamp,
        'OlcumTipi': measurement.olcumTipi.value,
        'Amac': measurement.olcumTipi.displayName,
      });
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Ölçümü sil
  Future<ApiResponse<Map<String, dynamic>>> deleteMeasurement(int id) async {
    isLoading.value = true;
    try {
      final response = await delete<Map<String, dynamic>>('/MobilOlcum/$id');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Ölçümü sil (RFID ve ölçüm tipine göre)
  Future<ApiResponse<Map<String, dynamic>>> olcumSil(
      String rfid, String olcumTipi) async {
    isLoading.value = true;
    try {
      final response = await delete<Map<String, dynamic>>(
          '/AgirlikOlcum/olcum-sil?rfid=$rfid&olcumTipi=$olcumTipi');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Teşhis bilgilerini getir
  Future<ApiResponse<Map<String, dynamic>>> getDiagnostics() async {
    isLoading.value = true;
    try {
      final response =
          await get<Map<String, dynamic>>('/MobilOlcum/diagnostics');
      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }
}
