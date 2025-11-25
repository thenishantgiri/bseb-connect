import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable dropdown field widget with consistent styling and validation
class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T? selectedValue;
  final List<T> items;
  final bool isRequired;
  final bool enabled;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;
  final String Function(T)? displayText;
  final String? hintText;

  const CustomDropdownField({
    Key? key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.enabled = true,
    this.validator,
    this.displayText,
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
          // Dropdown field
          DropdownButtonFormField<T>(
            value: selectedValue,
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  displayText != null ? displayText!(item) : item.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            style: TextStyle(
              color: enabled ? Colors.black : Colors.grey,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hintText ?? 'select_$label'.tr,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
              filled: !enabled,
              fillColor: !enabled ? Colors.grey.shade100 : null,
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
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            dropdownColor: Colors.white,
            menuMaxHeight: 300,
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

  String? _defaultValidator(T? value) {
    if (value == null) {
      return 'field_required'.tr;
    }
    return null;
  }
}