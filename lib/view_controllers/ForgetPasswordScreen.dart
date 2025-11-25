import 'package:bseb/utilities/Constant.dart';
import 'package:bseb/utilities/CustomColors.dart';
import 'package:bseb/view_controllers/OtpScreen.dart';
import 'package:bseb/view_controllers/OtpVerificationScreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:bseb/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../utilities/CustomColors.dart';
import '../utilities/Utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  String _otp = "";
  String _userId = "";

  // void _sendResetCode() {
  //   // Simulate sending a reset code
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Reset Code Sent'),
  //       content: Text('A reset code has been sent to your mobile number.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Future<void> _sendOtp() async {
    final String phone = _mobileController.text.trim();
    if (phone.isEmpty) {
      Utils.snackBarInfo(context, 'Enter Register no.');
      return;
    }
    
    Utils.progressbar(context, CustomColors.themeColorBlack);
    
    final success = await _authController.forgotPassword(phone);
    
    Navigator.pop(context);

    if (success) {
      // Note: Legacy API returned OTP in response, but secure flow sends it via SMS.
      // We'll pass empty OTP or handle it if AuthController stores it.
      // For now, assuming SMS flow.
      
      Utils.snackBarSuccess(context, "OTP sent successfully");
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phone: _mobileController.text.trim(),
            otp: '', // OTP should come via SMS
          ),
        ),
      );
    } else {
      Utils.snackBarError(context, _authController.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content (scrollable)
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar mimic
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Color(0xFF970202),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.white),
                    title: const Text(
                      'Forgot Password',
                      style: TextStyle(color: Colors.white),
                    ),
                    centerTitle: true,
                    automaticallyImplyLeading: true,
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Reset Your Password',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF970202),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Enter your registered mobile number and we will send you a reset code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 30),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Mobile Number',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    cursorColor: Color(0xFF970202),
                    decoration: InputDecoration(
                      hintText: 'Enter Register no.',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF970202),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_android, color: Colors.white),
                      ),
                      hintStyle: const TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _sendOtp();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF970202),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Send Reset Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom section fixed
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Color(0xFF970202),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}