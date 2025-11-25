import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utilities/CustomColors.dart';

class QuestionBankScreen extends StatelessWidget {
  const QuestionBankScreen({Key? key}) : super(key: key);

  static  Map<String, String> questionBankData = {
    "mathematics".tr: "https://biharboardonline.com/files/121_327_Mathematics.pdf",
    "chemistry".tr: "https://biharboardonline.com/files/118_Chemistry.pdf",
    "biology".tr: "https://biharboardonline.com/files/119_Bilology.pdf",
    "english".tr: "https://biharboardonline.com/files/105_124_205_223-English.pdf",
    "computer_science".tr: "https://biharboardonline.com/files/122_221_328_Computer%20Science.pdf",
    "economics".tr: "https://biharboardonline.com/files/219_Economics.pdf",
    "accountancy".tr: "https://biharboardonline.com/files/220_Accountancey.pdf",
    "business_btudies".tr: "https://biharboardonline.com/files/217_Business%20Studies.pdf",
    // More subjects...
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(CustomColors.theme_orange),
        title: const Text("Question Bank",style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: ListView(
        children: questionBankData.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(entry.key),
              trailing: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
              onTap: () async {
                final uri = Uri.parse(entry.value);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to open PDF link")),
                  );
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
