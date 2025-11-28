import '../config/environment.dart';

/// Application constants including API endpoints and SharedPreferences keys
///
/// Contains all configuration constants used throughout the app for:
/// - API base URLs and endpoint paths
/// - SharedPreferences storage keys
/// - Application-wide configuration values
class Constant {
  // ==================== API ENDPOINTS ====================

  /// Base URL for NestJS backend - ALL features use this endpoint
  /// Now using environment configuration instead of hardcoded value
  static String get BASE_URL => Environment.baseUrl;

  // ==================== NestJS API ENDPOINTS ====================
  
  // Auth Endpoints
  static const String SEND_OTP_LOGIN = 'auth/send-otp';
  static const String VERIFY_LOGIN_OTP = 'auth/verify-otp';
  static const String LOGIN_PASSWORD = 'auth/login/password';
  static const String REGISTER = 'auth/register';
  static const String FORGOT_PASSWORD = 'auth/password/forgot';
  static const String RESET_PASSWORD = 'auth/password/reset';
  static const String SET_PASSWORD = 'auth/password/reset'; // Alias for ChangePasswordScreen
  static const String VERIFY_BSEB_CREDENTIALS = 'auth/verify-bseb-credentials';
  static const String REGISTER_BSEB_LINKED = 'auth/register/bseb-linked';
  static const String SEND_REGISTRATION_OTP = 'auth/register/send-otp';
  static const String VERIFY_REGISTRATION_OTP = 'auth/register/verify-otp';

  // Profile Endpoints (require JWT)
  static const String GET_PROFILE = 'profile';
  static const String UPDATE_PROFILE = 'profile';
  static const String UPLOAD_PHOTO = 'profile/image/photo';
  static const String UPLOAD_SIGNATURE = 'profile/image/signature';
  static const String CHANGE_PASSWORD = 'profile/change-password';
  static const String UPGRADE_CLASS = 'profile/upgrade-class';
  static const String DELETE_ACCOUNT = 'profile';

  // Session Management Endpoints (require JWT)
  static const String GET_SESSIONS = 'profile/sessions';
  static const String REVOKE_SESSION = 'profile/sessions';  // + /:sessionId
  static const String REVOKE_OTHER_SESSIONS = 'profile/sessions/revoke-others';
  static const String REVOKE_ALL_SESSIONS = 'profile/sessions/revoke-all';

  // BSEB External API Endpoints (require JWT)
  static const String BSEB_FORM_DATA = 'bseb/form-data';  // + /:registrationNumber
  static const String BSEB_ADMIT_CARD_THEORY = 'bseb/admit-card/theory';
  static const String BSEB_ADMIT_CARD_PRACTICAL = 'bseb/admit-card/practical';

  // ==================== LEGACY API ENDPOINTS (OLD BACKEND) ====================
  // These are kept for backward compatibility with screens not yet migrated

  static String get LEGACY_BASE_URL => Environment.legacyApiUrl;
  static const String VERIFY_OTP = 'VerifyOtp';
  static const String SEND_OTP = 'SendOtpLogin';
  static const String GET_NOTIFICATION_COUNT = 'GetNotificationCount';
  static const String ADMIT_CARD_NEW = 'AdmitCardNew';
  static const String INFRORMATION = 'UpdatePersonalDetails';
  static const String UPDATE_ADDRESS_FORM = 'UpdateAddressDetails';
  static const String UPDATE_STUDENT_IMAGE = 'UpdateStudentImage';
  static const String SHOW_MARKSHEET = 'marksheet';
  static const String DOWNLOAD_ADMIT_CARD_New = 'UploadAdmitCardPdfNew';
  static const String DOWNLOAD_MARKSHEET = 'downloadmarksheetpdf';
  static const String GET_NOTIFICATION = 'GetNotificationDetails';
  static const String ADMIT_CARD_STATUS = 'AdmitCardStatus';
  static const String REGISTRACTION = 'RegisterStudent';

  // ==================== SHAREDPREFERENCES KEYS ====================

  /// Key for storing JWT token
  static const String JWT_TOKEN = 'jwt_token';
  
  /// Key for storing username
  static const String USER_NAME = 'username';
  static const String USER_ID = 'userId';
  static const String EMAIL = 'email';
  static const String CLASS = 'class';

  static const String PHONE = 'phone';
  static const String ROLL_CODE = 'rollCode';
  static const String ROLL_NUMBER = 'rollNumber';
  static const String FCM_TOKEN = 'fcmToken';
  static const String IMAGE_URL = 'imageUrl';
  static const String FATHERS_NAME = 'father_name';
  static const String MOTHERS_NAME = 'mother_name';
  static const String DOB = 'dob';
  static const String GENDER = 'gender';
  static const String CATEGORY = 'category';
  static const String PRESERT_ADDRESS = 'present_address';
  static const String PIN_CODE = 'present_pinCode';
  static const String SCHOOL_NAME = 'school_name';
  static const String bseb_reg_no = 'bseb_reg_no';
}
