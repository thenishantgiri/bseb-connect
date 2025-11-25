import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utilities/CustomColors.dart';
import 'PdfListScreen.dart';

class SubjectsScreen extends StatelessWidget {
   SubjectsScreen({Key? key}) : super(key: key);

  // Example subjects (You can fetch from API later)
  final List<String> subjects =  [
    "mathematics".tr,
    "physics".tr,
    "chemistry".tr,
    "biology".tr,
    "english".tr,
    "computer_science".tr
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(CustomColors.theme_orange),
        title:  Text("library_subjects".tr,style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(subjects[index]),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PdfListScreen(subjectName: subjects[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
