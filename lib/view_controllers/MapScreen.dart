// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class WebViewScreen extends StatefulWidget {
//   final double startLat, startLng, endLat, endLng;
//
//   WebViewScreen({required this.startLat, required this.startLng, required this.endLat, required this.endLng});
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late WebViewController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController();
//     _controller.setJavaScriptMode(JavaScriptMode.unrestricted); // Enable JavaScript
//
//     _controller.setNavigationDelegate(
//       NavigationDelegate(
//         onPageStarted: (url) {
//           print("Page started loading: $url");
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&origin=${widget.startLat},${widget.startLng}&destination=${widget.endLat},${widget.endLng}&travelmode=driving';
//     return Scaffold(
//       appBar: AppBar(title: Text('Directions')),
//       body: WebViewWidget(
//         controller: _controller..loadRequest(Uri.parse(googleMapsUrl)),  // Convert String to Uri
//       ),    );
//   }
// }
