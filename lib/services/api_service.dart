import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/storage_manager.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP client with timeout
  static final http.Client _client = http.Client();

  // Build correct API URL with /api prefix
  String _buildUrl(String endpoint) {
    return '${ApiConfig.baseUrl}/api$endpoint';
  }

  // Make GET request
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse(_buildUrl(endpoint));
      final token = await StorageManager.getToken();
      
      final requestHeaders = {
        ...ApiConfig.defaultHeaders,
        if (token != null) ...ApiConfig.authHeaders(token),
        ...?headers,
      };

      debugPrint('🌐 GET Request URL: $url'); // Debug log
      debugPrint('📦 GET Headers: $requestHeaders'); // Debug log

      final response = await _client
          .get(url, headers: requestHeaders)
          .timeout(ApiConfig.requestTimeout);

      return _handleDynamicResponse(response);
    } catch (e) {
      debugPrint('❌ GET Error: $e'); // Debug log
      throw _handleError(e);
    }
  }

  // Make POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse(_buildUrl(endpoint));
      final token = await StorageManager.getToken();
      
      final requestHeaders = {
        ...ApiConfig.defaultHeaders,
        if (token != null) ...ApiConfig.authHeaders(token),
        ...?headers,
      };

      debugPrint('🌐 POST Request URL: $url'); // Debug log  
      debugPrint('📦 POST Headers: $requestHeaders'); // Debug log
      debugPrint('📋 POST Body: ${body != null ? json.encode(body) : 'null'}'); // Debug log

      final response = await _client
          .post(
            url,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConfig.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ POST Error: $e'); // Debug log
      throw _handleError(e);
    }
  }

  // Make PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse(_buildUrl(endpoint));
      final token = await StorageManager.getToken();
      
      final requestHeaders = {
        ...ApiConfig.defaultHeaders,
        if (token != null) ...ApiConfig.authHeaders(token),
        ...?headers,
      };

      final response = await _client
          .put(
            url,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConfig.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Make DELETE request
  Future<Map<String, dynamic>> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse(_buildUrl(endpoint));
      final token = await StorageManager.getToken();
      
      final requestHeaders = {
        ...ApiConfig.defaultHeaders,
        if (token != null) ...ApiConfig.authHeaders(token),
        ...?headers,
      };

      final response = await _client
          .delete(url, headers: requestHeaders)
          .timeout(ApiConfig.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle HTTP response
  dynamic _handleDynamicResponse(http.Response response) {
    final dynamic data = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final errorMessage = data is Map<String, dynamic> 
          ? data['message'] ?? 'An error occurred'
          : 'An error occurred';
      throw ApiException(
        statusCode: response.statusCode,
        message: errorMessage,
      );
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Handle string responses (like "Sale added successfully")
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } catch (e) {
        // If it's not JSON, treat it as a success message
        return {'success': true, 'message': response.body};
      }
    } else {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        throw ApiException(
          statusCode: response.statusCode,
          message: data['message'] ?? 'An error occurred',
        );
      } catch (e) {
        throw ApiException(
          statusCode: response.statusCode,
          message: response.body.isNotEmpty ? response.body : 'An error occurred',
        );
      }
    }
  }

  // Handle errors
  Exception _handleError(dynamic error) {
    if (error is SocketException) {
      return ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } else if (error is http.ClientException) {
      return ApiException(
        statusCode: 0,
        message: 'Network error occurred',
      );
    } else if (error is ApiException) {
      return error;
    } else {
      return ApiException(
        statusCode: 0,
        message: 'Unexpected error: ${error.toString()}',
      );
    }
  }

  // Close client when done
  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}