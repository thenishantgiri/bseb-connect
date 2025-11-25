import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// ApiInterceptor provides request/response/error logging for API calls
///
/// This interceptor sets up comprehensive logging to help with debugging
/// and monitoring network traffic
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint("API Request Method: ${options.method}");
      debugPrint("API Request URL: ${options.uri}");
      debugPrint("API Request Headers: ${options.headers}");
      debugPrint("API Request Body: ${options.data}");
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint("API Response Status Code: ${response.statusCode}");
      // Limit response data logging to prevent console overflow
      final responseData = response.data.toString();
      if (responseData.length > 500) {
        debugPrint("API Response Data: ${responseData.substring(0, 500)}...[truncated]");
      } else {
        debugPrint("API Response Data: $responseData");
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint("API Error Type: ${error.type}");
      debugPrint("API Error Message: ${error.message}");
      if (error.response != null) {
        debugPrint("API Error Response Status: ${error.response?.statusCode}");
        debugPrint("API Error Response Data: ${error.response?.data}");
      }
    }
    handler.next(error);
  }

  /// Creates a configured Dio instance with logging interceptors
  /// DEPRECATED: Use DioSingleton.instance.dio instead
  @Deprecated('Use DioSingleton.instance.dio instead')
  static Dio createDio() {
    final Dio dio = Dio();

    // Add custom interceptor
    dio.interceptors.add(ApiInterceptor());

    // Add the built-in LogInterceptor for extended logs
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (log) {
          final String logString = log.toString();
          if (logString.length > 1000) {
            // Break long logs into chunks
            final chunks = _splitIntoChunks(logString, 1000);
            for (final chunk in chunks) {
              debugPrint(chunk);
            }
          } else {
            debugPrint(logString);
          }
        },
      ));
    }

    return dio;
  }

  /// Splits long log strings into smaller chunks for better console readability
  static List<String> _splitIntoChunks(String text, int chunkSize) {
    final List<String> chunks = [];
    for (var i = 0; i < text.length; i += chunkSize) {
      chunks.add(text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }
    return chunks;
  }
}
