import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utilities/Utils.dart';
import 'LoginScreen.dart';

/// Session Management Screen
///
/// View and manage active sessions across multiple devices.
/// Features:
/// - View all active sessions
/// - Revoke specific session
/// - Logout from other devices
/// - Logout from all devices
class SessionManagementScreen extends StatefulWidget {
  const SessionManagementScreen({Key? key}) : super(key: key);

  @override
  State<SessionManagementScreen> createState() => _SessionManagementScreenState();
}

class _SessionManagementScreenState extends State<SessionManagementScreen> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;
  String? _currentToken;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  /// Load active sessions
  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);

    // Get current token
    _currentToken = await _apiService.getJwtToken();

    final response = await _apiService.getActiveSessions();

    setState(() => _isLoading = false);

    if (response.isSuccess && response.data != null) {
      setState(() {
        _sessions = response.data!;
      });
    } else {
      Utils.snackBarError(context, response.message);
    }
  }

  /// Revoke specific session
  Future<void> _revokeSession(String sessionId, bool isCurrentSession) async {
    if (isCurrentSession) {
      final confirm = await _showConfirmDialog(
        'Logout from Current Device?',
        'This will log you out from this device. You will need to login again.',
      );
      if (confirm != true) return;
    }

    Utils.progressbar(context, const Color(0xFF970202));

    final response = await _apiService.revokeSession(sessionId);

    Navigator.pop(context); // Close progress dialog

    if (response.isSuccess) {
      Utils.snackBarSuccess(context, 'Session revoked successfully');

      if (isCurrentSession) {
        // Navigate to login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        // Refresh sessions list
        _loadSessions();
      }
    } else {
      Utils.snackBarError(context, response.message);
    }
  }

  /// Logout from other devices
  Future<void> _logoutOtherDevices() async {
    final confirm = await _showConfirmDialog(
      'Logout from Other Devices?',
      'This will log you out from all devices except this one.',
    );

    if (confirm != true) return;

    Utils.progressbar(context, const Color(0xFF970202));

    final response = await _apiService.logoutOtherDevices();

    Navigator.pop(context); // Close progress dialog

    if (response.isSuccess) {
      Utils.snackBarSuccess(context, 'Logged out from all other devices');
      _loadSessions();
    } else {
      Utils.snackBarError(context, response.message);
    }
  }

  /// Logout from all devices
  Future<void> _logoutAllDevices() async {
    final confirm = await _showConfirmDialog(
      'Logout from All Devices?',
      'This will log you out from ALL devices including this one. You will need to login again.',
    );

    if (confirm != true) return;

    Utils.progressbar(context, const Color(0xFF970202));

    final response = await _apiService.logoutAllDevices();

    Navigator.pop(context); // Close progress dialog

    if (response.isSuccess) {
      Utils.snackBarSuccess(context, 'Logged out from all devices');

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      Utils.snackBarError(context, response.message);
    }
  }

  /// Show confirmation dialog
  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF970202),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Format date
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  /// Check if session is current
  bool _isCurrentSession(String sessionToken) {
    return sessionToken == _currentToken;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Active Sessions'),
        backgroundColor: const Color(0xFF970202),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout_others') {
                _logoutOtherDevices();
              } else if (value == 'logout_all') {
                _logoutAllDevices();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout_others',
                child: Row(
                  children: [
                    Icon(Icons.devices_other, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Logout Other Devices'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout_all',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout All Devices'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSessions,
              child: _sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phonelink_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No active sessions',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        final isCurrentSession = _isCurrentSession(session['token'] ?? '');

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isCurrentSession
                                  ? const Color(0xFF970202)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCurrentSession
                                    ? const Color(0xFF970202).withOpacity(0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isCurrentSession ? Icons.smartphone : Icons.devices,
                                color: isCurrentSession
                                    ? const Color(0xFF970202)
                                    : Colors.grey,
                                size: 28,
                              ),
                            ),
                            title: Text(
                              isCurrentSession ? 'Current Device' : 'Other Device',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCurrentSession
                                    ? const Color(0xFF970202)
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Last active: ${_formatDate(session['lastUsedAt'] ?? session['createdAt'])}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Created: ${_formatDate(session['createdAt'])}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                if (session['ipAddress'] != null)
                                  Text(
                                    'IP: ${session['ipAddress']}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.logout, color: Colors.red),
                              tooltip: isCurrentSession
                                  ? 'Logout from this device'
                                  : 'Revoke this session',
                              onPressed: () => _revokeSession(
                                session['id'],
                                isCurrentSession,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
