import 'package:flutter/material.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({Key? key}) : super(key: key);

  // Replace this with your actual timetable image URL
  final String timetableImageUrl = 'https://www.esaral.com/media/uploads/2019/12/CB-1-1.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Timetable', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF9A1515), // Theme color consistent with your app
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.network(
            timetableImageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Failed to load timetable image',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
