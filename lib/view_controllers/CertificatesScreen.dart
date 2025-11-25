import 'dart:io';
import 'package:bseb/utilities/SharedPreferencesHelper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class CertificateScreen extends StatefulWidget {
  @override
  _CertificateScreenState createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  List<File> _certificates = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _isAuthenticated = false; // ✅ track if password verified
  final SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();

  @override
  void initState() {
    super.initState();
    _verifyPassword(); // ✅ ask password first
  }

  // 🔒 Step 1: Verify password before showing anything
  Future<void> _verifyPassword() async {
    String savedPassword = await sharedPreferencesHelper.getPref("Password") ?? "";
    print(savedPassword);
    print("object111");

    await Future.delayed(const Duration(milliseconds: 300)); // smooth transition

    TextEditingController _passwordController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false, // cannot skip
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Password"),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // exit screen
              },
            ),
            ElevatedButton(
              child: const Text("Verify"),
              onPressed: () {
                if (_passwordController.text.trim() == savedPassword) {
                  Navigator.of(context).pop(); // close dialog
                  setState(() {
                    _isAuthenticated = true;
                  });
                  _loadCertificates();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Incorrect password. Try again.")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Load all previously uploaded files from app directory
  Future<void> _loadCertificates() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync().whereType<File>().toList();

    setState(() {
      _certificates = files;
    });
  }

  Future<void> _addCertificate() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final pickedFile = File(result.files.single.path!);
    final dir = await getApplicationDocumentsDirectory();
    final newPath = "${dir.path}/${pickedFile.uri.pathSegments.last}";

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    // Simulate upload with progress
    final totalBytes = await pickedFile.length();
    final sink = File(newPath).openWrite();
    final stream = pickedFile.openRead();
    int copied = 0;

    await for (var chunk in stream) {
      copied += chunk.length;
      sink.add(chunk);
      setState(() {
        _uploadProgress = copied / totalBytes;
      });
      await Future.delayed(const Duration(milliseconds: 50)); // smooth progress
    }
    await sink.close();

    setState(() {
      _certificates.add(File(newPath));
      _isUploading = false;
      _uploadProgress = 0.0;
    });
  }

  void _deleteCertificate(int index) {
    final file = _certificates[index];
    if (file.existsSync()) file.deleteSync();

    setState(() {
      _certificates.removeAt(index);
    });
  }

  void _openCertificate(File file) {
    OpenFilex.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Certificates")),
      body: Column(
        children: [
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text("Uploading ${_certificates.length + 1} document..."),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _uploadProgress),
                ],
              ),
            ),
          Expanded(
            child: _certificates.isEmpty
                ? const Center(child: Text("No certificates added"))
                : ListView.builder(
              itemCount: _certificates.length,
              itemBuilder: (context, index) {
                final file = _certificates[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading:
                    const Icon(Icons.picture_as_pdf, color: Colors.blue),
                    title: Text(file.uri.pathSegments.last),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new,
                              color: Colors.green),
                          onPressed: () => _openCertificate(file),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCertificate(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _addCertificate,
        child: _isUploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      ),
    );
  }
}
