import 'package:bseb/view_controllers/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'package:bseb/controllers/auth_controller.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../utilities/Constant.dart';
import '../utilities/CustomColors.dart';
import '../utilities/Utils.dart';
import 'LoginScreen.dart';

class OtpScreen extends StatefulWidget {
  final String name;
  final String email;
  final String number;
  final String confirmPassword;
  final String rollCode;
  final String rollNo;
  final String registration;
  final String dob;
  final String otp;
  final String fatherName;
  final String motherName;
  final String address;
  final String aadhaar;
  final String udise;
  final String stream;
  final String? selectedClass;
  final String? selectedGender;
  final String? selectedDivisions;
  final String? selectedDistrict;
  final String? selectedBlock;
  final String? selectedSchool;
  final String? filePath;
  final String? fileName;
  final bool isForget;
  final String? selectedCaste;
  final String? selectedDifferentlyAbled;
  final String? selectedReligion;
  final String? selectedArea;
  final String? selectedMaritalStatus;
  final String? fileNameSignature;
  final String? filePathSignature;
  final String? password; // Added password field

  final File? photoFile;
  final File? signatureFile;

  const OtpScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.number,
    required this.confirmPassword,
    required this.rollCode,
    required this.rollNo,
    required this.registration,
    required this.dob,
    required this.otp,
    required this.fatherName,
    required this.motherName,
    required this.address,
    required this.aadhaar,
    required this.udise,
    required this.stream,
    this.selectedClass,
    this.selectedGender,
    this.selectedDivisions,
    this.selectedDistrict,
    this.selectedBlock,
    this.selectedSchool,
    this.isForget = false,
    this.filePath,
    this.fileName,
    this.selectedCaste,
    this.selectedDifferentlyAbled,
    this.selectedReligion,
    this.selectedArea,
    this.selectedMaritalStatus,
    this.fileNameSignature,
    this.filePathSignature,
    this.password, // Added password param
    this.photoFile,
    this.signatureFile,
  }) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  final AuthController _authController = Get.put(AuthController());
  int _secondsRemaining = 30;
  bool _isResendEnabled = false;
  Timer? _timer;
  String newOtp = '';
  String? otpCode;

  // ✅ Your App Hash
  final String _appHash = "DLDpNfbhc74";

  @override
  void initState() {
    super.initState();
    // SECURITY FIX: Removed storing OTP from widget parameter
    // OTP should only come via SMS, not from backend
    _startTimer();
    listenForCode(); // start listening for OTP SMS
  }

  @override
  void dispose() {
    cancel(); // stop listening for SMS
    _timer?.cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code; // autofill SMS
    });
    if (otpCode != null && otpCode!.length == 6) {
      _verifyOtp(); // auto verify when OTP complete
    }
  }

  Future<void> _resendOtp() async {
    final success = await _authController.sendOtp(widget.number);

    if (success) {
      debugPrint("✅ OTP sent successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP sent successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authController.error)),
      );
    }
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
      _isResendEnabled = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isResendEnabled = true;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (otpCode == null || otpCode!.isEmpty) {
      Utils.snackBarInfo(context, 'Please enter OTP');
      return;
    }

    // SECURITY FIX: Removed frontend OTP validation
    // OTP validation should ONLY happen on backend for security
    // Removed: if (otpCode != newOtp) { ... }

    // Removed: Legacy verifyRegistrationOtp() call
    // New flow: Registration API handles OTP verification internally

    await registerStudent();
  }

  Future<void> registerStudent() async {
    // Utils.progressbar(context, CustomColors.themeColorBlack);

    FormData formData = FormData.fromMap({
      "Phone": widget.number,
      "Email": widget.email,
      "RollNumber": widget.rollNo,
      "RollCode": widget.rollCode,
      "Dob": widget.dob,
      "FullName": widget.name,
      "Gender": widget.selectedGender,
      "FatherName": widget.fatherName,
      "MotherName": widget.motherName,
      "Distic": widget.selectedDistrict,
      "Division": widget.selectedDivisions,
      "Block": widget.selectedBlock,
      "FullAddress": widget.address,
      "Class": widget.selectedClass,
      "AddharNumber": widget.aadhaar,
      "SchoolName": widget.selectedSchool,
      "UdiseCode": widget.udise,
      "Stream": widget.stream,
      "RegistrationNumber": widget.registration,
      "Password": widget.confirmPassword,
      "Username": widget.name,
      "Otp": otpCode, // SECURITY FIX: Use user-entered OTP, not backend-provided one
      "MaritalStatus": widget.selectedMaritalStatus,
    });

    // Add files if available
    if (widget.photoFile != null) {
      String fileName = widget.photoFile!.path.split('/').last;
      formData.files.add(MapEntry(
        "Photo",
        await MultipartFile.fromFile(widget.photoFile!.path, filename: fileName),
      ));
    }

    if (widget.signatureFile != null) {
      String fileName = widget.signatureFile!.path.split('/').last;
      formData.files.add(MapEntry(
        "SignaturePhoto",
        await MultipartFile.fromFile(widget.signatureFile!.path, filename: fileName),
      ));
    }

    final success = await _authController.registerStudent(formData);

    // if (Navigator.canPop(context)) Navigator.pop(context); // close loader

    if (success) {
      print("land");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update Successful')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authController.error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(CustomColors.theme_orange),
        title: const Text(
          'OTP Verification',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter OTP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// ✅ OTP Autofill Field
            PinFieldAutoFill(
              codeLength: 6,
              currentCode: otpCode,
              onCodeChanged: (val) {
                otpCode = val;
              },
              decoration: BoxLooseDecoration(
                strokeColorBuilder: FixedColorBuilder(Color(CustomColors.theme_orange)),
                bgColorBuilder: FixedColorBuilder(Colors.white),
                textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                radius: const Radius.circular(8),
              ),
            ),

            const SizedBox(height: 10),

            /// ✅ Show App Signature Hash (Tap to Copy)
            // GestureDetector(
            //   onTap: () {
            //     Clipboard.setData(ClipboardData(text: _appHash));
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text("App Hash copied!")),
            //     );
            //   },
            //   child: Text(
            //     "App Hash: $_appHash",
            //     style: const TextStyle(
            //       fontSize: 14,
            //       color: Colors.grey,
            //       fontStyle: FontStyle.italic,
            //       decoration: TextDecoration.underline,
            //     ),
            //   ),
            // ),

            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(CustomColors.theme_orange),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _verifyOtp,
              child: const Text(
                'Verify OTP',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            TextButton(
              onPressed: _isResendEnabled ? _resendOtp : null,
              child: Text(
                _isResendEnabled
                    ? "Resend OTP"
                    : "Resend OTP in $_secondsRemaining sec",
                style: TextStyle(
                  color: _isResendEnabled ? Color(CustomColors.theme_orange) : Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
