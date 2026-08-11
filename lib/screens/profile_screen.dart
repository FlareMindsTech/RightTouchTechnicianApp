import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/utils/ux_helpers.dart';
import 'package:right_touch/screens/profile/edit_profile_screen.dart';
import 'package:right_touch/services/location_tracking_service.dart';
import 'package:right_touch/screens/profile/service_history_screen.dart';
import 'package:right_touch/screens/profile/help_support_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/screens/profile/legal_policy_screen.dart';
import 'package:right_touch/screens/profile/edit_skills_screen.dart';
import 'package:right_touch/screens/profile/view_bank_details_screen.dart';
import 'package:right_touch/screens/profile/widgets/profile_header.dart';
import 'package:right_touch/screens/profile/widgets/profile_image_section.dart';
import 'package:right_touch/screens/profile/widgets/profile_user_info.dart';
import 'package:right_touch/screens/profile/widgets/profile_menu_item.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isOnline = true;
  bool _isLoading = false;
  bool _isProcessInProgress = false; // Guard for pick/crop
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessInProgress) return;
    setState(() => _isProcessInProgress = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70, // Optimize image size
      );

      if (pickedFile != null) {
        if (!mounted) {
          setState(() => _isProcessInProgress = false);
          return;
        }
        // Direct upload without cropping
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        _uploadImage(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessInProgress = false);
      }
    }
  }

  Future<void> _uploadImage(String path) async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.uploadProfileImage(path);
      if (mounted) setState(() => _isLoading = false);

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully')),
          );
        }
      } else {
        if (mounted) {
          ErrorHandler.showError(
            context,
            result['message'] ?? 'Failed to upload image',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
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
                _pickImage(ImageSource.camera);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Gallery'),
              onPressed: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                _pickImage(ImageSource.gallery);
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
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final authState = ref.read(authProvider);
    final savedStatus =
        await ref.read(authRepositoryProvider).loadAvailabilityStatus();

    authState.maybeWhen(
      authenticated: (user) {
        setState(() {
          _isOnline = user.isOnline;
        });
      },
      orElse: () {
        setState(() {
          _isOnline = savedStatus;
        });
      },
    );
  }

  Future<void> _toggleOnline(bool value) async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.updateTechnicianProfile({
        'availability': {'isOnline': value},
      });

      if (mounted) setState(() => _isLoading = false);

      if (result['success']) {
        if (mounted) setState(() => _isOnline = value);
        await repository.saveAvailabilityStatus(value);

        if (value) {
          ref.read(locationServiceProvider).startTracking();
        } else {
          ref.read(locationServiceProvider).stopTracking();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value ? 'You are now Online' : 'You are now Offline',
              ),
              backgroundColor: value ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          String errorMessage = result['message'] ?? 'Failed to update status';
          if (errorMessage.toLowerCase().contains('trainingcompleted') ||
              errorMessage.toLowerCase().contains('cannot set online true')) {
            errorMessage = 'Verification needed. Try to contact admin.';
          }
          ErrorHandler.showError(
            context,
            errorMessage,
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.toLowerCase().contains('trainingcompleted') ||
            errorMessage.toLowerCase().contains('cannot set online true')) {
          errorMessage = 'Verification needed. Try to contact admin.';
        }
        ErrorHandler.showError(context, errorMessage);
      }
    }
  }

  void _navigateToEditSkills() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditSkillsScreen()),
    ).then((_) => _loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    Map<String, dynamic>? user;
    authState.maybeWhen(
      authenticated: (userData) {
        final rawData = userData.rawData;
        final profile = userData.profile;

        final Map<String, dynamic> baseData = (rawData is Map)
            ? Map<String, dynamic>.from(rawData as Map)
            : (profile is Map ? Map<String, dynamic>.from(profile as Map) : {});

        user = Map<String, dynamic>.from(baseData);
        user!['name'] = userData.fullDisplayName;
        user!['role'] = userData.role;

        final pMap = userData.profile;
        final pImg = pMap?['profileImage'];
        final rMap = userData.rawData;
        final rImg = rMap?['profileImage'];

        user!['profileImage'] = user!['profileImage'] ?? pImg ?? rImg;
      },
      orElse: () => user = null,
    );

    final userName = user?['name'] ?? "Technician";
    final userRole = user?['role'] ?? "Professional Service Provider";
    final profileImageUrl = user?['profileImage']?.toString();

    return SafeArea(
      child: NestedScrollView(
        physics: const ClampingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileStickyHeaderDelegate(
                isOnline: _isOnline,
                isLoading: _isLoading,
                onToggleOnline: _toggleOnline,
                imageFile: _imageFile,
                profileImageUrl: profileImageUrl,
                userName: userName,
                userRole: userRole,
                rating: authState.maybeWhen(
                    authenticated: (u) => u.avgRating, orElse: () => 4.5),
                ratingCount: authState.maybeWhen(
                    authenticated: (u) => u.ratingCount, orElse: () => 0),
                onImageTap: () => _showImageSourceActionSheet(context),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Column(
            children: [
              ProfileMenuItem(
                icon: Icons.person_outline,
                text: "Edit Profile",
                onTap: () async {
                  if (!mounted) return;
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadProfile();
                  }
                },
              ),
              ProfileMenuItem(
                icon: Icons.psychology_outlined,
                text: "Edit Skills",
                onTap: () {
                  _navigateToEditSkills();
                },
              ),
              ProfileMenuItem(
                icon: Icons.account_balance_outlined,
                text: "Bank Details",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewBankDetailsScreen(),
                    ),
                  );
                },
              ),
              ProfileMenuItem(
                icon: Icons.history,
                text: "Service History",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServiceHistoryScreen(),
                    ),
                  );
                },
              ),
              ProfileMenuItem(
                icon: Icons.help_outline,
                text: "Help & Support",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 40, thickness: 1),
              ProfileMenuItem(
                icon: Icons.privacy_tip_outlined,
                text: "Privacy Policy",
                onTap: () {
                  _launchPolicy("https://righttouch.vercel.app/privacy/");
                },
              ),
              ProfileMenuItem(
                icon: Icons.gavel_outlined,
                text: "Terms of Service",
                onTap: () {
                  _launchPolicy("https://righttouch.vercel.app/terms/");
                },
              ),
              ProfileMenuItem(
                icon: Icons.delete_forever_outlined,
                text: "Data Deletion Policy",
                onTap: () {
                  _launchPolicy("https://righttouch.vercel.app/datadeletion/");
                },
              ),
              ProfileMenuItem(
                icon: Icons.security_outlined,
                text: "GDPR Compliance",
                onTap: () {
                  _showLegalPolicy(
                    context,
                    "GDPR Compliance",
                    "If you are located in the European Union (EU), we process your personal data in accordance with the General Data Protection Regulation (GDPR). We collect and use personal data only where we have a lawful basis, including: To provide and operate the platform, To comply with legal obligations, For legitimate business interests, and description With your consent.\n\nYour Rights:\nEEA users have the right to:\n• Access their personal data\n• Correct inaccurate data\n• Request deletion of their data\n• Restrict or object to processing\n• Request data portability\n• Withdraw consent at any time\n\nTo exercise these rights, contact us at support@righttouch.com. Your data may be processed on secure servers outside the EU with appropriate safeguards in place. You also have the right to lodge a complaint with your local data protection authority.",
                  );
                },
              ),
              ProfileMenuItem(
                icon: Icons.delete_outline,
                text: "Delete Account",
                textColor: Colors.red,
                onTap: () {
                  _showDeleteAccountConfirmation();
                },
              ),
              const SizedBox(height: 20),
              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () async {
                    final router = GoRouter.of(context);
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text("Logout Confirmation"),
                          content: const Text(
                            "Are you sure you want to log out? Please stay professional.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text("Log Out"),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldLogout == true) {
                      await ref.read(authProvider.notifier).logout();
                      if (mounted) {
                        router.go('/login');
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Log Out"),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showLegalPolicy(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LegalPolicyScreen(title: title, content: content),
      ),
    );
  }

  Future<void> _launchPolicy(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        UXDialog.showError(context: context, message: 'Could not launch $url');
      }
    }
  }

  Future<void> _showDeleteAccountConfirmation() async {
    HapticFeedback.mediumImpact();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Delete Account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Text(
                'This action cannot be undone. All your data including:',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              ...[
                '• Profile information',
                '• Job history',
                '• Earnings records',
                '• Settings and preferences',
              ].map(
                (item) => Padding(
                  padding: EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'will be permanently deleted.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      // Second confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Final Confirmation',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              'This is your last chance. Are you absolutely sure you want to delete your account?',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop(false);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Yes, Delete My Account'),
              ),
            ],
          );
        },
      );

      if (confirmed == true && mounted) {
        _deleteAccount();
      }
    }
  }

  Future<void> _deleteAccount() async {
    HapticFeedback.heavyImpact();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          margin: EdgeInsets.all(40),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Deleting your account...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final result = await ref.read(authProvider.notifier).deleteAccount();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (result['success'] == true) {
        if (mounted) {
          HapticFeedback.heavyImpact();
          GoRouter.of(context).go('/login');

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Your account has been deleted successfully'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        if (mounted) {
          HapticFeedback.vibrate();
          ErrorHandler.showError(
            context,
            result['message'] ?? 'Failed to delete account',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        HapticFeedback.vibrate();
        ErrorHandler.showError(context, e);
      }
    }
  }
}

class _ProfileStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
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

  _ProfileStickyHeaderDelegate({
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
      color: Colors.white,
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
  bool shouldRebuild(_ProfileStickyHeaderDelegate oldDelegate) {
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
