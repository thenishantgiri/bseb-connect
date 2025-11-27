import 'dart:io';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/student_model.dart';
import '../models/session_model.dart';
import '../utilities/Constant.dart';
import '../utilities/dio_singleton.dart';
import '../utilities/error_handler.dart';

/// Service for all profile-related API calls
/// Matches the backend NestJS profile module endpoints
class ProfileApiService {
  static final ProfileApiService _instance = ProfileApiService._internal();
  factory ProfileApiService() => _instance;
  ProfileApiService._internal();

  Dio get _dio => DioSingleton.instance.dio;

  // ==================== PROFILE ACCESS ====================

  /// Get current user profile
  /// Requires JWT authentication
  Future<ApiResponse<StudentModel>> getProfile() async {
    try {
      final response = await _dio.get('${Constant.BASE_URL}profile');
      return ApiResponse.fromJson(response.data, (json) => StudentModel.fromJson(json));
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Update profile information
  /// Only specific fields can be updated
  Future<ApiResponse<StudentModel>> updateProfile({
    String? email,
    String? fullName,
    String? address,
    String? block,
    String? district,
    String? state,
    String? pincode,
    String? schoolName,
    String? fatherName,
    String? motherName,
    String? caste,
    String? religion,
    String? maritalStatus,
    String? area,
  }) async {
    try {
      Map<String, dynamic> data = {};
      if (email != null) data['email'] = email;
      if (fullName != null) data['fullName'] = fullName;
      if (address != null) data['address'] = address;
      if (block != null) data['block'] = block;
      if (district != null) data['district'] = district;
      if (state != null) data['state'] = state;
      if (pincode != null) data['pincode'] = pincode;
      if (schoolName != null) data['schoolName'] = schoolName;
      if (fatherName != null) data['fatherName'] = fatherName;
      if (motherName != null) data['motherName'] = motherName;
      if (caste != null) data['caste'] = caste;
      if (religion != null) data['religion'] = religion;
      if (maritalStatus != null) data['maritalStatus'] = maritalStatus;
      if (area != null) data['area'] = area;

      final response = await _dio.put(
        '${Constant.BASE_URL}profile',
        data: data,
      );
      return ApiResponse.fromJson(response.data, (json) => StudentModel.fromJson(json));
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== IMAGE MANAGEMENT ====================

  /// Upload photo or signature
  /// Type: 'photo' or 'signature'
  /// Photo: 40-100 KB, JPG/PNG
  /// Signature: 20-60 KB, JPG/PNG
  Future<ApiResponse<StudentModel>> uploadImage(String type, File imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: '$type.jpg',
        ),
      });

      final response = await _dio.post(
        '${Constant.BASE_URL}profile/image/$type',
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

  // ==================== ACADEMIC MANAGEMENT ====================

  /// Upgrade class/stream
  Future<ApiResponse<StudentModel>> upgradeClass({
    required String newClass,
    String? newStream,
    String? newRollNumber,
    String? newRollCode,
    String? newRegistrationNumber,
    String? newSchoolName,
    String? newUdiseCode,
  }) async {
    try {
      Map<String, dynamic> data = {
        'newClass': newClass,
      };
      if (newStream != null) data['newStream'] = newStream;
      if (newRollNumber != null) data['newRollNumber'] = newRollNumber;
      if (newRollCode != null) data['newRollCode'] = newRollCode;
      if (newRegistrationNumber != null) data['newRegistrationNumber'] = newRegistrationNumber;
      if (newSchoolName != null) data['newSchoolName'] = newSchoolName;
      if (newUdiseCode != null) data['newUdiseCode'] = newUdiseCode;

      final response = await _dio.post(
        '${Constant.BASE_URL}profile/upgrade-class',
        data: data,
      );

      return ApiResponse.fromJson(response.data, (json) => StudentModel.fromJson(json));
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== PASSWORD MANAGEMENT ====================

  /// Change password while logged in
  /// Requires current password verification
  Future<ApiResponse<Map<String, dynamic>>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}profile/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Get all active sessions
  Future<ApiResponse<List<SessionModel>>> getSessions() async {
    try {
      final response = await _dio.get('${Constant.BASE_URL}profile/sessions');

      if (response.data['success'] == true) {
        List<SessionModel> sessions = (response.data['data'] as List)
            .map((json) => SessionModel.fromJson(json))
            .toList();
        return ApiResponse(
          status: 1,
          message: response.data['message'],
          data: sessions,
        );
      }

      return ApiResponse(status: 0, message: response.data['message']);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Revoke specific session
  Future<ApiResponse<Map<String, dynamic>>> revokeSession(String sessionId) async {
    try {
      final response = await _dio.delete(
        '${Constant.BASE_URL}profile/sessions/$sessionId',
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Logout all other devices
  Future<ApiResponse<Map<String, dynamic>>> revokeOtherSessions() async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}profile/sessions/revoke-others',
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  /// Logout all devices
  Future<ApiResponse<Map<String, dynamic>>> revokeAllSessions() async {
    try {
      final response = await _dio.post(
        '${Constant.BASE_URL}profile/sessions/revoke-all',
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== ACCOUNT MANAGEMENT ====================

  /// Delete account permanently
  Future<ApiResponse<Map<String, dynamic>>> deleteAccount() async {
    try {
      final response = await _dio.delete('${Constant.BASE_URL}profile');
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }
}