import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../utilities/Constant.dart';
import '../utilities/CustomColors.dart';
import '../utilities/SharedPreferencesHelper.dart';
import 'EditProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();

  // student profile fields
  String? imageUrl;
  String? signatureUrl;
  String? userName;
  String? rollNumber;
  String? rollCode;
  String? userClass;
  String? gender;
  String? dob;
  String? phone;
  String? email;
  String? fatherName;
  String? motherName;
  String? caste;
  String? religion;
  String? maritalStatus;
  String? differentlyAbled;
  String? stream;
  String? registrationNumber;
  String? schoolName;
  String? udiseCode;
  String? address;
  String? state;
  String? district;
  String? block;
  String? aadhar;

  @override
  void initState() {
    super.initState();
    _loadProfileDetails();
  }

  Future<void> _loadProfileDetails() async {
    userName = await sharedPreferencesHelper.getPref("FullName");
    email = await sharedPreferencesHelper.getPref("Email");
    userClass = await sharedPreferencesHelper.getPref("Class");
    phone = await sharedPreferencesHelper.getPref("Phone");
    rollCode = await sharedPreferencesHelper.getPref("RollCode");
    rollNumber = await sharedPreferencesHelper.getPref("RollNumber");
    imageUrl = await sharedPreferencesHelper.getPref("Photo");
    imageUrl = imageUrl!
        .trim()
        .replaceAll(' ', '')
        .replaceAll('studentprofile', 'signature');

    signatureUrl = await sharedPreferencesHelper.getPref("SignaturePhoto");
    fatherName = await sharedPreferencesHelper.getPref("FatherName");
    motherName = await sharedPreferencesHelper.getPref("MotherName");
    dob = await sharedPreferencesHelper.getPref("Dob");
    gender = await sharedPreferencesHelper.getPref("Gender");
    caste = await sharedPreferencesHelper.getPref("Caste");
    religion = await sharedPreferencesHelper.getPref("Religion");
    maritalStatus = await sharedPreferencesHelper.getPref("MaritalStatus");
    differentlyAbled = await sharedPreferencesHelper.getPref("DifferentlyAbled");
    stream = await sharedPreferencesHelper.getPref("Stream");
    registrationNumber = await sharedPreferencesHelper.getPref("RegistrationNumber");
    schoolName = await sharedPreferencesHelper.getPref("SchoolName");
    udiseCode = await sharedPreferencesHelper.getPref("UdiseCode");
    address = await sharedPreferencesHelper.getPref("FullAddress");
    state = await sharedPreferencesHelper.getPref("State");
    district = await sharedPreferencesHelper.getPref("Distic");
    block = await sharedPreferencesHelper.getPref("Block");
    aadhar = await sharedPreferencesHelper.getPref("AddharNumber");

    setState(() {});


    print("dfdsfdsfs"+signatureUrl.toString());
    print("dfdsfdssdsdfs"+imageUrl.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color(CustomColors.theme_orange),
        title:  Text("profile_title".tr, style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // top banner
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bseb_bg_new.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                height: 180,
                color: Colors.black.withOpacity(0.5),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage:
                            imageUrl != null
                               ? NetworkImage(imageUrl!)
                               :
                              const AssetImage('assets/images/john.jpg') as ImageProvider,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userName ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                  "${"class".tr} ${userClass ?? ''} | ${"roll".tr} ${rollNumber ?? ''}",
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              if (userClass == "12th")
                                Text(
                                  "stream: ${stream ?? ''}".tr,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => EditProfileScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // parents info
            // InfoCard(title: "fathers_info".tr, name: fatherName ?? '', phone: phone ?? '', email: email ?? ''),
            // InfoCard(title: "mothers_info".tr, name: motherName ?? '', phone: phone ?? '', email: email ?? ''),

            // student info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      "students_info".tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(CustomColors.theme_orange),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoRow(label:  "fathers_info".tr, value: fatherName ?? ''),
                    InfoRow(label: "mothers_info".tr, value: motherName ?? ''),

                    InfoRow(label: 'class'.tr, value: userClass ?? ''),
                    InfoRow(label: 'date_of_birth'.tr, value: dob ?? ''),
                    InfoRow(label: 'gender'.tr, value: gender ?? ''),
               //     InfoRow(label: 'aadhar_number'.tr, value: aadhar ?? ''),
                    InfoRow(label: 'caste'.tr, value: caste ?? ''),
                    InfoRow(label: 'religion'.tr, value: religion ?? ''),
                    InfoRow(label: 'differently_abled'.tr, value: differentlyAbled ?? ''),
                    InfoRow(label: 'marital_status'.tr, value: maritalStatus ?? ''),

                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Academic".tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(CustomColors.theme_orange),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoRow(label: 'roll_number'.tr, value: rollNumber ?? ''),
                    InfoRow(label: 'roll_code'.tr, value: rollCode ?? ''),
                    InfoRow(label: 'class'.tr, value: userClass ?? ''),
                    InfoRow(label: 'registration_no'.tr, value: registrationNumber ?? ''),
                    InfoRow(label: 'school_name'.tr, value: schoolName ?? ''),
                    //           InfoRow(label: 'udise_code'.tr, value: udiseCode ?? ''),
                    // InfoRow(label: 'block'.tr, value: block ?? ''),
                    // InfoRow(label: 'district'.tr, value: district ?? ''),
                    // InfoRow(label: 'state'.tr, value: state ?? ''),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "address".tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(CustomColors.theme_orange),
                      ),
                    ),
                    const SizedBox(height: 8),

                    InfoRow(label: 'address'.tr, value: address ?? ''),
                    InfoRow(label: 'block'.tr, value: block ?? ''),
                    InfoRow(label: 'district'.tr, value: district ?? ''),
                    InfoRow(label: 'state'.tr, value: state ?? ''),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String name;
  final String phone;
  final String email;

  const InfoCard({
    required this.title,
    required this.name,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(CustomColors.theme_orange),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Color(CustomColors.theme_orange)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    // Text('Mobile Number : $phone'),
                    // Text('Email : $email'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label :',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
