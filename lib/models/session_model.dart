/// Session model representing an active user session
class SessionModel {
  final String id;
  final int studentId;
  final String token;
  final String? deviceInfo;
  final String? ipAddress;
  final String? userAgent;
  final bool isActive;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? lastUsedAt;

  SessionModel({
    required this.id,
    required this.studentId,
    required this.token,
    this.deviceInfo,
    this.ipAddress,
    this.userAgent,
    required this.isActive,
    required this.createdAt,
    required this.expiresAt,
    this.lastUsedAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      studentId: json['studentId'],
      token: json['token'],
      deviceInfo: json['deviceInfo'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      lastUsedAt: json['lastUsedAt'] != null
        ? DateTime.parse(json['lastUsedAt'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'token': token,
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  /// Check if session is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get device display name
  String get deviceDisplayName {
    if (deviceInfo != null && deviceInfo!.isNotEmpty) {
      return deviceInfo!;
    }
    if (userAgent != null && userAgent!.isNotEmpty) {
      // Extract browser/device info from user agent
      if (userAgent!.contains('Chrome')) return 'Chrome Browser';
      if (userAgent!.contains('Safari')) return 'Safari Browser';
      if (userAgent!.contains('Firefox')) return 'Firefox Browser';
      if (userAgent!.contains('Android')) return 'Android Device';
      if (userAgent!.contains('iPhone')) return 'iPhone';
      if (userAgent!.contains('iPad')) return 'iPad';
    }
    return 'Unknown Device';
  }

  /// Get location display (from IP)
  String get locationDisplay {
    return ipAddress ?? 'Unknown Location';
  }

  /// Get last active time display
  String get lastActiveDisplay {
    final lastActive = lastUsedAt ?? createdAt;
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  /// Check if this is the current session
  bool isCurrent(String currentToken) {
    return token == currentToken;
  }
}