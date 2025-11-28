import 'package:dio/dio.dart';
import '../utilities/dio_singleton.dart';
import '../utilities/Constant.dart';
import '../utilities/error_handler.dart';
import '../models/api_response.dart';
import '../models/bseb_form_data_model.dart';
import '../models/bseb_admit_card_model.dart';

/// Service for BSEB external API endpoints
///
/// Fetches data from BSEB external APIs through our backend proxy:
/// - Student form/registration data
/// - Theory admit card
/// - Practical admit card
///
/// All endpoints require JWT authentication
class BsebApiService {
  static final BsebApiService _instance = BsebApiService._internal();
  factory BsebApiService() => _instance;
  BsebApiService._internal();

  Dio get _dio => DioSingleton.instance.dio;

  // ==================== Form Data API ====================

  /// Fetch student form/registration data from BSEB
  ///
  /// [registrationNumber] - Format: XXXXX-XXXXX-XX (e.g., 91341-00009-24)
  ///
  /// Returns student details including:
  /// - Personal info (name, parents, DOB, gender)
  /// - Academic info (school, registration number)
  /// - Contact info (mobile, email, address)
  /// - Subjects enrolled
  /// - Photo and signature URLs
  Future<ApiResponse<BsebFormDataModel>> getFormData(
      String registrationNumber) async {
    try {
      final response = await _dio.get(
        '${Constant.BASE_URL}${Constant.BSEB_FORM_DATA}/$registrationNumber',
      );

      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return ApiResponse(
          status: 1,
          message: 'Form data fetched successfully',
          data: BsebFormDataModel.fromJson(data['data'] as Map<String, dynamic>),
        );
      } else {
        return ApiResponse(
          status: 0,
          message: data['message'] ?? 'Failed to fetch form data',
        );
      }
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== Admit Card APIs ====================

  /// Fetch theory admit card from BSEB
  ///
  /// Either [registrationNumber] OR ([rollCode] + [rollNumber]) is required
  ///
  /// Returns admit card with:
  /// - Student details (name, roll number, exam center)
  /// - Subject-wise exam schedule (date, time, shift)
  Future<ApiResponse<BsebAdmitCardModel>> getTheoryAdmitCard({
    String? registrationNumber,
    String? rollCode,
    String? rollNumber,
  }) async {
    return _getAdmitCard(
      endpoint: Constant.BSEB_ADMIT_CARD_THEORY,
      registrationNumber: registrationNumber,
      rollCode: rollCode,
      rollNumber: rollNumber,
    );
  }

  /// Fetch practical admit card from BSEB
  ///
  /// Either [registrationNumber] OR ([rollCode] + [rollNumber]) is required
  ///
  /// Returns admit card with:
  /// - Student details (name, roll number, exam center)
  /// - Subject-wise practical exam schedule
  Future<ApiResponse<BsebAdmitCardModel>> getPracticalAdmitCard({
    String? registrationNumber,
    String? rollCode,
    String? rollNumber,
  }) async {
    return _getAdmitCard(
      endpoint: Constant.BSEB_ADMIT_CARD_PRACTICAL,
      registrationNumber: registrationNumber,
      rollCode: rollCode,
      rollNumber: rollNumber,
    );
  }

  /// Internal method to fetch admit card by type
  Future<ApiResponse<BsebAdmitCardModel>> _getAdmitCard({
    required String endpoint,
    String? registrationNumber,
    String? rollCode,
    String? rollNumber,
  }) async {
    try {
      // Validate input
      if (registrationNumber == null &&
          (rollCode == null || rollNumber == null)) {
        return ApiResponse(
          status: 0,
          message:
              'Either registration number or roll code + roll number is required',
        );
      }

      final response = await _dio.post(
        '${Constant.BASE_URL}$endpoint',
        data: {
          'registrationNumber': registrationNumber ?? '',
          'rollCode': rollCode ?? '',
          'rollNumber': rollNumber ?? '',
        },
      );

      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return ApiResponse(
          status: 1,
          message: 'Admit card fetched successfully',
          data:
              BsebAdmitCardModel.fromJson(data['data'] as Map<String, dynamic>),
        );
      } else {
        return ApiResponse(
          status: 0,
          message: data['message'] ?? 'Failed to fetch admit card',
        );
      }
    } catch (e) {
      return ApiResponse(status: 0, message: ErrorHandler.handleError(e));
    }
  }

  // ==================== Utility Methods ====================

  /// Check if form data response indicates student not found
  bool isStudentNotFound(ApiResponse response) {
    return response.status == 0 &&
        response.message.toLowerCase().contains('not found');
  }

  /// Check if response is from cache
  bool isCachedResponse(Map<String, dynamic> responseData) {
    return responseData['cached'] == true;
  }
}
