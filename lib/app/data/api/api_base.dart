import 'dart:convert';
import 'package:animaltracker/app/data/api/models/api_error.dart';
import 'package:animaltracker/app/data/api/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

abstract class ApiBase extends GetxService {
  final String baseUrl;
  String? _basicAuth;
  Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  ApiBase(this.baseUrl);

  void setBasicAuth(String username, String password) {
    String credentials = base64Encode(utf8.encode('$username:$password'));
    _basicAuth = 'Basic $credentials';
  }

  void setHeaders(Map<String, String> headers) {
    _headers = headers;
  }

  Map<String, String> _getHeaders(Map<String, String>? additionalHeaders) {
    final headers = Map<String, String>.from(_headers);
    if (_basicAuth != null) {
      headers['Authorization'] = _basicAuth!;
    }
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  Future<ApiResponse<T>> get<T>(String endpoint,
      {Map<String, String>? headers}) async {
    return _sendRequest<T>('GET', endpoint, headers: headers);
  }

  Future<ApiResponse<T>> post<T>(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    return _sendRequest<T>('POST', endpoint, headers: headers, body: body);
  }

  Future<ApiResponse<T>> put<T>(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    return _sendRequest<T>('PUT', endpoint, headers: headers, body: body);
  }

  Future<ApiResponse<T>> delete<T>(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    return _sendRequest<T>('DELETE', endpoint, headers: headers, body: body);
  }

  Future<ApiResponse<T>> _sendRequest<T>(String method, String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = _getHeaders(headers);
      late final http.Response response;

      switch (method) {
        case 'POST':
          response = await http.post(uri,
              headers: requestHeaders, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await http.put(uri,
              headers: requestHeaders, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(uri,
              headers: requestHeaders, body: jsonEncode(body));
          break;
        case 'GET':
        default:
          response = await http.get(uri, headers: requestHeaders);
          break;
      }

      return _processResponse<T>(response);
    } catch (e) {
      return ApiResponse(error: ApiError(message: e.toString()));
    }
  }

  ApiResponse<T> _processResponse<T>(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return ApiResponse<T>(
        data: jsonResponse is T ? jsonResponse : jsonResponse as T,
      );
    } else {
      return ApiResponse(
        error: ApiError(
          statusCode: response.statusCode,
          message: 'HTTP error ${response.statusCode}',
          technicalMessage: response.body,
        ),
      );
    }
  }
}
