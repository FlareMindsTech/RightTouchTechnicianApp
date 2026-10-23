import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/wallet_transaction.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/wallet_provider.dart';
import 'package:right_touch/screens/profile/widgets/withdraw_bottom_sheet.dart';
import 'package:right_touch/screens/profile/widgets/wallet_transaction_tile.dart';
import 'package:right_touch/screens/profile/widgets/withdrawal_request_tile.dart';
import 'package:right_touch/screens/tabs/widgets/earnings_stat_card.dart';
import 'package:right_touch/screens/tabs/widgets/sliver_app_bar_delegate.dart';
import 'package:right_touch/screens/tabs/widgets/sticky_earnings_header_delegate.dart';
import 'package:right_touch/services/security_service.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/utils/money.dart';
import 'package:right_touch/widgets/empty_state.dart';
import 'package:right_touch/widgets/error_boundary.dart';
import 'package:right_touch/widgets/list_shimmer.dart';

class EarningsTab extends ConsumerStatefulWidget {
  const EarningsTab({super.key});

  @override
  ConsumerState<EarningsTab> createState() => _EarningsTabState();
}

class _EarningsTabState extends ConsumerState<EarningsTab>
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

    unawaited(HapticFeedback.mediumImpact());
    final result =
        await ref.read(walletProvider.notifier).requestWithdrawal(amount);
    if (!mounted) return;

    if (result['success'] == true) {
      unawaited(HapticFeedback.heavyImpact());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal request submitted successfully'),
          backgroundColor: AppTheme.green,
        ),
      );
    } else {
      unawaited(HapticFeedback.vibrate());
      ErrorHandler.showError(
        context,
        result['message'] ?? 'Failed to request withdrawal',
      );
    }
  }

  void _showWithdrawDialog(Money balance) {
    unawaited(HapticFeedback.mediumImpact());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: WithdrawBottomSheet(
          availableBalance: balance,
          onWithdraw: _handleWithdrawRequest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);

    return RefreshIndicator(
      onRefresh: () async {
        unawaited(HapticFeedback.mediumImpact());
        await ref.read(walletProvider.notifier).refresh();
      },
      color: AppTheme.primaryColor,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          final walletData = walletAsync.asData?.value;
          final balance = walletData?.balance ?? Money.zero;
          return [
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyEarningsHeaderDelegate(
                balance: balance,
                onWithdraw: balance.isPositive
                    ? () => _showWithdrawDialog(balance)
                    : null,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: EarningsStatCard(
                            label: 'Total Earned',
                            value: (walletData?.totalEarnings ?? Money.zero)
                                .formatted,
                            icon: Icons.trending_up,
                            color: AppTheme.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: EarningsStatCard(
                            label: 'Jobs Done',
                            value: '${walletData?.jobsDone ?? 0}',
                            icon: Icons.work_outline,
                            color: AppTheme.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.grey,
                  indicatorColor: AppTheme.primaryColor,
                  indicatorWeight: 3,
                  onTap: (_) => HapticFeedback.selectionClick(),
                  tabs: const [
                    Tab(text: 'Transactions'),
                    Tab(text: 'Withdrawals'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: walletAsync.when(
          loading: () => const Center(
            child: Padding(padding: EdgeInsets.all(20), child: ListShimmer()),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ErrorBoundary(
              message: ErrorHandler.parseError(err.toString()),
              onRetry: () => ref.read(walletProvider.notifier).refresh(),
              showTitle: false,
              isElevated: true,
              onLoginAgain: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
          ),
          data: (data) => TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionsList(data.transactions),
              _buildWithdrawalsList(data.withdrawRequests),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<WalletTransaction> transactions) {
    if (transactions.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: "No transactions yet",
        subtitle: "Your earnings will appear here",
        onRetry: () => ref.read(walletProvider.notifier).refresh(),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          WalletTransactionTile(transaction: transactions[index]),
    );
  }

  Widget _buildWithdrawalsList(List<WithdrawalRequest> requests) {
    if (requests.isEmpty) {
      return EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: "No withdrawal requests",
        subtitle: "Request withdrawals from your wallet balance",
        onRetry: () => ref.read(walletProvider.notifier).refresh(),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          WithdrawalRequestTile(request: requests[index]),
    );
  }
}
