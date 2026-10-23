import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/rt_loader.dart';
import '../../providers/auth_provider.dart';
import 'package:right_touch/utils/app_theme.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _isLoading = false;

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              unawaited(_handleDelete());
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.deleteMyAccount();

      if (mounted) {
        setState(() => _isLoading = false);
        if (result['success'] == true || result['statusCode'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully.'),
              backgroundColor: AppTheme.green,
            ),
          );
          // Log out and go to login
          await ref.read(authProvider.notifier).logout();
          if (mounted) {
            context.go('/login');
          }
        } else {
          ErrorHandler.showError(
            context,
            result['message'] ?? 'Failed to delete account',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        foregroundColor: AppTheme.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.red,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'We are sorry to see you go',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Deleting your account will result in:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildBulletedItem('Permanent removal of your profile and data.'),
              _buildBulletedItem(
                'Loss of access to your job history and earnings.',
              ),
              _buildBulletedItem(
                'Cancellation of any active subscriptions or services.',
              ),
              const SizedBox(height: 32),
              const Text(
                'If you just want to take a break, you can simply go offline or logout.',
                style: TextStyle(fontSize: 14, color: AppTheme.grey),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _showDeleteConfirmation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.red,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const RtLoader.button(color: AppTheme.white)
                      : const Text(
                          'Delete My Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppTheme.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletedItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppTheme.black54),
            ),
          ),
        ],
      ),
    );
  }
}
