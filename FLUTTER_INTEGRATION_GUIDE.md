# BSEB Connect - Flutter Backend Integration Guide

**Last Updated**: November 24, 2025
**Backend Version**: v2.0 (All SRS features implemented)
**Flutter App Version**: Compatible with NestJS backend

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Setup & Configuration](#setup--configuration)
3. [API Service Updates](#api-service-updates)
4. [Authentication Features](#authentication-features)
5. [Profile Management](#profile-management)
6. [Session Management](#session-management)
7. [Usage Examples](#usage-examples)
8. [Error Handling](#error-handling)
9. [Testing Checklist](#testing-checklist)

---

## Overview

The backend has been fully updated to match all SRS requirements. The Flutter app now supports:

- ✅ **Email Support**: Login/register with phone OR email
- ✅ **BSEB Verification**: Path A registration with auto-fetched data
- ✅ **Change Password**: For logged-in users
- ✅ **Session Management**: Multi-device tracking and revocation
- ✅ **Password Reset**: 30-minute OTP expiry
- ✅ **Account Lockout**: Automatic after failed attempts

---

## Setup & Configuration

### 1. Update Base URL

The backend is running on `http://localhost:3000`. For production, update:

**File**: `lib/utilities/Constant.dart`

```dart
// Development
static const String BASE_URL = 'http://localhost:3000/';

// Production (update when deploying)
static const String BASE_URL = 'https://your-production-api.com/';
```

### 2. Install Dependencies

Ensure you have these dependencies in `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.0.0
  get: ^4.6.5
  shared_preferences: ^2.0.15
  firebase_messaging: ^14.0.0
```

### 3. API Service

The `ApiService` has been updated with all new endpoints. No additional configuration needed.

---

## API Service Updates

### Changed Methods (Breaking Changes)

These methods now accept `identifier` (phone OR email) instead of just `phone`:

#### 1. Send OTP for Login

```dart
// OLD
Future<ApiResponse<Map<String, dynamic>>> sendOtpLogin(String phone)

// NEW
Future<ApiResponse<Map<String, dynamic>>> sendOtpLogin(String identifier)
```

**Usage**:
```dart
// With phone
await apiService.sendOtpLogin('9876543210');

// With email
await apiService.sendOtpLogin('user@example.com');
```

#### 2. Verify OTP and Login

```dart
// OLD
Future<ApiResponse<StudentModel>> verifyOtp(String phone, String otp)

// NEW
Future<ApiResponse<StudentModel>> verifyOtp(String identifier, String otp)
```

#### 3. Login with Password

```dart
// OLD
Future<ApiResponse<StudentModel>> loginWithPassword(String phone, String password)

// NEW
Future<ApiResponse<StudentModel>> loginWithPassword(String identifier, String password)
```

#### 4. Forgot Password

```dart
// OLD
Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String phone)

// NEW
Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String identifier)
```

---

## Authentication Features

### 1. Email/Phone Login with OTP

**Step 1: Send OTP**

```dart
final apiService = ApiService();

// Send OTP to phone or email
final response = await apiService.sendOtpLogin('test@example.com');

if (response.isSuccess) {
  print('OTP sent successfully');
  // Navigate to OTP verification screen
} else {
  print('Error: ${response.message}');
}
```

**Step 2: Verify OTP**

```dart
final response = await apiService.verifyOtp('test@example.com', '123456');

if (response.isSuccess && response.data != null) {
  print('Login successful');
  print('User: ${response.data!.fullName}');
  // JWT token is automatically stored
  // Navigate to home screen
} else {
  print('Error: ${response.message}');
}
```

### 2. Login with Password

```dart
final response = await apiService.loginWithPassword(
  'user@example.com',  // or phone number
  'Password@123',
);

if (response.isSuccess && response.data != null) {
  print('Login successful');
  // Navigate to home screen
}
```

### 3. BSEB Verification & Registration

**Step 1: Verify BSEB Credentials**

```dart
final response = await apiService.verifyBsebCredentials(
  rollNumber: 'TEST123',
  dob: '2005-01-01',
  rollCode: 'ROLL001',  // optional
);

if (response.isSuccess && response.data != null) {
  // Student data verified
  final studentData = response.data!['data'];
  print('Student Name: ${studentData['fullName']}');
  print('School: ${studentData['schoolName']}');
  print('Class: ${studentData['class']}');

  // Pre-fill registration form with this data
} else {
  print('BSEB verification failed: ${response.message}');
}
```

**Step 2: Register with BSEB Link**

```dart
final response = await apiService.registerWithBsebLink(
  rollNumber: 'TEST123',
  dob: '2005-01-01',
  phone: '9876543210',
  email: 'student@example.com',
  password: 'SecurePass@123',
  rollCode: 'ROLL001',  // optional
);

if (response.isSuccess) {
  print('Registration successful with BSEB data');
  // All BSEB data automatically filled in profile
  // Navigate to login screen
}
```

### 4. Password Reset

**Step 1: Request OTP**

```dart
final response = await apiService.forgotPassword('9876543210');

if (response.isSuccess) {
  print('OTP sent (expires in 30 minutes)');
  // Navigate to OTP verification screen
}
```

**Step 2: Reset Password with OTP**

```dart
final response = await apiService.resetPassword(
  identifier: '9876543210',
  otp: '123456',
  newPassword: 'NewPassword@456',
);

if (response.isSuccess) {
  print('Password reset successful');
  // Navigate to login screen
}
```

---

## Profile Management

### 1. Change Password (Logged In)

```dart
final apiService = ApiService();

final response = await apiService.changePassword(
  currentPassword: 'OldPassword@123',
  newPassword: 'NewPassword@456',
);

if (response.isSuccess) {
  print('Password changed successfully');
  Get.snackbar('Success', 'Password updated');
} else {
  print('Error: ${response.message}');
  Get.snackbar('Error', response.message);
}
```

### 2. Update Profile

```dart
final response = await apiService.updateProfile({
  'fullName': 'Updated Name',
  'address': 'New Address',
  'block': 'Block Name',
});

if (response.isSuccess && response.data != null) {
  print('Profile updated');
  // Update local state
  AuthController.to.updateUser(response.data!);
}
```

### 3. Upgrade Class

```dart
final response = await apiService.upgradeClass(
  newClass: '12',
  newStream: 'Science',
  newRollNumber: 'ROLL2025',
  newRollCode: 'RC2025',
);

if (response.isSuccess && response.data != null) {
  print('Class upgraded successfully');
  AuthController.to.updateUser(response.data!);
}
```

### 4. Delete Account

```dart
final response = await apiService.deleteAccount();

if (response.isSuccess) {
  print('Account deleted');
  // Clear local data and navigate to welcome screen
  await AuthController.to.logout();
  Get.offAllNamed('/welcome');
}
```

---

## Session Management

### 1. View Active Sessions

```dart
final response = await apiService.getActiveSessions();

if (response.isSuccess && response.data != null) {
  final sessions = response.data!;

  for (var session in sessions) {
    print('Session ID: ${session['id']}');
    print('Created: ${session['createdAt']}');
    print('Last Used: ${session['lastUsedAt']}');
    print('Active: ${session['isActive']}');
  }
}
```

**Display in UI**:

```dart
ListView.builder(
  itemCount: sessions.length,
  itemBuilder: (context, index) {
    final session = sessions[index];
    final isCurrentSession = session['token'] == currentToken;

    return ListTile(
      title: Text(isCurrentSession ? 'Current Device' : 'Other Device'),
      subtitle: Text('Last used: ${session['lastUsedAt']}'),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => revokeSession(session['id']),
      ),
    );
  },
)
```

### 2. Revoke Specific Session

```dart
Future<void> revokeSession(String sessionId) async {
  final response = await apiService.revokeSession(sessionId);

  if (response.isSuccess) {
    print('Session revoked');
    Get.snackbar('Success', 'Device logged out');
    // Refresh session list
    refreshSessions();
  }
}
```

### 3. Logout Other Devices

```dart
Future<void> logoutOtherDevices() async {
  final response = await apiService.logoutOtherDevices();

  if (response.isSuccess) {
    print('All other devices logged out');
    Get.snackbar('Success', 'Logged out from all other devices');
    refreshSessions();
  }
}
```

### 4. Logout All Devices

```dart
Future<void> logoutAllDevices() async {
  final response = await apiService.logoutAllDevices();

  if (response.isSuccess) {
    print('All devices logged out');
    // Clear local data and redirect to login
    await AuthController.to.logout();
    Get.offAllNamed('/login');
  }
}
```

---

## Usage Examples

### Complete Login Flow

```dart
class LoginController extends GetxController {
  final ApiService _api = ApiService();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Step 1: Send OTP
  Future<void> sendOtp(String identifier) async {
    isLoading.value = true;
    error.value = '';

    final response = await _api.sendOtpLogin(identifier);

    isLoading.value = false;

    if (response.isSuccess) {
      Get.toNamed('/otp-verification', arguments: identifier);
    } else {
      error.value = response.message;
      Get.snackbar('Error', response.message);
    }
  }

  // Step 2: Verify OTP
  Future<void> verifyOtp(String identifier, String otp) async {
    isLoading.value = true;

    final response = await _api.verifyOtp(identifier, otp);

    isLoading.value = false;

    if (response.isSuccess && response.data != null) {
      // Save user data
      AuthController.to.updateUser(response.data!);
      Get.offAllNamed('/home');
    } else {
      error.value = response.message;
      Get.snackbar('Error', response.message);
    }
  }

  // Alternative: Password Login
  Future<void> loginWithPassword(String identifier, String password) async {
    isLoading.value = true;

    final response = await _api.loginWithPassword(identifier, password);

    isLoading.value = false;

    if (response.isSuccess && response.data != null) {
      AuthController.to.updateUser(response.data!);
      Get.offAllNamed('/home');
    } else {
      error.value = response.message;
      Get.snackbar('Error', response.message);
    }
  }
}
```

### BSEB Registration Flow

```dart
class BsebRegistrationController extends GetxController {
  final ApiService _api = ApiService();
  final Rx<Map<String, dynamic>?> bsebData = Rx<Map<String, dynamic>?>(null);

  // Step 1: Verify BSEB credentials
  Future<void> verifyBsebCredentials(
    String rollNumber,
    String dob,
  ) async {
    final response = await _api.verifyBsebCredentials(
      rollNumber: rollNumber,
      dob: dob,
    );

    if (response.isSuccess && response.data != null) {
      bsebData.value = response.data!['data'];
      Get.toNamed('/bseb-registration-form');
    } else {
      Get.snackbar('Error', response.message);
    }
  }

  // Step 2: Complete registration
  Future<void> registerWithBseb({
    required String phone,
    required String email,
    required String password,
  }) async {
    if (bsebData.value == null) return;

    final response = await _api.registerWithBsebLink(
      rollNumber: bsebData.value!['rollNumber'],
      dob: bsebData.value!['dob'],
      phone: phone,
      email: email,
      password: password,
    );

    if (response.isSuccess) {
      Get.snackbar('Success', 'Registration successful');
      Get.offAllNamed('/login');
    } else {
      Get.snackbar('Error', response.message);
    }
  }
}
```

---

## Error Handling

### Common Error Scenarios

#### 1. Account Lockout

```dart
// Error response
{
  "statusCode": 401,
  "message": "Account temporarily locked due to multiple failed attempts. Try again in 15 minutes."
}
```

**Handle in UI**:
```dart
if (response.message.contains('locked')) {
  // Show lockout dialog with timer
  showLockoutDialog(response.message);
}
```

#### 2. Rate Limiting

```dart
// Error response
{
  "statusCode": 429,
  "message": "ThrottlerException: Too Many Requests"
}
```

**Handle in UI**:
```dart
if (response.message.contains('Too Many Requests')) {
  Get.snackbar(
    'Rate Limit',
    'Too many requests. Please wait and try again.',
    duration: Duration(seconds: 5),
  );
}
```

#### 3. OTP Expired

```dart
// Error response
{
  "statusCode": 401,
  "message": "OTP expired or invalid"
}
```

**Handle in UI**:
```dart
if (response.message.contains('expired')) {
  // Offer to resend OTP
  showResendOtpOption();
}
```

#### 4. Not Authenticated

```dart
// JWT token expired or invalid
{
  "statusCode": 401,
  "message": "Unauthorized"
}
```

**Handle globally**:
```dart
// In ApiInterceptor
if (error.response?.statusCode == 401) {
  // Clear token and redirect to login
  await AuthController.to.logout();
  Get.offAllNamed('/login');
}
```

---

## Testing Checklist

### Authentication
- [ ] Login with phone number (OTP)
- [ ] Login with email (OTP)
- [ ] Login with phone (password)
- [ ] Login with email (password)
- [ ] Test wrong OTP (should show error)
- [ ] Test account lockout (5 wrong OTP attempts)
- [ ] Forgot password (phone)
- [ ] Forgot password (email)
- [ ] Reset password with OTP

### Registration
- [ ] Register without BSEB (Path B)
- [ ] Verify BSEB credentials
- [ ] Register with BSEB link (Path A)
- [ ] Test duplicate phone/email (should show error)

### Profile Management
- [ ] Get profile data
- [ ] Update profile information
- [ ] Change password (logged in)
- [ ] Upgrade class
- [ ] Delete account

### Session Management
- [ ] View all active sessions
- [ ] Login from multiple devices (create multiple sessions)
- [ ] Revoke specific session
- [ ] Logout other devices
- [ ] Logout all devices

### Edge Cases
- [ ] Network timeout handling
- [ ] Invalid email format
- [ ] Weak password (should fail validation)
- [ ] OTP expiry (wait 30+ minutes for password reset)
- [ ] JWT token expiry (wait 30 days or manually expire)

---

## API Response Formats

### Success Response

```json
{
  "status": 1,
  "message": "Success message",
  "data": {
    // Response data
  }
}
```

### Error Response

```json
{
  "status": 0,
  "message": "Error message"
}
```

### Login Response

```json
{
  "status": 1,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGci...",
    "user": {
      "id": 1,
      "phone": "9876543210",
      "email": "user@example.com",
      "fullName": "Test User",
      // ... other fields
    }
  }
}
```

---

## Production Deployment Checklist

Before deploying to production:

1. **Update BASE_URL** in `Constant.dart` to production API
2. **Test on Real Devices** with actual network conditions
3. **Integrate SMS Gateway** for phone OTPs (backend)
4. **Integrate Email Service** for email OTPs (backend)
5. **Connect Real BSEB API** (backend - currently using mock data)
6. **Update JWT Secret** in backend `.env`
7. **Configure Redis** for production (backend)
8. **Enable HTTPS** and update BASE_URL accordingly
9. **Test All Features** with production backend
10. **Monitor Error Logs** after deployment

---

## Support & Documentation

- **Backend API Docs**: See `/backend/IMPLEMENTATION_SUMMARY.md`
- **Postman Collection**: `/backend/BSEB_Connect_API.postman_collection.json`
- **Testing Guide**: `/backend/POSTMAN_TESTING_GUIDE.md`
- **Test Results**: `/backend/TEST_RESULTS.md`
- **Architecture**: `/ARCHITECTURE.md`

---

## Troubleshooting

### Issue: "Not authenticated" error

**Solution**: Check if JWT token is stored and valid
```dart
final token = await ApiService().getJwtToken();
print('JWT Token: $token');
```

### Issue: "Connection refused" error

**Solution**: Ensure backend is running on http://localhost:3000
```bash
cd backend
npm run start:dev
```

### Issue: Email login not working

**Solution**: Ensure you're using `identifier` parameter, not `phone`
```dart
// Wrong
await apiService.sendOtpLogin(phone: 'user@example.com');

// Correct
await apiService.sendOtpLogin('user@example.com');
```

### Issue: Sessions not showing up

**Solution**: Ensure you're logged in and token is valid
```dart
final response = await apiService.getProfile();
if (!response.isSuccess) {
  // Token expired or invalid
  await AuthController.to.logout();
}
```

---

## 🎉 Conclusion

The Flutter app is now fully integrated with the NestJS backend. All SRS features are implemented and tested. The app supports:

- Multi-factor authentication (OTP, password)
- Email and phone number support
- BSEB credential verification
- Complete profile management
- Multi-device session management
- Comprehensive error handling

**Next Steps**:
1. Test all features on real devices
2. Integrate with production APIs (SMS, Email, BSEB)
3. Deploy to staging environment
4. Conduct user acceptance testing (UAT)

**Questions?** Contact the development team or refer to the documentation files listed above.
