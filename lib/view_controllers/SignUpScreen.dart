import 'dart:io';
import 'dart:typed_data'; // ✅ correct import
import 'package:flutter/material.dart';
import 'package:bseb/utilities/Constant.dart';
import 'package:bseb/utilities/CustomColors.dart';
import 'package:bseb/utilities/Utils.dart';
import 'package:bseb/view_controllers/OtpScreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bseb/controllers/auth_controller.dart';
import 'package:flutter/services.dart'; // required for input formatters

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  File? _selectedPhoto;
  File? _selectedSignature;

  final AuthController _authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _rollCodeController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _udiseController = TextEditingController();
  final TextEditingController _streamController = TextEditingController();

  String? selectedClass;
  String? selectedGender;
  String? selectedState;
  String? selectedDivisions;
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedSchool;
  String? selectedCaste;
  String? selectedReligion;
  String? selectedDifferentlyAbled;
  String? selectedArea;
  String? selectedMaritalStatus;
  String? filePath;

  // String? fileName;
  String? fileNamePhoto;
  String? fileNameSignature;
  List<String> blockList = [];

  final List<String> classList = ["9th", "10th","11th", "12th", "other"];
  final List<String> genderList = ["Male", "Female", "Transgender"];
  final List<String> casteCategories = ["General", "OBC", "SC", "ST", "EWS"];
  final List<String> differentlyAbled = ["Yes", "No"];
  final List<String> religions = [
    "Hindu", "Muslim", "Jain", "Sikh", "Bauddh", "Christ", "Other"];
  final List<String> areas = ["Rural", "Urban"];
  final List<String> maritalStatus = ["Married", "Unmarried"];
  final List<String> divisionList = ["PURNIA", "MUNGER", "BHAGALPUR", "KOSHI", "TIRHUT", "DARBHANGA", "PATNA", "MAGADH", "SARAN"];

  final Map<String, List<String>> divisionDistrictMap = {
    "PURNIA": ["Purnia", "Araria", "Kishanganj", "Katihar"],
    "MUNGER": ["Munger", "Jamui", "Lakhisarai", "Sheikhpura", "Khagaria", "Begusarai"],
    "BHAGALPUR": ["Bhagalpur", "Banka"],
    "KOSHI": ["Saharsa", "Supaul", "Madhepura"],
    "TIRHUT": ["Muzaffarpur", "Sitamarhi", "Vaishali", "Bettiah (W. Champaran)", "Motihari (E. Champaran)", "Sheohar"],
    "DARBHANGA": ["Darbhanga", "Madhubani", "Samastipur"],
    "PATNA": ["Patna", "Nalanda", "Bhojpur", "Rohtas", "Buxar", "Bhabhua"],
    "MAGADH": ["Gaya", "Nawada", "Aurangabad", "Jehanabad", "Arwal"],
    "SARAN": ["Saran", "Siwan", "Gopalganj"],
  };

  final List<String> districtList = [
    "Araria", "Arwal", "Aurangabad", "Banka", "Begusarai", "Bhagalpur", "Darbhanga", "East Champaran (Motihari)", "Gaya",
    "Gopalganj", "Jamui", "Jehanabad", "Bhojpur", "Buxar", "Kaimur (Bhabua)", "Katihar", "Khagaria", "Kishanganj", "Lakhisarai", "Vaishali", "West Champaran (Bettiah)"
        "Madhepura", "Madhubani", "Munger", "Muzaffarpur", "Nalanda", "Nawada", "Patna",
    "Purnia", "Rohtas", "Saharsa", "Samastipur", "Saran", "Sheikhpura", "Sheohar", "Sitamarhi", "Siwan", "Supaul",
  ];
  final Map<String, List<String>> blockMap = {
    "Patna": [
      "Patna Sadar", "Sampatchak", "Phulwarisharif", "Fatwah", "Daniyawan", "Khusrupur", "Bihta", "Naubatpur", "Paliganj", "Barh", "Mokama",
      "Masaurhi", "Punpun", "Maner", "Danapur", "Bikram", "Bakhtiyarpur", "Pandarak", "Fatuha", "Daniawan", "Khusrupur", "Athmalgola",
      "Belchhi", "Ghoswari", "Dulhinbazar"],
    "Gaya": [
      "Gaya Sadar", "Belaganj", "Wazirganj", "Manpur", "Bodhgaya", "Tankuppa", "Fatehpur", "Tekari",
      "Konch", "Tekari", "Guraru", "Paraiya", "Neemchak Bathani", "Khizarsarai", "Atri", "Bathani",
      "Mohra", "Sherghati", "Gurua", "Amas", "Banke Bazar", "Imamganj", "Dumariya", "Sherghati",
      "Dobhi", "Mohanpur", "Barachatti"
    ],
    "Nalanda": [
      "Bihar Sharif", "Bind", "Chandi", "Ekangarsarai", "Giriyak", "Harnaut", "Hilsa",
      "Islampur", "Karai Parsurai", "Katrisarai", "Noorsarai", "Parbalpur", "Rahui",
      "Rajgir", "Sarmera", "Silao", "Tharthari"
    ],
    "Araria": [
      "Araria", "Kursakatta", "Palasi", "Raniganj", "Forbesganj", "Jokihat", "Dholbaja", "Phulbari", "Sikti"
    ],
    "Arwal": ["Arwal", "Kaler", "Kochas", "Nawanagar", "Sadar"],
    "Aurangabad": ["Aurangabad", "Barun", "Obra", "Dev", "Rafiganj", "Haspura", "Madankaur", "Kutumbba", "Daudnagar", "Nabinagar", "Kaler"
    ],
    "Banka": ["Banka", "Amarpur", "Bounsi", "Chandankyari", "Dhoraiya", "Katoria", "Kharagpur", "Jama", "Raghunathganj", "Shambhuganj", "Sultanganj"
    ],
    "Begusarai": ["Begusarai", "Bachhwara", "Chhaurahi", "Dandari", "Gadhpura", "Gidhaur", "Kharik", "Matihani", "Mokama", "Nawada", "Phulwaria", "Sadar"
    ],
    "Bhagalpur": ["Bhagalpur", "Goradih", "Jagdishpur", "Nathnagar", "Sabour","Shahkund", "Sultanganj", "Kahalgaon", "Pirpainty", "Sanhaula"
    ],
    "Bhojpur": [
      "Arrah", "Jagdispur", "Koilwar", "Sahar", "Barhara", "Sandesh", "Charpokhari", "Piro", "Tarari", "Bihia", "Agiawon", "Garhani"
    ],
    "Buxar": ["Buxar", "Dumraon", "Simari", "Brahmpur", "Rajpur", "Itarhi", "Nawanagar", "Chaungain", "Chausa", "Chakki", "Kesath"
    ],
    "Darbhanga": ["Darbhanga", "Bahadurpur", "Biraul", "Benipur", "Biraul", "Jale", "Kusheshwar Asthan", "Kusheshwar Sthan", "Madhubani", "Manigachhi", "Mushari", "Pachrukhi", "Singhwara", "Tardih"
    ],
    "East Champaran (Motihari)": [
      "Motihari", "Areraj", "Chakia", "Dhaka", "Harsidhi", "Kalyanpur", "Madhuban", "Paharpur", "Raxaul", "Turkaulia", "Adapur", "Chiraia", "Paharpur", "Raxaul"
    ],
    "Gopalganj": [
      "Gopalganj", "Baikunthpur", "Barauli", "Bishambharpur", "Kuchaikote", "Manjha", "Maharajganj", "Pachrukhi", "Sadar", "Saraiya", "Udwantnagar"
    ],
    "Jamui": ["Jamui", "Chakai", "Gidhaur", "Jhajha", "Khaira", "Lakhisarai", "Munger", "Madhupur", "Sadar"
    ],
    "Jehanabad": [
      "Jehanabad", "Makhdumpur", "Kako", "Ratnifridpur", "Hulasganj", "Modanganj", "Kauakol", "Varsaliganj"
    ],
    "Kaimur (Bhabua)": [
      "Bhabua", "Ramgarh", "Mohania", "Durgawati", "Adhaura", "Bhagwanpur", "Chand", "Chainpur", "Kudra", "Rampur", "Nuawon", "Nauhatta"
    ],
    "Katihar": [
      "Katihar", "Amdabad", "Barsoi", "Dandkhora", "Hirmin", "Islampur", "Kushmudi", "Kursela", "Mansahi", "Pranpur", "Saharsa", "Supaul"
    ],
    "Khagaria": ["Khagaria", "Alamnagar", "Bihariganj", "Chousa", "Gamhariya", "Ghelardh", "Gwalpara", "Kumarkhand", "Madhepura"
    ],
    "Kishanganj": ["Kishanganj", "Bahadurganj", "Chhatapur", "Dighalbank", "Kishanganj", "Kumargram", "Purnia", "Supaul"
    ],
    "Lakhisarai": ["Lakhisarai", "Chanan", "Karma", "Kharagpur", "Lakhisarai", "Munger", "Madhupur", "Sadar"
    ],
    "Madhepura": ["Madhepura", "Alamnagar", "Bihariganj", "Chousa", "Gamhariya", "Ghelardh", "Gwalpara", "Kumarkhand", "Madhepura"
    ],
    "Madhubani": [
      "Madhubani", "Benipur", "Bisfi", "Brahmpur", "Chandpura", "Chandpura", "Chandpura", "Chandpura", "Chandpura", "Chandpura"
    ],
    "Munger": ["Munger", "Lakhisarai", "Madhupur", "Sadar"],
    "Muzaffarpur": [
      "Muzaffarpur", "Belsand", "Biraul", "Kanti","Madhubani", "Madhubani", "Madhubani"
    ],
    "Nalanda": [
      "Bihar Sharif", "Bind", "Chandi","Ekangarsarai", "Giriyak", "Harnaut", "Hilsa", "Islampur", "Karai Parsurai", "Katrisarai", "Noorsarai", "Parbalpur", "Rahui", "Rajgir",
      "Sarmera", "Silao", "Tharthari"
    ],
    "Nawada": ["Nawada", "Rajouli", "Hisua", "Narhat", "Govindpur", "Pakribarawan",
      "Sirdalla", "Kasichak", "Roh", "Nardiganj", "Meskaur", "Madanpur", "Kutumbba", "Daudnagar", "Aurangabad", "Barun", "Obra", "Dev"
    ],
    "Pashchim Champaran (Bettiah)": [
      "Bettiah", "Bairgania", "Belsand", "Riga", "Sursand", "Pupri", "Sonbarsa", "Dumra", "Runni saidpur", "Majorganj", "Suppi", "Parsauni", "Bokhra", "Chorout", "Sheohar"
    ],
    "Patna": [
      "Patna Sadar", "Sampatchak", "Phulwarisharif", "Fatwah", "Daniyawan", "Khusrupur", "Bihta", "Naubatpur", "Paliganj", "Barh", "Mokama", "Masaurhi", "Punpun", "Maner", "Danapur", "Bikram",
      "Bakhtiyarpur", "Pandarak", "Fatuha", "Daniawan", "Khusrupur", "Athmalgola", "Belchhi", "Ghoswari", "Dulhinbazar"
    ]
  };

  // final List<String> blockList = ["Block A", "Block B", "Block C"];
  final List<String> schoolList = [
    "Schools in Aided M. S. Chainpur. Cluster",
    "Schools in Basic School Sarahra. Cluster",
    "Schools in M. S. Baghauna. Cluster",
    "Schools in M. S. Gangpur Siswan. Cluster",
    "Schools in M. S. Nonia Patti Cluster",
    "Schools in M. S. Siswa Kalan Cluster",
    "Schools in M. S. Ubadhi Cluster",
    "Schools in U.m.s. Morwan. Cluster",
  ];


  Future<void> _pickImage(String type) async {
    try {
      debugPrint("Starting image picker for $type");

      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,   // downscale early for memory safety
        maxHeight: 1200,
        imageQuality: 90, // initial compression
      );

      if (picked == null) {
        debugPrint("Image picker cancelled");
        return;
      }

      debugPrint("Image picked: ${picked.path}");

      File file = File(picked.path);
      int fileSize = await file.length();
      double sizeInKb = fileSize / 1024;

      // ✅ Extension validation
      String extension = picked.path.split('.').last.toLowerCase();
      if (!(extension == "jpg" || extension == "jpeg" || extension == "png")) {
        _showError("Only JPG or PNG images are allowed");
        return;
      }

      // ✅ Decode image safely
      final bytes = await picked.readAsBytes();
      final img.Image? decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        _showError("Unable to read image file");
        return;
      }

      Uint8List processedBytes = bytes;
      img.Image workingImage = decodedImage;
      int quality = 90;

      // ✅ Adjust image to 40–100 KB
      int loopCount = 0;
      while ((sizeInKb < 40 || sizeInKb > 100) && loopCount < 15) {
        // Downscale if too large
        if (sizeInKb > 100) {
          if (quality > 30) {
            quality -= 5;
          } else {
            workingImage = img.copyResize(
              workingImage,
              width: (workingImage.width * 0.85).toInt(),
              height: (workingImage.height * 0.85).toInt(),
            );
          }
        }
        // Slightly upscale if too small
        else if (sizeInKb < 40) {
          if (quality < 100) quality += 5;
          workingImage = img.copyResize(
            workingImage,
            width: (workingImage.width * 1.1).toInt(),
            height: (workingImage.height * 1.1).toInt(),
          );
        }

        final compressed = img.encodeJpg(workingImage, quality: quality);
        processedBytes = Uint8List.fromList(compressed);
        sizeInKb = processedBytes.length / 1024;
        loopCount++;
      }

      // ✅ Validate final size
      if (sizeInKb < 40 || sizeInKb > 100) {
        _showError("Image could not be adjusted to 40–100 KB. Please choose another image.");
        return;
      }

      // ✅ Save processed image to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = await File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      ).writeAsBytes(processedBytes);

      file = tempFile;

      // ✅ Save to state
      setState(() {
        if (type == "photo") {
          _selectedPhoto = file;
          fileNamePhoto = picked.name;
        } else if (type == "signature") {
          _selectedSignature = file;
          fileNameSignature = picked.name;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ File uploaded successfully (${sizeInKb.toStringAsFixed(1)} KB)"),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint("ERROR in _pickImage: $e");
      debugPrint("Stack trace: $stackTrace");
      _showError("Failed to process image: ${e.toString()}");
    }
  }
// 🔹 Reusable error method
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }


  Widget _label(String text, {bool required = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        if (required) const Text(" *", style: TextStyle(color: Colors.red)),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose all TextEditingControllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _rollCodeController.dispose();
    _rollNoController.dispose();
    _registrationController.dispose();
    _dobController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _addressController.dispose();
    _aadhaarController.dispose();
    _udiseController.dispose();
    _streamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF970202),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(0xFF970202), width: 1.5),
                        borderRadius: BorderRadius.circular(27),
                      ),
                      child: Text(
                        'registration_form'.tr,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),


                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Class
                          _buildDropdownField(
                              _label("select_class".tr, required: true),
                              classList,
                              selectedClass,
                              (val) => setState(() => selectedClass = val),
                              validator: (v) =>
                                  v == null ? "Class is required" : null),
                          const SizedBox(height: 16),

                          // Name
                          _buildTextFormField(
                              _label("full_name".tr, required: true),
                              _nameController,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Full Name required"
                                  : null),
                          const SizedBox(height: 16),

                          // Gender
                          _buildDropdownField(
                              _label("gender".tr, required: true),
                              genderList,
                              selectedGender,
                              (val) => setState(() => selectedGender = val),
                              validator: (v) =>
                                  v == null ? "Gender is required" : null),
                          const SizedBox(height: 16),
                          // Caste Category
                          // _buildDropdownField(
                          //   "caste_category".tr,
                          //   casteCategories,
                          //   selectedCaste,
                          //   (val) => setState(() => selectedCaste = val),
                          //   isRequired: true,
                          // ),
                          //
                          // const SizedBox(height: 16),
                          // _buildDropdownField(
                          //   "differently_abled".tr,
                          //   differentlyAbled,
                          //   selectedDifferentlyAbled,
                          //   (val) =>
                          //       setState(() => selectedDifferentlyAbled = val),
                          //   isRequired: true,
                          // ),

                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     _buildDropdownField(
                          //       "differently_abled".tr,
                          //       differentlyAbled, // e.g. ["Yes", "No"]
                          //       selectedDifferentlyAbled,
                          //           (val) => setState(() => selectedDifferentlyAbled = val),
                          //       isRequired: true,
                          //     ),
                          //
                          //     // ✅ Show textfield only if "Yes" is selected
                          //     if (selectedDifferentlyAbled == "Yes")
                          //       Padding(
                          //         padding: const EdgeInsets.only(top: 12.0),
                          //         child: TextFormField(
                          //           // controller: _differentlyAbledDetailController,
                          //           decoration: InputDecoration(
                          //             labelText: "Please_provide_disability_details".tr,
                          //             border: OutlineInputBorder(
                          //               borderRadius: BorderRadius.circular(8),
                          //             ),
                          //           ),
                          //           validator: (value) {
                          //             if (selectedDifferentlyAbled == "Yes" &&
                          //                 (value == null || value.trim().isEmpty)) {
                          //               return "This_field_is_required";
                          //             }
                          //             return null;
                          //           },
                          //         ),
                          //       ),
                          //   ],
                          // ),

                          // const SizedBox(height: 16),
                          // _buildDropdownField(
                          //   "religion".tr,
                          //   religions,
                          //   selectedReligion,
                          //   (val) => setState(() => selectedReligion = val),
                          //   isRequired: true,
                          // ),
                          //
                          // const SizedBox(height: 16),

// Area
//                           _buildDropdownField(
//                             "area".tr,
//                             areas,
//                             selectedArea,
//                             (val) => setState(() => selectedArea = val),
//                             isRequired: true,
//                           ),
//
//                           const SizedBox(height: 16),

// Marital Status
//                           _buildDropdownField(
//                             "marital_status".tr,
//                             maritalStatus,
//                             selectedMaritalStatus,
//                             (val) =>
//                                 setState(() => selectedMaritalStatus = val),
//                             isRequired: true,
//                           ),

                          // const SizedBox(height: 16),

                          // DOB
                          _buildDateField(
                            _label("date_of_birth".tr, required: true),
                            _dobController,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "DOB required";
                              }

                              try {
                                final dob = DateFormat("dd-MM-yyyy").parseStrict(v); // 👈 match your format
                                final today = DateTime.now();
                                final age = today.year - dob.year -
                                    ((today.month < dob.month || (today.month == dob.month && today.day < dob.day)) ? 1 : 0);

                                if (age < 10) {
                                  return "Minimum age required is 10 years";
                                }
                              } catch (e) {
                                return "Invalid date format (use dd-MM-yyyy)";
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          //
                          // _buildTextFormField(
                          //     "father_name".tr, _fatherNameController),
                          // const SizedBox(height: 16),
                          // _buildTextFormField(
                          //     "mother_name".tr, _motherNameController),
                          // const SizedBox(height: 16),

                          _buildTextFormField("email_address".tr, _emailController,
                              inputType: TextInputType.emailAddress,
                              validator: (v) {
                            if (v != null && v.isNotEmpty && !v.contains("@"))
                              return "Invalid email";
                            return null;
                          }),
                          const SizedBox(height: 16),

                          _buildTextFormField(
                              _label("mobile_number".tr, required: true),
                              _numberController,
                              inputType: TextInputType.phone,
                              validator: (v) => v == null || v.length != 10
                                  ? "Enter 10-digit mobile"
                                  : null),
                          const SizedBox(height: 16),

                          // _buildTextFormField(
                          //     _label("aadhaar_number".tr, required: true),
                          //     _aadhaarController,
                          //     inputType: TextInputType.number,
                          //     validator: (v) => v == null || v.length != 12
                          //         ? "Enter 12-digit Aadhaar"
                          //         : null),
                          // const SizedBox(height: 16),

                          // _buildTextFormField(
                          //     "full_address".tr, _addressController),
                          // const SizedBox(height: 16),

                          // Division Dropdown
                          // _buildDropdownField(
                          //   _label("divisions".tr, required: true),
                          //   divisionList,
                          //   selectedDivisions,
                          //   (val) {
                          //     setState(() {
                          //       selectedDivisions = val;
                          //       selectedDistrict =
                          //           null; // reset district when division changes
                          //     });
                          //   },
                          //   validator: (v) =>
                          //       v == null ? "Division is required" : null,
                          // ),
                          //
                          // const SizedBox(height: 16),

// District Dropdown (filtered)
//                           _buildDropdownField(
//                             "district".tr,
//                             selectedDivisions != null
//                                 ? divisionDistrictMap[selectedDivisions]!
//                                 : [],
//                             selectedDistrict,
//                             (val) {
//                               setState(() {
//                                 selectedDistrict = val;
//                                 selectedBlock = null;
//                                 blockList = blockMap[val] ?? [];
//                               });
//                             },
//                             isRequired: true,
//                           ),
//
//                           const SizedBox(height: 16),
//                           _buildDropdownField(
//                               _label("block".tr, required: true),
//                               blockList,
//                               selectedBlock,
//                               (val) => setState(() => selectedBlock = val),
//                               validator: (v) =>
//                                   v == null ? "Block is required" : null),
//                           const SizedBox(height: 16),

                          // _buildDropdownField(
                          //     _label("school_name".tr, required: true),
                          //     schoolList,
                          //     selectedSchool,
                          //     (val) => setState(() => selectedSchool = val),
                          //     validator: (v) =>
                          //         v == null ? "School is required" : null),

                          _buildAutoCompleteField(
                            label: _label("school_name".tr, required: true),
                            options: schoolList,
                            selectedValue: selectedSchool,
                            onSelected: (val) => setState(() => selectedSchool = val),
                            validator: (v) => v == null || v.isEmpty ? "School is required" : null,
                          ),

                          const SizedBox(height: 16),

                          // _buildTextFormField(
                          //     "udise_code".tr, _udiseController),
                          // const SizedBox(height: 16),
                          // _buildTextFormField(
                          //     "stream_subjects".tr, _streamController),
                          // const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                  child: _buildTextFormFieldRollCode(
                                      "roll_code".tr, _rollCodeController,
                                      inputType: TextInputType.number)),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _buildTextFormField(
                                      "roll_no".tr, _rollNoController,
                                      inputType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(8),
                                    ],

                                  )),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                              "registration_number".tr, _registrationController),
                          const SizedBox(height: 16),

                          _buildPasswordField(
                              _label("password".tr, required: true),
                              _isPasswordHidden,
                              () {
                                setState(() =>
                                    _isPasswordHidden = !_isPasswordHidden);
                              },
                              _passwordController,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return "Password required";
                                if (v.length < 8) return "Min 8 chars required";
                                return null;
                              }),
                          const SizedBox(height: 16),

                          _buildPasswordField(
                              _label("confirm_password".tr, required: true),
                              _isConfirmPasswordHidden,
                              () {
                                setState(() => _isConfirmPasswordHidden =
                                    !_isConfirmPasswordHidden);
                              },
                              _confirmPasswordController,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return "Confirm Password required";
                                if (v != _passwordController.text)
                                  return "Passwords do not match";
                                return null;
                              }),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => {_pickImage('photo')},
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFF970202), width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _selectedPhoto == null
                                  ?  Center(
                                      child: Text("upload_passport_photo".tr))
                                  : Image.file(_selectedPhoto!,
                                      fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => {_pickImage('signature')},
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFF970202), width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _selectedSignature == null
                                  ?  Center(
                                      child: Text("upload_signature_photo".tr))
                                  : Image.file(_selectedSignature!,
                                      fit: BoxFit.cover),
                            ),
                          ),

                          const SizedBox(height: 30),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF970202),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () => {
                   _submitForm() // Directly submit - backend will check if phone exists
                            },
                            child: Text(
                              "submit".tr,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- VALIDATION & SUBMIT ----------
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPhoto == null) {
        _showError("Please upload passport photo");
        return;
      }
      if (_selectedSignature == null) {
        _showError("Please upload signature");
        return;
      }

      final phone = _numberController.text.trim();
      
      Utils.progressbar(context, CustomColors.themeColorBlack);
      
      // Step 1: Send OTP for login/registration verification
      final success = await _authController.sendOtp(phone);
      
      Navigator.pop(context);

      if (success) {
        Utils.snackBarSuccess(context, 'otp_sent'.tr);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OtpScreen(
                    name: _nameController.text.trim(),
                    email: _emailController.text.trim(),
                    number: _numberController.text.trim(),
                    confirmPassword: _confirmPasswordController.text.trim(),
                    rollCode: _rollCodeController.text.trim(),
                    rollNo: _rollNoController.text.trim(),
                    registration: _registrationController.text.trim(),
                    dob: _dobController.text.trim(),
                    otp: '', // OTP handled by SMS
                    fatherName: _fatherNameController.text.trim(),
                    motherName: _motherNameController.text.trim(),
                    address: _addressController.text.trim(),
                    aadhaar: _aadhaarController.text.trim(),
                    udise: _udiseController.text.trim(),
                    stream: _streamController.text.trim(),
                    selectedClass: selectedClass ?? '',
                    selectedGender: selectedGender,
                    photoFile: _selectedPhoto,
                    signatureFile: _selectedSignature,
                    password: _passwordController.text.trim(),
                  )),
        );
      } else {
        _showError(_authController.error.isNotEmpty ? _authController.error : "Failed to send OTP");
      }
    }
  }

  // REMOVED: Legacy checkRegisterOrNot() method
  // Backend now handles duplicate phone number checks during registration

  // ---------- WIDGET HELPERS ----------
  Widget _buildTextFormField(
      dynamic label,
      TextEditingController controller, {
        TextInputType inputType = TextInputType.text,
        String? Function(String?)? validator,
        List<TextInputFormatter>? inputFormatters, // optional
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      cursorColor: const Color(CustomColors.theme_orange),
      validator: validator,
      inputFormatters: inputFormatters, // only applied if not null
      decoration: _decoration(label),
    );
  }
  Widget _buildTextFormFieldRollCode(
      dynamic label,
      TextEditingController controller, {
        TextInputType inputType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      cursorColor: const Color(CustomColors.theme_orange),
      validator: validator,
      maxLength: 5, // ✅ Limit input length to 4
      inputFormatters: [
        LengthLimitingTextInputFormatter(5), // ✅ Prevent typing more than 4 chars
      ],
      decoration: _decoration(label).copyWith(
        counterText: '', // ✅ Hide the length counter text below the field
      ),
    );
  }

  Widget _buildDateField(dynamic label, TextEditingController controller,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: validator,
      decoration: _decoration(label).copyWith(
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              initialDate: DateTime(2005),
            );
            if (picked != null) {
              setState(() =>
                  controller.text = DateFormat("dd-MM-yyyy").format(picked));
            }
          },
        ),
      ),
    );
  }

  Widget _buildPasswordField(dynamic label, bool isHidden, VoidCallback toggle,
      TextEditingController controller,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: isHidden,
      validator: validator,
      cursorColor: const Color(CustomColors.theme_orange),
      decoration: _decoration(label).copyWith(
        suffixIcon: IconButton(
          icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility,
              color: const Color(CustomColors.theme_orange)),
          onPressed: toggle,
        ),
      ),
    );
  }
  Widget _buildAutoCompleteField({
    required Widget label,            // 🔹 accept Widget instead of String
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onSelected,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // label, // 🔹 now you can pass _label(...) directly
        const SizedBox(height: 8),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: selectedValue ?? ""),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return options.where((String option) =>
                option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            onSelected(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              validator: validator,
              decoration: _decoration(label),

              // decoration: InputDecoration(
              //   hintText: "स्कूल का नाम टाइप करें",
              //   border: OutlineInputBorder(
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              // ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    dynamic label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged, {
    String? Function(String?)? validator,
    bool isRequired = false, // 👈 add flag for required
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator ??
          (isRequired
              ? (v) => v == null || v.isEmpty ? "This field is required" : null
              : null),
      decoration: _decoration(label, isRequired: isRequired),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _decoration(dynamic label, {bool isRequired = false}) {
    return InputDecoration(
      label: label is Widget
          ? label
          : RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(color: Colors.black),
                children: isRequired
                    ? const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        )
                      ]
                    : [],
              ),
            ),
      labelStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(CustomColors.theme_orange)),
      ),
    );
  }
}
