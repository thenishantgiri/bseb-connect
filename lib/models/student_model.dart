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
  /// Supports both camelCase (NestJS) and PascalCase (legacy) keys
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      phone: (json['phone'] ?? json['Phone'])?.toString(),
      email: (json['email'] ?? json['Email'])?.toString(),
      rollNumber: (json['rollNumber'] ?? json['RollNumber'])?.toString(),
      rollCode: (json['rollCode'] ?? json['RollCode'])?.toString(),
      dob: (json['dob'] ?? json['Dob'])?.toString(),
      fullName: (json['fullName'] ?? json['FullName'])?.toString(),
      gender: (json['gender'] ?? json['Gender'])?.toString(),
      fatherName: (json['fatherName'] ?? json['FatherName'])?.toString(),
      motherName: (json['motherName'] ?? json['MotherName'])?.toString(),
      district: (json['district'] ?? json['Distic'])?.toString(),
      state: (json['state'] ?? json['State'])?.toString(),
      block: (json['block'] ?? json['Block'])?.toString(),
      fullAddress: (json['address'] ?? json['FullAddress'])?.toString(),
      className: (json['class'] ?? json['Class'])?.toString(),
      aadharNumber: (json['aadhaarNumber'] ?? json['AddharNumber'])?.toString(),
      schoolName: (json['schoolName'] ?? json['SchoolName'])?.toString(),
      udiseCode: (json['udiseCode'] ?? json['UdiseCode'])?.toString(),
      stream: (json['stream'] ?? json['Stream'])?.toString(),
      registrationNumber: (json['registrationNumber'] ?? json['RegistrationNumber'])?.toString(),
      password: (json['password'] ?? json['Password'])?.toString(),
      photo: (json['photoUrl'] ?? json['Photo'])?.toString(),
      signaturePhoto: (json['signatureUrl'] ?? json['SignaturePhoto'])?.toString(),
      emailIsVerified: (json['emailIsVerified'] ?? json['EmailIsVerified'])?.toString(),
      phoneIsVerified: (json['phoneIsVerified'] ?? json['PhoneIsVerified'])?.toString(),
      otp: (json['otp'] ?? json['OTP'])?.toString(),
      username: (json['username'] ?? json['Username'])?.toString(),
      createdAt: (json['createdAt'] ?? json['CreatedAt'])?.toString(),
      caste: (json['caste'] ?? json['Caste'])?.toString(),
      differentlyAbled: (json['differentlyAbled'] ?? json['DifferentlyAbled'])?.toString(),
      religion: (json['religion'] ?? json['Religion'])?.toString(),
      area: (json['area'] ?? json['Area'])?.toString(),
      maritalStatus: (json['maritalStatus'] ?? json['MaritalStatus'])?.toString(),
    );
  }

  /// Converts StudentModel to JSON map
  /// Uses camelCase keys to match NestJS API format
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'rollNumber': rollNumber,
      'rollCode': rollCode,
      'dob': dob,
      'fullName': fullName,
      'gender': gender,
      'fatherName': fatherName,
      'motherName': motherName,
      'district': district,
      'state': state,
      'block': block,
      'address': fullAddress,
      'class': className,
      'aadhaarNumber': aadharNumber,
      'schoolName': schoolName,
      'udiseCode': udiseCode,
      'stream': stream,
      'registrationNumber': registrationNumber,
      'password': password,
      'photoUrl': photo,
      'signatureUrl': signaturePhoto,
      'emailIsVerified': emailIsVerified,
      'phoneIsVerified': phoneIsVerified,
      'otp': otp,
      'username': username,
      'createdAt': createdAt,
      'caste': caste,
      'differentlyAbled': differentlyAbled,
      'religion': religion,
      'area': area,
      'maritalStatus': maritalStatus,
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
