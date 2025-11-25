import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utilities/CustomColors.dart';
import '../utilities/Utils.dart';
import 'BsebRegistrationScreen.dart';

/// BSEB Credential Verification Screen (Path A Registration)
///
/// Allows students to verify their BSEB credentials before registration.
/// Fetches student data from BSEB database and navigates to registration form.
class BsebVerificationScreen extends StatefulWidget {
  const BsebVerificationScreen({Key? key}) : super(key: key);

  @override
  State<BsebVerificationScreen> createState() => _BsebVerificationScreenState();
}

class _BsebVerificationScreenState extends State<BsebVerificationScreen> {
  final ApiService _apiService = ApiService();

  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _rollCodeController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _rollNumberController.dispose();
    _dobController.dispose();
    _rollCodeController.dispose();
    super.dispose();
  }

  /// Verify BSEB credentials
  Future<void> _verifyCredentials() async {
    final rollNumber = _rollNumberController.text.trim();
    final dob = _dobController.text.trim();
    final rollCode = _rollCodeController.text.trim();

    if (rollNumber.isEmpty || dob.isEmpty) {
      Utils.snackBarError(context, 'Please enter Roll Number and Date of Birth');
      return;
    }

    setState(() => _isLoading = true);

    final response = await _apiService.verifyBsebCredentials(
      rollNumber: rollNumber,
      dob: dob,
      rollCode: rollCode.isEmpty ? null : rollCode,
    );

    setState(() => _isLoading = false);

    if (response.isSuccess && response.data != null) {
      final bsebData = response.data!['data'];

      Utils.snackBarSuccess(context, 'BSEB Credentials Verified!');

      // Navigate to registration form with pre-filled data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BsebRegistrationScreen(bsebData: bsebData),
        ),
      );
    } else {
      Utils.snackBarError(
        context,
        response.message.isEmpty
          ? 'Student record not found. Please verify your credentials.'
          : response.message
      );
    }
  }

  /// Date picker for DOB
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
    );

    if (picked != null) {
      setState(() {
        _dobController.text = picked.toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('BSEB Verification'),
        backgroundColor: const Color(0xFF970202),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const SizedBox(height: 20),
            const Text(
              'Verify BSEB Credentials',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2B65),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your BSEB credentials to verify your student record and register with pre-filled information.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Roll Number
            TextField(
              controller: _rollNumberController,
              decoration: InputDecoration(
                labelText: 'Roll Number *',
                hintText: 'Enter your BSEB Roll Number',
                prefixIcon: const Icon(Icons.numbers, color: Color(0xFF970202)),
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
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Date of Birth
            TextField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: 'Date of Birth *',
                hintText: 'YYYY-MM-DD',
                prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF970202)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month, color: Color(0xFF970202)),
                  onPressed: _selectDate,
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
              readOnly: true,
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),

            // Roll Code (Optional)
            TextField(
              controller: _rollCodeController,
              decoration: InputDecoration(
                labelText: 'Roll Code (Optional)',
                hintText: 'Enter Roll Code if available',
                prefixIcon: const Icon(Icons.code, color: Color(0xFF970202)),
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
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 30),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your information will be auto-fetched from BSEB records',
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyCredentials,
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
                        'Verify Credentials',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Back to regular registration
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back to Regular Registration',
                  style: TextStyle(
                    color: Color(0xFF1D2B65),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
