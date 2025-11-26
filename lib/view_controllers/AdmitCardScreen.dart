import 'dart:convert';

import 'package:bseb/utilities/Constant.dart';
import 'package:bseb/view_controllers/ShowAdmitCard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utilities/dio_singleton.dart';
import '../utilities/CustomColors.dart';
import '../utilities/SharedPreferencesHelper.dart';
import '../utilities/Utils.dart';

class AdmitCardScreen extends StatefulWidget {
  const AdmitCardScreen({Key? key}) : super(key: key);

  @override
  State<AdmitCardScreen> createState() => _AdmitCardScreenState();
}

class _AdmitCardScreenState extends State<AdmitCardScreen> {
  final Dio _dio = getDio(); // Use singleton Dio instance
  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();
  List<dynamic> admitCards = []; // To store the admit card data dynamically

  TextEditingController reg_controller = TextEditingController();
  TextEditingController dob_controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getAdmitCard();
    });
  }

  Future<void> _getAdmitCard() async {
    // if (reg_controller.text.isEmpty || dob_controller.text.isEmpty) {
    //   Utils.snackBarInfo(context, 'Enter valid inputs');
    //   return;
    // }

    // ✅ Registration number length check
    // if (reg_controller.text.length < 5) {
    //   Utils.snackBarInfo(context, 'Registration number must be at least 5 digits');
    //   return;
    // }

    // ✅ DOB check (at least 8 years old)
    // try {
    //   // Parse using same format
    //   final enteredDob = DateFormat('dd-MM-yyyy').parseStrict(dob_controller.text);
    //
    //   final today = DateTime.now();
    //   final eightYearsAgo = DateTime(today.year - 8, today.month, today.day);
    //
    //   if (enteredDob.isAfter(eightYearsAgo)) {
    //     Utils.snackBarInfo(context, 'Age must be at least 8 years');
    //     return;
    //   }
    // } catch (e) {
    //   Utils.snackBarInfo(context, 'Invalid date format');
    //   return;
    // }

    try {
      Utils.progressbar(context, CustomColors.theme_orange);
      final String apiUrl = Constant.BASE_URL + Constant.ADMIT_CARD_NEW;

      final response = await _dio.post(
        apiUrl,
        data: {
          // "RegistrationNumber": reg_controller.text.toString().trim(), // Use dynamic input if needed
          // "DOB": dob_controller.text.toString().trim() // Use dob_controller.text if needed
          "RegistrationNumber": "R-531010124-23", // Use dynamic input if needed
          "DOB": "20-01-2006" // Use dob_controller.text if needed
        },
      );

      Navigator.pop(context);
      if (response.statusCode == 200 && response.data['status'] == 1) {
        setState(() {
          // Parse the response data and populate the admitCards list
          admitCards = response.data['data']['data']['Table1'];
        });
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
        title: const Text("Admit Cards", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: reg_controller,
                        keyboardType: TextInputType.text,
                        cursorColor: const Color(CustomColors.theme_orange),
                        decoration: InputDecoration(
                          labelText: "Enter Registration Number",
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(CustomColors.theme_orange)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dob_controller,
                        readOnly: true,
                        cursorColor: const Color(CustomColors.theme_orange),
                        decoration: InputDecoration(
                          labelText: "Enter DOB",
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(CustomColors.theme_orange)),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  dob_controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _getAdmitCard();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(CustomColors.theme_orange),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("SUBMIT",style: TextStyle(
                        color: Colors.white, // White text
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: admitCards.isEmpty
                ? Center(child: Text(""))
                : ListView.builder(
              itemCount: admitCards.length,
              itemBuilder: (context, index) {
                final admitCard = admitCards[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(15),
                    // title: Text("Student ID: ${admitCard['studentid']}",
                    title: const Text("Practical Admit Card",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Click to view details'),
                    onTap: () {
                      // Navigate to the Full Screen WebView with the Admit Card details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenWebView(
                            htmlData: admitCard['admitcardString'],
                            intentFrom: "admitCard",
                            registrationNumber:reg_controller.text.toString().trim(),
                             dob:dob_controller.text.toString().trim()
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
