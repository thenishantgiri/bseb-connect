import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utilities/dio_singleton.dart';
import '../utilities/Constant.dart';
import '../utilities/error_handler.dart';
import '../models/api_response.dart';
import '../models/student_model.dart';

/// Centralized API service for all network calls
///
/// Provides type-safe methods for each API endpoint
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Use singleton Dio instance instead of creating multiple instances
  Dio get _dio => DioSingleton.instance.dio;

  // ==================== AUTH APIs ====================

  /// Send OTP for login (supports both phone and email)
  Future<ApiResponse<Map<String, dynamic>>> sendOtpLogin(String identifier) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.SEND_OTP_LOGIN}',
        data: {'identifier': identifier},
      );

      // Backend returns { success: true/false, message: '...' } format
      final data = response.data;
      final isSuccess = data['success'] == true || data['status'] == 1;

      return ApiResponse(
        status: isSuccess ? 1 : 0,
        message: data['message'] ?? (isSuccess ? 'OTP sent successfully' : 'Failed to send OTP'),
        data: data as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Verify OTP and login (returns JWT token) - Supports phone or email
  Future<ApiResponse<StudentModel>> verifyOtp(String identifier, String otp) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.VERIFY_LOGIN_OTP}',
        data: {'identifier': identifier, 'otp': otp},  // Changed from 'phone' to 'identifier'
      );
      
      // NestJS response format: { status: 1, message: '...', data: { token: '...', user: {...} } }
      if (response.data['status'] == 1 && response.data['data'] != null) {
        final userData = response.data['data']['user'] as Map<String, dynamic>;
        final token = response.data['data']['token'] as String;
        
        // Store JWT token
        await _storeJwtToken(token);
        
        return ApiResponse(
          status: 1,
          message: response.data['message'] ?? 'Login successful',
          data: StudentModel.fromJson(userData),
        );
      } else {
        return ApiResponse(status: 0, message: response.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Login with password (returns JWT token) - Supports phone or email
  Future<ApiResponse<StudentModel>> loginWithPassword(String identifier, String password) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.LOGIN_PASSWORD}',
        data: {'identifier': identifier, 'password': password},  // Changed from 'phone' to 'identifier'
      );
      
      // NestJS response format: { status: 1, message: '...', data: { token: '...', user: {...} } }
      if (response.data['status'] == 1 && response.data['data'] != null) {
        final userData = response.data['data']['user'] as Map<String, dynamic>;
        final token = response.data['data']['token'] as String;
        
        // Store JWT token
        await _storeJwtToken(token);
        
        return ApiResponse(
          status: 1,
          message: response.data['message'] ?? 'Login successful',
          data: StudentModel.fromJson(userData),
        );
      } else {
        return ApiResponse(status: 0, message: response.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Register new student
  Future<ApiResponse<Map<String, dynamic>>> registerStudent(dynamic data) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.REGISTER}',
        data: data,
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Send OTP for registration verification (email or phone)
  Future<ApiResponse<Map<String, dynamic>>> sendRegistrationOtp(String identifier) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.SEND_REGISTRATION_OTP}',
        data: {'identifier': identifier},
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Verify OTP for registration
  Future<ApiResponse<Map<String, dynamic>>> verifyRegistrationOtp(String identifier, String otp) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.VERIFY_REGISTRATION_OTP}',
        data: {'identifier': identifier, 'otp': otp},
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Store JWT token in SharedPreferences
  Future<void> _storeJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constant.JWT_TOKEN, token);
  }
  
  /// Get stored JWT token
  Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constant.JWT_TOKEN);
  }

  /// Forgot password (send reset code) - Supports phone or email
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String identifier) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.FORGOT_PASSWORD}',
        data: {'identifier': identifier},  // Changed from 'phone' to 'identifier'
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Reset password with OTP (30-minute expiry)
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.RESET_PASSWORD}',
        data: {
          'identifier': identifier,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }


  // ==================== LEGACY APIs REMOVED ====================
  // All legacy API methods have been removed.
  // The app now exclusively uses the NestJS backend at localhost:3000
  // For profile updates, image uploads, etc., use the new profile endpoints below.

  // ==================== STUB METHODS FOR PHASE 2 FEATURES ====================
  // These features (admit cards, marksheets) are not yet implemented in new backend

  Future<ApiResponse<Map<String, dynamic>>> getAdmitCardStatus(String rollCode) async {
    return ApiResponse(status: 0, message: 'Admit card feature not yet available');
  }

  Future<ApiResponse<Map<String, dynamic>>> getAdmitCard(String rollCode) async {
    return ApiResponse(status: 0, message: 'Admit card feature not yet available');
  }

  Future<ApiResponse<Map<String, dynamic>>> getMarksheet(String rollCode) async {
    return ApiResponse(status: 0, message: 'Marksheet feature not yet available');
  }

  Future<ApiResponse<String>> downloadMarksheetPdf(String rollCode) async {
    return ApiResponse(status: 0, message: 'Marksheet download not yet available');
  }

  Future<ApiResponse<void>> updatePersonalDetails(Map<String, dynamic> data) async {
    return ApiResponse(status: 0, message: 'Use updateProfile() method instead');
  }

  Future<ApiResponse<void>> updateAddressDetails(Map<String, dynamic> data) async {
    return ApiResponse(status: 0, message: 'Use updateProfile() method instead');
  }

  Future<ApiResponse<void>> uploadStudentImage({
    required String phone,
    required String imageBase64,
    required String imageType,
  }) async {
    return ApiResponse(status: 0, message: 'Use profile/image endpoints instead');
  }

  Future<ApiResponse<void>> setPassword(String phone, String password) async {
    return ApiResponse(status: 0, message: 'Use resetPassword() method instead');
  }

  // ==================== NEW SRS FEATURES ====================

  /// Update profile (with JWT authentication)
  Future<ApiResponse<StudentModel>> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        return ApiResponse(status: 0, message: 'Not authenticated');
      }

      final response = await _dio.put(
        '${Constant.BASE_URL}/profile',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['status'] == 1 && response.data['data'] != null) {
        return ApiResponse(
          status: 1,
          message: response.data['message'] ?? 'Profile updated',
          data: StudentModel.fromJson(response.data['data']),
        );
      }
      return ApiResponse(status: 0, message: response.data['message'] ?? 'Update failed');
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Upgrade class (SRS requirement)
  Future<ApiResponse<StudentModel>> upgradeClass({
    required String newClass,
    String? newStream,
    String? newRollNumber,
    String? newRollCode,
    String? newRegistrationNumber,
    String? newSchoolName,
  }) async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        return ApiResponse(status: 0, message: 'Not authenticated');
      }

      final response = await _dio.post(
        '${Constant.BASE_URL}/profile/upgrade-class',
        data: {
          'newClass': newClass,
          if (newStream != null) 'newStream': newStream,
          if (newRollNumber != null) 'newRollNumber': newRollNumber,
          if (newRollCode != null) 'newRollCode': newRollCode,
          if (newRegistrationNumber != null) 'newRegistrationNumber': newRegistrationNumber,
          if (newSchoolName != null) 'newSchoolName': newSchoolName,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['status'] == 1 && response.data['data'] != null) {
        return ApiResponse(
          status: 1,
          message: response.data['message'] ?? 'Class upgraded successfully',
          data: StudentModel.fromJson(response.data['data']),
        );
      }
      return ApiResponse(status: 0, message: response.data['message'] ?? 'Upgrade failed');
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Delete account (SRS requirement)
  Future<ApiResponse<void>> deleteAccount() async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        return ApiResponse(status: 0, message: 'Not authenticated');
      }

      final response = await _dio.delete(
        '${Constant.BASE_URL}/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return ApiResponse(
        status: response.data['status'] ?? 1,
        message: response.data['message'] ?? 'Account deleted successfully',
      );
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Get profile (with JWT authentication)
  Future<ApiResponse<StudentModel>> getProfile() async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        return ApiResponse(status: 0, message: 'Not authenticated');
      }

      final response = await _dio.get(
        '${Constant.BASE_URL}/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['status'] == 1 && response.data['data'] != null) {
        return ApiResponse(
          status: 1,
          message: response.data['message'] ?? 'Profile retrieved successfully',
          data: StudentModel.fromJson(response.data['data']),
        );
      }
      return ApiResponse(status: 0, message: response.data['message'] ?? 'Failed to get profile');
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Get notifications (Stub for now)
  Future<ApiResponse<List<dynamic>>> getNotifications(String phone) async {
    // TODO: Implement notification endpoint in backend
    return ApiResponse(
      status: 1,
      message: 'No notifications',
      data: [],
    );
  }

  /// Upload profile image (photo or signature)
  /// Uses multipart/form-data to upload file to POST /profile/image/:type
  Future<ApiResponse<StudentModel>> uploadProfileImage({
    required String filePath,
    required String type, // 'photo' or 'signature'
  }) async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        return ApiResponse(status: 0, message: 'Not authenticated');
      }

      // Create FormData for file upload
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: '${type}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        '${Constant.BASE_URL}profile/image/$type',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.data['status'] == 1) {
        // Backend may return data with updated user, or just success message
        if (response.data['data'] != null) {
          return ApiResponse(
            status: 1,
            message: response.data['message'] ?? 'Image uploaded successfully',
            data: StudentModel.fromJson(response.data['data']),
          );
        }
        // Success without data - upload worked
        return ApiResponse(
          status: 1,
          message: response.data['message'] ?? 'Image uploaded successfully',
        );
      }
      return ApiResponse(status: 0, message: response.data['message'] ?? 'Upload failed');
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== BSEB VERIFICATION (Path A Registration) ====================

  /// Verify BSEB credentials (returns student data from BSEB database)
  Future<ApiResponse<Map<String, dynamic>>> verifyBsebCredentials({
    required String rollNumber,
    required String dob,
    String? rollCode,
    String? schoolCode,
    String? udiseCode,
  }) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.VERIFY_BSEB_CREDENTIALS}',
        data: {
          'rollNumber': rollNumber,
          'dob': dob,
          if (rollCode != null) 'rollCode': rollCode,
          if (schoolCode != null) 'schoolCode': schoolCode,
          if (udiseCode != null) 'udiseCode': udiseCode,
        },
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Register with BSEB credentials (auto-fetches student data)
  Future<ApiResponse<Map<String, dynamic>>> registerWithBsebLink({
    required String rollNumber,
    required String dob,
    required String phone,
    required String email,
    required String password,
    String? rollCode,
    String? schoolCode,
    String? udiseCode,
  }) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.REGISTER_BSEB_LINKED}',
        data: {
          'rollNumber': rollNumber,
          'dob': dob,
          'phone': phone,
          'email': email,
          'password': password,
          if (rollCode != null) 'rollCode': rollCode,
          if (schoolCode != null) 'schoolCode': schoolCode,
          if (udiseCode != null) 'udiseCode': udiseCode,
        },
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== PASSWORD MANAGEMENT ====================

  /// Change password (for logged-in users)
  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        return ApiResponse(status: 0, message: 'Not authenticated');
      }

      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.CHANGE_PASSWORD}',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Get all active sessions
  Future<ApiResponse<List<Map<String, dynamic>>>> getActiveSessions() async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        return ApiResponse(status: 0, message: 'Not authenticated');
      }

      final response = await _dio.get(
        '${Constant.BASE_URL}${Constant.GET_SESSIONS}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['status'] == 1 && response.data['data'] != null) {
        return ApiResponse(
          status: 1,
          message: response.data['message'] ?? 'Sessions retrieved successfully',
          data: (response.data['data'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList(),
        );
      }
      return ApiResponse(status: 0, message: response.data['message'] ?? 'Failed to get sessions');
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Revoke a specific session
  Future<ApiResponse<Map<String, dynamic>>> revokeSession(String sessionId) async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        return ApiResponse(status: 0, message: 'Not authenticated');
      }

      final response = await _dio.delete(
        '${Constant.BASE_URL}${Constant.REVOKE_SESSION}/$sessionId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Logout from other devices (keep current session)
  Future<ApiResponse<Map<String, dynamic>>> logoutOtherDevices() async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        return ApiResponse(status: 0, message: 'Not authenticated');
      }

      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.REVOKE_OTHER_SESSIONS}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Logout from all devices (including current)
  Future<ApiResponse<Map<String, dynamic>>> logoutAllDevices() async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        return ApiResponse(status: 0, message: 'Not authenticated');
      }

      final response = await _dio.post(
        '${Constant.BASE_URL}${Constant.REVOKE_ALL_SESSIONS}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }
}

/// Extension for easy access
extension ApiServiceExtension on ApiService {
  /// Check if response is successful
  bool isSuccess(ApiResponse response) => response.isSuccess;
}
