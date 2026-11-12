import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:right_touch/screens/profile/edit_profile_screen.dart';
import 'package:right_touch/screens/profile/edit_skills_screen.dart';
import 'package:right_touch/screens/profile/help_support_screen.dart';
import 'package:right_touch/screens/profile/legal_policy_screen.dart';
import 'package:right_touch/screens/profile/notifications_screen.dart';
import 'package:right_touch/screens/profile/refunds_history_screen.dart';
import 'package:right_touch/screens/profile/view_bank_details_screen.dart';
import 'package:right_touch/screens/profile/widgets/delete_account_dialog.dart';
import 'package:right_touch/screens/profile/widgets/logout_dialog.dart';
import 'package:right_touch/screens/profile/widgets/profile_image_picker_sheet.dart';
import 'package:right_touch/providers/notification_provider.dart';
import 'package:right_touch/screens/profile/widgets/profile_menu_item.dart';
import 'package:right_touch/services/location_tracking_service.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';

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

    if (!mounted) return;

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
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final fileLength = await pickedFile.length();
        if (!mounted) return;
        if (fileLength > 5 * 1024 * 1024) {
          ErrorHandler.showError(
            context,
            'Image size exceeds 5 MB limit. Please select a smaller photo.',
          );
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

      if (result['success'] == true) {
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

  String _getPolicyContent(String type) {
    switch (type) {
      case 'privacy':
        return "Right Touch takes your privacy seriously. We collect personal and service information solely to connect technicians with customer service requests, process payouts securely, verify technician credentials, and ensure community safety. Your sensitive personal data is protected using industry-standard AES encryption and is never sold to third parties.";
      case 'terms':
        return "By registering and operating as an independent service partner on Right Touch, you agree to fulfill accepted bookings promptly, maintain professional service standards, adhere to pricing guidelines, and respect customer property. Right Touch reserves the right to suspend or deactivate accounts that violate community guidelines or safety protocols.";
      case 'data_deletion':
        return "You have the right to request the permanent deletion of your partner account, profile details, and identity documents from our active database. Payout and tax transaction histories may be retained for the minimum period required by applicable financial regulations. To submit a deletion request, use the Delete Account option or contact partner support.";
      case 'gdpr':
        return "For partners operating in or originating from jurisdictions covered by GDPR/EEA regulations, Right Touch guarantees your rights to access, rectification, portability, and restriction of personal processing. You may exercise these rights at any time through our Data Protection Officer.";
      default:
        return "Right Touch Partner Policies & Guidelines. For full details or assistance, please reach out to our 24/7 technician support.";
    }
  }

  void _openLegalPolicy(String title, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LegalPolicyScreen(
          title: title,
          content: _getPolicyContent(type),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final dashboardData = ref.watch(dashboardDataProvider).asData?.value;

    String userName = "Technician";
    String userRole = "Service Partner";
    String? profileImageUrl;
    double? rating;
    bool isVerified = false;
    int completedJobs = dashboardData?.completedJobs ?? 0;

    authState.maybeWhen(
      authenticated: (userData) {
        userName = userData.fullDisplayName;
        bool isHexId(String? s) =>
            s != null && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(s.trim());

        if (userData.skills != null && userData.skills!.isNotEmpty) {
          final firstSkill = userData.skills!.first;
          userRole =
              isHexId(firstSkill) ? "Certified Service Partner" : firstSkill;
        } else if (userData.role != null &&
            userData.role!.isNotEmpty &&
            !isHexId(userData.role)) {
          userRole = userData.role!;
        } else {
          userRole = "Certified Service Partner";
        }
        profileImageUrl = userData.profileImage ??
            userData.profile?['profileImage']?.toString() ??
            userData.rawData?['profileImage']?.toString();
        final userRating = userData.rating ??
            userData.averageRating ??
            (userData.avgRating > 0 ? userData.avgRating : null);
        rating = userRating;
        isVerified = userData.kycVerified == true || userData.isVerified == true;
      },
      orElse: () {},
    );

    final unreadNotificationCount =
        ref.watch(unreadNotificationCountProvider).value ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── 1. Curved Green Header ─────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 18,
                    left: 20,
                    right: 20,
                    bottom: 95,
                  ),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top Row: "My Profile" & On-Duty Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "My Profile",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          // On-Duty Capsule
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007A3E).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppTheme.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _isOnline
                                        ? const Color(0xFF69F0AE)
                                        : const Color(0xFFFFB74D),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isOnline ? "ON-DUTY" : "OFF-DUTY",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.white,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Transform.scale(
                                  scale: 0.72,
                                  child: Switch(
                                    value: _isOnline,
                                    onChanged: _isLoading ? null : _toggleOnline,
                                    activeThumbColor: AppTheme.white,
                                    activeTrackColor: const Color(0xFF00C853),
                                    inactiveThumbColor: AppTheme.white,
                                    inactiveTrackColor: Colors.black26,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Profile Avatar with Camera Badge
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.white,
                                  width: 3.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _imageFile != null
                                    ? Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                        width: 90,
                                        height: 90,
                                      )
                                    : (profileImageUrl != null &&
                                            profileImageUrl!.isNotEmpty)
                                        ? Image.network(
                                            profileImageUrl!,
                                            fit: BoxFit.cover,
                                            width: 90,
                                            height: 90,
                                            errorBuilder: (context, error, stackTrace) =>
                                                _buildDefaultAvatar(),
                                          )
                                        : _buildDefaultAvatar(),
                              ),
                            ),
                            // Camera Edit Button
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => ProfileImagePickerSheet.show(
                                  context,
                                  onSelected: _pickImage,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007A3E),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: AppTheme.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Technician Name
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Skill / Specialization
                      Text(
                        userRole,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Verified Technician Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007A3E).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF69F0AE).withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF69F0AE),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isVerified ? "Verified technician" : "Partner technician",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── 2. Dual Floating Stats Cards ─────────────────────
                Positioned(
                  bottom: -36,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      // Card 1: Completed Jobs
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Color(0xFF00A859),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "$completedJobs",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Jobs",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Card 2: Rating
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF57C00),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (rating != null && rating! > 0)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      rating!.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.black,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Color(0xFFF57C00),
                                    ),
                                  ],
                                )
                              else
                                const Text(
                                  "--",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.black,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                "Rating",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 52),

            // ─── 3. Section: ACCOUNT & SERVICES ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ACCOUNT & SERVICES",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.grey[600],
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Menu Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.person_outline_rounded,
                          iconColor: const Color(0xFF00A859),
                          iconBgColor: const Color(0xFFE8F5E9),
                          title: "Edit Profile",
                          subtitle: "Personal info & contact details",
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                            if (result == true) _loadProfile();
                          },
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.psychology_outlined,
                          iconColor: const Color(0xFF7E57C2),
                          iconBgColor: const Color(0xFFEDE7F6),
                          title: "Skills & Services",
                          subtitle: "Service categories & expertise",
                          onTap: _navigateToEditSkills,
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.account_balance_outlined,
                          iconColor: const Color(0xFFFFA000),
                          iconBgColor: const Color(0xFFFFF8E1),
                          title: "Bank & KYC Details",
                          subtitle: "Payout account & verification",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ViewBankDetailsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.currency_exchange_rounded,
                          iconColor: const Color(0xFFF57C00),
                          iconBgColor: const Color(0xFFFFF3E0),
                          title: "Refunds History",
                          subtitle: "Deducted customer refunds",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RefundsHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.notifications_none_rounded,
                          iconColor: const Color(0xFF1976D2),
                          iconBgColor: const Color(0xFFE3F2FD),
                          title: "Notifications",
                          subtitle: "Alerts, broadcasts & updates",
                          badgeText: unreadNotificationCount > 0
                              ? '$unreadNotificationCount'
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── 4. Section: SUPPORT & LEGAL ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SUPPORT & LEGAL",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.grey[600],
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Menu Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.help_outline_rounded,
                          iconColor: const Color(0xFF0288D1),
                          iconBgColor: const Color(0xFFE1F5FE),
                          title: "Help & Support",
                          subtitle: "FAQs, contact admin & live help",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpSupportScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.privacy_tip_outlined,
                          iconColor: const Color(0xFF7B1FA2),
                          iconBgColor: const Color(0xFFF3E5F5),
                          title: "Privacy Policy",
                          subtitle: "How we protect your data",
                          onTap: () =>
                              _openLegalPolicy("Privacy Policy", "privacy"),
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.gavel_rounded,
                          iconColor: const Color(0xFF5E35B1),
                          iconBgColor: const Color(0xFFEDE7F6),
                          title: "Terms of Service",
                          subtitle: "Platform terms & technician agreement",
                          onTap: () =>
                              _openLegalPolicy("Terms of Service", "terms"),
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.folder_delete_outlined,
                          iconColor: const Color(0xFFF57F17),
                          iconBgColor: const Color(0xFFFFFDE7),
                          title: "Data Deletion Policy",
                          subtitle: "Information removal requests",
                          onTap: () => _openLegalPolicy(
                            "Data Deletion Policy",
                            "data-deletion",
                          ),
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.verified_user_outlined,
                          iconColor: const Color(0xFF2E7D32),
                          iconBgColor: const Color(0xFFE8F5E9),
                          title: "GDPR Compliance",
                          subtitle: "Rights for EU/EEA partners",
                          onTap: () =>
                              _openLegalPolicy("GDPR Compliance", "gdpr"),
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.delete_outline_rounded,
                          iconColor: const Color(0xFFD32F2F),
                          iconBgColor: const Color(0xFFFFEBEE),
                          title: "Delete Account",
                          subtitle: "Permanently remove your partner profile",
                          isDestructive: true,
                          onTap: () => DeleteAccountDialog.show(context, ref),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── 5. Full-Width Log Out Card Button ───────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () => LogoutDialog.show(context, ref),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0).withValues(alpha: 0.6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFE53935),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.7,
      indent: 72,
      endIndent: 16,
      color: Color(0xFFEEEEEE),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFF007A3E),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 48,
          color: AppTheme.white,
        ),
      ),
    );
  }
}
