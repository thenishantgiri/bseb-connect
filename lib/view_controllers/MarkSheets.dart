import 'package:bseb/utilities/CustomColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 👈 make sure you are using GetX for translations

import '../utilities/dio_singleton.dart';
import '../utilities/Constant.dart';
import '../utilities/SharedPreferencesHelper.dart';
import '../utilities/Utils.dart';
import 'ShowAdmitCard.dart';

class MarksheetScreen extends StatefulWidget {
  @override
  State<MarksheetScreen> createState() => _MarksheetScreenState();
}

class _MarksheetScreenState extends State<MarksheetScreen> {
  final Dio _dio = getDio(); // Use singleton Dio instance
  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();
  String markSheetHtml = "";
  List<Map<String, dynamic>> markSheets = [
    {'type': 'general_result'.tr, 'id': '1', 'admitCardUrl': 'https://example.com/admitcard1'},
    {'type': 'supplementary_result'.tr, 'id': '2', 'admitCardUrl': 'https://example.com/admitcard2'},
    // {'type': 'reexam_result'.tr, 'id': '3', 'admitCardUrl': 'https://example.com/admitcard3'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getMarkSheet();
    });
  }

  Future<void> _getMarkSheet() async {
    try {
      Utils.progressbar(context, CustomColors.theme_orange);
      const String apiUrl = Constant.BASE_URL + Constant.SHOW_MARKSHEET;

      final response = await _dio.post(
        apiUrl,
        data: {
          'StudentId': 4,
        },
      );
      Navigator.pop(context);
      if (response.statusCode == 200 && response.data['status'] == 1) {
        setState(() {});
        markSheetHtml = response.data['data']['data']['Table1'][0]['marksheet_string'];
      } else {
        Utils.snackBarError(context, response.data['message']);
      }
    } catch (e) {
      Navigator.pop(context);
      Utils.snackBarError(context, 'Catch Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(CustomColors.theme_orange),
        title: Text("result".tr, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: markSheets.length,
        itemBuilder: (context, index) {
          final admitCard = markSheets[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              title: Text(admitCard['type'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("click_to_view_details".tr),
              onTap: () {
                switch (markSheets[index]["id"]) {
                  case "1":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenWebView(
                          htmlData: markSheetHtml,
                          intentFrom: "markSheets",
                          registrationNumber: '',
                          dob: '',
                        ),
                      ),
                    );
                    break;
                  default:
                    Utils.snackBarSuccess(context, "work_in_progress".tr);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
