import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class providing helper methods for common app operations
///
/// Includes utilities for:
/// - Navigation and routing
/// - Image processing and compression
/// - Alert dialogs and snackbars
/// - Network connectivity checks
/// - Password validation
/// - JSON parsing helpers
class Utils {
  /// Opens a URL in the default browser or app
  static Future<void> openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  /// Converts image file to Base64 string with compression
  ///
  /// [file] The image file to convert
  /// [quality] JPEG quality (0-100), default: 50
  /// [maxWidth] Maximum width in pixels, default: 300
  /// [maxHeight] Maximum height in pixels, default: 400
  ///
  /// Returns Base64 encoded string of the compressed image
  static Future<String> fileToBase64(File file, {int quality = 50, int maxWidth = 300, int maxHeight = 400}) async {
    try {
      List<int> fileBytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(Uint8List.fromList(fileBytes));
      if (image == null) {
        throw Exception("Failed to decode image.");
      }
      img.Image resizedImage = img.copyResize(image, width: maxWidth, height: maxHeight);

      List<int> compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      String base64String = base64Encode(compressedBytes);
      return base64String;
    } catch (e) {
      print("Error converting file to Base64: $e");
      return '';
    }
  }


  static String getContentType(File file) {
    // Get the file extension from the file path
    String extension = file.path.split('.').last.toLowerCase();

    // Map file extensions to MIME types
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream'; // Default for unknown types
    }
  }
  static void navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }
  static void snackBarSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(' $message'),
        backgroundColor: Colors.green,
      ),
    );
  }
  static void snackBarError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $message'), backgroundColor: Colors.red,),
    );
  }

  static void snackBarInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }


  static void navigateToPageAnimation(BuildContext context, Widget page) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve));
        var scaleAnimation = animation.drive(tween);

        return ScaleTransition(
          scale: scaleAnimation,
          child: child,
        );
      },
    ));
  }





  static void showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('No Internet Connection'),
            content: Text('Please check your internet connection.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  static String formDataToString(FormData formData) {
    StringBuffer buffer = StringBuffer();

    for (var entry in formData.fields) {
      buffer.write('${entry.key}: ${entry.value}\n');
    }

    return buffer.toString();
  }
  static int getIdBySubName(String jsonResponse, String subName) {
    final decodedResponse = json.decode(jsonResponse);

    if (decodedResponse['data'] != null &&
        decodedResponse['data']['data'] != null &&
        decodedResponse['data']['data']['PacketInBankClasswise'] != null) {
      final packetInBankClasswise = decodedResponse['data']['data']['PacketInBankClasswise'];

      for (var packet in packetInBankClasswise) {
        if (packet['subName'] == subName) {
          return packet['id'];
        }
      }
    }

    // If the subName is not found, you can return a default value or handle it as needed.
    return -1; // Return -1 as an example for not found.
  }

  static void PermisionAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Alert'),
              content: Text(
                  "To enhance the security and authenticity of student examinations, the app requires access to your location and camera. These permissions are necessary for verifying teacher presence and identity during exams. Please enable both location and camera access to ensure a smooth and secure examination process. You can update these settings in your device's Settings app."),
              actions: [
                TextButton(
                  child:
                  Text('Close', style: TextStyle(color: Color(0xFF01579B))),
                  // Negative button
                  onPressed: () {
                    // Close the dialog without performing any action
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }
  static void progressbar(BuildContext context,int) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          child: SpinKitFadingCircle(
            color: Color(int),
            size: 50.0,
          ),
          onWillPop: () async => false,
        );
      },
    );
  }



  static void showAlertDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          title: Text('Alert', style: TextStyle(color: Colors.red)), // Set title color to red
          content: Text(title),
          elevation: 5, // Add a slight elevation to create a shadow effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Round the corners of the dialog
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10), // Reduce vertical padding
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.red), // Set button text color to red
              ),
            ),
          ],
        );
      },
    );
  }
  // static void showAlertDialogError(BuildContext context, String title, String message) {
  //   QuickAlert.show(
  //     context: context,
  //     type: QuickAlertType.info,
  //     title: title,
  //     text: message,
  //     textColor: Colors.white,
  //     confirmBtnText: 'OKAY',
  //     confirmBtnColor:  Colors.white,
  //     confirmBtnTextStyle: TextStyle(fontFamily: 'gilroy',fontSize: 12,color:  Color(Colores.theme_finalBlue)),
  //     titleColor:  Colors.white,
  //     headerBackgroundColor: Color(Colores.theme_finalBlue) ,
  //     backgroundColor:  Color(Colores.theme_finalBlue),
  //   );
  // }
  static String convertListToString(String input) {
    // Remove any commas from the input string
    String result = input.replaceAll(',', '');
    String result1 = result.replaceAll('[', '');
    String result2 = result1.replaceAll(']', '');
    String result3 = result2.replaceAll(' ', '');

    return result3;
  }

  static void showCustomAlertDialog(
      BuildContext context, {
        required String title,
        String? content, // Optional content
        String positiveButtonText = 'OK',
        VoidCallback? onPositivePressed, // Optional callback for positive button
        String? negativeButtonText,
        VoidCallback? onNegativePressed, // Optional callback for negative button
        bool isDismissible = true, // Allow user to dismiss by tapping outside
      })


  {
    showDialog(
      context: context,
      barrierDismissible: isDismissible, // Control dismiss on outside tap
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: content != null ? Text(content) : null, // Only show content if provided
          actions: [
            if (negativeButtonText != null) // Conditionally add negative button
              TextButton(
                onPressed: onNegativePressed,
                child: Text(negativeButtonText),
              ),
            TextButton(
              onPressed: onPositivePressed ?? () => Navigator.pop(context), // Default close on positive button press
              child: Text(positiveButtonText),
            ),
          ],
        );
      },
    );
  }


  static bool isStrongPassword(String password) {
    // Define a regular expression pattern to match the password criteria
    RegExp regex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\-]).{8,}$',
    );

    // Use the RegExp's hasMatch method to check if the password matches the pattern
    return regex.hasMatch(password);
  }

  static Future<bool> checkNetworkStatus() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
  // static String getCurrentFormattedDate() {
  //   //'2024-07-05'
  //   DateTime currentDate = DateTime.now();
  //   return DateFormat('yyyy-MM-dd').format(currentDate);
  // }

  static void addAllUniqueClasses(String jsonResponse, List<String> dropdownItemList) {
    final decodedResponse = json.decode(jsonResponse);

    if (decodedResponse['data'] != null &&
        decodedResponse['data']['data'] != null &&
        decodedResponse['data']['data']['PacketInBank'] != null) {
      final packetInBank = decodedResponse['data']['data']['PacketInBank'];

      for (var packet in packetInBank) {
        String currentClass = packet['class'];
        if (!dropdownItemList.contains(currentClass)) {
          dropdownItemList.add(currentClass);
        }
      }
    }
  }
  static String replaceSchoolCodeInJson(String originalJson, String newSchoolCode) {
    try {
      // Parse the original JSON string
      Map<String, dynamic> jsonData = json.decode(originalJson);

      // Replace the "SchoolCode" value with the newSchoolCode
      jsonData['SchoolCode'] = newSchoolCode;

      // Convert the modified data back to a JSON string
      String modifiedJson = json.encode(jsonData);

      return modifiedJson;
    } catch (e) {
      // Handle JSON parsing errors
      print("Error parsing or modifying JSON: $e");
      return originalJson; // Return the original JSON on error
    }
  }
  static void printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((RegExpMatch match) =>   print(match.group(0)));
  }
  static int getNoOfBlankSheetFromJsonString(String jsonString, String desiredClass) {
    final Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
    final List<dynamic> table = jsonResponse['data']['data']['Table'];

    for (var entry in table) {
      if (entry['class'] == desiredClass) {
        return entry['NoOfBlankSheet'];
      }
    }

    return 0; // Return a default value if the class is not found
  }

  static int getNoOfBlankSheetForClass(String responseJson, String targetClass) {
    Map<String, dynamic> jsonResponse = json.decode(responseJson);

    if (jsonResponse.containsKey('data') && jsonResponse['data'].containsKey('data')) {
      List<dynamic> tableData = jsonResponse['data']['data']['Table'];

      for (var entry in tableData) {
        String classs = entry['Class'];
        int noOfBlankSheet = entry['NoOfBlankSheet'];

        if (classs == targetClass) {
          return noOfBlankSheet;
        }
      }
    }

    // Return a default value or handle the case when the class is not found
    return 0;
  }



  static String formDataToStringg(FormData formData) {
    StringBuffer buffer = StringBuffer();

    for (var entry in formData.fields) {
      buffer.write('${entry.key}: ${entry.value}\n');
    }

    return buffer.toString();
  }
  // static Future<void> saveDevicesList(List<dynamic> devices) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String devicesJson = jsonEncode(devices);
  //   await prefs.setString('devices', devicesJson);
  // }
  // static Future<List<dynamic>> getDevicesList() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String devicesJson = prefs.getString('devices') ?? '[]';
  //   List<dynamic> devices = jsonDecode(devicesJson);
  //   return devices;
  // }
  // static Future<void> saveListShared(List<dynamic> list,String KeyName) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String devicesJson = jsonEncode(list);
  //   await prefs.setString(KeyName, devicesJson);
  // }
  // static Future<List<dynamic>> getListShared(String KeyName) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String devicesJson = prefs.getString(KeyName) ?? '[]';
  //   List<dynamic> devices = jsonDecode(devicesJson);
  //   return devices;
  // }
}