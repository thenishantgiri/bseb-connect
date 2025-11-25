# Data Models Documentation

This directory contains typed data models for the BSEB Connect app.

## Available Models

### 1. **StudentModel** (`student_model.dart`)
Represents a student with all their information.

**Usage:**
```dart
import 'package:bseb/models/student_model.dart';

// From API response
final student = StudentModel.fromJson(jsonData);

// Access properties with type safety
print(student.fullName); // String?
print(student.rollNumber); // String?

// Create modified copy
final updated = student.copyWith(email: 'new@email.com');

// Convert to JSON for API
final json = student.toJson();
```

### 2. **ApiResponse<T>** (`api_response.dart`)
Generic wrapper for all API responses.

**Usage:**
```dart
import 'package:bseb/models/api_response.dart';
import 'package:bseb/models/student_model.dart';

// Parse login response
final response = ApiResponse<StudentModel>.fromJson(
  apiJsonResponse,
  (data) => StudentModel.fromJson(data as Map<String, dynamic>),
);

if (response.isSuccess) {
  final student = response.data;
  print('Welcome ${student?.fullName}');
} else {
  print('Error: ${response.message}');
}
```

### 3. **NotificationModel** (`notification_model.dart`)
Represents app notifications and alerts.

**Usage:**
```dart
import 'package:bseb/models/notification_model.dart';

final notification = NotificationModel.fromJson(jsonData);
print(notification.title);

// Mark as read
final updated = notification.copyWith(isRead: true);
```

---

## Migration Guide

### Before (using Map):
```dart
Map<String, dynamic> student = jsonDecode(response);
String? name = student['FullName'] as String?; // Manual casting
String? roll = student['RollNumber'] as String?; // Risk of typos
```

### After (using Models):
```dart
final student = StudentModel.fromJson(jsonDecode(response));
String? name = student.fullName; // Type-safe, auto-complete
String? roll = student.rollNumber; // No typos possible
```

---

## Benefits

1. **Type Safety** - Compile-time errors instead of runtime crashes
2. **Auto-complete** - IDE suggests available fields
3. **Documentation** - Clear field names and types
4. **Refactoring** - Easy to find all usages
5. **Validation** - Can add validation in fromJson
6. **Testing** - Easier to mock and test

---

## How to Integrate

### Step 1: Import the model
```dart
import 'package:bseb/models/student_model.dart';
import 'package:bseb/models/api_response.dart';
```

### Step 2: Replace Map with Model
```dart
// Old way
final response = await dio.post(url, data: data);
final student = response.data['data'] as Map<String, dynamic>;
final name = student['FullName'];

// New way
final response = await dio.post(url, data: data);
final apiResponse = ApiResponse<StudentModel>.fromJson(
  response.data,
  (data) => StudentModel.fromJson(data),
);
final name = apiResponse.data?.fullName;
```

### Step 3: Update SharedPreferences storage
```dart
// Store as JSON string
await prefs.setString('student', jsonEncode(student.toJson()));

// Retrieve and parse
final json = jsonDecode(prefs.getString('student') ?? '{}');
final student = StudentModel.fromJson(json);
```

---

## Example: Updating LoginScreen

### Current Code (LoginScreen.dart):
```dart
// Around line 450-470
final response = await _dio.post(url, data: data);
if (response.data['status'] == 1) {
  final userData = response.data['data'];
  await sharedPreferencesHelper.setPref(Constant.USER_NAME, userData['FullName']);
  // ... more manual field access
}
```

### With Models:
```dart
import 'package:bseb/models/api_response.dart';
import 'package:bseb/models/student_model.dart';

final response = await _dio.post(url, data: data);
final apiResponse = ApiResponse<StudentModel>.fromJson(
  response.data,
  (data) => StudentModel.fromJson(data),
);

if (apiResponse.isSuccess && apiResponse.data != null) {
  final student = apiResponse.data!;
  await sharedPreferencesHelper.setPref(Constant.USER_NAME, student.fullName ?? '');
  await sharedPreferencesHelper.setPref(Constant.ROLL_NUMBER, student.rollNumber ?? '');
  // Type-safe access to all fields
}
```

---

## Creating New Models

Template for new models:

```dart
class YourModel {
  final String? field1;
  final int? field2;

  YourModel({this.field1, this.field2});

  factory YourModel.fromJson(Map<String, dynamic> json) {
    return YourModel(
      field1: json['field1'] as String?,
      field2: json['field2'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field1': field1,
      'field2': field2,
    };
  }

  YourModel copyWith({String? field1, int? field2}) {
    return YourModel(
      field1: field1 ?? this.field1,
      field2: field2 ?? this.field2,
    );
  }
}
```

---

## Future Models to Create

- [ ] `MarksheetModel` - For exam results
- [ ] `AdmitCardModel` - For admit card data
- [ ] `CertificateModel` - For certificates
- [ ] `FormDataModel` - For registration forms
- [ ] `SubjectModel` - For subject information
- [ ] `ExamScheduleModel` - For timetables

---

**Note:** Models are optional additions. Existing code will continue to work.
You can gradually migrate screens to use models for better code quality.
