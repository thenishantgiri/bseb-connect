/// Generic API response wrapper
///
/// All API responses from BSEB backend follow this structure:
/// {
///   "status": 1 or 0,
///   "message": "Success message",
///   "data": { ... actual data ... }
/// }
class ApiResponse<T> {
  final int status;
  final String message;
  final T? data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  /// Check if the API call was successful
  bool get isSuccess => status == 1;

  /// Check if the API call failed
  bool get isFailure => status == 0;

  /// Creates an ApiResponse from JSON
  ///
  /// [json] The JSON map from API
  /// [fromJsonT] Function to convert data field to type T
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }

  /// Converts ApiResponse to JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJsonT) {
    return {
      'status': status,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(status: $status, message: $message, hasData: ${data != null})';
  }
}

/// Example usage:
///
/// ```dart
/// // For login API response
/// final response = ApiResponse<StudentModel>.fromJson(
///   jsonResponse,
///   (data) => StudentModel.fromJson(data as Map<String, dynamic>),
/// );
///
/// if (response.isSuccess) {
///   final student = response.data;
///   print('Welcome ${student?.fullName}');
/// } else {
///   print('Error: ${response.message}');
/// }
/// ```
