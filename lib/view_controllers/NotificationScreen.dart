import 'package:bseb/utilities/Constant.dart';
import 'package:bseb/utilities/SharedPreferencesHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:bseb/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../utilities/CustomColors.dart';
import '../utilities/Utils.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AuthController _authController = Get.put(AuthController());
  List<Map<String, dynamic>> notifications = [];

  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    initiate();

  }
  void initiate() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getNotification("1");
      await _getNotification("2");

    });

  }

  Future<void> _getNotification(String studentId) async {
    // Note: studentId parameter is kept for signature compatibility but ignored
    // as we fetch notifications for the logged-in user via AuthController
    
    Utils.progressbar(context, CustomColors.theme_orange);
    
    final fetchedNotifications = await _authController.getNotifications();
    
    Navigator.pop(context);

    if (fetchedNotifications.isNotEmpty) {
      setState(() {
        notifications.clear(); // Clear old list to avoid duplicates if called multiple times
        
        for (var item in fetchedNotifications) {
          notifications.add({
            'date': _formatDate(item['InsertDate']),
            'title': item['NTitle'] ?? '',
            'description': item['NDescription'] ?? '',
            'attachments': ([
              item['Attachment_1'],
              item['Attachment_2'],
              item['Attachment_3'],
              item['Attachment_4'],
              item['Attachment_5'],
            ]..removeWhere((url) => url == null || url.isEmpty))
                .cast<String>(),
          });
        }
      });
    } else {
      // Optional: Show empty state or snackbar
      // Utils.snackBarInfo(context, "No notifications found");
    }
  }

  String _formatDate(String? serverDate) {
    if (serverDate == null || serverDate.isEmpty) return "";
    try {
      final dateTime = DateTime.parse(serverDate).toLocal();
      return DateFormat("dd MMM yyyy, hh:mm a").format(dateTime);
    } catch (e) {
      return serverDate; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(CustomColors.theme_orange),
        title:
        const Text("Notification", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isExpanded = expandedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                expandedIndex = isExpanded ? null : index;
              });
            },
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: _CollapsedCard(title: notification['title']),
              secondChild: NotificationCard(
                title: notification['title'],
                date: notification['date'],
                description: notification['description'],
                attachments: notification['attachments'] ?? [],
              ),
            ),
          );
        },
      ),
    );
  }


}

/// Collapsed view (only title)
class _CollapsedCard extends StatelessWidget {
  final String title;
  const _CollapsedCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.notifications, color: Color(CustomColors.theme_orange)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// Expanded full view
class NotificationCard extends StatelessWidget {
  final String date;
  final String title;
  final String description;
  final List<String> attachments;

  NotificationCard({
    required this.date,
    required this.title,
    required this.description,
    required this.attachments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.notifications,  color: Color(CustomColors.theme_orange)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            if (date.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],

            if (description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(description, style: const TextStyle(fontSize: 14)),
            ],

            if (attachments.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'Attachments:',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
              ...attachments.map(
                    (url) => GestureDetector(
                  onTap: () {
                    Utils.openUrl(url);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file,
                            color: Color(CustomColors.theme_orange)),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            url,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.blue),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
