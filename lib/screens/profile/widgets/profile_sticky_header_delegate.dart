import 'dart:io';
import 'package:flutter/material.dart';
import 'package:right_touch/screens/profile/widgets/profile_header.dart';
import 'package:right_touch/screens/profile/widgets/profile_image_section.dart';
import 'package:right_touch/screens/profile/widgets/profile_user_info.dart';
import 'package:right_touch/utils/app_theme.dart';

class ProfileStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isOnline;
  final bool isLoading;
  final ValueChanged<bool> onToggleOnline;
  final File? imageFile;
  final String? profileImageUrl;
  final String userName;
  final String userRole;
  final double rating;
  final int ratingCount;
  final VoidCallback onImageTap;

  ProfileStickyHeaderDelegate({
    required this.isOnline,
    required this.isLoading,
    required this.onToggleOnline,
    this.imageFile,
    this.profileImageUrl,
    required this.userName,
    required this.userRole,
    required this.rating,
    required this.ratingCount,
    required this.onImageTap,
  });

  @override
  double get minExtent => 360.0;
  @override
  double get maxExtent => 360.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          ProfileHeader(
            isOnline: isOnline,
            isLoading: isLoading,
            onToggleOnline: onToggleOnline,
          ),
          const SizedBox(height: 20),
          ProfileImageSection(
            imageFile: imageFile,
            profileImageUrl: profileImageUrl,
            isLoading: isLoading,
            onTap: onImageTap,
          ),
          const SizedBox(height: 16),
          ProfileUserInfo(
            name: userName,
            role: userRole,
            rating: rating,
            ratingCount: ratingCount,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(ProfileStickyHeaderDelegate oldDelegate) {
    return oldDelegate.isOnline != isOnline ||
        oldDelegate.isLoading != isLoading ||
        oldDelegate.imageFile != imageFile ||
        oldDelegate.profileImageUrl != profileImageUrl ||
        oldDelegate.userName != userName ||
        oldDelegate.userRole != userRole ||
        oldDelegate.rating != rating ||
        oldDelegate.ratingCount != ratingCount;
  }
}
