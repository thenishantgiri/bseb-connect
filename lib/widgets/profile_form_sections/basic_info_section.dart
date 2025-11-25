import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../profile_form_widgets/custom_text_field.dart';
import '../profile_form_widgets/custom_dropdown_field.dart';

/// Section widget for basic student information
class BasicInfoSection extends StatelessWidget {
  final String? selectedClass;
  final TextEditingController nameController;
  final String? selectedGender;
  final Function(String?) onClassChanged;
  final Function(String?) onGenderChanged;

  const BasicInfoSection({
    Key? key,
    required this.selectedClass,
    required this.nameController,
    required this.selectedGender,
    required this.onClassChanged,
    required this.onGenderChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> classList = ["9th", "10th", "11th", "12th", "other"];
    final List<String> genderList = ["Male", "Female", "Transgender"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        _buildSectionHeader(),
        const SizedBox(height: 16),

        // Class Selection
        CustomDropdownField<String>(
          label: 'class',
          selectedValue: selectedClass,
          items: classList,
          onChanged: onClassChanged,
          isRequired: true,
          hintText: 'select_class'.tr,
        ),

        // Full Name
        CustomTextField(
          label: 'full_name',
          controller: nameController,
          isRequired: true,
          keyboardType: TextInputType.name,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'name_required'.tr;
            }
            if (value.trim().length < 3) {
              return 'name_too_short'.tr;
            }
            return null;
          },
        ),

        // Gender Selection
        CustomDropdownField<String>(
          label: 'gender',
          selectedValue: selectedGender,
          items: genderList,
          onChanged: onGenderChanged,
          isRequired: true,
          hintText: 'select_gender'.tr,
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            color: Colors.blue.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'basic_information'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}