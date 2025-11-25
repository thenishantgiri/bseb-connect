import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Reusable text field widget with consistent styling and validation
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int maxLines;
  final String? hintText;
  final Widget? suffixIcon;
  final bool obscureText;
  final Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
    this.hintText,
    this.suffixIcon,
    this.obscureText = false,
    this.onChanged,
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
          // Text field
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType ?? TextInputType.text,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            maxLines: maxLines,
            obscureText: obscureText,
            onChanged: onChanged,
            style: TextStyle(
              color: enabled ? Colors.black : Colors.grey,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hintText ?? 'enter_$label'.tr,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
              suffixIcon: suffixIcon,
              filled: !enabled,
              fillColor: !enabled ? Colors.grey.shade100 : null,
              counterText: '', // Hide character counter
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
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
      return 'field_required'.tr;
    }
    return null;
  }
}