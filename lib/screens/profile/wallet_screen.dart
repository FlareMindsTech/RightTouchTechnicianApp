import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/wallet_transaction.dart';
import 'package:right_touch/providers/wallet_provider.dart';
import 'package:right_touch/screens/profile/widgets/wallet_balance_card.dart';
import 'package:right_touch/screens/profile/widgets/wallet_transaction_tile.dart';
import 'package:right_touch/screens/profile/widgets/withdraw_bottom_sheet.dart';
import 'package:right_touch/screens/profile/widgets/withdrawal_request_tile.dart';
import 'package:right_touch/services/security_service.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/utils/money.dart';
import 'package:right_touch/widgets/list_shimmer.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleWithdrawRequest(Money amount) async {
    final securityError = await SecurityService.checkSensitiveActionSecurity();
    if (securityError != null) {
      if (mounted) {
        ErrorHandler.showError(context, securityError);
      }
      return;
    }

    final result =
        await ref.read(walletProvider.notifier).requestWithdrawal(amount);
    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal request submitted successfully'),
          backgroundColor: AppTheme.green,
        ),
      );
    } else {
      ErrorHandler.showError(
        context,
        result['message'] ?? 'Failed to request withdrawal',
      );
    }
  }

  void _showWithdrawDialog(Money balance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WithdrawBottomSheet(
        availableBalance: balance,
        onWithdraw: _handleWithdrawRequest,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('My Wallet'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        foregroundColor: AppTheme.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Transactions'),
            Tab(text: 'Withdrawals'),
          ],
        ),
      ),
      body: walletAsync.when(
        loading: () => const ListShimmer(),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.red),
              const SizedBox(height: 12),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(walletProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => Column(
          children: [
            WalletBalanceCard(
              balance: data.balance,
              onWithdraw: () => _showWithdrawDialog(data.balance),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactionsList(data.transactions),
                  _buildWithdrawalsList(data.withdrawRequests),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<WalletTransaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.grey),
            SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(color: AppTheme.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(walletProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: transactions.length,
        itemBuilder: (context, index) =>
            WalletTransactionTile(transaction: transactions[index]),
      ),
    );
  }

  Widget _buildWithdrawalsList(List<WithdrawalRequest> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppTheme.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No withdrawal requests',
              style: TextStyle(color: AppTheme.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(walletProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: requests.length,
        itemBuilder: (context, index) =>
            WithdrawalRequestTile(request: requests[index]),
      ),
    );
  }
}
