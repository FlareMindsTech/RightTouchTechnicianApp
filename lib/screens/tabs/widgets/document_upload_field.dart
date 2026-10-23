import 'dart:io';
import 'package:flutter/material.dart';
import 'package:right_touch/utils/app_theme.dart';

class DocumentUploadField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hint;
  final String? path;
  final VoidCallback onUpload;
  final String? title2;
  final String? path2;
  final VoidCallback? onUpload2;

  const DocumentUploadField({
    super.key,
    required this.title,
    required this.controller,
    required this.hint,
    required this.path,
    required this.onUpload,
    this.title2,
    this.path2,
    this.onUpload2,
  });

  Widget _buildUploadBox(String? filePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: filePath != null ? AppTheme.green : AppTheme.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: filePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: filePath.startsWith('http')
                      ? Image.network(filePath, fit: BoxFit.cover)
                      : Image.file(File(filePath), fit: BoxFit.cover),
                )
              : const Icon(
                  Icons.cloud_upload_outlined,
                  color: AppTheme.grey,
                  size: 40,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildUploadBox(path, onUpload)),
            if (onUpload2 != null) ...[
              const SizedBox(width: 12),
              Expanded(child: _buildUploadBox(path2, onUpload2!)),
            ],
          ],
        ),
      ],
    );
  }
}
