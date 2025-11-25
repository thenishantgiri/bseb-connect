import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable password field widget with visibility toggle
class CustomPasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPasswordHidden;
  final VoidCallback toggleVisibility;
  final bool isRequired;
  final String? Function(String?)? validator;
  final String? hintText;

  const CustomPasswordField({
    Key? key,
    required this.label,
    required this.controller,
    required this.isPasswordHidden,
    required this.toggleVisibility,
    this.isRequired = false,
    this.validator,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with optional asterisk for required fields
          _buildLabel(),
          const SizedBox(height: 4),
          // Password field
          TextFormField(
            controller: controller,
            obscureText: isPasswordHidden,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText ?? 'enter_$label'.tr,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: toggleVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: validator ?? (isRequired ? _defaultValidator : null),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          label.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'password_required'.tr;
    }
    if (value.length < 6) {
      return 'password_min_length'.tr;
    }
    return null;
  }
}