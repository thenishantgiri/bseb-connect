import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';
import '../services/api_service.dart';

/// Authentication state controller
///
/// Manages user authentication state across the app
class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final ApiService _api = ApiService();

  // Observable state
  final Rx<StudentModel?> _currentUser = Rx<StudentModel?>(null);
  final RxBool _isLoggedIn = false.obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  StudentModel? get currentUser => _currentUser.value;
  bool get isLoggedIn => _isLoggedIn.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  String get phone => _currentUser.value?.phone ?? '';
  String get rollCode => _currentUser.value?.rollCode ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadUserFromPrefs();
  }

  /// Load user data from SharedPreferences on app start
  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn.value) {
      // Load basic user info from prefs
      _currentUser.value = StudentModel(
        phone: prefs.getString('Phone'),
        email: prefs.getString('Email'),
        rollNumber: prefs.getString('RollNumber'),
        rollCode: prefs.getString('RollCode'),
        fullName: prefs.getString('FullName'),
        className: prefs.getString('Class'),
        stream: prefs.getString('Stream'),
        photo: prefs.getString('Photo'),
      );
    }
  }

  /// Send OTP for login
  Future<bool> sendOtp(String phone) async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.sendOtpLogin(phone);

    _isLoading.value = false;

    if (response.isSuccess) {
      return true;
    } else {
      _error.value = response.message;
      return false;
    }
  }

  // REMOVED: Legacy registration check methods
  // Use the new NestJS registration flow: sendOtpLogin() → verifyOtp() → registerStudent()

  /// Send OTP for registration verification (email or phone)
  Future<bool> sendRegistrationOtp(String identifier) async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.sendRegistrationOtp(identifier);

    _isLoading.value = false;

    if (response.isSuccess) {
      return true;
    } else {
      _error.value = response.message;
      return false;
    }
  }

  /// Verify OTP for registration
  Future<bool> verifyRegistrationOtp(String identifier, String otp) async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.verifyRegistrationOtp(identifier, otp);

    _isLoading.value = false;

    if (response.isSuccess) {
      return true;
    } else {
      _error.value = response.message;
      return false;
    }
  }

  /// Verify OTP and complete login
  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.verifyOtp(phone, otp);

    if (response.isSuccess && response.data != null) {
      await _saveUserData(response.data!);
      
      // Fetch fresh profile data from backend
      await fetchUserProfile();
      
      _isLoading.value = false;
      return true;
    } else {
      _isLoading.value = false;
      _error.value = response.message;
      return false;
    }
  }

  /// Login with password
  Future<bool> loginWithPassword(String phone, String password) async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.loginWithPassword(phone, password);

    if (response.isSuccess && response.data != null) {
      await _saveUserData(response.data!);
      
      // Fetch fresh profile data from backend
      await fetchUserProfile();
      
      _isLoading.value = false;
      return true;
    } else {
      _isLoading.value = false;
      _error.value = response.message;
      return false;
    }
  }

  /// Register new student
  Future<bool> registerStudent(dynamic data) async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.registerStudent(data);

    _isLoading.value = false;

    if (response.isSuccess) {
      return true;
    } else {
      _error.value = response.message;
      return false;
    }
  }

  /// Save user data to state and SharedPreferences
  Future<void> _saveUserData(StudentModel user) async {
    _currentUser.value = user;
    _isLoggedIn.value = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    // Save all user fields EXCEPT sensitive data
    final json = user.toJson();
    // List of sensitive fields that should NEVER be stored
    const sensitiveFields = ['Password', 'OTP'];

    for (final entry in json.entries) {
      // Skip sensitive fields
      if (sensitiveFields.contains(entry.key)) {
        continue;
      }

      if (entry.value != null) {
        if (entry.value is String) {
          await prefs.setString(entry.key, entry.value);
        } else if (entry.value is int) {
          await prefs.setInt(entry.key, entry.value);
        } else if (entry.value is bool) {
          await prefs.setBool(entry.key, entry.value);
        }
      }
    }
  }

  /// Logout user
  Future<void> logout() async {
    _currentUser.value = null;
    _isLoggedIn.value = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Update current user data
  void updateUser(StudentModel user) {
    _currentUser.value = user;
  }

  /// Forgot password
  Future<bool> forgotPassword(String phone) async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.forgotPassword(phone);

    _isLoading.value = false;

    if (response.isSuccess) {
      if (response.data?['status'] == 0) {
         _error.value = response.message;
         return false;
      }
      // Store OTP if needed, or just return true to navigate
      // The legacy code used response.data['data']['OTP']
      return true;
    } else {
      _error.value = response.message;
      return false;
    }
  }

  /// Verify OTP for forget password (legacy method for backward compatibility)
  Future<bool> verifyOtpForgetPassword(String phone, String otp, String password) async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.resetPassword(
      identifier: phone,
      otp: otp,
      newPassword: password,
    );

    _isLoading.value = false;

    if (response.isSuccess) {
      return true;
    } else {
      _error.value = response.message;
      return false;
    }
  }

  /// Reset password with OTP (new NestJS endpoint)
  Future<bool> resetPassword(String identifier, String otp, String newPassword) async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.resetPassword(
      identifier: identifier,
      otp: otp,
      newPassword: newPassword,
    );

    _isLoading.value = false;

    if (response.isSuccess) {
      return true;
    } else {
      _error.value = response.message;
      return false;
    }
  }

  /// Get notifications (DISABLED - Phase 2 feature not migrated yet)
  Future<List<Map<String, dynamic>>> getNotifications() async {
    // TODO: Implement notifications in new NestJS backend
    return [];
  }

  /// Get FCM Token
  Future<void> getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', token);
      }
    } catch (e) {
      print('FCM token retrieval failed: $e');
    }
  }

  // ==================== PROFILE MANAGEMENT (SRS Features) ====================

  /// Get current user profile from backend
  Future<bool> fetchUserProfile() async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.getProfile();

    _isLoading.value = false;

    if (response.isSuccess && response.data != null) {
      await _saveUserData(response.data!);
      return true;
    } else {
      _error.value = response.message;
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.updateProfile(data);

    _isLoading.value = false;

    if (response.isSuccess && response.data != null) {
      await _saveUserData(response.data!);
      return true;
    } else {
      _error.value = response.message;
      return false;
    }
  }

  /// Upgrade class (SRS requirement)
  Future<bool> upgradeClass({
    required String newClass,
    String? newStream,
    String? newRollNumber,
    String? newRollCode,
    String? newRegistrationNumber,
    String? newSchoolName,
  }) async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.upgradeClass(
      newClass: newClass,
      newStream: newStream,
      newRollNumber: newRollNumber,
      newRollCode: newRollCode,
      newRegistrationNumber: newRegistrationNumber,
      newSchoolName: newSchoolName,
    );

    _isLoading.value = false;

    if (response.isSuccess && response.data != null) {
      await _saveUserData(response.data!);
      Get.snackbar(
        'Success',
        'Class upgraded successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } else {
      _error.value = response.message;
      Get.snackbar(
        'Error',
        _error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Delete account (SRS requirement)
  Future<bool> deleteAccount() async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.deleteAccount();

    _isLoading.value = false;

    if (response.isSuccess) {
      // Clear all user data
      await logout();
      Get.snackbar(
        'Account Deleted',
        'Your account has been permanently deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } else {
      _error.value = response.message;
      Get.snackbar(
        'Error',
        _error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error.value = '';
  }

  /// Upload profile image (photo or signature)
  Future<bool> uploadProfileImage({
    required String filePath,
    required String type, // 'photo' or 'signature'
  }) async {
    _isLoading.value = true;
    _error.value = '';

    final response = await _api.uploadProfileImage(
      filePath: filePath,
      type: type,
    );

    _isLoading.value = false;

    if (response.isSuccess) {
      // Save user data if returned (backend may or may not return updated user)
      if (response.data != null) {
        await _saveUserData(response.data!);
      }
      return true;
    } else {
      _error.value = response.message;
      return false;
    }
  }
}
