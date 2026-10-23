import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/screens/profile/edit_profile_screen.dart';
import 'package:right_touch/screens/profile/edit_skills_screen.dart';
import 'package:right_touch/screens/profile/help_support_screen.dart';
import 'package:right_touch/screens/profile/legal_policy_screen.dart';
import 'package:right_touch/screens/profile/service_history_screen.dart';
import 'package:right_touch/screens/profile/view_bank_details_screen.dart';
import 'package:right_touch/screens/profile/widgets/delete_account_dialog.dart';
import 'package:right_touch/screens/profile/widgets/logout_dialog.dart';
import 'package:right_touch/screens/profile/widgets/profile_image_picker_sheet.dart';
import 'package:right_touch/screens/profile/widgets/profile_menu_item.dart';
import 'package:right_touch/screens/profile/widgets/profile_sticky_header_delegate.dart';
import 'package:right_touch/services/location_tracking_service.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/utils/ux_helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:right_touch/utils/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isOnline = true;
  bool _isLoading = false;
  bool _isProcessInProgress = false;
  File? _imageFile;

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

  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessInProgress) return;
    setState(() => _isProcessInProgress = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        if (!mounted) {
          setState(() => _isProcessInProgress = false);
          return;
        }
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        unawaited(_uploadImage(pickedFile.path));
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

  Future<void> _toggleOnline(bool value) async {
    unawaited(HapticFeedback.mediumImpact());
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
          unawaited(ref.read(locationServiceProvider).startTracking());
        } else {
          ref.read(locationServiceProvider).stopTracking();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value ? 'You are now Online' : 'You are now Offline',
              ),
              backgroundColor: value ? AppTheme.green : AppTheme.orange,
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
          ErrorHandler.showError(context, errorMessage);
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
              delegate: ProfileStickyHeaderDelegate(
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
                onImageTap: () => ProfileImagePickerSheet.show(
                  context,
                  onSelected: _pickImage,
                ),
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
                onTap: _navigateToEditSkills,
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
                onTap: () =>
                    _launchPolicy("https://righttouch.vercel.app/privacy/"),
              ),
              ProfileMenuItem(
                icon: Icons.gavel_outlined,
                text: "Terms of Service",
                onTap: () =>
                    _launchPolicy("https://righttouch.vercel.app/terms/"),
              ),
              ProfileMenuItem(
                icon: Icons.delete_forever_outlined,
                text: "Data Deletion Policy",
                onTap: () =>
                    _launchPolicy("https://righttouch.vercel.app/datadeletion/"),
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
                textColor: AppTheme.red,
                onTap: () => DeleteAccountDialog.show(context, ref),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () => LogoutDialog.show(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.red,
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
}
