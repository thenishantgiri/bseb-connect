  import 'dart:convert';
  import 'dart:io';
  import 'package:bseb/utilities/Utils.dart';
import 'package:dio/dio.dart';
  import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
  import 'package:webview_flutter/webview_flutter.dart';
  import 'package:flutter_downloader/flutter_downloader.dart';
  import '../utilities/dio_singleton.dart';
import '../utilities/Constant.dart';
import '../utilities/CustomColors.dart';
import '../utilities/SharedPreferencesHelper.dart';


  class FullScreenWebView2 extends StatefulWidget {
    final String htmlData;
    final String intentFrom;
    final String registrationNumber;
    final String dob;
    FullScreenWebView2({required this.htmlData, required this.intentFrom,required this.registrationNumber,required this.dob});

    @override
    _FullScreenWebView2State createState() => _FullScreenWebView2State();
  }

  class _FullScreenWebView2State extends State<FullScreenWebView2> {
    late WebViewController _controller;
    final Dio _dio = getDio(); // Use singleton Dio instance
    SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();
    String _locationMessage = "Location not yet fetched";

    @override
    void initState() {
      super.initState();
      _controller = WebViewController();
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted); // Enable JavaScript
      _controller.enableZoom(true);
      // _controller.
      _controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print("Page started loading: $url");
          },
      ),
      );
    }
    // Strict permission handler
    Future<void> _checkAndRequestPermission() async {
      LocationPermission permission;
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() {
          _locationMessage = "Location services are disabled. Please enable them.";
        });
        return;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationMessage = "Location permission denied. Please grant permission.";
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        // await openAppSettings()
        _showPermissionDialog();
        setState(() {
          _locationMessage = "Location permission permanently denied. Enable it from App Settings.";
        });
        return;
      }
      _getLocation();
    }

    void _showPermissionDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permission Required"),
          content: const Text(
              "Location permission has been denied permanently. Please click on open setting and enable location access for this app to continue using this feature."
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
               // openAppSettings(); // Open app settings
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
    }
    Future<void> _getLocation() async {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _locationMessage = "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
          print(_locationMessage);
          openGoogleMaps(position.latitude, position.longitude, 26.8749, 75.7684);
        });
      } catch (e) {
        setState(() {
          _locationMessage = "Error fetching location: $e";
        });
      }
    }
    Future<void> _getAdmitCardLink() async {
      // "RegistrationNumber": "R-110082307-23",
      // "DOB": "01-01-2006"
      try {
        Utils.progressbar(context, CustomColors.theme_orange);
        const String apiUrl = Constant.BASE_URL + Constant.DOWNLOAD_ADMIT_CARD_New;

        final response = await _dio.post(
          apiUrl,
          data: {
            // "RegistrationNumber": widget.registrationNumber,
            // "DOB": widget.dob
            "RegistrationNumber": "R-531010124-23", // Use dynamic input if needed
            "DOB": "20-01-2006" //
          },
        );
        Navigator.pop(context);
        if (response.statusCode == 200 && response.data['status'] == 1) {
          setState(() {});
          String  admitCarLink = response.data['data']['PdfUrl'];
          try {
            // Ensure permissions are granted
         //   var status = await Permission.storage.request();
            Utils.openUrl(admitCarLink);
          } catch (e) {
            // Handle any unexpected errors
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to download file: $e")),
            );
          }

        } else {
          Utils.snackBarError(context, response.data['message']);
        }
      } catch (e) {
        Navigator.pop(context);
        Utils.snackBarError(context, 'Catch Error: $e');
      }
    }
    Future<void> _getMarkSheetLink() async {
      try {
        Utils.progressbar(context, CustomColors.theme_orange);
        const String apiUrl = Constant.BASE_URL + Constant.DOWNLOAD_MARKSHEET;

        final response = await _dio.post(
          apiUrl,
          data: {
            // 'StudentId': await sharedPreferencesHelper.getPref(Constant.USER_ID),
            'StudentId': "4",
          },
        );
        Navigator.pop(context);
        if (response.statusCode == 200 && response.data['status'] == 1) {
          setState(() {});
          String  markSheetLink = response.data['data']['PdfUrl'];
          try {
            Utils.openUrl(markSheetLink);
          } catch (e) {
            // Handle any unexpected errors
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to download file: $e")),
            );
          }
        } else {
          Utils.snackBarError(context, response.data['message']);
        }
      } catch (e) {
        Navigator.pop(context);
        Utils.snackBarError(context, 'Catch Error: $e');
      }
    }
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.intentFrom == 'admitCard' ? 'Dummy Admit Card ' : 'Marksheet',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(CustomColors.theme_orange),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.download),
              onPressed: () async {
                widget.intentFrom == 'admitCard' ? _getAdmitCardLink() : _getMarkSheetLink();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: WebViewWidget(
                controller: _controller
                  ..loadRequest(
                    Uri.dataFromString(
                      widget.htmlData,
                      mimeType: 'text/html',
                      encoding: Encoding.getByName('utf-8'),
                    ),
                  ),
              ),

            ),
            // TextButton(
            //   onPressed: () {
            //     _checkAndRequestPermission();
            //     // openGoogleMaps(26.806683, 75.810730, 26.8749, 75.7684); // Example coordinates (San Francisco to Los Angeles)
            //   },
            //   child: const Text(
            //     'Click To View Route in Maps',
            //     style: TextStyle(color: Colors.blue),
            //   ),
            // ),
          ],
        ),
      );
    }
    void openGoogleMaps(double startLat, double startLng, double endLat, double endLng) async {
      final googleMapsUrl = Uri.parse('google.navigation:q=$endLat,$endLng&origin=$startLat,$startLng&mode=d');
      if (await canLaunch(googleMapsUrl.toString())) {
        await launch(googleMapsUrl.toString());
      } else {
        final browserUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving');
        if (await canLaunch(browserUrl.toString())) {
          await launch(browserUrl.toString());
        } else {
          throw 'Could not open the map.';
        }
      }
    }

  }
