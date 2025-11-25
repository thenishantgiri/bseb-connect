import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'ApiInterceptor.dart';
import 'auth_interceptor.dart';
import '../config/environment.dart';

/// Singleton class to manage a single Dio instance throughout the app
/// This prevents memory waste from multiple Dio instances and ensures
/// consistent configuration across all API calls
class DioSingleton {
  static DioSingleton? _instance;
  static Dio? _dio;

  // Private constructor
  DioSingleton._();

  /// Get the singleton instance
  static DioSingleton get instance {
    _instance ??= DioSingleton._();
    return _instance!;
  }

  /// Get the configured Dio instance
  /// Uses lazy initialization to create Dio only when needed
  Dio get dio {
    if (_dio == null) {
      _dio = _createDio();
      _configureDio(_dio!);
    }
    return _dio!;
  }

  /// Create a new Dio instance with base configuration
  Dio _createDio() {
    final dio = Dio();

    // Set base options using environment configuration
    dio.options = BaseOptions(
      connectTimeout: Environment.connectTimeout,
      receiveTimeout: Environment.receiveTimeout,
      sendTimeout: Environment.connectTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    return dio;
  }

  /// Configure Dio with interceptors
  void _configureDio(Dio dio) {
    // Add auth interceptor for JWT token management and 401 handling
    dio.interceptors.add(AuthInterceptor(dio));

    // Add the API interceptor for logging
    dio.interceptors.add(ApiInterceptor());

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (log) {
          // Use debugPrint instead of print for better control
          debugPrint('DIO: $log');
        },
      ));
    }
  }

  /// Reset the Dio instance (useful for testing or when configuration changes)
  void reset() {
    _dio?.close();
    _dio = null;
  }

  /// Update headers (e.g., when token changes)
  void updateHeaders(Map<String, dynamic> headers) {
    _dio?.options.headers.addAll(headers);
  }

  /// Set authorization token
  void setAuthToken(String token) {
    _dio?.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authorization token
  void clearAuthToken() {
    _dio?.options.headers.remove('Authorization');
  }
}

/// Convenience function to get the Dio instance
Dio getDio() => DioSingleton.instance.dio;