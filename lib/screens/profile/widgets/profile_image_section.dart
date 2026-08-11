import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:right_touch/utils/app_theme.dart';

class ProfileImageSection extends StatelessWidget {
  final File? imageFile;
  final String? profileImageUrl;
  final bool isLoading;
  final VoidCallback onTap;

  const ProfileImageSection({
    super.key,
    this.imageFile,
    this.profileImageUrl,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Material(
            elevation: 4,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isLoading ? null : onTap,
              splashColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              highlightColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: const Color(0xFFF5F5F5),
                backgroundImage: imageFile != null
                    ? FileImage(imageFile!) as ImageProvider
                    : (profileImageUrl?.isNotEmpty ?? false)
                        ? CachedNetworkImageProvider(profileImageUrl!)
                        : null,
                child: imageFile == null && (profileImageUrl?.isEmpty ?? true)
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Material(
                color: AppTheme.primaryColor,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                elevation: 4,
                child: InkWell(
                  onTap: isLoading ? null : onTap,
                  splashColor: Colors.white24,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
