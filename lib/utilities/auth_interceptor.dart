import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import 'Constant.dart';

/// Interceptor to handle JWT token management and 401 responses
class AuthInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add JWT token to headers if available
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constant.JWT_TOKEN);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (kDebugMode) {
      debugPrint('AUTH: Request to ${options.uri} with token: ${token != null ? 'Present' : 'Missing'}');
    }

    handler.next(options);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    if (error.response?.statusCode == 401) {
      if (kDebugMode) {
        debugPrint('AUTH: 401 Unauthorized detected');
      }

      // Store the original request
      final RequestOptions requestOptions = error.requestOptions;

      // If already refreshing, queue this request
      if (_isRefreshing) {
        _pendingRequests.add(requestOptions);
        return;
      }

      _isRefreshing = true;

      try {
        // Attempt to refresh the token
        final success = await _refreshToken();

        if (success) {
          // Token refreshed successfully
          if (kDebugMode) {
            debugPrint('AUTH: Token refreshed successfully');
          }

          // Get the new token
          final prefs = await SharedPreferences.getInstance();
          final newToken = prefs.getString(Constant.JWT_TOKEN);

          if (newToken != null) {
            // Update the failed request with new token
            requestOptions.headers['Authorization'] = 'Bearer $newToken';

            // Retry all pending requests with new token
            for (final pendingRequest in _pendingRequests) {
              pendingRequest.headers['Authorization'] = 'Bearer $newToken';
              dio.fetch(pendingRequest).then(
                (response) => handler.resolve(response),
                onError: (e) {
                  if (e is DioException) {
                    handler.reject(e);
                  }
                },
              );
            }
            _pendingRequests.clear();

            // Retry the original request
            final response = await dio.fetch(requestOptions);
            handler.resolve(response);
          } else {
            throw Exception('No token after refresh');
          }
        } else {
          throw Exception('Token refresh failed');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AUTH: Token refresh failed: $e');
        }

        // Clear pending requests
        _pendingRequests.clear();

        // Logout user and redirect to login
        await _handleAuthFailure();

        handler.reject(DioException(
          requestOptions: requestOptions,
          error: 'Authentication failed. Please login again.',
          type: DioExceptionType.cancel,
        ));
      } finally {
        _isRefreshing = false;
      }
    } else {
      // Not a 401 error, pass it through
      handler.next(error);
    }
  }

  /// Attempt to refresh the JWT token
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('AUTH: No refresh token available');
        }
        return false;
      }

      // Call refresh token endpoint
      final response = await Dio().post(
        '${Constant.BASE_URL}auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final newToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'] ?? refreshToken;

        // Save new tokens
        await prefs.setString(Constant.JWT_TOKEN, newToken);
        await prefs.setString('refresh_token', newRefreshToken);

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AUTH: Error refreshing token: $e');
      }
      return false;
    }
  }

  /// Handle authentication failure - logout and redirect
  Future<void> _handleAuthFailure() async {
    try {
      // Clear stored tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constant.JWT_TOKEN);
      await prefs.remove('refresh_token');
      await prefs.setBool('isLoggedIn', false);

      // Logout via AuthController if available
      if (getx.Get.isRegistered<AuthController>()) {
        final authController = getx.Get.find<AuthController>();
        await authController.logout();
      }

      // Navigate to login screen
      getx.Get.offAllNamed('/login');

      // Show error message
      getx.Get.snackbar(
        'Session Expired',
        'Please login again to continue',
        snackPosition: getx.SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AUTH: Error handling auth failure: $e');
      }
    }
  }
}