/// API hata durumlarını temsil eden sınıf
class ApiError {
  final String message;
  final String? code;
  final int? statusCode;
  final String? technicalMessage;

  ApiError({
    required this.message,
    this.code,
    this.statusCode,
    this.technicalMessage,
  });

  /// Hatayı okunabilir bir mesaja dönüştürme
  @override
  String toString() {
    return 'ApiError: $message${code != null ? ' (Code: $code)' : ''}${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }

  /// Hatayı JSON formatına dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (code != null) 'code': code,
      if (statusCode != null) 'statusCode': statusCode,
      if (technicalMessage != null) 'technicalMessage': technicalMessage,
    };
  }

  /// JSON verilerinden ApiError oluşturma
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? json['Message'] ?? 'Bilinmeyen hata',
      code: json['code']?.toString() ?? json['Code']?.toString(),
      statusCode: json['statusCode'] ?? json['StatusCode'],
      technicalMessage: json['technicalMessage'] ?? json['TechnicalMessage'],
    );
  }
}
