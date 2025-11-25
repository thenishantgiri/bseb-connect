import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable custom text field with consistent styling
///
/// Provides common text input configurations used throughout the app
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Specialized phone number field
class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  const PhoneTextField({
    super.key,
    this.controller,
    this.labelText,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText ?? 'Phone Number',
      hintText: '10 digit mobile number',
      prefixIcon: Icons.phone,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            if (value.length != 10) {
              return 'Please enter a valid 10-digit phone number';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}

/// Example usage:
///
/// ```dart
/// CustomTextField(
///   controller: _emailController,
///   labelText: 'Email',
///   hintText: 'Enter your email',
///   prefixIcon: Icons.email,
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) {
///     if (value?.isEmpty ?? true) return 'Email required';
///     return null;
///   },
/// )
///
/// PhoneTextField(
///   controller: _phoneController,
///   onChanged: (value) => print(value),
/// )
/// ```
