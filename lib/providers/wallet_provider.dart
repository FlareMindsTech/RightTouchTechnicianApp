import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/wallet_transaction.dart';
import 'package:right_touch/data/repositories/dashboard_repository.dart';
import 'package:right_touch/utils/money.dart';

final walletProvider =
    AsyncNotifierProvider<WalletNotifier, WalletData>(() => WalletNotifier());

class WalletNotifier extends AsyncNotifier<WalletData> {
  @override
  Future<WalletData> build() async {
    return _fetchWalletData();
  }

  Future<WalletData> _fetchWalletData({bool forceRefresh = false}) async {
    final repo = ref.read(dashboardRepositoryProvider);

    final results = await Future.wait([
      repo.getWalletBalance(forceRefresh: forceRefresh),
      repo.getWalletTransactions(forceRefresh: forceRefresh),
      repo.getWalletHistory(forceRefresh: forceRefresh),
      repo.getFinanceEarnings().catchError((_) => <String, dynamic>{}),
    ]);

    final bData = results[0];
    final transactionsData = results[1];
    final withdrawalHistory = results[2] as List<dynamic>;
    final financeData = results[3] as Map<String, dynamic>;

    Money balance = Money.zero;
    Money totalEarnings = Money.zero;
    int jobsDone = 0;

    if (financeData.isNotEmpty) {
      final totalVal = financeData['totalEarnings'] ??
          financeData['grossEarnings'] ??
          financeData['earnings'];
      if (totalVal != null) {
        totalEarnings = Money.fromDynamic(totalVal);
      }
      if (financeData['jobsCompleted'] != null) {
        jobsDone = (financeData['jobsCompleted'] as num).toInt();
      }
    }

    if (bData is Map) {
      final balanceVal = bData['balance'] is Map
          ? (bData['balance']['balance'] ?? 0)
          : (bData['balance'] ?? bData['availableBalance'] ?? 0);
      balance = Money.fromDynamic(balanceVal);

      final resultData = bData['result'] ?? bData;
      if (resultData is Map) {
        if (totalEarnings == Money.zero && resultData['totalEarnings'] != null) {
          totalEarnings = Money.fromDynamic(resultData['totalEarnings']);
        }
        final stats = resultData['stats'];
        if (stats is Map && jobsDone == 0) {
          jobsDone = (stats['approvedCount'] as num?)?.toInt() ?? 0;
        }
      }
    }

    final rawTxList = (transactionsData is Map && transactionsData['transactions'] is List)
        ? (transactionsData['transactions'] as List)
        : [];
    final transactions = rawTxList
        .whereType<Map>()
        .map((m) => WalletTransaction.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    final rawWithdrawList = (transactionsData is Map &&
            transactionsData['withdrawRequests'] is List &&
            (transactionsData['withdrawRequests'] as List).isNotEmpty)
        ? (transactionsData['withdrawRequests'] as List)
        : withdrawalHistory;
    final withdrawRequests = rawWithdrawList
        .whereType<Map>()
        .map((m) => WithdrawalRequest.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    return WalletData(
      balance: balance,
      totalEarnings: totalEarnings,
      jobsDone: jobsDone,
      transactions: transactions,
      withdrawRequests: withdrawRequests,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchWalletData(forceRefresh: true));
  }

  Future<Map<String, dynamic>> requestWithdrawal(Money amount) async {
    final repo = ref.read(dashboardRepositoryProvider);
    final result = await repo.requestWithdrawal(amount.inRupees);
    if (result['success'] == true) {
      await refresh();
    }
    return result;
  }

  Future<Map<String, dynamic>> cancelWithdrawal(String withdrawalId) async {
    final repo = ref.read(dashboardRepositoryProvider);
    final result = await repo.cancelWithdrawal(withdrawalId);
    await refresh();
    return result;
  }
}
