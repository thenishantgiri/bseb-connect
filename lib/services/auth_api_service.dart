import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/student_model.dart';
import '../utilities/Constant.dart';
import '../utilities/dio_singleton.dart';
import '../utilities/error_handler.dart';

/// Service for all authentication-related API calls
/// Matches the backend NestJS auth module endpoints
class AuthApiService {
  static final AuthApiService _instance = AuthApiService._internal();
  factory AuthApiService() => _instance;
  AuthApiService._internal();

  Dio get _dio => DioSingleton.instance.dio;

  // ==================== OTP AUTHENTICATION ====================

  /// Send OTP for login
  /// Rate Limited: 5 requests per hour per user
  Future<ApiResponse<Map<String, dynamic>>> sendLoginOtp(String identifier) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}auth/login/otp',
        data: {'identifier': identifier},
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Verify OTP and login
  /// Returns JWT token and user data
  Future<ApiResponse<Map<String, dynamic>>> verifyLoginOtp(
    String identifier,
    String otp,
  ) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}auth/login/verify',
        data: {
          'identifier': identifier,
          'otp': otp,
        },
      );

      if (response.data['success'] == true) {
        // Save JWT token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constant.JWT_TOKEN, response.data['data']['token']);

        // Update Dio headers with token
        DioSingleton.instance.setAuthToken(response.data['data']['token']);
      }

      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== PASSWORD AUTHENTICATION ====================

  /// Login with password
  /// Account locked after 10 failed attempts
  Future<ApiResponse<Map<String, dynamic>>> loginWithPassword(
    String identifier,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}auth/login/password',
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        // Save JWT token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constant.JWT_TOKEN, response.data['data']['token']);

        // Update Dio headers with token
        DioSingleton.instance.setAuthToken(response.data['data']['token']);
      }

      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== REGISTRATION ====================

  /// Standard registration with manual data entry
  Future<ApiResponse<StudentModel>> register({
    required String phone,
    required String fullName,
    required String className,
    required String gender,
    required String dob,
    required String password,
    String? email,
    String? fatherName,
    String? motherName,
    String? schoolName,
    String? rollCode,
    String? rollNumber,
    String? registrationNumber,
    String? address,
    String? district,
    String? state,
    String? pincode,
    String? udiseCode,
    String? stream,
    String? aadhaarNumber,
    String? caste,
    String? religion,
    String? maritalStatus,
    String? area,
    String? differentlyAbled,
    File? photoFile,
    File? signatureFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'phone': phone,
        'fullName': fullName,
        'class': className,
        'gender': gender,
        'dob': dob,
        'password': password,
        if (email != null) 'email': email,
        if (fatherName != null) 'fatherName': fatherName,
        if (motherName != null) 'motherName': motherName,
        if (schoolName != null) 'schoolName': schoolName,
        if (rollCode != null) 'rollCode': rollCode,
        if (rollNumber != null) 'rollNumber': rollNumber,
        if (registrationNumber != null) 'registrationNumber': registrationNumber,
        if (address != null) 'address': address,
        if (district != null) 'district': district,
        if (state != null) 'state': state,
        if (pincode != null) 'pincode': pincode,
        if (udiseCode != null) 'udiseCode': udiseCode,
        if (stream != null) 'stream': stream,
        if (aadhaarNumber != null) 'aadhaarNumber': aadhaarNumber,
        if (caste != null) 'caste': caste,
        if (religion != null) 'religion': religion,
        if (maritalStatus != null) 'maritalStatus': maritalStatus,
        if (area != null) 'area': area,
        if (differentlyAbled != null) 'differentlyAbled': differentlyAbled,
        if (photoFile != null)
          'photo': await MultipartFile.fromFile(
            photoFile.path,
            filename: 'photo.jpg',
          ),
        if (signatureFile != null)
          'signature': await MultipartFile.fromFile(
            signatureFile.path,
            filename: 'signature.jpg',
          ),
      });

      final response = await _dio.post(
        '${Constant.BASE_URL}auth/register',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return ApiResponse.fromJson(response.data, (json) => StudentModel.fromJson(json));
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== BSEB-LINKED REGISTRATION ====================

  /// Verify BSEB credentials and get pre-filled data
  Future<ApiResponse<Map<String, dynamic>>> verifyBsebCredentials({
    required String rollNumber,
    required String dob,
    String? rollCode,
    String? schoolCode,
    String? udiseCode,
  }) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}auth/verify-bseb-credentials',
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

  /// Register with BSEB auto-filled data
  Future<ApiResponse<StudentModel>> registerWithBseb({
    required String rollNumber,
    required String dob,
    required String phone,
    required String password,
    String? rollCode,
    String? schoolCode,
    String? udiseCode,
    String? email,
    File? photoFile,
    File? signatureFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'rollNumber': rollNumber,
        'dob': dob,
        'phone': phone,
        'password': password,
        if (rollCode != null) 'rollCode': rollCode,
        if (schoolCode != null) 'schoolCode': schoolCode,
        if (udiseCode != null) 'udiseCode': udiseCode,
        if (email != null) 'email': email,
        if (photoFile != null)
          'photo': await MultipartFile.fromFile(
            photoFile.path,
            filename: 'photo.jpg',
          ),
        if (signatureFile != null)
          'signature': await MultipartFile.fromFile(
            signatureFile.path,
            filename: 'signature.jpg',
          ),
      });

      final response = await _dio.post(
        '${Constant.BASE_URL}auth/register/bseb-linked',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return ApiResponse.fromJson(response.data, (json) => StudentModel.fromJson(json));
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== PASSWORD RESET ====================

  /// Request password reset OTP
  /// Rate Limited: 5 requests per hour
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String identifier) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}auth/password/forgot',
        data: {'identifier': identifier},
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Reset password with OTP
  Future<ApiResponse<Map<String, dynamic>>> resetPassword(
    String identifier,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}auth/password/reset',
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

  // ==================== LOGOUT ====================

  /// Logout and clear local session
  Future<void> logout() async {
    try {
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constant.JWT_TOKEN);
      await prefs.setBool('isLoggedIn', false);

      // Clear auth token from Dio
      DioSingleton.instance.clearAuthToken();
    } catch (e) {
      // Handle error silently
    }
  }
}