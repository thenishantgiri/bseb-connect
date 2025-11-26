import 'package:bseb/view_controllers/LoginScreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../utilities/dio_singleton.dart';
import '../utilities/Constant.dart';
import '../utilities/CustomColors.dart';
import '../utilities/Utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  var _phone="";
  var _userId ="";

  ChangePasswordScreen(this._userId, this._phone);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final Dio _dio = getDio(); // Use singleton Dio instance
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isNewPasswordVisible = false;

  Future<void> _changePassword() async {
    final String newPass = _newPasswordController.text.trim();
    final String confPass = _confirmNewPasswordController.text.trim();
    if (newPass.isEmpty) {
      Utils.snackBarInfo(context, 'Enter New Password');
      return;
    }
    if (newPass !=confPass) {
      Utils.snackBarInfo(context, 'Passwords do not match');
      return;
    }
    try {
      Utils.progressbar(context,CustomColors.themeColorBlack);
      final String apiUrl = Constant.BASE_URL+Constant.SET_PASSWORD;
      Response response = await _dio.post(
        apiUrl,
        data: {
          'phone':widget._phone,
          'id':widget._userId,
          'password': newPass,
        },
      );
      Navigator.pop(context);
      if (response.statusCode == 200) {
        if (response.data['status'] == 0) {
          Utils.snackBarError(context, response.data['message']);
        } else {
          Utils.snackBarSuccess(context, response.data['message']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>LoginScreen()),
          );
        }
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to register')));
        Utils.snackBarError(context, response.data['message']);
      }
    } catch (e) {
      Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Catch Error: $e')));
      Utils.snackBarError(context,'Catch Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(CustomColors.theme_orange),
        title: const Text('Change Password',style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // New Password Field
              TextField(
                controller: _newPasswordController,
                obscureText: !_isNewPasswordVisible,
                cursorColor: Color(0xFFFF7043), // Cursor color (orange)
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Color(CustomColors.theme_orange)), // Lock icon
                  hintText: 'Enter your new password',
                  hintStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(CustomColors.theme_orange)), // Focused border color
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Color(CustomColors.theme_orange),
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              // Confirm New Password Field
              TextField(
                controller: _confirmNewPasswordController,
                obscureText: !_isNewPasswordVisible,
                cursorColor: Color(0xFFFF7043), // Cursor color (orange)
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Color(CustomColors.theme_orange)), // Lock icon
                  hintText: 'Confirm your new password',
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(CustomColors.theme_orange)), // Focused border color
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Color(CustomColors.theme_orange),
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  _changePassword();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(CustomColors.theme_orange),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Set Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
