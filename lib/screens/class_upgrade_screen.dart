import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// Class Upgrade Screen
/// Allows students to upgrade their class (e.g., 10th to 12th) as per SRS requirement
class ClassUpgradeScreen extends StatefulWidget {
  const ClassUpgradeScreen({Key? key}) : super(key: key);

  @override
  State<ClassUpgradeScreen> createState() => _ClassUpgradeScreenState();
}

class _ClassUpgradeScreenState extends State<ClassUpgradeScreen> {
  final AuthController _authController = AuthController.to;
  final _formKey = GlobalKey<FormState>();

  String? selectedClass;
  final TextEditingController streamController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController rollCodeController = TextEditingController();
  final TextEditingController registrationNumberController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();

  final List<String> classes = ['10', '11', '12'];

  @override
  void dispose() {
    streamController.dispose();
    rollNumberController.dispose();
    rollCodeController.dispose();
    registrationNumberController.dispose();
    schoolNameController.dispose();
    super.dispose();
  }

  Future<void> _submitUpgrade() async {
    if (_formKey.currentState!.validate()) {
      final success = await _authController.upgradeClass(
        newClass: selectedClass!,
        newStream: streamController.text.isNotEmpty ? streamController.text : null,
        newRollNumber: rollNumberController.text.isNotEmpty ? rollNumberController.text : null,
        newRollCode: rollCodeController.text.isNotEmpty ? rollCodeController.text : null,
        newRegistrationNumber: registrationNumberController.text.isNotEmpty 
            ? registrationNumberController.text 
            : null,
        newSchoolName: schoolNameController.text.isNotEmpty ? schoolNameController.text : null,
      );

      if (success) {
        Get.back(); // Return to previous screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade Class'),
        centerTitle: true,
      ),
      body: Obx(() => _authController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Update your class and academic details after promotion',
                                style: TextStyle(color: Colors.blue.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Class Dropdown *
                    const Text('New Class *', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedClass,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select your new class',
                      ),
                      items: classes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text('Class $value'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedClass = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a class';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Stream
                    const Text('Stream (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: streamController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Science, Commerce, Arts',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Roll Number
                    const Text('New Roll Number (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: rollNumberController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter new roll number',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Roll Code
                    const Text('New Roll Code (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: rollCodeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter new roll code',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Registration Number
                    const Text('New Registration Number (Optional)', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: registrationNumberController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter new registration number',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // School Name
                    const Text('New School Name (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: schoolNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter new school name if changed',
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitUpgrade,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Upgrade Class',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
