import 'package:bseb/utilities/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../utilities/CustomColors.dart';

class SyllabusScreen extends StatelessWidget {
  const SyllabusScreen({super.key});

  final List<Map<String, String>> syllabusList = const [
    {"title": "9th Syllabus", "file": "assets/pdfs/9th.pdf"},
    {"title": "10th Syllabus", "file": "assets/pdfs/10th.pdf"},
    {"title": "11th Syllabus", "file": "assets/pdfs/11th.pdf"},
    {"title": "12th Syllabus", "file": "assets/pdfs/12th.pdf"},
    {"title": "Others (Vividh) Syllabus", "file": "assets/pdfs/others.pdf"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Syllabus",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(CustomColors.theme_orange),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: syllabusList.length,
        itemBuilder: (context, index) {
          final item = syllabusList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Image.asset(
                "assets/pdfs/pdf_icon.png", // your own image/icon
                width: 40,
                height: 40,
              ),
              title: Text(
                item["title"]!,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PdfViewerScreen(title: item["title"]!, path: item["file"]!),
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

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final String path;

  const PdfViewerScreen({super.key, required this.title, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(CustomColors.theme_orange),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SfPdfViewer.asset(path),
    );
  }
}
