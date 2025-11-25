/// Notification model for BSEB app notifications
///
/// Represents push notifications and in-app alerts
class NotificationModel {
  final String? id;
  final String? title;
  final String? message;
  final String? type;
  final String? date;
  final String? time;
  final bool? isRead;
  final String? actionUrl;
  final String? imageUrl;

  NotificationModel({
    this.id,
    this.title,
    this.message,
    this.type,
    this.date,
    this.time,
    this.isRead,
    this.actionUrl,
    this.imageUrl,
  });

  /// Creates NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      title: json['title'] as String?,
      message: json['message'] as String?,
      type: json['type'] as String?,
      date: json['date'] as String?,
      time: json['time'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// Converts NotificationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'date': date,
      'time': time,
      'isRead': isRead,
      'actionUrl': actionUrl,
      'imageUrl': imageUrl,
    };
  }

  /// Creates a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? date,
    String? time,
    bool? isRead,
    String? actionUrl,
    String? imageUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(title: $title, read: $isRead)';
  }
}
