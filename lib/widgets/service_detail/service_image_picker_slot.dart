import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:right_touch/utils/app_theme.dart';

class ServiceImagePickerSlot extends StatelessWidget {
  final String label;
  final String? imagePath;
  final ValueChanged<String> onImagePicked;

  const ServiceImagePickerSlot({
    super.key,
    required this.label,
    required this.imagePath,
    required this.onImagePicked,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: source, imageQuality: 70);
      if (photo != null) {
        onImagePicked(photo.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImagePreview(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(path), fit: BoxFit.contain),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null)
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Preview Image'),
                onTap: () {
                  Navigator.pop(context);
                  _showImagePreview(context, imagePath!);
                },
              ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _showOptions(context),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: imagePath != null
                    ? AppTheme.primaryColor
                    : AppTheme.grey.shade300,
                width: imagePath != null ? 2 : 1,
              ),
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(imagePath!), fit: BoxFit.cover),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: AppTheme.grey),
                      SizedBox(height: 4),
                      Text("Capture", style: TextStyle(fontSize: 12)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
