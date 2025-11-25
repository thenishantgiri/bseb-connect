import 'dart:io';

/// Validation helper class for form fields
/// Matches backend validation requirements
class Validators {
  // ==================== PHONE VALIDATION ====================

  /// Validate phone number (10 digits)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters
    String cleanedPhone = value.replaceAll(RegExp(r'\D'), '');

    if (cleanedPhone.length != 10) {
      return 'Phone number must be 10 digits';
    }

    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanedPhone)) {
      return 'Enter a valid Indian mobile number';
    }

    return null;
  }

  // ==================== EMAIL VALIDATION ====================

  /// Validate email format
  static String? validateEmail(String? value, {bool isRequired = false}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Email is required' : null;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // ==================== PASSWORD VALIDATION ====================

  /// Validate password strength
  /// Requirements:
  /// - Minimum 8 characters
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter
  /// - At least 1 number
  /// - At least 1 special character (@$!%*?&#)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (!RegExp(r'[@$!%*?&#]').hasMatch(value)) {
      return 'Password must contain at least one special character (@$!%*?&#)';
    }

    // Full pattern check
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$')
        .hasMatch(value)) {
      return 'Invalid password format';
    }

    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ==================== OTP VALIDATION ====================

  /// Validate OTP (6 digits)
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  // ==================== NAME VALIDATION ====================

  /// Validate name fields
  static String? validateName(String? value, String fieldName, {bool isRequired = true}) {
    if (value == null || value.isEmpty) {
      return isRequired ? '$fieldName is required' : null;
    }

    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    if (value.length > 50) {
      return '$fieldName must not exceed 50 characters';
    }

    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // ==================== DATE VALIDATION ====================

  /// Validate date of birth
  static String? validateDob(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required';
    }

    try {
      DateTime dob = DateTime.parse(value);
      DateTime now = DateTime.now();

      // Must be at least 10 years old
      if (now.difference(dob).inDays < 3650) {
        return 'Must be at least 10 years old';
      }

      // Cannot be more than 100 years old
      if (now.difference(dob).inDays > 36500) {
        return 'Invalid date of birth';
      }
    } catch (e) {
      return 'Invalid date format (YYYY-MM-DD)';
    }

    return null;
  }

  // ==================== AADHAAR VALIDATION ====================

  /// Validate Aadhaar number (12 digits)
  static String? validateAadhaar(String? value, {bool isRequired = false}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Aadhaar number is required' : null;
    }

    // Remove spaces and hyphens
    String cleanedAadhaar = value.replaceAll(RegExp(r'[\s-]'), '');

    if (cleanedAadhaar.length != 12) {
      return 'Aadhaar number must be 12 digits';
    }

    if (!RegExp(r'^\d{12}$').hasMatch(cleanedAadhaar)) {
      return 'Aadhaar number must contain only numbers';
    }

    // Basic Verhoeff algorithm check could be added here

    return null;
  }

  // ==================== PINCODE VALIDATION ====================

  /// Validate pincode (6 digits)
  static String? validatePincode(String? value, {bool isRequired = false}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Pincode is required' : null;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Pincode must be 6 digits';
    }

    return null;
  }

  // ==================== ROLL NUMBER VALIDATION ====================

  /// Validate roll number
  static String? validateRollNumber(String? value, {bool isRequired = false}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Roll number is required' : null;
    }

    if (value.length < 3) {
      return 'Roll number must be at least 3 characters';
    }

    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value.toUpperCase())) {
      return 'Roll number can only contain letters and numbers';
    }

    return null;
  }

  // ==================== CLASS VALIDATION ====================

  /// Validate class selection
  static String? validateClass(String? value) {
    if (value == null || value.isEmpty) {
      return 'Class is required';
    }

    List<String> validClasses = ['9', '10', '11', '12', '9th', '10th', '11th', '12th', 'other'];

    if (!validClasses.contains(value.toLowerCase().replaceAll('th', ''))) {
      return 'Please select a valid class';
    }

    return null;
  }

  // ==================== FILE VALIDATION ====================

  /// Validate photo file
  /// Requirements: 40-100 KB, JPG/PNG
  static String? validatePhotoFile(File? file, {bool isRequired = true}) {
    if (file == null) {
      return isRequired ? 'Photo is required' : null;
    }

    // Check file size
    int fileSizeInBytes = file.lengthSync();
    int fileSizeInKB = fileSizeInBytes ~/ 1024;

    if (fileSizeInKB < 40) {
      return 'Photo size must be at least 40 KB';
    }

    if (fileSizeInKB > 100) {
      return 'Photo size must not exceed 100 KB';
    }

    // Check file extension
    String extension = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png'].contains(extension)) {
      return 'Photo must be in JPG or PNG format';
    }

    return null;
  }

  /// Validate signature file
  /// Requirements: 20-60 KB, JPG/PNG
  static String? validateSignatureFile(File? file, {bool isRequired = true}) {
    if (file == null) {
      return isRequired ? 'Signature is required' : null;
    }

    // Check file size
    int fileSizeInBytes = file.lengthSync();
    int fileSizeInKB = fileSizeInBytes ~/ 1024;

    if (fileSizeInKB < 20) {
      return 'Signature size must be at least 20 KB';
    }

    if (fileSizeInKB > 60) {
      return 'Signature size must not exceed 60 KB';
    }

    // Check file extension
    String extension = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png'].contains(extension)) {
      return 'Signature must be in JPG or PNG format';
    }

    return null;
  }

  // ==================== GENERAL VALIDATION ====================

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate dropdown selection
  static String? validateDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty || value == 'Select') {
      return 'Please select $fieldName';
    }
    return null;
  }

  /// Validate address
  static String? validateAddress(String? value, {bool isRequired = false}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Address is required' : null;
    }

    if (value.length < 10) {
      return 'Address must be at least 10 characters';
    }

    if (value.length > 200) {
      return 'Address must not exceed 200 characters';
    }

    return null;
  }

  /// Clean phone number for API submission
  static String cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  /// Clean Aadhaar number for API submission
  static String cleanAadhaar(String aadhaar) {
    return aadhaar.replaceAll(RegExp(r'[\s-]'), '');
  }

  /// Format date for display
  static String formatDate(String date) {
    try {
      DateTime dt = DateTime.parse(date);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (e) {
      return date;
    }
  }

  /// Format date for API (YYYY-MM-DD)
  static String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}