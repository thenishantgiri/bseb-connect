import 'package:flutter/material.dart';
import '../utilities/CustomColors.dart';
import '../utilities/Utils.dart'; // your openUrl function

class PdfListScreen extends StatelessWidget {
  final String subjectName;
   PdfListScreen({Key? key, required this.subjectName}) : super(key: key);

  // Example PDFs for demo (You can fetch from API per subject)
  final Map<String, List<Map<String, String>>> pdfData = {
    // Mathematics
    "Mathematics": [
      {
        "title": "NCERT Maths Class 12 Part I (PDF)",
        "url": "https://ncert.nic.in/textbook/pdf/leph2ps.pdf"
      },
      {
        "title": "NCERT Maths Full Book – Download",
        "url": "https://ncertbooks.guru/ncert-books-class-12/physics/"
      },
    ],
    "गणित": [
      {
        "title": "NCERT Maths Class 12 Part I (PDF)",
        "url": "https://ncert.nic.in/textbook/pdf/leph2ps.pdf"
      },
      {
        "title": "NCERT Maths Full Book – Download",
        "url": "https://ncertbooks.guru/ncert-books-class-12/physics/"
      },
    ],

    // Physics
    "Physics": [
      {
        "title": "NCERT Physics Class 12 Part I (chapter-wise PDFs)",
        "url": "https://www.studiestoday.com/download-books/449/physics.html"
      },
      {
        "title": "NCERT Physics PDFs (Educart 2025-26)",
        "url": "https://www.educart.co/ncert/ncert-books-class-12-physics"
      },
    ],
    "भौतिक विज्ञान": [
      {
        "title": "NCERT Physics Class 12 Part I (chapter-wise PDFs)",
        "url": "https://www.studiestoday.com/download-books/449/physics.html"
      },
      {
        "title": "NCERT Physics PDFs (Educart 2025-26)",
        "url": "https://www.educart.co/ncert/ncert-books-class-12-physics"
      },
    ],

    // Chemistry
    "Chemistry": [
      {
        "title": "NCERT Chemistry PDFs (StudieToday)",
        "url": "https://www.studiestoday.com/download-books/447/chemistry.html"
      },
      {
        "title": "NCERT Chemistry PDFs (Educart)",
        "url": "https://www.educart.co/ncert/ncert-books-class-12-chemistry"
      },
    ],
    "रसायन विज्ञान": [
      {
        "title": "NCERT Chemistry PDFs (StudieToday)",
        "url": "https://www.studiestoday.com/download-books/447/chemistry.html"
      },
      {
        "title": "NCERT Chemistry PDFs (Educart)",
        "url": "https://www.educart.co/ncert/ncert-books-class-12-chemistry"
      },
    ],

    // Biology
    "Biology": [
      {
        "title": "NCERT Biology PDF downloads",
        "url": "https://ncertbooks.guru/ncert-books-for-class-12/"
      },
      {
        "title": "NCERT Official Textbooks Portal",
        "url": "https://ncert.nic.in/textbook.php?lech1=0-9"
      },
    ],
    "जीव विज्ञान": [
      {
        "title": "NCERT Biology PDF downloads",
        "url": "https://ncertbooks.guru/ncert-books-for-class-12/"
      },
      {
        "title": "NCERT Official Textbooks Portal",
        "url": "https://ncert.nic.in/textbook.php?lech1=0-9"
      },
    ],

    // English
    "English": [
      {
        "title": "NCERT English Textbooks (Class 12)",
        "url": "https://ncertbooks.guru/ncert-books-for-class-12/"
      },
    ],
    "अंग्रेज़ी": [
      {
        "title": "NCERT English Textbooks (Class 12)",
        "url": "https://ncertbooks.guru/ncert-books-for-class-12/"
      },
    ],

    // Computer Science
    "Computer Science": [
      {
        "title": "NCERT Computer Science PDFs (if available)",
        "url": "https://ncertbooks.guru/ncert-books-for-class-12/"
      },
    ],
    "कंप्यूटर विज्ञान": [
      {
        "title": "NCERT Computer Science PDFs (if available)",
        "url": "https://ncertbooks.guru/ncert-books-for-class-12/"
      },
    ],
  };


  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> subjectPdfs = pdfData[subjectName] ?? [];

    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(CustomColors.theme_orange),
        title:  Text("$subjectName Books & Notes",style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: subjectPdfs.isEmpty
          ? const Center(child: Text("No PDFs available"))
          : ListView.builder(
        itemCount: subjectPdfs.length,
        itemBuilder: (context, index) {
          final pdf = subjectPdfs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(pdf["title"] ?? "Untitled"),
              trailing: IconButton(
                icon: const Icon(Icons.download, color: Color(0xFF9A1515)),
                onPressed: () {
                  if (pdf["url"] != null) {
                    Utils.openUrl(pdf["url"]!);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
