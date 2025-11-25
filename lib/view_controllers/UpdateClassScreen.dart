import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateClassScreen extends StatefulWidget {
  const UpdateClassScreen({Key? key}) : super(key: key);

  @override
  State<UpdateClassScreen> createState() => _UpdateClassScreenState();
}

class _UpdateClassScreenState extends State<UpdateClassScreen> {
  final List<String> classes = ['9th', '10th', '11th', '12th'];
  String? selectedClass;
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _classError = false;
  bool _regError = false;
  bool _passError = false;
  String? _storedPassword; // fetched from SharedPreferences

  @override
  void initState() {
    super.initState();
    _loadSavedValues();
  }

  Future<void> _loadSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedClass = prefs.getString('Class');
      _regNumberController.text = prefs.getString('RegistrationNumber') ?? '';
      _storedPassword = prefs.getString('Password') ?? ''; // get stored password
    });
  }

  Future<void> _saveValues() async {
    // validate fields
    setState(() {
      _classError = selectedClass == null;
      _regError = _regNumberController.text.trim().isEmpty;
      _passError = _passwordController.text.trim().isEmpty ||
          _passwordController.text.trim() != (_storedPassword ?? '');
    });

    if (_classError || _regError || _passError) {
      // don’t save if validation fails
      if (_passError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password is incorrect')),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Class', selectedClass!);
    await prefs.setString('RegistrationNumber', _regNumberController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Class updated successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF9A1515);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text(
          'Update Class',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Class',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _classError ? Colors.red : Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text("Choose Class"),
                  value: selectedClass,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      selectedClass = value;
                      _classError = false;
                    });
                  },
                  items: classes.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (_classError)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  'Please select a class',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),

            const Text(
              'Enter Registration Number',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _regNumberController,
              decoration: InputDecoration(
                hintText: 'Enter new registration number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: _regError ? Colors.red : Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: _regError ? Colors.red : Colors.grey.shade400),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              onChanged: (_) {
                if (_regError) {
                  setState(() {
                    _regError = false;
                  });
                }
              },
            ),
            if (_regError)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  'Registration number is required',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),

            const Text(
              'Enter Password',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: _passError ? Colors.red : Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: _passError ? Colors.red : Colors.grey.shade400),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              onChanged: (_) {
                if (_passError) {
                  setState(() {
                    _passError = false;
                  });
                }
              },
            ),
            if (_passError)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  'Password is required or incorrect',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveValues,
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
