import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utilities/CustomColors.dart';

class VideoListScreen extends StatelessWidget {
  final String subjectName;
  const VideoListScreen({Key? key, required this.subjectName}) : super(key: key);

  static const Map<String, String> videoPlaylistUrls = {
    // Mathematics
    "Mathematics": "https://www.youtube.com/playlist?list=PLVLoWQFkZbhU5r5DlfxPc3gKw-QLLAvLn",
    "गणित": "https://www.youtube.com/playlist?list=PLVLoWQFkZbhU5r5DlfxPc3gKw-QLLAvLn",

    // Physics
    "Physics": "https://www.youtube.com/playlist?list=PLqjFFrfKcY5zko18yoJgFV0grYC68g3X0",
    "भौतिक विज्ञान": "https://www.youtube.com/playlist?list=PLqjFFrfKcY5zko18yoJgFV0grYC68g3X0",
  };

  @override
  Widget build(BuildContext context) {
    final playlistUrl = videoPlaylistUrls[subjectName];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(CustomColors.theme_orange),
        title:  Text("$subjectName Video Lectures",style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Center(
        child: playlistUrl != null
            ? ElevatedButton.icon(
          onPressed: () async {
            final uri = Uri.parse(playlistUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Could not open video playlist")),
              );
            }
          },
          icon: const Icon(Icons.play_circle_fill,color: Colors.white,),
          label: const Text("Open Video Lectures",style: TextStyle(color:  Colors.white),),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9A1515),
          ),
        )
            : const Text("No video lectures available for this subject"),
      ),
    );
  }
}
