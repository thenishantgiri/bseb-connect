import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utilities/Utils.dart';

/// Change Password Screen for Logged-in Users
///
/// Allows authenticated users to change their password.
/// Requires current password verification.
class ChangePasswordProfileScreen extends StatefulWidget {
  const ChangePasswordProfileScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordProfileScreen> createState() => _ChangePasswordProfileScreenState();
}

class _ChangePasswordProfileScreenState extends State<ChangePasswordProfileScreen> {
  final ApiService _apiService = ApiService();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validate password strength
  bool _isPasswordStrong(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special char
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$');
    return regex.hasMatch(password);
  }

  /// Change password
  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Utils.snackBarError(context, 'All fields are required');
      return;
    }

    if (!_isPasswordStrong(newPassword)) {
      Utils.snackBarError(
        context,
        'Password must be at least 8 characters with 1 uppercase, 1 lowercase, 1 number, and 1 special character',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Utils.snackBarError(context, 'New passwords do not match');
      return;
    }

    if (currentPassword == newPassword) {
      Utils.snackBarError(context, 'New password must be different from current password');
      return;
    }

    setState(() => _isLoading = true);

    final response = await _apiService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    setState(() => _isLoading = false);

    if (response.isSuccess) {
      Utils.snackBarSuccess(context, 'Password changed successfully');

      // Clear fields
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Navigate back
      Navigator.pop(context);
    } else {
      Utils.snackBarError(context, response.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: const Color(0xFF970202),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Change Your Password',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2B65),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'For your security, please enter your current password to set a new one.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Current Password
            TextField(
              controller: _currentPasswordController,
              obscureText: !_isCurrentPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Current Password *',
                hintText: 'Enter your current password',
                prefixIcon: const Icon(Icons.lock_open, color: Color(0xFF970202)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isCurrentPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF970202),
                  ),
                  onPressed: () => setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF970202)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // New Password
            TextField(
              controller: _newPasswordController,
              obscureText: !_isNewPasswordVisible,
              decoration: InputDecoration(
                labelText: 'New Password *',
                hintText: 'Enter new password',
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF970202)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF970202),
                  ),
                  onPressed: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF970202)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Password must contain:\n• At least 8 characters\n• 1 uppercase letter\n• 1 lowercase letter\n• 1 number\n• 1 special character (@\$!%*?&#)',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Confirm New Password
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm New Password *',
                hintText: 'Re-enter new password',
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF970202)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF970202),
                  ),
                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF970202)),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Security Tips Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.security, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Security Tips',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Use a unique password you don\'t use elsewhere\n'
                    '• Avoid common words and patterns\n'
                    '• Change your password regularly\n'
                    '• Never share your password with anyone',
                    style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Change Password Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF970202),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
