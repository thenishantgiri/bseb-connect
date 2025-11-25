import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../controllers/auth_controller.dart';
import '../utilities/dio_singleton.dart';
import '../utilities/CustomColors.dart';
import '../utilities/Constant.dart';
import '../utilities/SharedPreferencesHelper.dart';
import '../utilities/Utils.dart';
import 'OtpScreen.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  File? _selectedPhoto;
  File? _selectedSignature;

  final Dio _dio = getDio(); // Use singleton Dio instance
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =TextEditingController();
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
  String? _otp;
  String? filePath;
  String? password;

  // String? fileName;
  String? fileNamePhoto;
  String? fileNameSignature;
  List<String> blockList = [];
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
  String? area;
  String? division;




  final List<String> classList = ["9th", "10th","11th", "12th", "other"];
  final List<String> genderList = ["Male", "Female", "Other"];
  final List<String> casteCategories = ["General", "OBC", "SC", "ST", "EWS"];
  final List<String> differentlyAbledList = ["Yes", "No"];
  final List<String> religions = [
    "Hindu",
    "Muslim",
    "Jain",
    "Sikh",
    "Bauddh",
    "Christ",
    "Other"
  ];
  final List<String> areas = ["Rural", "Urban"];
  final List<String> maritalStatusList = ["Married", "Unmarried"];
  final List<String> divisionList = [
    "PURNIA",
    "MUNGER",
    "BHAGALPUR",
    "KOSHI",
    "TIRHUT",
    "DARBHANGA",
    "PATNA",
    "MAGADH",
    "SARAN"
  ];

  final Map<String, List<String>> divisionDistrictMap = {
    "PURNIA": ["Purnia", "Araria", "Kishanganj", "Katihar"],
    "MUNGER": [
      "Munger", "Jamui", "Lakhisarai", "Sheikhpura", "Khagaria", "Begusarai"
    ],
    "BHAGALPUR": ["Bhagalpur", "Banka"],
    "KOSHI": ["Saharsa", "Supaul", "Madhepura"],
    "TIRHUT": [
      "Muzaffarpur", "Sitamarhi", "Vaishali", "Bettiah (W. Champaran)",
      "Motihari (E. Champaran)", "Sheohar"
    ],
    "DARBHANGA": ["Darbhanga", "Madhubani", "Samastipur"],
    "PATNA": ["Patna", "Nalanda", "Bhojpur", "Rohtas", "Buxar", "Bhabhua"],
    "MAGADH": ["Gaya", "Nawada", "Aurangabad", "Jehanabad", "Arwal"],
    "SARAN": ["Saran", "Siwan", "Gopalganj"],
  };


  final Map<String, List<String>> blockMap = {
    "Patna": [
      "Patna Sadar",
      "Sampatchak",
      "Phulwarisharif",
      "Fatwah",
      "Daniyawan",
      "Khusrupur",
      "Bihta",
      "Naubatpur",
      "Paliganj",
      "Barh",
      "Mokama",
      "Masaurhi",
      "Punpun",
      "Maner",
      "Danapur",
      "Bikram",
      "Bakhtiyarpur",
      "Pandarak",
      "Fatuha",
      "Athmalgola",
      "Belchhi",
      "Ghoswari",
      "Dulhinbazar"
    ],
    "Gaya": [
      "Gaya Sadar",
      "Belaganj",
      "Wazirganj",
      "Manpur",
      "Bodhgaya",
      "Tankuppa",
      "Fatehpur",
      "Tekari",
      "Konch",
      "Guraru",
      "Paraiya",
      "Neemchak Bathani",
      "Khizarsarai",
      "Atri",
      "Bathani",
      "Mohra",
      "Sherghati",
      "Gurua",
      "Amas",
      "Banke Bazar",
      "Imamganj",
      "Dumariya",
      "Dobhi",
      "Mohanpur",
      "Barachatti"
    ],
    "Nalanda": [
      "Bihar Sharif",
      "Bind",
      "Chandi",
      "Ekangarsarai",
      "Giriyak",
      "Harnaut",
      "Hilsa",
      "Islampur",
      "Karai Parsurai",
      "Katrisarai",
      "Noorsarai",
      "Parbalpur",
      "Rahui",
      "Rajgir",
      "Sarmera",
      "Silao",
      "Tharthari"
    ],
    "Araria": [
      "Araria",
      "Kursakatta",
      "Palasi",
      "Raniganj",
      "Forbesganj",
      "Jokihat",
      "Dholbaja",
      "Phulbari",
      "Sikti"
    ],
    "Arwal": ["Arwal", "Kaler", "Kochas", "Nawanagar", "Sadar"],
    "Aurangabad": [
      "Aurangabad",
      "Barun",
      "Obra",
      "Dev",
      "Rafiganj",
      "Haspura",
      "Madankaur",
      "Kutumbba",
      "Daudnagar",
      "Nabinagar"
    ],
    "Banka": [
      "Banka",
      "Amarpur",
      "Bounsi",
      "Chandankyari",
      "Dhoraiya",
      "Katoria",
      "Kharagpur",
      "Jama",
      "Raghunathganj",
      "Shambhuganj",
      "Sultanganj"
    ],
    "Begusarai": [
      "Begusarai",
      "Bachhwara",
      "Chhaurahi",
      "Dandari",
      "Gadhpura",
      "Gidhaur",
      "Kharik",
      "Matihani",
      "Nawada",
      "Phulwaria",
      "Sadar"
    ],
    "Bhagalpur": [
      "Bhagalpur",
      "Goradih",
      "Jagdishpur",
      "Nathnagar",
      "Sabour",
      "Shahkund",
      "Sultanganj",
      "Kahalgaon",
      "Pirpainty",
      "Sanhaula"
    ],
    "Bhojpur": [
      "Arrah",
      "Jagdispur",
      "Koilwar",
      "Sahar",
      "Barhara",
      "Sandesh",
      "Charpokhari",
      "Piro",
      "Tarari",
      "Bihia",
      "Agiawon",
      "Garhani"
    ],
    "Buxar": [
      "Buxar",
      "Dumraon",
      "Simari",
      "Brahmpur",
      "Rajpur",
      "Itarhi",
      "Nawanagar",
      "Chaungain",
      "Chausa",
      "Chakki",
      "Kesath"
    ],
    "Darbhanga": [
      "Darbhanga",
      "Bahadurpur",
      "Biraul",
      "Benipur",
      "Jale",
      "Kusheshwar Asthan",
      "Madhubani",
      "Manigachhi",
      "Mushari",
      "Pachrukhi",
      "Singhwara",
      "Tardih"
    ],
    "East Champaran (Motihari)": [
      "Motihari",
      "Areraj",
      "Chakia",
      "Dhaka",
      "Harsidhi",
      "Kalyanpur",
      "Madhuban",
      "Paharpur",
      "Raxaul",
      "Turkaulia",
      "Adapur",
      "Chiraia"
    ],
    "Gopalganj": [
      "Gopalganj",
      "Baikunthpur",
      "Barauli",
      "Bishambharpur",
      "Kuchaikote",
      "Manjha",
      "Maharajganj",
      "Pachrukhi",
      "Sadar",
      "Saraiya",
      "Udwantnagar"
    ],
    "Jamui": [
      "Jamui",
      "Chakai",
      "Gidhaur",
      "Jhajha",
      "Khaira",
      "Lakhisarai",
      "Munger",
      "Madhupur",
      "Sadar"
    ],
    "Jehanabad": [
      "Jehanabad",
      "Makhdumpur",
      "Kako",
      "Ratnifridpur",
      "Hulasganj",
      "Modanganj",
      "Kauakol",
      "Varsaliganj"
    ],
    "Kaimur (Bhabua)": [
      "Bhabua",
      "Ramgarh",
      "Mohania",
      "Durgawati",
      "Adhaura",
      "Bhagwanpur",
      "Chand",
      "Chainpur",
      "Kudra",
      "Rampur",
      "Nuawon",
      "Nauhatta"
    ],
    "Katihar": [
      "Katihar",
      "Amdabad",
      "Barsoi",
      "Dandkhora",
      "Hirmin",
      "Islampur",
      "Kushmudi",
      "Kursela",
      "Mansahi",
      "Pranpur",
      "Saharsa",
      "Supaul"
    ],
    "Khagaria": [
      "Khagaria",
      "Alamnagar",
      "Bihariganj",
      "Chousa",
      "Gamhariya",
      "Ghelardh",
      "Gwalpara",
      "Kumarkhand",
      "Madhepura"
    ],
    "Kishanganj": [
      "Kishanganj",
      "Bahadurganj",
      "Chhatapur",
      "Dighalbank",
      "Kumargram",
      "Purnia",
      "Supaul"
    ],
    "Lakhisarai": [
      "Lakhisarai",
      "Chanan",
      "Karma",
      "Kharagpur",
      "Munger",
      "Madhupur",
      "Sadar"
    ],
    "Madhepura": [
      "Madhepura",
      "Alamnagar",
      "Bihariganj",
      "Chousa",
      "Gamhariya",
      "Ghelardh",
      "Gwalpara",
      "Kumarkhand"
    ],
    "Madhubani": [
      "Madhubani",
      "Benipur",
      "Bisfi",
      "Brahmpur",
      "Chandpura"
    ],
    "Munger": ["Munger", "Lakhisarai", "Madhupur", "Sadar"],
    "Muzaffarpur": [
      "Muzaffarpur",
      "Belsand",
      "Biraul",
      "Kanti",
      "Madhubani"
    ],
    "Nawada": [
      "Nawada",
      "Rajouli",
      "Hisua",
      "Narhat",
      "Govindpur",
      "Pakribarawan",
      "Sirdalla",
      "Kasichak",
      "Roh",
      "Nardiganj",
      "Meskaur",
      "Madanpur",
      "Kutumbba",
      "Daudnagar",
      "Aurangabad",
      "Barun",
      "Obra",
      "Dev"
    ],
    "Pashchim Champaran (Bettiah)": [
      "Bettiah",
      "Bairgania",
      "Belsand",
      "Riga",
      "Sursand",
      "Pupri",
      "Sonbarsa",
      "Dumra",
      "Runni saidpur",
      "Majorganj",
      "Suppi",
      "Parsauni",
      "Bokhra",
      "Chorout",
      "Sheohar"
    ],
  };


  Future<void> _loadProfileDetails() async {
    SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();

    // ✅ First try to fetch fresh data from API
    try {
      // Initialize AuthController if not already registered
      AuthController authController;
      try {
        authController = Get.find<AuthController>();
      } catch (e) {
        // If controller doesn't exist, create it
        authController = Get.put(AuthController());
      }

      final success = await authController.fetchUserProfile();

      if (!success) {
        // If API call fails, show error but continue with cached data
        debugPrint("Failed to fetch fresh profile data: ${authController.error}");
      }
    } catch (e) {
      debugPrint("Error fetching profile from API: $e");
    }

    // Load from SharedPreferences (either fresh from API or cached)
    userName = await sharedPreferencesHelper.getPref("FullName");
    email = await sharedPreferencesHelper.getPref("Email");
    userClass = await sharedPreferencesHelper.getPref("Class");
    phone = await sharedPreferencesHelper.getPref("Phone");
    rollCode = await sharedPreferencesHelper.getPref("RollCode");
    rollNumber = await sharedPreferencesHelper.getPref("RollNumber");
    // imageUrl = await sharedPreferencesHelper.getPref("Photo");

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
    division = await sharedPreferencesHelper.getPref("State");
    district = await sharedPreferencesHelper.getPref("Distic");
    block = await sharedPreferencesHelper.getPref("Block");
    aadhar = await sharedPreferencesHelper.getPref("AddharNumber");
    password = await sharedPreferencesHelper.getPref("Password");
    area = await sharedPreferencesHelper.getPref("Area");


    // ✅ Assign values to controllers only if not null/empty
    if (userName != null && userName!.isNotEmpty) _nameController.text = userName!;
    if (email != null && email!.isNotEmpty) _emailController.text = email!;
    if (phone != null && phone!.isNotEmpty) _numberController.text = phone!;
    if (rollCode != null && rollCode!.isNotEmpty) _rollCodeController.text = rollCode!;
    if (rollNumber != null && rollNumber!.isNotEmpty) _rollNoController.text = rollNumber!;
    if (registrationNumber != null && registrationNumber!.isNotEmpty) _registrationController.text = registrationNumber!;
    if (dob != null && dob!.isNotEmpty) _dobController.text = dob!;
    if (fatherName != null && fatherName!.isNotEmpty) _fatherNameController.text = fatherName!;
    if (motherName != null && motherName!.isNotEmpty) _motherNameController.text = motherName!;
    if (address != null && address!.isNotEmpty) _addressController.text = address!;
    if (aadhar != null && aadhar!.isNotEmpty) _aadhaarController.text = aadhar!;
    if (password != null && password!.isNotEmpty) _passwordController.text = password!;
    if (password != null && password!.isNotEmpty) _confirmPasswordController.text = password!;
    if (udiseCode != null && udiseCode!.isNotEmpty) _udiseController.text = udiseCode!;
    if (stream != null && stream!.isNotEmpty) _streamController.text = stream!;
    if (area != null && area!.isNotEmpty) selectedArea = area!;

    // ✅ Assign dropdown selections
    if (userClass != null && userClass!.isNotEmpty) selectedClass = userClass;
    if (gender != null && gender!.isNotEmpty) selectedGender = gender;
    if (division != null && division!.isNotEmpty) selectedDivisions = division;
    if (district != null && district!.isNotEmpty) selectedDistrict = district;
    // if (block != null && block!.isNotEmpty) selectedBlock = block;
    // if (schoolName != null && schoolName!.isNotEmpty) selectedSchool = schoolName;
    if (schoolName != null && schoolName!.isNotEmpty) {
      selectedSchool = schoolName;
    }

    if (caste != null && caste!.isNotEmpty) selectedCaste = caste;
    if (religion != null && religion!.isNotEmpty) selectedReligion = religion;
    if (differentlyAbled != null && differentlyAbled!.isNotEmpty) selectedDifferentlyAbled = differentlyAbled;
    if (maritalStatus != null && maritalStatus!.isNotEmpty) selectedMaritalStatus = maritalStatus;

    if (district != null && district!.isNotEmpty) {
      selectedDistrict = district;

      // Load block list only from district
      if (blockMap.containsKey(selectedDistrict)) {
        blockList = blockMap[selectedDistrict]!;
      }
    }
    //
    if (block != null && block!.isNotEmpty) {
      selectedBlock = block;
    }
    // if (schoolName != null && schoolName!.isNotEmpty) _school.text = rollNumber!;

    print("object"+block.toString());
    print("objecsdst"+differentlyAbled.toString());
    setState(() {});
  }

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

  @override
  void initState() {
    super.initState();
    _loadProfileDetails();
    print("dfdffd"+selectedClass.toString());
  }



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
    } catch (e) {
      _showError("Failed to process image: $e");
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
                        'update_profile'.tr,
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
                          _buildDropdownField(
                            "caste_category".tr,
                            casteCategories,
                            selectedCaste,
                            (val) => setState(() => selectedCaste = val),
                            isRequired: true,
                          ),
                          //
                          const SizedBox(height: 16),
                          // _buildDropdownField(
                          //   "differently_abled".tr,
                          //   differentlyAbled,
                          //   selectedDifferentlyAbled,
                          //   (val) =>
                          //       setState(() => selectedDifferentlyAbled = val),
                          //   isRequired: true,
                          // ),
                          // const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDropdownField(
                                "differently_abled".tr,
                                differentlyAbledList, // e.g. ["Yes", "No"]
                                selectedDifferentlyAbled,
                                    (val) => setState(() => selectedDifferentlyAbled = val),
                                isRequired: true,
                              ),

                              // ✅ Show textfield only if "Yes" is selected
                              if (selectedDifferentlyAbled == "Yes")
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: TextFormField(
                                    // controller: _differentlyAbledDetailController,
                                    decoration: InputDecoration(
                                      labelText: "Please_provide_disability_details".tr,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (selectedDifferentlyAbled == "Yes" &&
                                          (value == null || value.trim().isEmpty)) {
                                        return "This_field_is_required";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          _buildDropdownField(
                            "religion".tr,
                            religions,
                            selectedReligion,
                            (val) => setState(() => selectedReligion = val),
                            isRequired: true,
                          ),

                          const SizedBox(height: 16),

// Area
                          _buildDropdownField(
                            "area".tr,
                            areas,
                            selectedArea,
                            (val) => setState(() => selectedArea = val),
                            isRequired: true,
                          ),

                          const SizedBox(height: 16),

// Marital Status
                          _buildDropdownField(
                            "marital_status".tr,
                            maritalStatusList,
                            selectedMaritalStatus,
                            (val) =>
                                setState(() => selectedMaritalStatus = val),
                            isRequired: true,
                          ),

                          const SizedBox(height: 16),

                          // DOB
                          _buildDateField(
                              _label("date_of_birth".tr, required: true),
                              _dobController,
                              validator: (v) => v == null || v.isEmpty
                                  ? "DOB required"
                                  : null),
                          const SizedBox(height: 16),
                          //
                          _buildTextFormField(
                              "father_name".tr, _fatherNameController),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                              "mother_name".tr, _motherNameController),
                          const SizedBox(height: 16),

                          _buildTextFormField("email_address".tr, _emailController,
                              inputType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v != null && v.isNotEmpty && !v.contains("@"))
                                  return "Invalid email";
                                return null;
                              }),
                          const SizedBox(height: 16),

                          // _buildTextFormField(
                          //     _label("mobile_number".tr, required: true),
                          //     _numberController,
                          //     inputType: TextInputType.phone,
                          //     validator: (v) => v == null || v.length != 10
                          //         ? "Enter 10-digit mobile"
                          //         : null),

                          _buildTextFormField(
                            _label("mobile_number".tr, required: true),
                            _numberController,
                            inputType: TextInputType.phone,
                            enabled: false, // 🔹 fully disabled
                            validator: (v) => null, // no need for validation since it's fixed
                          ),

                          const SizedBox(height: 16),

                          // _buildTextFormField(
                          //     _label("aadhaar_number".tr, required: true),
                          //     _aadhaarController,
                          //     inputType: TextInputType.number,
                          //     validator: (v) => v == null || v.length != 12
                          //         ? "Enter 12-digit Aadhaar"
                          //         : null),
                          // const SizedBox(height: 16),

                          _buildTextFormField(
                              "full_address".tr, _addressController),
                          const SizedBox(height: 16),

                          // Division Dropdown
                          _buildDropdownField(
                            _label("divisions".tr, required: true),
                            divisionList,
                            selectedDivisions,
                            (val) {
                              setState(() {
                                selectedDivisions = val;
                                selectedDistrict =
                                    null; // reset district when division changes
                              });
                            },
                            validator: (v) =>
                                v == null ? "Division is required" : null,
                          ),

                          const SizedBox(height: 16),

// District Dropdown (filtered)
                          _buildDropdownField(
                            "district".tr,
                            selectedDivisions != null ? divisionDistrictMap[selectedDivisions]! : [],
                            selectedDistrict,
                            (val) {
                              setState(() {
                                selectedDistrict = val;
                                selectedBlock = null;
                                blockList = blockMap[val] ?? [];
                              });
                            },
                            isRequired: true,
                          ),

                          const SizedBox(height: 16),
                          _buildDropdownField(
                              _label("block".tr, required: true),
                              blockList,
                              selectedBlock,
                              (val) => setState(() => selectedBlock = val),
                              validator: (v) =>
                                  v == null ? "Block is required" : null),
                          const SizedBox(height: 16),

                          // _buildDropdownField(
                          //     _label("school_name".tr, required: true),
                          //     schoolList,
                          //     selectedSchool,
                          //         (val) => setState(() => selectedSchool = val),
                          //     validator: (v) =>
                          //     v == null ? "School is required" : null),

                          _buildAutoCompleteField(
                            label: _label("school_name".tr, required: true),
                            options: schoolList,
                            selectedValue: selectedSchool,      // ✅ This shows prefilled value
                            onSelected: (val) => setState(() => selectedSchool = val),
                            validator: (v) => v == null || v.isEmpty ? "School is required" : null,
                          ),

                          const SizedBox(height: 16),

                          // _buildTextFormField(
                          //     "udise_code".tr, _udiseController),
                          // const SizedBox(height: 16),
                          // Visibility(
                          //   visible: selectedClass == "12th",
                          //   child: _buildTextFormField(
                          //     "stream_subjects".tr,
                          //     _streamController,
                          //   ),
                          // ),
                          //
                          // const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                  child: _buildTextFormField(
                                      "roll_code".tr, _rollCodeController,
                                      inputType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(5),
                                    ],

                                  )),
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
                          // GestureDetector(
                          //   onTap: () => {_pickImage('photo')},
                          //   child: Container(
                          //     height: 150,
                          //     width: double.infinity,
                          //     decoration: BoxDecoration(
                          //       border: Border.all(
                          //           color: const Color(0xFF970202), width: 1.5),
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //     child: _selectedPhoto == null
                          //         ?  Center(
                          //         child: Text("upload_passport_photo".tr))
                          //         : Image.file(_selectedPhoto!,
                          //         fit: BoxFit.cover),
                          //   ),
                          // ),
                      GestureDetector(
                        onTap: () => _pickImage('photo'),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF970202), width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _selectedPhoto != null
                              ? Image.file(
                            _selectedPhoto!,
                            fit: BoxFit.cover,
                          )
                              : (imageUrl != null && imageUrl!.isNotEmpty)
                              ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Text("Failed to load image"));
                            },
                          )
                              : Center(
                            child: Text("upload_passport_photo".tr),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                          // GestureDetector(
                          //   onTap: () => {_pickImage('signature')},
                          //   child: Container(
                          //     height: 150,
                          //     width: double.infinity,
                          //     decoration: BoxDecoration(
                          //       border: Border.all(
                          //           color: const Color(0xFF970202), width: 1.5),
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //     child: _selectedSignature == null
                          //         ?  Center(
                          //         child: Text("upload_signature_photo".tr))
                          //         : Image.file(_selectedSignature!,
                          //         fit: BoxFit.cover),
                          //   ),
                          // ),

                      GestureDetector(
                        onTap: () => _pickImage('signature'),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF970202), width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _selectedSignature != null
                              ? Image.file(
                            _selectedSignature!,
                            fit: BoxFit.cover,
                          )
                              : (signatureUrl != null && signatureUrl!.isNotEmpty)
                              ? Image.network(
                            signatureUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Text("Failed to load image"));
                            },
                          )
                              : Center(
                            child: Text("upload_signature_photo".tr),
                          ),
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
                            onPressed: () => {_submitForm()},
                            child: Text(
                              "update".tr,
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
      //   return;
      // }
      //
      // if (_selectedSignature == null) {
      //   _showError("upload_signature_photo".tr); // or "Please upload signature"
      //   return;
      // }

      try {
        Utils.progressbar(context, CustomColors.themeColorBlack);
        final response = await _dio.post(
          Constant.LEGACY_BASE_URL + Constant.SEND_OTP,
          options: Options(
            headers: {
              "Content-Type": "application/json",
            },
          ),
          data: {
            "Phone": _numberController.text.trim().toString(),
            // Replace with dynamic phone if needed
          },
        );
        Navigator.pop(context);
        if (response.statusCode == 200) {
          // SECURITY FIX: OTP should NOT be sent from backend to frontend
          // OTP should only be sent via SMS to user's phone
          // Removed: _otp = response.data['data']['OTP'];
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OtpScreen(
                  name: _nameController.text.trim().toString(),
                  email: _emailController.text.trim().toString(),
                  number: _numberController.text.trim().toString(),
                  confirmPassword: _confirmPasswordController.text.trim().toString(),
                  rollCode: _rollCodeController.text.trim().toString(),
                  rollNo: _rollNoController.text.trim().toString(),
                  registration:
                  _registrationController.text.trim().toString(),
                  dob: _dobController.text.trim().toString(),
                  otp: '', // Empty string - OTP should come via SMS
                  fatherName: _fatherNameController.text.trim().toString(),
                  motherName: _motherNameController.text.trim().toString(),
                  address: _addressController.text.trim().toString(),
                  aadhaar: _aadhaarController.text.trim().toString(),
                  udise: _udiseController.text.trim().toString(),
                  stream: _streamController.text.trim().toString(),
                  selectedClass: selectedClass.toString(),
                  selectedGender: selectedGender,
                  selectedDivisions: selectedDivisions,
                  selectedDistrict: selectedDistrict,
                  selectedBlock: selectedBlock,
                  selectedSchool: selectedSchool,
                  filePath: _selectedPhoto?.path.toString(),
                  fileName: fileNamePhoto,
                  selectedCaste: selectedCaste,
                  selectedDifferentlyAbled: selectedDifferentlyAbled,
                  selectedReligion: selectedReligion,
                  selectedArea: selectedArea,
                  selectedMaritalStatus: selectedMaritalStatus,
                  fileNameSignature: fileNameSignature,
                  filePathSignature: _selectedSignature?.path.toString(),
                )),
          );
          final data = response.data;
          if (data is Map<String, dynamic>) {
            final result = data["result"];
            final message = data["message"];
            print("✅ Success: $message");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message ?? "OTP sent successfully")),
            );
          } else {
            print("⚠️ Unexpected response format: $data");
          }
        } else {
          print("❌ Failed with status: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to send OTP. Try again.")),
          );
        }
      } on DioError catch (e) {
        // Dio-specific error
        print("❌ Dio error: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Network error: ${e.message}")),
        );
      } catch (e) {
        // Other errors
        print("❌ Unexpected error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Something went wrong")),
        );
      }
    }
  }

  // ---------- WIDGET HELPERS ----------
  // Widget _buildTextFormField(dynamic label, TextEditingController controller,
  //     {TextInputType inputType = TextInputType.text,
  //       String? Function(String?)? validator}) {
  //   return TextFormField(
  //     controller: controller,
  //     keyboardType: inputType,
  //     cursorColor: const Color(CustomColors.theme_orange),
  //     validator: validator,
  //     decoration: _decoration(label),
  //   );
  // }

  Widget _buildTextFormField(
      dynamic label,
      TextEditingController controller, {
        TextInputType inputType = TextInputType.text,
        String? Function(String?)? validator,
        bool? enabled, // nullable
        List<TextInputFormatter>? inputFormatters, // ✅ new
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      cursorColor: const Color(CustomColors.theme_orange),
      validator: validator,
      enabled: enabled,
      inputFormatters: inputFormatters, // ✅ apply input formatters if provided
      decoration: _decoration(label),
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
    required Widget label,
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onSelected,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

            // ✅ Set default value when widget loads - Fixed setState during build error
            if (controller.text.isEmpty && selectedValue != null) {
              // Use post-frame callback to avoid setState during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (controller.text.isEmpty && selectedValue != null) {
                  controller.text = selectedValue!;
                }
              });
            }

            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              validator: validator,
              decoration: _decoration(label),
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
