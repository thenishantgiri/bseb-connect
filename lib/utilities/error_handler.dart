import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Utils.dart';

/// Centralized error handling for the app
///
/// Provides consistent error messages and handling across all screens
class ErrorHandler {
  /// Handle Dio/API errors and show appropriate user message
  static String handleError(dynamic error, [BuildContext? context]) {
    String message = _getErrorMessage(error);

    if (context != null) {
      Utils.snackBarError(context, message);
    }

    return message;
  }

  /// Get user-friendly error message from exception
  static String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is SocketException) {
      return 'no_internet'.tr;
    } else if (error is FormatException) {
      return 'invalid_response'.tr;
    } else if (error is TypeError) {
      return 'data_error'.tr;
    } else {
      return error?.toString() ?? 'unknown_error'.tr;
    }
  }

  /// Handle Dio-specific errors
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'connection_timeout'.tr;
      case DioExceptionType.sendTimeout:
        return 'send_timeout'.tr;
      case DioExceptionType.receiveTimeout:
        return 'receive_timeout'.tr;
      case DioExceptionType.badResponse:
        // First try to extract the actual error message from the backend response
        final backendMessage = _extractBackendMessage(error.response?.data);
        if (backendMessage != null) {
          return backendMessage;
        }
        return _handleStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'request_cancelled'.tr;
      case DioExceptionType.connectionError:
        return 'no_internet'.tr;
      default:
        return 'network_error'.tr;
    }
  }

  /// Extract error message from backend response
  static String? _extractBackendMessage(dynamic data) {
    if (data == null) return null;

    try {
      if (data is Map) {
        // Check for common error message fields
        final message = data['message'] ?? data['error'] ?? data['msg'];
        if (message != null && message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Get message for HTTP status codes
  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'bad_request'.tr;
      case 401:
        return 'unauthorized'.tr;
      case 403:
        return 'forbidden'.tr;
      case 404:
        return 'not_found'.tr;
      case 408:
        return 'request_timeout'.tr;
      case 429:
        return 'too_many_attempts'.tr;
      case 500:
        return 'server_error'.tr;
      case 502:
        return 'bad_gateway'.tr;
      case 503:
        return 'service_unavailable'.tr;
      default:
        return 'error_occurred'.tr;
    }
  }

  /// Wrap async operations with error handling
  static Future<T?> tryAsync<T>(
    Future<T> Function() operation, {
    BuildContext? context,
    String? fallbackMessage,
    VoidCallback? onError,
  }) async {
    try {
      return await operation();
    } catch (e) {
      final message = fallbackMessage ?? handleError(e, context);
      print('ErrorHandler: $message - $e');
      onError?.call();
      return null;
    }
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout;
    }
    return error is SocketException;
  }

  /// Check if error requires re-authentication
  static bool requiresReAuth(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 401;
    }
    return false;
  }
}

/// Extension for easier error handling in screens
extension ErrorHandlerContext on BuildContext {
  void showError(dynamic error) {
    ErrorHandler.handleError(error, this);
  }

  void showErrorMessage(String message) {
    Utils.snackBarError(this, message);
  }

  void showSuccess(String message) {
    Utils.snackBarSuccess(this, message);
  }
}
