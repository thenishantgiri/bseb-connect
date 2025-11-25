/// Student data model representing a BSEB student
///
/// This model contains all student information retrieved from the API
/// including personal details, contact info, and academic information
class StudentModel {
  final String? phone;
  final String? email;
  final String? rollNumber;
  final String? rollCode;
  final String? dob;
  final String? fullName;
  final String? gender;
  final String? fatherName;
  final String? motherName;
  final String? district;
  final String? state;
  final String? block;
  final String? fullAddress;
  final String? className;
  final String? aadharNumber;
  final String? schoolName;
  final String? udiseCode;
  final String? stream;
  final String? registrationNumber;
  final String? password;
  final String? photo;
  final String? signaturePhoto;
  final String? emailIsVerified;
  final String? phoneIsVerified;
  final String? otp;
  final String? username;
  final String? createdAt;
  final String? caste;
  final String? differentlyAbled;
  final String? religion;
  final String? area;
  final String? maritalStatus;

  StudentModel({
    this.phone,
    this.email,
    this.rollNumber,
    this.rollCode,
    this.dob,
    this.fullName,
    this.gender,
    this.fatherName,
    this.motherName,
    this.district,
    this.state,
    this.block,
    this.fullAddress,
    this.className,
    this.aadharNumber,
    this.schoolName,
    this.udiseCode,
    this.stream,
    this.registrationNumber,
    this.password,
    this.photo,
    this.signaturePhoto,
    this.emailIsVerified,
    this.phoneIsVerified,
    this.otp,
    this.username,
    this.createdAt,
    this.caste,
    this.differentlyAbled,
    this.religion,
    this.area,
    this.maritalStatus,
  });

  /// Creates a StudentModel from JSON map
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      phone: json['Phone'] as String?,
      email: json['Email'] as String?,
      rollNumber: json['RollNumber'] as String?,
      rollCode: json['RollCode'] as String?,
      dob: json['Dob'] as String?,
      fullName: json['FullName'] as String?,
      gender: json['Gender'] as String?,
      fatherName: json['FatherName'] as String?,
      motherName: json['MotherName'] as String?,
      district: json['Distic'] as String?, // Note: API uses 'Distic'
      state: json['State'] as String?,
      block: json['Block'] as String?,
      fullAddress: json['FullAddress'] as String?,
      className: json['Class'] as String?,
      aadharNumber: json['AddharNumber'] as String?, // Note: API typo
      schoolName: json['SchoolName'] as String?,
      udiseCode: json['UdiseCode'] as String?,
      stream: json['Stream'] as String?,
      registrationNumber: json['RegistrationNumber'] as String?,
      password: json['Password'] as String?,
      photo: json['Photo'] as String?,
      signaturePhoto: json['SignaturePhoto'] as String?,
      emailIsVerified: json['EmailIsVerified'] as String?,
      phoneIsVerified: json['PhoneIsVerified'] as String?,
      otp: json['OTP'] as String?,
      username: json['Username'] as String?,
      createdAt: json['CreatedAt'] as String?,
      caste: json['Caste'] as String?,
      differentlyAbled: json['DifferentlyAbled'] as String?,
      religion: json['Religion'] as String?,
      area: json['Area'] as String?,
      maritalStatus: json['MaritalStatus'] as String?,
    );
  }

  /// Converts StudentModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'Phone': phone,
      'Email': email,
      'RollNumber': rollNumber,
      'RollCode': rollCode,
      'Dob': dob,
      'FullName': fullName,
      'Gender': gender,
      'FatherName': fatherName,
      'MotherName': motherName,
      'Distic': district,
      'State': state,
      'Block': block,
      'FullAddress': fullAddress,
      'Class': className,
      'AddharNumber': aadharNumber,
      'SchoolName': schoolName,
      'UdiseCode': udiseCode,
      'Stream': stream,
      'RegistrationNumber': registrationNumber,
      'Password': password,
      'Photo': photo,
      'SignaturePhoto': signaturePhoto,
      'EmailIsVerified': emailIsVerified,
      'PhoneIsVerified': phoneIsVerified,
      'OTP': otp,
      'Username': username,
      'CreatedAt': createdAt,
      'Caste': caste,
      'DifferentlyAbled': differentlyAbled,
      'Religion': religion,
      'Area': area,
      'MaritalStatus': maritalStatus,
    };
  }

  /// Creates a copy of StudentModel with updated fields
  StudentModel copyWith({
    String? phone,
    String? email,
    String? rollNumber,
    String? rollCode,
    String? dob,
    String? fullName,
    String? gender,
    String? fatherName,
    String? motherName,
    String? district,
    String? state,
    String? block,
    String? fullAddress,
    String? className,
    String? aadharNumber,
    String? schoolName,
    String? udiseCode,
    String? stream,
    String? registrationNumber,
    String? password,
    String? photo,
    String? signaturePhoto,
    String? emailIsVerified,
    String? phoneIsVerified,
    String? otp,
    String? username,
    String? createdAt,
    String? caste,
    String? differentlyAbled,
    String? religion,
    String? area,
    String? maritalStatus,
  }) {
    return StudentModel(
      phone: phone ?? this.phone,
      email: email ?? this.email,
      rollNumber: rollNumber ?? this.rollNumber,
      rollCode: rollCode ?? this.rollCode,
      dob: dob ?? this.dob,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      district: district ?? this.district,
      state: state ?? this.state,
      block: block ?? this.block,
      fullAddress: fullAddress ?? this.fullAddress,
      className: className ?? this.className,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      schoolName: schoolName ?? this.schoolName,
      udiseCode: udiseCode ?? this.udiseCode,
      stream: stream ?? this.stream,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      password: password ?? this.password,
      photo: photo ?? this.photo,
      signaturePhoto: signaturePhoto ?? this.signaturePhoto,
      emailIsVerified: emailIsVerified ?? this.emailIsVerified,
      phoneIsVerified: phoneIsVerified ?? this.phoneIsVerified,
      otp: otp ?? this.otp,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      caste: caste ?? this.caste,
      differentlyAbled: differentlyAbled ?? this.differentlyAbled,
      religion: religion ?? this.religion,
      area: area ?? this.area,
      maritalStatus: maritalStatus ?? this.maritalStatus,
    );
  }

  @override
  String toString() {
    return 'StudentModel(name: $fullName, rollNo: $rollNumber, class: $className)';
  }
}
