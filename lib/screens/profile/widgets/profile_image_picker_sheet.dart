import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePickerSheet {
  static void show(
    BuildContext context, {
    required Function(ImageSource source) onSelected,
  }) {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: const Text('Camera'),
              onPressed: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                onSelected(ImageSource.camera);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Gallery'),
              onPressed: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                onSelected(ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  onSelected(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  onSelected(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}
