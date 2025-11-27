import 'package:bseb/utilities/Constant.dart';
import 'package:bseb/utilities/Utils.dart';
import 'package:bseb/view_controllers/AdmitCardScreen.dart';
import 'package:bseb/view_controllers/CenterLocationScreen.dart';
import 'package:bseb/view_controllers/ContactScreen.dart';
import 'package:bseb/view_controllers/ExamPrepration.dart';
import 'package:bseb/view_controllers/FAQScreen.dart';
import 'package:bseb/view_controllers/LoginScreen.dart';
import 'package:bseb/view_controllers/NotificationScreen.dart';
import 'package:bseb/view_controllers/ProfileScreen.dart';
import 'package:bseb/view_controllers/QuestionBankScreen.dart';
import 'package:bseb/view_controllers/SubjectsScreen.dart';
import 'package:bseb/view_controllers/TimetableScreen.dart';
import 'package:bseb/view_controllers/UpdateClassScreen.dart';
import 'package:bseb/view_controllers/VideoLectureScreen.dart';
import 'package:bseb/view_controllers/examEssentialsScreen.dart';
import 'package:bseb/view_controllers/form/FormScreen.dart';
import 'package:bseb/widgets/cached_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

import '../utilities/dio_singleton.dart';
import '../utilities/SharedPreferencesHelper.dart';
import 'CertificatesScreen.dart';
import 'MarkSheets.dart';

class Homescreen extends StatefulWidget {
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final Dio _dio = getDio(); // Use singleton Dio instance
  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();
  String _name = "";
  String _class = "";
  String _rollNo = "";
  String? imageUrl;
  String? unreadCount = "";

  // final List<Map<String, dynamic>> menuItems = [
  //   {"icon": Icons.person, "label": "profile".tr},
  //
  //   {"icon": Icons.book, "label": "results".tr},
  //   {"icon": Icons.card_travel, "label": "admit_card".tr},
  //   {"icon": Icons.location_on_rounded, "label": "center_location".tr},
  //
  //   {"icon": Icons.school, "label": "certificates".tr},
  //   // {"icon": Icons.history, "label": "History"},
  //   // {"icon": Icons.info, "label": "Information"},
  //   // {"icon": Icons.currency_rupee, "label": "Fee"},
  //   // {"icon": Icons.bar_chart, "label": "Examination Marks"},
  //   // {"icon": Icons.quiz, "label": "Preparation"},
  //   {"icon": Icons.quiz, "label": "exam_prep".tr},
  //   {"icon": Icons.notifications, "label": "notification".tr},
  //   {"icon": Icons.event_note, "label": "exam_form".tr},
  //   {"icon": Icons.library_books, "label": "e_library".tr},
  //   {"icon": Icons.videocam, "label": "video_lecture".tr},
  //   {"icon": Icons.newspaper_outlined, "label": "question_bank".tr},
  //   {"icon": Icons.list_alt, "label": "exam_schedule".tr},
  //   {"icon": Icons.announcement, "label": "announcements".tr},
  //   {"icon": Icons.help_outline, "label": "faqs".tr},
  //   {"icon": Icons.contact_page, "label": "support".tr},
  //
  //   // {"icon": Icons.support_agent, "label": "Support"},
  // ];
  final List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.person, "key": "profile", "label": "प्रोफ़ाइल"}, // Hindi
    {"icon": Icons.book, "key": "results", "label": "परिणाम"},
    // {"icon": Icons.card_travel, "key": "admit_card", "label": "प्रवेश पत्र"},
    {"icon": Icons.card_travel, "key": "exam_essentials", "label": "आवश्यकताएँ"},
    {"icon": Icons.location_on_rounded, "key": "center_location", "label": "केंद्र स्थान"},
    {"icon": Icons.school, "key": "certificates", "label": "प्रमाण पत्र"},
    {"icon": Icons.quiz, "key": "exam_prep", "label": "परीक्षा तैयारी"},
    {"icon": Icons.notifications, "key": "notification", "label": "सूचना"},
    {"icon": Icons.event_note, "key": "exam_form", "label": "परीक्षा फॉर्म"},
   // {"icon": Icons.videocam, "key": "video_lecture", "label": "वीडियो व्याख्यान"},
   // {"icon": Icons.newspaper_outlined, "key": "question_bank", "label": "प्रश्न बैंक"},
   // {"icon": Icons.list_alt, "key": "exam_schedule", "label": "परीक्षा समय सारिणी"},
   // {"icon": Icons.announcement, "key": "announcements", "label": "घोषणाएँ"},
    {"icon": Icons.help_outline, "key": "faqs", "label": "प्रश्नोत्तर"},
    {"icon": Icons.contact_page, "key": "support", "label": "सहायता"},
  ];

  @override
  void initState() {
    super.initState();
    initiate();
    // _getNotificationCount();
    _loadImageUrl();
    // initializeFCM();
    // loadInitialCount();
  }

  Future<void> initiate() async {
    // Await the future and assign the resolved value directly to the variable
    _name = await sharedPreferencesHelper.getPref(Constant.USER_NAME) ??
        ''; // Default to empty string if null
    _class = await sharedPreferencesHelper.getPref(Constant.CLASS) ?? '';
    _rollNo = await sharedPreferencesHelper.getPref(Constant.ROLL_NUMBER) ?? '';
    final url = sharedPreferencesHelper.getPref(Constant.IMAGE_URL);
  }

  void initializeFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("Message received: ${message.data}");
      _getNotificationCount();

    });
  }

  Future<void> _loadImageUrl() async {
    final String? url = await sharedPreferencesHelper.getPref("photoUrl");
    setState(() {
      // Only process if url is not null
      if (url != null && url.isNotEmpty) {
        imageUrl = url.trim();
      } else {
        imageUrl = null;
      }
    });

    debugPrint('Image URL loaded: $imageUrl');
  }

  Future<void> _getNotificationCount() async {
    try {
      // Utils.progressbar(context, CustomColors.theme_orange);
      final String apiUrl = Constant.BASE_URL + Constant.GET_NOTIFICATION_COUNT;

      final response = await _dio.post(
        apiUrl,
        data: {
          'Student_Id': await sharedPreferencesHelper.getPref(Constant.USER_ID) ?? '',
          // "Student_Id":3
        },
      );
      // Navigator.pop(context);
      if (response.statusCode == 200 && response.data['status'] == 1) {
        if (response.data['data']['UnreadCount'] != 0) {
          setState(() {
            unreadCount = response.data['data']['UnreadCount'].toString();
          });
        } else {
          setState(() {
            unreadCount = "";
          });
        }
        // Utils.snackBarSuccess(context, response.data['message']);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF9A1515),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "home".tr,
          style: const TextStyle(
            fontSize: 19,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Image.asset(
            'assets/images/app_logo.png',
            height: 25,
            width: 25,
          ),
        ),
        actions: [
          // 🔔 Notifications
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),

          // ⋮ Language menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (langCode) {
              final locale = Locale(langCode);
              sharedPreferencesHelper.setPref("lang", langCode); // save only code
              Get.updateLocale(locale);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "en",
                child: Row(
                  children: [
                    if (Get.locale?.languageCode == "en")
                      const Icon(Icons.check, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    const Text("English"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "hi",
                child: Row(
                  children: [
                    if (Get.locale?.languageCode == "hi")
                      const Icon(Icons.check, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    const Text("हिंदी"),
                  ],
                ),
              ),
            ],
          ),
          Builder(
            builder: (context) {
              return IconButton(
                icon: Image.asset(
                  'assets/images/drawer_icon.png',
                  height: 24,
                  width: 24,
                  color: Colors.white,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF9A1515), // same as theme_orange
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedProfileImage(
                    imageUrl: imageUrl,
                    radius: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Text(
                  //   "roll_no $_rollNo",
                  //   style: const TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 12,
                  //   ),
                  // ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, "home".tr, () => Navigator.pop(context)),
            _buildDrawerItem(Icons.person, "profile".tr, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ProfileScreen()));
            }),
            _buildDrawerItem(Icons.book, "results".tr, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => MarksheetScreen()));
            }),

            _buildDrawerItem(Icons.card_travel, "exam_essentials".tr, () {
              Utils.navigateToPage(context, ExamEssentialsScreen());
            }),
            _buildDrawerItem(Icons.school, "certificates".tr, () {
              print('Certificates tapped');
            }),
            // _buildDrawerItem(Icons.history, "History", () {
            //   print('History tapped');
            // }),
            // _buildDrawerItem(Icons.info, "Information", () {
            //   print('Information tapped');
            // }),
            // _buildDrawerItem(Icons.currency_rupee, "Fee", () {
            //   print('Fee tapped');
            // }),
            // _buildDrawerItem(Icons.bar_chart, "Examination Marks", () {
            //   print('Examination Marks tapped');
            // }),
            _buildDrawerItem(Icons.quiz, "exam_prep".tr, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ExamPrepration()));
            }),

            _buildDrawerItem(Icons.location_on_rounded, "center_location".tr, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CenterLocationScreen()));
            }),

            _buildDrawerItem(Icons.notifications, "notification".tr, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => NotificationScreen()));
            }),
            _buildDrawerItem(Icons.event_note, "exam_form".tr, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ExamFormScreen()));
            }),
            _buildDrawerItem(Icons.flight_class_outlined, "Upgrade Class".tr, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UpdateClassScreen()));
            }),
            _buildDrawerItem(Icons.contacts, "support".tr, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ContactScreen()));
            }),





            //    {"icon": Icons.list_alt, "label": "Schedule"},
            // _buildDrawerItem(Icons.list_alt, "exam_schedule".tr, () {
            //   Navigator.push(context,
            //       MaterialPageRoute(builder: (_) => TimetableScreen()));
            // }),
            // _buildDrawerItem(Icons.announcement, "announcements".tr, () {
            //   print('Announcements tapped');
            // }),
            _buildDrawerItem(Icons.help_outline, "faqs".tr, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FAQscreen()));
            }),

            // _buildDrawerItem(Icons.support_agent, "Supports", () {
            //   print('Supports tapped');
            // }),
            const Divider(),
            _buildDrawerItem(Icons.logout, "logout".tr, () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginScreen()));
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/background.png'),
                // <-- your background image
                fit: BoxFit.none,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                CachedProfileImage(
                  imageUrl: imageUrl,
                  radius: 40,
                ),
                const SizedBox(height: 12),
                 Text(
                  "welcome_back".tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Container(
            height: 40,
            color: Color(0xFF9A1515),
            child: Marquee(
              text: [
                "bseb_marquee_1".tr,
                "bseb_marquee_2".tr,
                "bseb_marquee_3".tr
              ].join("           "),
              // separator between news items
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              blankSpace: 50,
              velocity: 50,
              pauseAfterRound: Duration(seconds: 2),
              startPadding: 10,
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: GridView.builder(
            itemCount: menuItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return GestureDetector(
                onTap: () {
                  _handleMenuTap(context, item["key"].toString().tr); // ✅ always use key
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            item["icon"],
                            size: 30,
                            color: Colors.black.withOpacity(0.3), // shadow
                          ),
                          Icon(
                            item["icon"],
                            size: 30,
                            color: Colors.brown[700], // foreground
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item["key"].toString().tr, // ✅ auto from translation file
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),

          // 🔴 Bottom Running Notification (Marquee)
        ],
      ),
    );
  }

  Widget _newsChip(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _handleMenuTap(BuildContext context, String label) {
    print("object"+label);
    switch (label) {
      case "Profile":
      case "प्रोफ़ाइल":
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        break;

     case "Certificates":
     case "प्रमाण पत्र":
        print("Tapped on: $label");
        // Utils.snackBarSuccess(context, "$label Coming soon");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CertificateScreen()));
        break;


     case "Exam Preparation":
     case "परीक्षा तैयारी":
     //   print("Tapped on: $label");
       Navigator.push(context,
           MaterialPageRoute(builder: (context) => ExamPrepration()));
        break;

      case "Announcements":
        Utils.snackBarSuccess(context, "$label Coming soon");
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        break;
      case "Results":
      case "परिणाम":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MarksheetScreen()));
        break;
      case "Support/Helpdesk":
      case "सहायता":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ContactScreen()));
        break;
      case "Preview Filled Form":
      case "परीक्षा फॉर्म":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ExamFormScreen()));
        break;
      case "Exam Essentials":
      case "परीक्षा आवश्यकताएँ":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ExamEssentialsScreen()));
        break;
      case "Resources and FAQ":
      case "सामान्य प्रश्न":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FAQscreen()));
        break;

      case "Exam Center Location":
      case "परीक्षा केंद्र स्थान":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CenterLocationScreen()));
        break;
      case "Notification and Alerts":
      case "सूचना":
        unreadCount = '';
        setState(() {});
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => NotificationScreen()));
        break;
      default:
        print("Tapped on: $label");
        Utils.snackBarSuccess(context, "$label Coming soon");


    }
  }
  // void _handleMenuTap(BuildContext context, String key) {
  //   switch (key) {
  //     case "profile":
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
  //       break;
  //
  //     case "certificates":
  //       print("Certificates tapped");
  //       break;
  //
  //     case "exam_prep":
  //       print("Exam Prep tapped");
  //       break;
  //
  //     case "announcements":
  //       // Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
  //       break;
  //
  //     case "results":
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => MarksheetScreen()));
  //       break;
  //
  //     case "support":
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => ContactScreen()));
  //       break;
  //
  //     case "exam_form":
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => ExamFormScreen()));
  //       break;
  //
  //     case "admit_card":
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => AdmitCardScreen()));
  //       break;
  //
  //     case "faqs":
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => FAQscreen()));
  //       break;
  //
  //     case "center_location":
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => CenterLocationScreen()));
  //       break;
  //
  //     case "e_library":
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectsScreen()));
  //       break;

  //     case "question_bank":
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => QuestionBankScreen()));
  //       break;
  //
  //     case "exam_schedule":
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => TimetableScreen()));
  //       break;
  //
  //     case "notification":
  //       unreadCount = '';
  //       setState(() {});
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
  //       break;
  //
  //     default:
  //       print("Tapped on: $key");
  //   }
  // }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF9A1515)), // theme_orange
      title: Text(title),
      onTap: onTap,
    );
  }
}
