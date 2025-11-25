import 'dart:async';
import 'package:bseb/utilities/Constant.dart';
import 'package:bseb/utilities/CustomColors.dart';
import 'package:bseb/utilities/SharedPreferencesHelper.dart';
import 'package:bseb/utilities/Utils.dart';
import 'package:bseb/controllers/auth_controller.dart';
import 'package:bseb/view_controllers/HomeScreen.dart';
import 'package:bseb/view_controllers/SignUpScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ForgetPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isOtpLogin = true;
  bool _otpRequested = false;
  bool _canResendOtp = false;

  final AuthController _authController = Get.put(AuthController());
  final SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();

  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String fcmToken = "";
  int _failCount = 0;
  Timer? _resendTimer;
  int _resendSeconds = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      fcmToken = await sharedPreferencesHelper.getPref(Constant.FCM_TOKEN) ?? "";
      String phone= await sharedPreferencesHelper.getPref("Phone") ?? "";
      // SECURITY FIX: Never store or retrieve passwords
      _emailPhoneController.text=phone;
      // Password field should remain empty for security
      setState(() {

      });


      if (fcmToken.isEmpty) {
        await _authController.getFCMToken();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> sendOtpLogin() async {
    final phone = _emailPhoneController.text.trim();
    if (phone.isEmpty) {
      Utils.snackBarInfo(context, 'enter_mobile_email'.tr);
      return;
    }

    Utils.progressbar(context, CustomColors.themeColorBlack);
    
    final success = await _authController.sendOtp(phone);
    
    Navigator.pop(context);

    if (success) {
      setState(() {
        _otpRequested = true;
        _canResendOtp = false;
        _resendSeconds = 30;
      });
      _startResendTimer();
      Utils.snackBarSuccess(context, 'otp_sent'.tr);
    } else {
      Utils.snackBarError(context, _authController.error);
    }
  }



  Future<void> _loginWithPassword() async {
    final email = _emailPhoneController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Utils.snackBarInfo(context, 'All Fields Required');
      return;
    }

    Utils.progressbar(context, CustomColors.themeColorBlack);
    
    final success = await _authController.loginWithPassword(email, password);
    
    Navigator.pop(context);

    if (success) {
      Utils.snackBarSuccess(context, "Login Successful");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Homescreen()),
      );
    } else {
      _failCount++;
      if (_failCount >= 3) {
        Utils.snackBarError(context, "Too many failures! Try again later.");
        return;
      }
      Utils.snackBarError(context, _authController.error);
    }
  }
  Future<void> _requestOtp() async {
    final phoneOrEmail = _emailPhoneController.text.trim();
    if (phoneOrEmail.isEmpty) {
      Utils.snackBarInfo(context, 'enter_mobile_email'.tr);
      return;
    }
    await sendOtpLogin();
    // setState(() {
    //   _otpRequested = true;
    //   _canResendOtp = false;
    //   _resendSeconds = 30;
    // });
    // _startResendTimer();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      Utils.snackBarInfo(context, 'Enter OTP');
      return;
    }

    Utils.progressbar(context, CustomColors.themeColorBlack);

    final success = await _authController.verifyOtp(_emailPhoneController.text.trim(), otp);

    Navigator.pop(context);

    if (success) {
      Utils.snackBarSuccess(context, "Login Successful");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Homescreen()),
      );
    } else {
      _failCount++;
      if (_failCount >= 3) {
        Utils.snackBarError(context, "Too many invalid OTP attempts. Locked 15 mins.");
        return;
      }
      Utils.snackBarError(context, _authController.error);
    }
  }
  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        setState(() => _canResendOtp = true);
        timer.cancel();
      }
    });
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint.tr,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Container(
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF970202)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with logo
            Stack(
              children: [
                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35)),
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        'assets/images/bseb_bg_new.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 58,
                    backgroundColor: Colors.transparent,
                    child: const CircleAvatar(
                      radius: 54,
                      backgroundImage: AssetImage('assets/images/app_logo.png'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('bseb_board'.tr,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Toggle Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text('otp_login'.tr),
                  selected: _isOtpLogin,
                  onSelected: (_) => setState(() => _isOtpLogin = true),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: Text('password_login'.tr),
                  selected: !_isOtpLogin,
                  onSelected: (_) => setState(() => _isOtpLogin = false),
                ),
              ],
            ),

            DropdownButton<String>(
              value: Get.locale?.languageCode, // "en" or "hi"
              items: const [
                DropdownMenuItem(value: "en", child: Text("English")),
                DropdownMenuItem(value: "hi", child: Text("हिंदी")),
              ],
              onChanged: (langCode) {
                if (langCode != null) {
                  final locale = Locale(langCode);
                  sharedPreferencesHelper.setPref("lang", langCode); // save only code
                  Get.updateLocale(locale);
                }
              },
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _isOtpLogin ? _buildOtpForm() : _buildPasswordForm(),
            ),

            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text('dont_have_account'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      _authController.getFCMToken();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('sign_up'.tr,
                        style: const TextStyle(
                            color: Color(0xFF1D2B65), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      children: [
        TextField(
          controller: _emailPhoneController,
          decoration: _inputDecoration('enter_email_phone', Icons.email),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: _inputDecoration('password', Icons.lock).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF970202),
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _loginWithPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF970202),
                padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text('login'.tr, style: const TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
              ),
              child: Text('forget_password'.tr,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      children: [
        TextField(
          controller: _emailPhoneController,
          decoration: _inputDecoration('enter_mobile_email', Icons.phone),
        ),
        const SizedBox(height: 14),
        if (_otpRequested) ...[
          TextField(
            controller: _otpController,
            decoration: _inputDecoration('enter_otp', Icons.lock),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF970202),
              padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text('verify_otp'.tr, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 12),
          _canResendOtp
              ? TextButton(onPressed: _requestOtp, child: Text('resend_otp'.tr))
              : Text('${'resend_otp_in'.tr} $_resendSeconds ${'sec'.tr}',
              style: const TextStyle(color: Colors.grey)),
        ] else
          ElevatedButton(
            onPressed: _requestOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF970202),
              padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text('request_otp'.tr, style: const TextStyle(color: Colors.white)),
          ),
      ],
    );
  }
}
