
import 'package:bseb/utilities/Utils.dart';
import 'package:bseb/view_controllers/SyllabusScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utilities/CustomColors.dart';
import 'QuestionBankScreen.dart';
import 'SamplePaper.dart';
import 'SubjectsScreen.dart';
import 'VideoLectureScreen.dart';

// Replace with your own color class if you have it


class ExamPrepration extends StatefulWidget {
  const ExamPrepration({super.key});

  @override
  State<ExamPrepration> createState() => _ExamPreprationState();
}

class _ExamPreprationState extends State<ExamPrepration> {
  Widget buildButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(CustomColors.theme_orange), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(CustomColors.theme_orange),
        title:  Text(
          "exam_preparation".tr,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding:  EdgeInsets.symmetric(vertical: 20),
        children: [
          buildButton(context, "syllabus".tr, Icons.menu_book, () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SyllabusScreen()));


            // Navigate or action
          }),
          buildButton(context, "e_library".tr, Icons.library_books, () {

            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SubjectsScreen()));
            // Navigate or action
          }),
          buildButton(context, "video_lectures".tr, Icons.play_circle_fill, () {

            Navigator.push(
                context, MaterialPageRoute(builder: (_) => VideoLectureScreen()));
            // Navigate or action
          }),
          buildButton(context, "question_bank".tr, Icons.question_answer, () {

            Navigator.push(
                context, MaterialPageRoute(builder: (_) => QuestionBankScreen()));
            // Navigate or action
          }),
          buildButton(context, "previous_years".tr, Icons.history_edu, () {
            // Navigate or action

            Utils.snackBarSuccess(context, "Previous Years Coming soon");

          }),

          buildButton(context, "How to cope with exam pressure", Icons.boy, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PdfViewerScreen(title: "How To Cope With Exam Pressure", path: "assets/pdfs/copeup.pdf"),
              ),
            );
          }), buildButton(context, "Exam Preparation Guidelines", Icons.newspaper_sharp, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PdfViewerScreen(title: "Exam Preparation Guidelines", path: "assets/pdfs/one.pdf"),
              ),
            );
          }), buildButton(context, "Effective exam techniques", Icons.format_align_justify, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PdfViewerScreen(title: "Effective exam techniques", path: "assets/pdfs/two.pdf"),
              ),
            );
          }), buildButton(context, "Checklist of items to carry for the exam", Icons.format_indent_increase, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PdfViewerScreen(title: "Checklist of items to carry for the exam", path: "assets/pdfs/three.pdf"),
              ),
            );
          }), buildButton(context, "Sample papers", Icons.newspaper_sharp, () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => SamplePaper()));
          }),
        ],
      ),
    );
  }
}
