import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/notification_model.dart';
import 'auth_controller.dart';

/// Notification state controller
///
/// Manages notifications across the app
class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  final ApiService _api = ApiService();

  // Observable state
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxInt _unreadCount = 0.obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasNotifications => _notifications.isNotEmpty;

  /// Fetch notifications from API
  Future<void> fetchNotifications() async {
    final phone = AuthController.to.phone;
    if (phone.isEmpty) return;

    _isLoading.value = true;
    _error.value = '';

    final response = await _api.getNotifications(phone);

    _isLoading.value = false;

    if (response.isSuccess && response.data != null) {
      _notifications.value = response.data!
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      _updateUnreadCount();
    } else {
      _error.value = response.message;
    }
  }

  /// Mark notification as read
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications[index] = notification.copyWith(isRead: true);
      _updateUnreadCount();
    }
  }

  /// Check if notification is read
  bool isNotificationRead(String id) {
    final notification = _notifications.firstWhereOrNull((n) => n.id == id);
    return notification?.isRead ?? false;
  }

  /// Mark all as read
  void markAllAsRead() {
    _notifications.value = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _unreadCount.value = 0;
  }

  /// Update unread count
  void _updateUnreadCount() {
    _unreadCount.value = _notifications.where((n) => n.isRead == false).length;
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    _unreadCount.value = 0;
  }

  /// Refresh notifications
  Future<void> refreshNotifications() => fetchNotifications();
}
