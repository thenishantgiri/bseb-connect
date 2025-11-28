/// Model for BSEB Form/Registration Data
///
/// Contains student registration information fetched from BSEB external API
class BsebFormDataModel {
  final int? schoolCode;
  final String? schoolName;
  final String? registrationNumber;
  final String? applicationNumber;
  final String? name;
  final String? fatherName;
  final String? motherName;
  final String? dateOfBirth;
  final String? gender;
  final String? caste;
  final String? category;
  final String? religion;
  final String? nationality;
  final String? area;
  final bool? isDifferentlyAbled;
  final bool? isVisuallyImpaired;
  final String? maritalStatus;
  final String? medium;
  final String? mobile;
  final String? email;
  final AddressData? address;
  final SubjectsData? subjects;
  final String? photoUrl;
  final String? signatureUrl;

  BsebFormDataModel({
    this.schoolCode,
    this.schoolName,
    this.registrationNumber,
    this.applicationNumber,
    this.name,
    this.fatherName,
    this.motherName,
    this.dateOfBirth,
    this.gender,
    this.caste,
    this.category,
    this.religion,
    this.nationality,
    this.area,
    this.isDifferentlyAbled,
    this.isVisuallyImpaired,
    this.maritalStatus,
    this.medium,
    this.mobile,
    this.email,
    this.address,
    this.subjects,
    this.photoUrl,
    this.signatureUrl,
  });

  factory BsebFormDataModel.fromJson(Map<String, dynamic> json) {
    return BsebFormDataModel(
      schoolCode: json['schoolCode'] as int?,
      schoolName: json['schoolName'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      applicationNumber: json['applicationNumber'] as String?,
      name: json['name'] as String?,
      fatherName: json['fatherName'] as String?,
      motherName: json['motherName'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      caste: json['caste'] as String?,
      category: json['category'] as String?,
      religion: json['religion'] as String?,
      nationality: json['nationality'] as String?,
      area: json['area'] as String?,
      isDifferentlyAbled: json['isDifferentlyAbled'] as bool?,
      isVisuallyImpaired: json['isVisuallyImpaired'] as bool?,
      maritalStatus: json['maritalStatus'] as String?,
      medium: json['medium'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      address: json['address'] != null
          ? AddressData.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      subjects: json['subjects'] != null
          ? SubjectsData.fromJson(json['subjects'] as Map<String, dynamic>)
          : null,
      photoUrl: json['photoUrl'] as String?,
      signatureUrl: json['signatureUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolCode': schoolCode,
      'schoolName': schoolName,
      'registrationNumber': registrationNumber,
      'applicationNumber': applicationNumber,
      'name': name,
      'fatherName': fatherName,
      'motherName': motherName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'caste': caste,
      'category': category,
      'religion': religion,
      'nationality': nationality,
      'area': area,
      'isDifferentlyAbled': isDifferentlyAbled,
      'isVisuallyImpaired': isVisuallyImpaired,
      'maritalStatus': maritalStatus,
      'medium': medium,
      'mobile': mobile,
      'email': email,
      'address': address?.toJson(),
      'subjects': subjects?.toJson(),
      'photoUrl': photoUrl,
      'signatureUrl': signatureUrl,
    };
  }

  /// Get list of all enrolled subjects (where isChecked is true or name is not null)
  List<SubjectDetail> getEnrolledSubjects() {
    if (subjects == null) return [];

    final allSubjects = [
      subjects!.mil,
      subjects!.sil,
      subjects!.optional,
      subjects!.vocational,
      subjects!.compulsory1,
      subjects!.compulsory2,
      subjects!.compulsory3,
      subjects!.compulsory4,
    ];

    return allSubjects
        .where((s) => s != null && s.name != null)
        .cast<SubjectDetail>()
        .toList();
  }

  /// Get full address as string
  String get fullAddress {
    if (address == null) return '';
    final parts = [
      address!.address,
      address!.city,
      address!.district,
      address!.state,
      address!.pincode,
    ].where((p) => p != null && p.isNotEmpty);
    return parts.join(', ');
  }
}

/// Address information
class AddressData {
  final String? city;
  final String? address;
  final String? pincode;
  final String? district;
  final String? state;

  AddressData({
    this.city,
    this.address,
    this.pincode,
    this.district,
    this.state,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      city: json['city'] as String?,
      address: json['address'] as String?,
      pincode: json['pincode'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'address': address,
      'pincode': pincode,
      'district': district,
      'state': state,
    };
  }
}

/// All subjects data
class SubjectsData {
  final SubjectDetail? mil;         // Mother language (Hindi)
  final SubjectDetail? sil;         // Second language (Sanskrit)
  final SubjectDetail? optional;    // Optional subject
  final SubjectDetail? vocational;  // Vocational subject
  final SubjectDetail? compulsory1; // Math
  final SubjectDetail? compulsory2; // Social Science
  final SubjectDetail? compulsory3; // Science
  final SubjectDetail? compulsory4; // English

  SubjectsData({
    this.mil,
    this.sil,
    this.optional,
    this.vocational,
    this.compulsory1,
    this.compulsory2,
    this.compulsory3,
    this.compulsory4,
  });

  factory SubjectsData.fromJson(Map<String, dynamic> json) {
    return SubjectsData(
      mil: json['mil'] != null
          ? SubjectDetail.fromJson(json['mil'] as Map<String, dynamic>)
          : null,
      sil: json['sil'] != null
          ? SubjectDetail.fromJson(json['sil'] as Map<String, dynamic>)
          : null,
      optional: json['optional'] != null
          ? SubjectDetail.fromJson(json['optional'] as Map<String, dynamic>)
          : null,
      vocational: json['vocational'] != null
          ? SubjectDetail.fromJson(json['vocational'] as Map<String, dynamic>)
          : null,
      compulsory1: json['compulsory1'] != null
          ? SubjectDetail.fromJson(json['compulsory1'] as Map<String, dynamic>)
          : null,
      compulsory2: json['compulsory2'] != null
          ? SubjectDetail.fromJson(json['compulsory2'] as Map<String, dynamic>)
          : null,
      compulsory3: json['compulsory3'] != null
          ? SubjectDetail.fromJson(json['compulsory3'] as Map<String, dynamic>)
          : null,
      compulsory4: json['compulsory4'] != null
          ? SubjectDetail.fromJson(json['compulsory4'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mil': mil?.toJson(),
      'sil': sil?.toJson(),
      'optional': optional?.toJson(),
      'vocational': vocational?.toJson(),
      'compulsory1': compulsory1?.toJson(),
      'compulsory2': compulsory2?.toJson(),
      'compulsory3': compulsory3?.toJson(),
      'compulsory4': compulsory4?.toJson(),
    };
  }
}

/// Individual subject details
class SubjectDetail {
  final String? name;
  final String? code;
  final bool isChecked;
  final bool readonly;

  SubjectDetail({
    this.name,
    this.code,
    this.isChecked = false,
    this.readonly = true,
  });

  factory SubjectDetail.fromJson(Map<String, dynamic> json) {
    return SubjectDetail(
      name: json['name'] as String?,
      code: json['code'] as String?,
      isChecked: json['isChecked'] as bool? ?? false,
      readonly: json['readonly'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'isChecked': isChecked,
      'readonly': readonly,
    };
  }
}
