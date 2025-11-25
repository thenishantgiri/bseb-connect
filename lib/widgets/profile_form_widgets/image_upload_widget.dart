import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Reusable image upload widget for photo and signature
class ImageUploadWidget extends StatelessWidget {
  final String label;
  final File? selectedFile;
  final String? networkImageUrl;
  final VoidCallback onTap;
  final bool isRequired;
  final double height;
  final double width;
  final IconData placeholderIcon;

  const ImageUploadWidget({
    Key? key,
    required this.label,
    required this.selectedFile,
    required this.networkImageUrl,
    required this.onTap,
    this.isRequired = false,
    this.height = 150,
    this.width = double.infinity,
    this.placeholderIcon = Icons.camera_alt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          _buildLabel(),
          const SizedBox(height: 8),
          // Upload container
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: _buildImageContent(),
            ),
          ),
          const SizedBox(height: 4),
          // Help text
          Text(
            'tap_to_upload'.tr,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
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
            fontWeight: FontWeight.w600,
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

  Widget _buildImageContent() {
    // Priority: Selected file > Network image > Placeholder
    if (selectedFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          selectedFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    } else if (networkImageUrl != null && networkImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          networkImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          placeholderIcon,
          size: 40,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'tap_to_select'.tr,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}