import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class ViewBankDetailsScreen extends ConsumerWidget {
  const ViewBankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bank Details"),
        centerTitle: true,
      ),
      body: authState.maybeWhen(
        authenticated: (user) {
          final bank = user.bankDetails ??
              user.rawData?['bankDetails'] ??
              user.rawData?['technician']?['bankDetails'];

          if (bank == null || bank is! Map) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Primary Account"),
                const SizedBox(height: 16),
                _buildBankCard(context, bank),
                const SizedBox(height: 32),
                _buildInfoNote(context),
              ],
            ),
          );
        },
        loading: () => const Center(child: RtLoader()),
        orElse: () => _buildEmptyState(context),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildBankCard(BuildContext context, Map<dynamic, dynamic> bank) {
    final accountHolder = bank['accountHolderName']?.toString() ??
        bank['accountHolder']?.toString() ??
        'Not provided';
    final bankName = bank['bankName']?.toString() ?? 'Not provided';
    final accountNumber = bank['accountNumber']?.toString() ??
        bank['bankAccountNumber']?.toString() ??
        bank['accountNo']?.toString() ??
        'Not provided';
    final ifscCode = bank['ifscCode']?.toString() ?? 'Not provided';
    final branchName = bank['branchName']?.toString() ?? 'Not provided';
    final upiId = bank['upiId']?.toString() ?? 'Not provided';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.account_balance, color: AppTheme.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  bankName,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "ACCOUNT NUMBER",
            style: TextStyle(
              color: AppTheme.white70,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            accountNumber,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildCardDetail("HOLDER NAME", accountHolder),
              ),
              Expanded(
                child: _buildCardDetail("IFSC CODE", ifscCode),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildCardDetail("BRANCH", branchName),
              ),
              Expanded(
                child: _buildCardDetail("UPI ID", upiId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.white70,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInfoNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.blue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "To update your bank details, please contact the support team or visit the KYC section.",
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.blue.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 80, color: AppTheme.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "No Bank Details Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please complete your KYC to add bank details.",
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
