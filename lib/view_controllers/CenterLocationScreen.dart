import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CenterLocationScreen extends StatefulWidget {
  const CenterLocationScreen({Key? key}) : super(key: key);

  @override
  State<CenterLocationScreen> createState() => _CenterLocationScreenState();
}

class _CenterLocationScreenState extends State<CenterLocationScreen> {
  String _locationMessage = "Fetch current location";

  @override
  void initState() {
    super.initState();
  }

  // Check and request permission
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
          _locationMessage = "Location permission denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = "Location permission permanently denied. Please enable it in settings.";
      });
      return;
    }

    _getLocation();
  }

  // Get current location
  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _locationMessage =
        "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      });

      // Example destination coordinates (replace with actual)
      openGoogleMaps(position.latitude, position.longitude, 26.8749, 75.7684);
    } catch (e) {
      setState(() {
        _locationMessage = "Error fetching location: $e";
      });
    }
  }

  // Open Google Maps
  void openGoogleMaps(
      double startLat, double startLng, double endLat, double endLng) async {
    final googleMapsUrl = Uri.parse(
        'google.navigation:q=$endLat,$endLng&origin=$startLat,$startLng&mode=d');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      final browserUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving');
      if (await canLaunchUrl(browserUrl)) {
        await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open the map.';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("center_location".tr, style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF9A1515),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _checkAndRequestPermission,
              child:  Text(
                'Click_below_to_fetch_your_location'.tr,
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Text(_locationMessage),
          ],
        ),
      ),
    );
  }
}
