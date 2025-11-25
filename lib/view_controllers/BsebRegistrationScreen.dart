import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utilities/Utils.dart';
import 'LoginScreen.dart';

/// BSEB Registration Screen with Pre-filled Data
///
/// Shows student data fetched from BSEB database.
/// User only needs to provide: phone, email, password
class BsebRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> bsebData;

  const BsebRegistrationScreen({
    Key? key,
    required this.bsebData,
  }) : super(key: key);

  @override
  State<BsebRegistrationScreen> createState() => _BsebRegistrationScreenState();
}

class _BsebRegistrationScreenState extends State<BsebRegistrationScreen> {
  final ApiService _apiService = ApiService();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validate password strength
  bool _isPasswordStrong(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special char
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$');
    return regex.hasMatch(password);
  }

  /// Register with BSEB link
  Future<void> _register() async {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (phone.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Utils.snackBarError(context, 'All fields are required');
      return;
    }

    if (phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      Utils.snackBarError(context, 'Please enter a valid 10-digit phone number');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Utils.snackBarError(context, 'Please enter a valid email address');
      return;
    }

    if (!_isPasswordStrong(password)) {
      Utils.snackBarError(
        context,
        'Password must be at least 8 characters with 1 uppercase, 1 lowercase, 1 number, and 1 special character',
      );
      return;
    }

    if (password != confirmPassword) {
      Utils.snackBarError(context, 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    final response = await _apiService.registerWithBsebLink(
      rollNumber: widget.bsebData['rollNumber'],
      dob: widget.bsebData['dob'],
      phone: phone,
      email: email,
      password: password,
      rollCode: widget.bsebData['rollCode'],
    );

    setState(() => _isLoading = false);

    if (response.isSuccess) {
      Utils.snackBarSuccess(context, 'Registration successful!');

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

  /// Build info row widget
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('BSEB Registration'),
        backgroundColor: const Color(0xFF970202),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const SizedBox(height: 10),
            const Text(
              'Complete Your Registration',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2B65),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your BSEB information has been verified. Please provide your contact details to complete registration.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // BSEB Data Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Verified BSEB Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _buildInfoRow('Name', widget.bsebData['fullName'] ?? 'N/A'),
                  _buildInfoRow('Roll Number', widget.bsebData['rollNumber'] ?? 'N/A'),
                  _buildInfoRow('Class', widget.bsebData['class'] ?? 'N/A'),
                  _buildInfoRow('School', widget.bsebData['schoolName'] ?? 'N/A'),
                  _buildInfoRow('DOB', widget.bsebData['dob'] ?? 'N/A'),
                  _buildInfoRow('Gender', widget.bsebData['gender'] ?? 'N/A'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Registration Form
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2B65),
              ),
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: '10-digit mobile number',
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF970202)),
                counterText: '',
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
            const SizedBox(height: 16),

            // Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email *',
                hintText: 'your.email@example.com',
                prefixIcon: const Icon(Icons.email, color: Color(0xFF970202)),
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
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password *',
                hintText: 'At least 8 characters',
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF970202)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF970202),
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
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
            const SizedBox(height: 16),

            // Confirm Password
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password *',
                hintText: 'Re-enter password',
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

            // Register Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
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
                        'Complete Registration',
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
