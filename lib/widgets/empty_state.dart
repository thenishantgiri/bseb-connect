import 'package:flutter/material.dart';

/// Empty state widget for displaying "no data" messages
///
/// Used when lists or data sources are empty
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: 8),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Common empty states
class NoNotificationsState extends StatelessWidget {
  const NoNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.notifications_none,
      title: 'No Notifications',
      message: 'You\'re all caught up! No new notifications at the moment.',
    );
  }
}

class NoResultsState extends StatelessWidget {
  const NoResultsState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'Try adjusting your search or filters',
    );
  }
}

class NoDataState extends StatelessWidget {
  final String? message;

  const NoDataState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inbox,
      title: 'No Data Available',
      message: message ?? 'There\'s nothing here yet',
    );
  }
}
