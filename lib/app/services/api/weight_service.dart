import 'package:animaltracker/app/data/api/api_base.dart';
import 'package:animaltracker/app/data/api/models/api_response.dart';
import 'package:animaltracker/app/data/api/models/api_error.dart';
import 'package:animaltracker/app/data/models/weight_measurement.dart';
import 'package:animaltracker/app/data/models/birth_weight_measurement.dart';
import 'package:animaltracker/app/data/models/weaning_weight_measurement.dart';
import 'package:get/get.dart';

class WeightService extends ApiBase {
  WeightService({String baseUrl = 'http://82.25.101.117:5000/api'})
      : super(baseUrl);

  final RxBool isLoading = false.obs;

  // NORMAL WEIGHT MEASUREMENTS

  // Get all normal weight measurements
  Future<ApiResponse<List<WeightMeasurement>>>
      getNormalWeightMeasurements() async {
    isLoading.value = true;
    try {
      final response = await get<List<dynamic>>('/AgirlikApi');

      if (response.data != null) {
        final measurements = response.data!
            .map((json) =>
                WeightMeasurement.fromJson(json as Map<String, dynamic>))
            .toList();

        isLoading.value = false;
        return ApiResponse(data: measurements);
      }

      isLoading.value = false;
      return response as ApiResponse<List<WeightMeasurement>>;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Get normal weight measurement by ID
  Future<ApiResponse<WeightMeasurement>> getNormalWeightMeasurementById(
      int id) async {
    isLoading.value = true;
    try {
      final response = await get<Map<String, dynamic>>('/AgirlikApi/$id');

      if (response.data != null) {
        final measurement = WeightMeasurement.fromJson(response.data!);

        isLoading.value = false;
        return ApiResponse(data: measurement);
      }

      isLoading.value = false;
      return ApiResponse(error: response.error);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Get normal weight measurements by animal ID
  Future<ApiResponse<List<WeightMeasurement>>>
      getNormalWeightMeasurementsByAnimalId(int animalId) async {
    isLoading.value = true;
    try {
      final response = await get<List<dynamic>>('/AgirlikApi/hayvan/$animalId');

      if (response.data != null) {
        final measurements = response.data!
            .map((json) =>
                WeightMeasurement.fromJson(json as Map<String, dynamic>))
            .toList();

        isLoading.value = false;
        return ApiResponse(data: measurements);
      }

      isLoading.value = false;
      return response as ApiResponse<List<WeightMeasurement>>;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Add normal weight measurement
  Future<ApiResponse<WeightMeasurement>> addNormalWeightMeasurement(
      WeightMeasurement measurement) async {
    isLoading.value = true;
    try {
      final response = await post<Map<String, dynamic>>(
        '/AgirlikApi',
        body: measurement.toJson(),
      );

      if (response.data != null && response.data!['data'] != null) {
        final addedMeasurement = WeightMeasurement.fromJson(
            response.data!['data'] as Map<String, dynamic>);

        isLoading.value = false;
        return ApiResponse(data: addedMeasurement);
      }

      isLoading.value = false;
      return ApiResponse(error: response.error);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Update normal weight measurement
  Future<ApiResponse<WeightMeasurement>> updateNormalWeightMeasurement(
      int id, WeightMeasurement measurement) async {
    isLoading.value = true;
    try {
      final response = await put<Map<String, dynamic>>(
        '/AgirlikApi/$id',
        body: measurement.toJson(),
      );

      if (response.data != null && response.data!['data'] != null) {
        final updatedMeasurement = WeightMeasurement.fromJson(
            response.data!['data'] as Map<String, dynamic>);

        isLoading.value = false;
        return ApiResponse(data: updatedMeasurement);
      }

      isLoading.value = false;
      return ApiResponse(error: response.error);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Delete normal weight measurement
  Future<ApiResponse<bool>> deleteNormalWeightMeasurement(int id) async {
    isLoading.value = true;
    try {
      final response = await delete<Map<String, dynamic>>('/AgirlikApi/$id');

      isLoading.value = false;
      if (response.error == null) {
        return ApiResponse(data: true);
      }

      return ApiResponse(data: false, error: response.error);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // WEANING WEIGHT MEASUREMENTS

  // Get all weaning weight measurements
  Future<ApiResponse<List<WeaningWeightMeasurement>>>
      getWeaningWeightMeasurements() async {
    isLoading.value = true;
    try {
      final response = await get<List<dynamic>>('/SuttenKesimAgirlik');

      if (response.data != null) {
        final measurements = response.data!
            .map((json) =>
                WeaningWeightMeasurement.fromJson(json as Map<String, dynamic>))
            .toList();

        isLoading.value = false;
        return ApiResponse(data: measurements);
      }

      isLoading.value = false;
      return response as ApiResponse<List<WeaningWeightMeasurement>>;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Get weaning weight measurement by ID
  Future<ApiResponse<WeaningWeightMeasurement>> getWeaningWeightMeasurementById(
      int id) async {
    isLoading.value = true;
    try {
      final response =
          await get<Map<String, dynamic>>('/SuttenKesimAgirlik/$id');

      if (response.data != null) {
        final measurement = WeaningWeightMeasurement.fromJson(response.data!);

        isLoading.value = false;
        return ApiResponse(data: measurement);
      }

      isLoading.value = false;
      return ApiResponse(error: response.error);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Get weaning weight measurements by animal ID
  Future<ApiResponse<List<WeaningWeightMeasurement>>>
      getWeaningWeightMeasurementsByAnimalId(int animalId) async {
    isLoading.value = true;
    try {
      final response =
          await get<List<dynamic>>('/SuttenKesimAgirlik/hayvan/$animalId');

      if (response.data != null) {
        final measurements = response.data!
            .map((json) =>
                WeaningWeightMeasurement.fromJson(json as Map<String, dynamic>))
            .toList();

        isLoading.value = false;
        return ApiResponse(data: measurements);
      }

      isLoading.value = false;
      return response as ApiResponse<List<WeaningWeightMeasurement>>;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Add weaning weight measurement
  Future<ApiResponse<WeaningWeightMeasurement>> addWeaningWeightMeasurement(
      WeaningWeightMeasurement measurement) async {
    isLoading.value = true;
    try {
      final response = await post<Map<String, dynamic>>(
        '/SuttenKesimAgirlik',
        body: measurement.toJson(),
      );

      if (response.data != null && response.data!['data'] != null) {
        final addedMeasurement = WeaningWeightMeasurement.fromJson(
            response.data!['data'] as Map<String, dynamic>);

        isLoading.value = false;
        return ApiResponse(data: addedMeasurement);
      }

      isLoading.value = false;
      return ApiResponse(error: response.error);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Update weaning weight measurement
  Future<ApiResponse<WeaningWeightMeasurement>> updateWeaningWeightMeasurement(
      int id, WeaningWeightMeasurement measurement) async {
    isLoading.value = true;
    try {
      final response = await put<Map<String, dynamic>>(
        '/SuttenKesimAgirlik/$id',
        body: measurement.toJson(),
      );

      if (response.data != null && response.data!['data'] != null) {
        final updatedMeasurement = WeaningWeightMeasurement.fromJson(
            response.data!['data'] as Map<String, dynamic>);

        isLoading.value = false;
        return ApiResponse(data: updatedMeasurement);
      }

      isLoading.value = false;
      return ApiResponse(error: response.error);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Delete weaning weight measurement
  Future<ApiResponse<bool>> deleteWeaningWeightMeasurement(int id) async {
    isLoading.value = true;
    try {
      final response =
          await delete<Map<String, dynamic>>('/SuttenKesimAgirlik/$id');

      isLoading.value = false;
      if (response.error == null) {
        return ApiResponse(data: true);
      }

      return ApiResponse(data: false, error: response.error);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // BIRTH WEIGHT MEASUREMENTS

  // Get all birth weight measurements
  Future<ApiResponse<List<BirthWeightMeasurement>>>
      getBirthWeightMeasurements() async {
    isLoading.value = true;
    try {
      final response = await get<List<dynamic>>('/DogumAgirlik');

      if (response.data != null) {
        final measurements = response.data!
            .map((json) =>
                BirthWeightMeasurement.fromJson(json as Map<String, dynamic>))
            .toList();

        isLoading.value = false;
        return ApiResponse(data: measurements);
      }

      isLoading.value = false;
      return response as ApiResponse<List<BirthWeightMeasurement>>;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Get birth weight measurement by ID
  Future<ApiResponse<BirthWeightMeasurement>> getBirthWeightMeasurementById(
      int id) async {
    isLoading.value = true;
    try {
      final response = await get<Map<String, dynamic>>('/DogumAgirlik/$id');

      if (response.data != null) {
        final measurement = BirthWeightMeasurement.fromJson(response.data!);

        isLoading.value = false;
        return ApiResponse(data: measurement);
      }

      isLoading.value = false;
      return ApiResponse(error: response.error);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Get birth weight measurements by animal ID
  Future<ApiResponse<List<BirthWeightMeasurement>>>
      getBirthWeightMeasurementsByAnimalId(int animalId) async {
    isLoading.value = true;
    try {
      final response =
          await get<List<dynamic>>('/DogumAgirlik/hayvan/$animalId');

      if (response.data != null) {
        final measurements = response.data!
            .map((json) =>
                BirthWeightMeasurement.fromJson(json as Map<String, dynamic>))
            .toList();

        isLoading.value = false;
        return ApiResponse(data: measurements);
      }

      isLoading.value = false;
      return response as ApiResponse<List<BirthWeightMeasurement>>;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Add birth weight measurement
  Future<ApiResponse<BirthWeightMeasurement>> addBirthWeightMeasurement(
      BirthWeightMeasurement measurement) async {
    isLoading.value = true;
    try {
      final response = await post<Map<String, dynamic>>(
        '/DogumAgirlik',
        body: measurement.toJson(),
      );

      if (response.data != null && response.data!['data'] != null) {
        final addedMeasurement = BirthWeightMeasurement.fromJson(
            response.data!['data'] as Map<String, dynamic>);

        isLoading.value = false;
        return ApiResponse(data: addedMeasurement);
      }

      isLoading.value = false;
      return ApiResponse(error: response.error);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Update birth weight measurement
  Future<ApiResponse<BirthWeightMeasurement>> updateBirthWeightMeasurement(
      int id, BirthWeightMeasurement measurement) async {
    isLoading.value = true;
    try {
      final response = await put<Map<String, dynamic>>(
        '/DogumAgirlik/$id',
        body: measurement.toJson(),
      );

      if (response.data != null && response.data!['data'] != null) {
        final updatedMeasurement = BirthWeightMeasurement.fromJson(
            response.data!['data'] as Map<String, dynamic>);

        isLoading.value = false;
        return ApiResponse(data: updatedMeasurement);
      }

      isLoading.value = false;
      return ApiResponse(error: response.error);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Delete birth weight measurement
  Future<ApiResponse<bool>> deleteBirthWeightMeasurement(int id) async {
    isLoading.value = true;
    try {
      final response = await delete<Map<String, dynamic>>('/DogumAgirlik/$id');

      isLoading.value = false;
      if (response.error == null) {
        return ApiResponse(data: true);
      }

      return ApiResponse(data: false, error: response.error);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Mobile device specific methods

  // Send normal weight measurement from mobile
  Future<ApiResponse<Map<String, dynamic>>> sendNormalWeightMeasurement(
      WeightMeasurement measurement) async {
    isLoading.value = true;
    try {
      final response = await post<Map<String, dynamic>>(
        '/AgirlikApi/mobile/weight',
        body: {
          'weight': measurement.weight,
          'hayvanId': measurement.animalId,
          'userId': measurement.userId,
          'rfid': measurement.rfid,
          'note': measurement.notes,
        },
      );

      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Send weaning weight measurement from mobile
  Future<ApiResponse<Map<String, dynamic>>> sendWeaningWeightMeasurement(
      WeaningWeightMeasurement measurement) async {
    isLoading.value = true;
    try {
      final response = await post<Map<String, dynamic>>(
        '/SuttenKesimAgirlik/mobile/weight',
        body: {
          'weight': measurement.weight,
          'hayvanId': measurement.animalId,
          'userId': measurement.userId,
          'rfid': measurement.rfid,
          'motherRfid': measurement.motherRfid,
          'note': measurement.notes,
          'weaningDate': measurement.weaningDate?.toIso8601String(),
          'weaningAge': measurement.weaningAge,
        },
      );

      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Send birth weight measurement from mobile
  Future<ApiResponse<Map<String, dynamic>>> sendBirthWeightMeasurement(
      BirthWeightMeasurement measurement) async {
    isLoading.value = true;
    try {
      final response = await post<Map<String, dynamic>>(
        '/DogumAgirlik/mobile/weight',
        body: {
          'weight': measurement.weight,
          'hayvanId': measurement.animalId,
          'userId': measurement.userId,
          'rfid': measurement.rfid,
          'motherRfid': measurement.motherRfid,
          'note': measurement.notes,
          'birthDate': measurement.birthDate?.toIso8601String(),
          'birthPlace': measurement.birthPlace,
        },
      );

      isLoading.value = false;
      return response;
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  // Offline synchronization helper
  Future<ApiResponse<bool>> synchronizeOfflineMeasurements(
      List<WeightMeasurement> normalMeasurements,
      List<WeaningWeightMeasurement> weaningMeasurements,
      List<BirthWeightMeasurement> birthMeasurements) async {
    isLoading.value = true;
    bool hasErrors = false;
    List<String> errorMessages = [];

    try {
      // Synchronize normal measurements
      for (var measurement in normalMeasurements) {
        final response = await sendNormalWeightMeasurement(measurement);
        if (response.error != null) {
          hasErrors = true;
          errorMessages.add(
              'Ağırlık senkronizasyonu hatası: ${response.error!.message}');
        }
      }

      // Synchronize weaning measurements
      for (var measurement in weaningMeasurements) {
        final response = await sendWeaningWeightMeasurement(measurement);
        if (response.error != null) {
          hasErrors = true;
          errorMessages.add(
              'Sütten kesim ağırlık senkronizasyonu hatası: ${response.error!.message}');
        }
      }

      // Synchronize birth measurements
      for (var measurement in birthMeasurements) {
        final response = await sendBirthWeightMeasurement(measurement);
        if (response.error != null) {
          hasErrors = true;
          errorMessages.add(
              'Doğum ağırlık senkronizasyonu hatası: ${response.error!.message}');
        }
      }

      isLoading.value = false;
      if (hasErrors) {
        return ApiResponse(
            data: false,
            error: ApiError(
                message:
                    'Senkronizasyon hataları: ${errorMessages.join(', ')}'));
      }

      return ApiResponse(data: true);
    } catch (e) {
      isLoading.value = false;
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }
}
