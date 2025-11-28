/// Model for BSEB Admit Card Data (Theory & Practical)
///
/// Contains student and exam information from BSEB admit card API
class BsebAdmitCardModel {
  final AdmitCardStudentDetails? studentDetails;
  final List<AdmitCardSubjectDetails> subjectDetails;

  BsebAdmitCardModel({
    this.studentDetails,
    this.subjectDetails = const [],
  });

  factory BsebAdmitCardModel.fromJson(Map<String, dynamic> json) {
    return BsebAdmitCardModel(
      studentDetails: json['studentDetails'] != null
          ? AdmitCardStudentDetails.fromJson(
              json['studentDetails'] as Map<String, dynamic>)
          : null,
      subjectDetails: (json['subjectDetails'] as List<dynamic>?)
              ?.map((e) =>
                  AdmitCardSubjectDetails.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentDetails': studentDetails?.toJson(),
      'subjectDetails': subjectDetails.map((e) => e.toJson()).toList(),
    };
  }

  /// Get subjects grouped by type (Compulsory vs Elective)
  Map<String, List<AdmitCardSubjectDetails>> getSubjectsByGroup() {
    final groups = <String, List<AdmitCardSubjectDetails>>{};
    for (final subject in subjectDetails) {
      final group = subject.subjectGroup ?? 'Other';
      groups.putIfAbsent(group, () => []).add(subject);
    }
    return groups;
  }
}

/// Student details on admit card
class AdmitCardStudentDetails {
  final String? studentName;
  final String? fatherName;
  final String? motherName;
  final String? dateOfBirth;
  final String? gender;
  final String? registrationNumber;
  final String? rollCode;
  final String? rollNumber;
  final String? schoolName;
  final String? schoolCode;
  final String? casteCategory;
  final String? religion;
  final String? examType;
  final String? examCenterName;
  final String? examCenterCode;

  AdmitCardStudentDetails({
    this.studentName,
    this.fatherName,
    this.motherName,
    this.dateOfBirth,
    this.gender,
    this.registrationNumber,
    this.rollCode,
    this.rollNumber,
    this.schoolName,
    this.schoolCode,
    this.casteCategory,
    this.religion,
    this.examType,
    this.examCenterName,
    this.examCenterCode,
  });

  factory AdmitCardStudentDetails.fromJson(Map<String, dynamic> json) {
    return AdmitCardStudentDetails(
      studentName: json['studentName'] as String?,
      fatherName: json['fatherName'] as String?,
      motherName: json['motherName'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      rollCode: json['rollCode'] as String?,
      rollNumber: json['rollNumber'] as String?,
      schoolName: json['schoolName'] as String?,
      schoolCode: json['schoolCode'] as String?,
      casteCategory: json['casteCategory'] as String?,
      religion: json['religion'] as String?,
      examType: json['examType'] as String?,
      examCenterName: json['examCenterName'] as String?,
      examCenterCode: json['examCenterCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'fatherName': fatherName,
      'motherName': motherName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'registrationNumber': registrationNumber,
      'rollCode': rollCode,
      'rollNumber': rollNumber,
      'schoolName': schoolName,
      'schoolCode': schoolCode,
      'casteCategory': casteCategory,
      'religion': religion,
      'examType': examType,
      'examCenterName': examCenterName,
      'examCenterCode': examCenterCode,
    };
  }

  /// Get full roll number (rollCode + rollNumber)
  String get fullRollNumber {
    if (rollCode == null && rollNumber == null) return '';
    return '${rollCode ?? ''}-${rollNumber ?? ''}';
  }
}

/// Subject details on admit card (with exam schedule)
class AdmitCardSubjectDetails {
  final String? subjectName;
  final String? subjectCode;
  final String? subjectGroup; // Compulsory, Elective
  final String? examDate;
  final String? examTime;
  final String? examShift;

  AdmitCardSubjectDetails({
    this.subjectName,
    this.subjectCode,
    this.subjectGroup,
    this.examDate,
    this.examTime,
    this.examShift,
  });

  factory AdmitCardSubjectDetails.fromJson(Map<String, dynamic> json) {
    return AdmitCardSubjectDetails(
      subjectName: json['subjectName'] as String?,
      subjectCode: json['subjectCode'] as String?,
      subjectGroup: json['subjectGroup'] as String?,
      examDate: json['examDate'] as String?,
      examTime: json['examTime'] as String?,
      examShift: json['examShift'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'subjectGroup': subjectGroup,
      'examDate': examDate,
      'examTime': examTime,
      'examShift': examShift,
    };
  }

  /// Get formatted exam schedule
  String get formattedSchedule {
    final parts = [examDate, examTime, examShift]
        .where((p) => p != null && p.isNotEmpty);
    return parts.join(' | ');
  }
}
