import 'package:animaltracker/app/data/api/models/api_error.dart';

/// API yanıtlarını temsil eden genel sınıf
class ApiResponse<T> {
  final T? data;
  final ApiError? error;
  final bool success;
  final String? message;

  ApiResponse({
    this.data,
    this.error,
    this.success = false,
    this.message,
  });

  /// API başarılı mı?
  bool get isSuccess => error == null && success;

  /// Bu işlem hata içeriyor mu?
  bool get hasError => error != null || !success;

  /// .NET Core API'nin döndüğü yanıt formatından ApiResponse oluşturma
  factory ApiResponse.fromDotNetResponse(Map<String, dynamic> json) {
    final success = json['Success'] ?? json['success'] ?? false;
    final message = json['Message'] ?? json['message'];
    final data = json['Data'] ?? json['data'];

    if (success) {
      return ApiResponse(
        data: data,
        success: true,
        message: message,
      );
    } else {
      final errorMessage = message ?? 'API yanıtı başarısız';
      final errorCode = json['ErrorCode'] ?? json['errorCode'] ?? 0;

      return ApiResponse(
        error: ApiError(
          message: errorMessage,
          code: errorCode.toString(),
        ),
        success: false,
        message: errorMessage,
      );
    }
  }

  /// API yanıtını JSON formatına dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'Success': success,
      'Message': message,
      'Data': data,
      if (error != null) 'Error': error!.toJson(),
    };
  }
}
