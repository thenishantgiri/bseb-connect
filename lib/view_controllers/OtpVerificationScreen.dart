import 'dart:async';
import 'package:bseb/controllers/auth_controller.dart';
import 'package:bseb/utilities/CustomColors.dart';
import 'package:bseb/view_controllers/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String otp;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.otp,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthController _authController = Get.put(AuthController());
  final TextEditingController _passwordController = TextEditingController();

  String? otpCode;
  bool _isResendEnabled = false;
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
   // otpCode = widget.otp;
  }

  void _startResendTimer() {
    _isResendEnabled = false;
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (otpCode == null || otpCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter new password')),
      );
      return;
    }

    // Utils.progressbar(context, CustomColors.themeColorBlack);

    final success = await _authController.resetPassword(
      widget.phone,
      otpCode!,
      _passwordController.text.trim(),
    );
    
    // Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Password reset successfully")),
      );

      // Navigate to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authController.error)),
      );
    }
  }

  void _resendOtp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP resent successfully!")),
    );
    _startResendTimer();
    // Optional: Call resend OTP API here if available
  }

  @override
  void dispose() {
    _timer?.cancel();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(CustomColors.theme_orange),
        title: const Text(
          'OTP Verification',
          style: TextStyle(color: Colors.white, fontFamily: 'Gilroy'),
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Gilroy',
              ),
            ),
            const SizedBox(height: 20),

            /// OTP Input
            PinFieldAutoFill(
              codeLength: 6,
              currentCode: otpCode,
              onCodeChanged: (val) {
                otpCode = val;
              },
              decoration: BoxLooseDecoration(
                strokeColorBuilder:
                FixedColorBuilder(const Color(CustomColors.theme_orange)),
                bgColorBuilder: FixedColorBuilder(Colors.white),
                textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                radius: const Radius.circular(8),
              ),
            ),

            const SizedBox(height: 20),

            /// Password Input
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Enter New Password',
                labelStyle: const TextStyle(fontFamily: 'Gilroy'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: const Color(CustomColors.theme_orange),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(CustomColors.theme_orange),
                padding:
                const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _verifyOtp,
              child: const Text(
                'Verify & Reset Password',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Gilroy',
                ),
              ),
            ),

            const SizedBox(height: 10),

            // TextButton(
            //   onPressed: _isResendEnabled ? _resendOtp : null,
            //   child: Text(
            //     _isResendEnabled
            //         ? "Resend OTP"
            //         : "Resend OTP in $_secondsRemaining sec",
            //     style: TextStyle(
            //       color: _isResendEnabled
            //           ? const Color(CustomColors.theme_orange)
            //           : Colors.grey,
            //       fontSize: 16,
            //       fontFamily: 'Gilroy',
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
