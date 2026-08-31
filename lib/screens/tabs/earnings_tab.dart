import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/services/auth_service.dart';
import 'package:right_touch/services/network_service.dart';
import 'package:intl/intl.dart';
import 'package:right_touch/widgets/list_shimmer.dart';
import 'package:right_touch/widgets/empty_state.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/fade_in_slide.dart';
import 'package:right_touch/widgets/error_boundary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/auth_provider.dart';

class EarningsTab extends ConsumerStatefulWidget {
  const EarningsTab({super.key});

  @override
  ConsumerState<EarningsTab> createState() => _EarningsTabState();
}

class _EarningsTabState extends ConsumerState<EarningsTab>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  List<dynamic> _transactions = [];
  List<dynamic> _withdrawRequests = [];
  bool _isLoading = true;
  double _walletBalance = 0.0;
  double _totalEarnings = 0.0;
  int _jobsDone = 0;
  String? _errorMessage;
  late TabController _tabController;

  final TextEditingController _amountController = TextEditingController();
  bool _isWithdrawing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWalletData();
    NetworkService().isConnected.addListener(_onNetworkBack);
  }

  void _onNetworkBack() {
    if (NetworkService().isConnected.value && _errorMessage != null) {
      _loadWalletData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    NetworkService().isConnected.removeListener(_onNetworkBack);
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load wallet balance, transactions and withdrawal history in parallel
      final results = await Future.wait([
        _authService.getWalletBalance(),
        _authService.getWalletTransactions(),
        _authService.getWithdrawalHistory(),
      ]);

      if (!mounted) return;

      final balanceData = results[0];
      final transactionsData = results[1];
      final withdrawalHistory = results[2];

      // Calculate total earnings from wallet API
      double total = 0;
      int completedJobsCount = 0;

      final dynamic bData = balanceData;
      final dynamic tData = transactionsData;

      if (bData is Map && bData['success'] == true) {
        final dynamic resultData = bData['result'] ?? bData;
        if (resultData is Map) {
          total = (resultData['totalEarnings'] as num?)?.toDouble() ?? 0.0;
          final stats = resultData['stats'];
          if (stats != null && stats is Map) {
            completedJobsCount = (stats['approvedCount'] as num?)?.toInt() ?? 0;
          }
        }
      }

      setState(() {
        if (bData is Map) {
          _walletBalance =
              ((bData['balance'] ?? bData['availableBalance']) as num?)
                      ?.toDouble() ??
                  0.0;
        } else {
          _walletBalance = 0.0;
        }

        if (tData is Map) {
          _transactions = (tData['transactions'] as List?)
                  ?.whereType<Map<String, dynamic>>()
                  .toList() ??
              [];
        } else if (tData is List) {
          _transactions = tData.whereType<Map<String, dynamic>>().toList();
        }

        if (withdrawalHistory is List) {
          _withdrawRequests =
              withdrawalHistory.whereType<Map<String, dynamic>>().toList();
        } else {
          _withdrawRequests = [];
        }

        _totalEarnings = total;
        _jobsDone = completedJobsCount;
        _isLoading = false;

        if (bData is Map && bData['success'] == false) {
          _errorMessage = bData['message'] ?? 'Failed to load balance';
        } else if (tData is Map && tData['success'] == false) {
          _errorMessage = tData['message'] ?? 'Failed to load transactions';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _requestWithdrawal() async {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount', isError: true);
      return;
    }

    if (amount > _walletBalance) {
      _showSnackBar('Insufficient balance', isError: true);
      return;
    }

    setState(() => _isWithdrawing = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await _authService.requestWithdrawal(amount);

      if (mounted) {
        setState(() => _isWithdrawing = false);
        Navigator.pop(context);
        _amountController.clear();

        if (result['success']) {
          HapticFeedback.heavyImpact();
          _showSnackBar(
            'Withdrawal request submitted successfully',
            isError: false,
          );
          _loadWalletData();
        } else {
          HapticFeedback.vibrate();
          _showSnackBar(
            result['message'] ?? 'Failed to request withdrawal',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isWithdrawing = false);
        HapticFeedback.vibrate();
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    if (isError) {
      ErrorHandler.showError(context, message);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showWithdrawDialog() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Request Withdrawal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Available Balance: ₹${_walletBalance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => HapticFeedback.selectionClick(),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isWithdrawing ? null : _requestWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isWithdrawing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await _loadWalletData();
      },
      color: AppTheme.primaryColor,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // PINNED Header with Title and Balance Card
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyEarningsHeaderDelegate(
                balance: _walletBalance,
                onWithdraw: _walletBalance > 0
                    ? () {
                        HapticFeedback.mediumImpact();
                        _showWithdrawDialog();
                      }
                    : null,
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Earned',
                            '₹${_totalEarnings.toStringAsFixed(2)}',
                            Icons.trending_up,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Jobs Done',
                            '$_jobsDone',
                            Icons.work_outline,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // New Section: Earnings Breakdown (Scrollable but potentially locked)
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
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
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(20), child: ListShimmer()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20), // Sensible padding
        child: ErrorBoundary(
          message: ErrorHandler.parseError(_errorMessage!),
          onRetry: _loadWalletData,
          showTitle: false,
          isElevated: true,
          onLoginAgain: () {
            ref.read(authProvider.notifier).logout();
          },
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildTransactionsList(bottomPadding: 40),
        _buildWithdrawalsList(bottomPadding: 40),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList({double bottomPadding = 40}) {
    if (_transactions.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: "No transactions yet",
        subtitle: "Your earnings will appear here",
        onRetry: _loadWalletData,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
      itemCount: _transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final dynamic item = _transactions[index];
        if (item is! Map) {
          return const SizedBox.shrink();
        }
        final tx = item;
        final amount = (tx['amount'] ?? 0.0).toDouble();
        final type = tx['type'] ?? 'unknown';
        final description = tx['description'] ?? 'Transaction';
        final date = tx['createdAt'] != null
            ? DateTime.parse(tx['createdAt'])
            : DateTime.now();

        final isCredit = type == 'credit' || type == 'earning';

        return FadeInSlide(
          index: index,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: isCredit
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                description,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(date),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              trailing: Text(
                '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isCredit ? Colors.green : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWithdrawalsList({double bottomPadding = 40}) {
    if (_withdrawRequests.isEmpty) {
      return EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: "No withdrawal requests",
        subtitle: "Request withdrawals from your wallet balance",
        onRetry: _loadWalletData,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
      itemCount: _withdrawRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = _withdrawRequests[index];
        final amount = (request['amount'] ?? 0.0).toDouble();
        final status = request['status'] ?? 'pending';
        final date = request['createdAt'] != null
            ? DateTime.parse(request['createdAt'])
            : DateTime.now();

        Color statusColor = Colors.orange;
        if (status == 'completed') statusColor = Colors.green;
        if (status == 'rejected') statusColor = Colors.red;

        return FadeInSlide(
          index: index,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.1),
                child: Icon(Icons.payment, color: statusColor),
              ),
              title: Text(
                '₹${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StickyEarningsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double balance;
  final VoidCallback? onWithdraw;

  _StickyEarningsHeaderDelegate({required this.balance, this.onWithdraw});

  @override
  double get minExtent => 280.0;
  @override
  double get maxExtent => 280.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: const Text(
              "Wallet & Earnings",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'WALLET',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onWithdraw,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.account_balance_wallet, size: 20),
                      label: const Text(
                        'Withdraw Funds',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyEarningsHeaderDelegate oldDelegate) {
    return oldDelegate.balance != balance ||
        oldDelegate.onWithdraw != onWithdraw;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
