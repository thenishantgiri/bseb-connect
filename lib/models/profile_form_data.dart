import 'dart:io';

/// Data model to encapsulate all profile form data
/// Replaces 25+ individual parameters being passed around
class ProfileFormData {
  // Basic Information
  String? className;
  String? fullName;
  String? gender;

  // Personal Details
  String? caste;
  String? differentlyAbled;
  String? differentlyAbledDetails;
  String? religion;
  String? area;
  String? maritalStatus;
  String? dob;
  String? fatherName;
  String? motherName;

  // Contact Information
  String? email;
  String? phone;
  String? fullAddress;

  // Location
  String? division;
  String? district;
  String? block;
  String? schoolName;

  // Academic Information
  String? rollCode;
  String? rollNumber;
  String? registrationNumber;
  String? aadhaarNumber;
  String? udiseCode;
  String? stream;

  // Authentication
  String? password;
  String? confirmPassword;

  // Documents
  File? photoFile;
  File? signatureFile;
  String? photoUrl;
  String? signatureUrl;

  ProfileFormData({
    this.className,
    this.fullName,
    this.gender,
    this.caste,
    this.differentlyAbled,
    this.differentlyAbledDetails,
    this.religion,
    this.area,
    this.maritalStatus,
    this.dob,
    this.fatherName,
    this.motherName,
    this.email,
    this.phone,
    this.fullAddress,
    this.division,
    this.district,
    this.block,
    this.schoolName,
    this.rollCode,
    this.rollNumber,
    this.registrationNumber,
    this.aadhaarNumber,
    this.udiseCode,
    this.stream,
    this.password,
    this.confirmPassword,
    this.photoFile,
    this.signatureFile,
    this.photoUrl,
    this.signatureUrl,
  });

  /// Convert to map for API submission
  Map<String, dynamic> toJson() {
    return {
      'Class': className,
      'FullName': fullName,
      'Gender': gender,
      'Caste': caste,
      'DifferentlyAbled': differentlyAbled,
      'DifferentlyAbledDetails': differentlyAbledDetails,
      'Religion': religion,
      'Area': area,
      'MaritalStatus': maritalStatus,
      'DOB': dob,
      'FatherName': fatherName,
      'MotherName': motherName,
      'Email': email,
      'Phone': phone,
      'FullAddress': fullAddress,
      'Division': division,
      'District': district,
      'Block': block,
      'SchoolName': schoolName,
      'RollCode': rollCode,
      'RollNumber': rollNumber,
      'RegistrationNumber': registrationNumber,
      'AddharNumber': aadhaarNumber,
      'UdiseCode': udiseCode,
      'Stream': stream,
      'Password': password,
      // Don't send confirmPassword to API
      // Files handled separately in multipart requests
    };
  }

  /// Create from existing user data
  factory ProfileFormData.fromJson(Map<String, dynamic> json) {
    return ProfileFormData(
      className: json['Class'],
      fullName: json['FullName'],
      gender: json['Gender'],
      caste: json['Caste'],
      differentlyAbled: json['DifferentlyAbled'],
      differentlyAbledDetails: json['DifferentlyAbledDetails'],
      religion: json['Religion'],
      area: json['Area'],
      maritalStatus: json['MaritalStatus'],
      dob: json['DOB'],
      fatherName: json['FatherName'],
      motherName: json['MotherName'],
      email: json['Email'],
      phone: json['Phone'],
      fullAddress: json['FullAddress'],
      division: json['Division'],
      district: json['District'],
      block: json['Block'],
      schoolName: json['SchoolName'],
      rollCode: json['RollCode'],
      rollNumber: json['RollNumber'],
      registrationNumber: json['RegistrationNumber'],
      aadhaarNumber: json['AddharNumber'],
      udiseCode: json['UdiseCode'],
      stream: json['Stream'],
      photoUrl: json['Photo'],
      signatureUrl: json['SignaturePhoto'],
    );
  }

  /// Validate form data
  String? validate() {
    // Required field validation
    if (fullName == null || fullName!.isEmpty) {
      return 'Name is required';
    }
    if (className == null || className!.isEmpty) {
      return 'Class is required';
    }
    if (gender == null || gender!.isEmpty) {
      return 'Gender is required';
    }
    if (email != null && email!.isNotEmpty) {
      // Basic email validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!)) {
        return 'Invalid email format';
      }
    }
    if (password != null && password!.isNotEmpty) {
      if (password!.length < 6) {
        return 'Password must be at least 6 characters';
      }
      if (confirmPassword != password) {
        return 'Passwords do not match';
      }
    }
    // Add more validation as needed
    return null; // No errors
  }

  /// Check if any data has been modified
  bool hasChanges(ProfileFormData original) {
    return className != original.className ||
        fullName != original.fullName ||
        gender != original.gender ||
        caste != original.caste ||
        differentlyAbled != original.differentlyAbled ||
        religion != original.religion ||
        area != original.area ||
        maritalStatus != original.maritalStatus ||
        dob != original.dob ||
        fatherName != original.fatherName ||
        motherName != original.motherName ||
        email != original.email ||
        fullAddress != original.fullAddress ||
        division != original.division ||
        district != original.district ||
        block != original.block ||
        schoolName != original.schoolName ||
        rollCode != original.rollCode ||
        rollNumber != original.rollNumber ||
        registrationNumber != original.registrationNumber ||
        aadhaarNumber != original.aadhaarNumber ||
        stream != original.stream ||
        photoFile != null ||
        signatureFile != null ||
        (password != null && password!.isNotEmpty);
  }
}