import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../utilities/ApiInterceptor.dart';
import '../../utilities/Constant.dart';
import '../../utilities/CustomColors.dart';
import '../../utilities/SharedPreferencesHelper.dart';
import '../../utilities/Utils.dart';

class ExamFormScreen extends StatefulWidget {
  @override
  _ExamFormScreenState createState() => _ExamFormScreenState();
}

class _ExamFormScreenState extends State<ExamFormScreen> {
  final Dio _dio = ApiInterceptor.createDio(); // Use ApiInterceptor to create Dio instance
  final PageController _pageController = PageController();
  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();
  File? _selectedImage; // For the selected profile image
  File? _selectedImage2; // For the selected profile image

  final TextEditingController _rollCodeController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _fathersNameController = TextEditingController();
  final TextEditingController _mothersNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _ciyController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _phoneController.text = await sharedPreferencesHelper.getPref(Constant.PHONE) ?? '';
      _studentNameController.text = await sharedPreferencesHelper.getPref(Constant.USER_NAME) ?? '';
      _emailController.text = await sharedPreferencesHelper.getPref(Constant.EMAIL) ?? '';
      _phoneController.text = await sharedPreferencesHelper.getPref(Constant.PHONE) ?? '';
      _rollCodeController.text = await sharedPreferencesHelper.getPref(Constant.ROLL_CODE) ?? '';
print("object"+ await sharedPreferencesHelper.getPref(Constant.PHONE));
    });  }

  void _nextPage() {
    if (_currentIndex < 3) {
      setState(() {
        _currentIndex++;
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pageController.previousPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }
  /// Open image picker to select an image
  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }
  Future<void> pickImage2() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage2 = File(pickedFile.path);

        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _submitInfoForm() async {
    final String rollCode = _rollCodeController.text.trim();
    final String schoolName = _schoolNameController.text.trim();
    final String studentName = _studentNameController.text.trim();
    final String fathersName = _fathersNameController.text.trim();
    final String mothersName = _mothersNameController.text.trim();
    final String email = _emailController.text.trim();
    final String gender = _genderController.text.trim();
    final String category = _categoryController.text.trim();
    final String phone = _phoneController.text.trim();

    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (rollCode.isEmpty || schoolName.isEmpty || studentName.isEmpty ||fathersName.isEmpty || mothersName.isEmpty || email.isEmpty ||gender.isEmpty ||category.isEmpty ||phone.isEmpty) {
      Utils.snackBarInfo(context, 'All Fields Required');
      return;
    }
    if (!emailRegExp.hasMatch(email)) {
      Utils.snackBarInfo(context, 'Enter a Valid Email');
      return;
    }
    try {
      Utils.progressbar(context, CustomColors.themeColorBlack);
      final String apiUrl = Constant.BASE_URL + Constant.INFRORMATION;
    Response response = await _dio.post(
        apiUrl,
        data: {
          'StudentId': await sharedPreferencesHelper.getPref(Constant.USER_ID),
          "school_code": rollCode,
          'reg_no': phone,
          'school_name': studentName,
          'StudentName': studentName,
          'FatherName': fathersName,
          'MotherName': mothersName,
          'ParentGuardianContactNumber': phone,
          'Email': email,
          'Gender': gender,
          'Category': category,
        },
      );
      // print("Response Data---: ${response.data}");
      Navigator.pop(context);
      if (response.statusCode == 200) {
        if (response.data['status'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.data['message']}')));
        } else {
          _nextPage();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Otp Send Successfully')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to register')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Catch Error: $e')));
    }
  }

  Future<void> _submitAddressForm() async {
    final String houseNo = _houseNoController.text.trim();
    final String locality = _localityController.text.trim();
    final String city = _ciyController.text.trim();
    final String state = _stateController.text.trim();
    final String pinCode = _pinCodeController.text.trim();

    if (houseNo.isEmpty || locality.isEmpty || city.isEmpty ||state.isEmpty || pinCode.isEmpty) {
      Utils.snackBarInfo(context, 'All Fields Required');
      return;
    }

    try {
      Utils.progressbar(context, CustomColors.themeColorBlack);
      final String apiUrl = Constant.BASE_URL + Constant.UPDATE_ADDRESS_FORM;
    Response response = await _dio.post(
        apiUrl,
        data: {
          'StudentId': await sharedPreferencesHelper.getPref(Constant.USER_ID),
          "house_no": houseNo,
          'town': locality,
          'PresentState': state,
          'PresentCity': city,
          'PresentPinCode': pinCode,
        },
      );
      // print("Response Data---: ${response.data}");
      Navigator.pop(context);
      if (response.statusCode == 200) {
        if (response.data['status'] == 0) {
          Utils.snackBarInfo(context, 'Error: ${response.data['message']}');

        } else {
          Utils.snackBarInfo(context, 'Success: ${response.data['message']}');
          _nextPage();
        }
      } else {
        Utils.snackBarInfo(context, 'Failed to register');
      }
    } catch (e) {
      Utils.snackBarInfo(context, 'Catch Error: $e');

    }
  }


  Future<void> _uploadDocs() async {

      if (_selectedImage!.path.isEmpty || _selectedImage2!.path.isEmpty ) {
      Utils.snackBarInfo(context, 'All Fields Required');
      return;
    }

    try {
      Utils.progressbar(context, CustomColors.themeColorBlack);
      final String apiUrl = Constant.BASE_URL + Constant.UPDATE_STUDENT_IMAGE;
      Response response = await _dio.post(
        apiUrl,
        data: {
          'StudentId': await sharedPreferencesHelper.getPref(Constant.USER_ID),
          "photo_fileName": _selectedImage!.path.split('/').last,
          'sign_fileName':_selectedImage2!.path.split('/').last,
          'Photo_contantType': Utils.getContentType(_selectedImage!),
          'Photo_base64': await Utils.fileToBase64(_selectedImage!),
          'Sign_contantType':  Utils.getContentType(_selectedImage2!),
          'Sign_base64':await Utils.fileToBase64(_selectedImage2!),
        },
      );
      // print("Response Data---: ${response.data}");
      Navigator.pop(context);
      if (response.statusCode == 200) {
        if (response.data['status'] == 0) {
          Utils.snackBarInfo(context, 'Error: ${response.data['message']}');

        } else {
          Utils.snackBarInfo(context, 'Success: ${response.data['message']}');
          _nextPage();
        }
      } else {
        Utils.snackBarInfo(context, 'Failed to register');
      }
    } catch (e) {
      Utils.snackBarInfo(context, 'Catch Error: $e');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(CustomColors.theme_orange),
        title: const Text(
          "Preview Filled Form",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
        child: Text(
          "Form is not filled yet",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepIndicator(0, "Information"),
              _buildProgressLine(),
              _buildStepIndicator(1, "Address"),
              _buildProgressLine(),
              _buildStepIndicator(2, "Upload"),
              _buildProgressLine(),
              _buildStepIndicator(3, "Preview"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title) {
    bool isActive = _currentIndex >= step;
    bool isCompleted = _currentIndex > step; // Completed steps logic

    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isActive ? Color(CustomColors.theme_orange) : Colors.grey,
          child: isCompleted
              ? const Icon(
            Icons.check,
            color: Colors.white,
            size: 20,
          )
              : Text(
            "${step + 1}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }


  Widget _buildProgressLine() {
    return Expanded(
      child: Container(
        height: 2,
        color: _currentIndex > 0 ?Color(CustomColors.theme_orange) : Colors.grey,
      ),
    );
  }

  Widget _buildInformationPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildTextField("School Code", _rollCodeController),
          _buildTextField("School Name", _schoolNameController),
          _buildTextField("Student Name", _studentNameController),
          _buildTextField("Father Name", _fathersNameController),
          _buildTextField("Mother Name", _mothersNameController),
          _buildTextField("Mobile Number", _phoneController,isReadOnly: true),
          _buildTextField("Email Address", _emailController),
          _buildTextField("Gender", _genderController),
          _buildTextField("Category", _categoryController),
        ],
      ),
    );
  }

  Widget _buildAddressPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildTextField("House No., Building, Street",_houseNoController),
          _buildTextField("Locality / Town",_localityController),
          _buildTextField("City",_ciyController),
          _buildTextField("State",_stateController),
          _buildTextField("Pin Code",_pinCodeController),
        ],
      ),
    );
  }

  // Widget _buildUploadPage() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         const Text(
  //           "Upload Documents",
  //           style: TextStyle(
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //             color: Color(CustomColors.theme_orange),
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //         SizedBox(height: 24),
  //         _buildUploadSection(
  //           label: "Upload Your Photo",
  //           onUpload: () {
  //             pickImage();
  //           },
  //         ),
  //         SizedBox(height: 16),
  //         _buildUploadSection2(
  //           label: "Upload Your Signature",
  //           onUpload: () {
  //             pickImage2();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildUploadPage() {
    return SingleChildScrollView( // Wrap the entire widget with a scroll view
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Upload Documents",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(CustomColors.theme_orange),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            _buildUploadSection(
              label: "Upload Your Photo",
              onUpload: () {
                pickImage();
              },
            ),
            SizedBox(height: 16),
            _buildUploadSection2(
              label: "Upload Your Signature",
              onUpload: () {
                pickImage2();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection({
    required String label,
    required VoidCallback onUpload,
    File? selectedImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onUpload,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: _selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
                : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    "Click to Upload",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildUploadSection2({
    required String label,
    required VoidCallback onUpload,
    File? selectedImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onUpload,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: _selectedImage2 != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage2!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
                : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    "Click to Upload",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            "Preview Your Details",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(CustomColors.theme_orange),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Information Section
        _buildPreviewSection("Personal Information", [
          {'label': 'School Code', 'value': _rollCodeController.text},
          {'label': 'Registration Number', 'value': '022454445'},
          {'label': 'School Name', 'value': _schoolNameController.text},
          {'label': 'Student Name', 'value': _studentNameController.text},
          {'label': 'Father Name', 'value': _fathersNameController.text},
          {'label': 'Mother Name', 'value': _mothersNameController.text},
          {'label': 'Mobile Number', 'value': _phoneController.text},
          {'label': 'Email Address', 'value': _emailController.text},
          {'label': 'Gender', 'value': _genderController.text},
          {'label': 'Category', 'value': _categoryController.text},
          {'label': 'Address', 'value': 'House No. 1 Patna Bihar India 203022'},
        ]),
          const SizedBox(height: 16),

          // Address Section
          _buildPreviewSection("Address Details", [
            {'label': 'House No', 'value': _houseNoController.text},
            {'label': 'Locality', 'value': _localityController.text},
            {'label': 'City', 'value': _ciyController.text},
            {'label': 'State', 'value': _stateController.text},
            {'label': 'Pin Code', 'value': _pinCodeController.text},
          ]),


          const SizedBox(height: 16),

          // Uploaded Files Section
          // Uploaded Files Section
          const Text(
            "Uploaded Files",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

// Use Wrap for better screen adjustment
          Wrap(
            spacing: 16, // Horizontal spacing
            runSpacing: 16, // Vertical spacing
            children: [
              // Uploaded Photo
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 24, // Half of screen width
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 8),
                    _selectedImage != null
                        ? _buildFilePreview("Uploaded Photo", _selectedImage!)
                        : const Text("No Photo Uploaded."),
                  ],
                ),
              ),

              // Uploaded Signature
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 24, // Half of screen width
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 8),
                    _selectedImage2 != null
                        ? _buildFilePreview("Uploaded Signature", _selectedImage2!)
                        : const Text("No Signature Uploaded."),
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildPreviewSection(String title, List<Map<String, String>> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        // Two-column layout with labels and readonly text fields
        Wrap(
          spacing: 16, // Horizontal space between columns
          runSpacing: 16, // Vertical space between rows
          children: details.map((field) {
            return SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 24, // Two-column width
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: field['label']!, // Label above TextField
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFFF7043)),
                  ),
                ),
                child: Text(
                  field['value']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  Widget _buildFilePreview(String label, File file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: _currentIndex > 0 ? _previousPage : null,
            child: Text("Previous"),
          ),
          // ElevatedButton(
          //   onPressed: _currentIndex < 3 ? _nextPage : null,
          //   child: Text(_currentIndex < 3 ? "Continue" : "Submit"),
          // ),
          ElevatedButton(
            onPressed: () async {
              if (_currentIndex == 0) {
                await _submitInfoForm();
                // _nextPage();
              } else if (_currentIndex ==1 ) {
                _submitAddressForm();

              }else if (_currentIndex ==2 ) {
                _uploadDocs();

              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentIndex < 3 ? Color(CustomColors.theme_orange) : Colors.green, // Button color
              foregroundColor: Colors.white, // Text color
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(8), // Optional rounded corners
              // ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Padding
            ),

            child: Text(_currentIndex < 3 ? "Continue" : "Proceed to Payment"),
          ),

        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,{bool isReadOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        readOnly: isReadOnly,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }


  Widget _buildUploadButton(String label) {
    return OutlinedButton.icon(
      onPressed: () {
        // Implement file picker logic
      },
      icon: Icon(Icons.upload_file),
      label: Text(label),
    );
  }
  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _rollCodeController.dispose();
    _schoolNameController.dispose();
    _studentNameController.dispose();
    _fathersNameController.dispose();
    _mothersNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
