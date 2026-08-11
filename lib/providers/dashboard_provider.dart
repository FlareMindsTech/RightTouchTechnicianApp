import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/repositories/job_repository.dart';
import 'package:right_touch/data/repositories/dashboard_repository.dart';
import 'package:fl_chart/fl_chart.dart';

// Filter state provider
class DashboardFilterNotifier extends Notifier<String> {
  @override
  String build() => 'Week';

  @override
  set state(String value) => super.state = value;
}

final dashboardFilterProvider =
    NotifierProvider<DashboardFilterNotifier, String>(
  DashboardFilterNotifier.new,
);

// Core dashboard data state
class DashboardData {
  final int pendingJobs;
  final int completedJobs;
  final double totalEarnings;
  final double availableBalance;
  final List<FlSpot> earningTrend;

  const DashboardData({
    this.pendingJobs = 0,
    this.completedJobs = 0,
    this.totalEarnings = 0,
    this.availableBalance = 0,
    this.earningTrend = const [],
  });
}

final dashboardDataProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardData>(() {
  return DashboardNotifier();
});

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  @override
  FutureOr<DashboardData> build() async {
    ref.keepAlive();
    final filter = ref.watch(dashboardFilterProvider);
    return _fetch(filter);
  }

  Future<DashboardData> _fetch(
    String filter, {
    bool forceRefresh = false,
  }) async {
    final jobRepo = ref.read(jobRepositoryProvider);
    final dashRepo = ref.read(dashboardRepositoryProvider);

    // Fetch in parallel
    final results = await Future.wait([
      dashRepo.getWalletBalance(forceRefresh: forceRefresh),
      dashRepo.getWalletTransactions(forceRefresh: forceRefresh),
      jobRepo.getCurrentJobs(forceRefresh: forceRefresh),
      jobRepo.getJobHistory(forceRefresh: forceRefresh),
    ]);

    final walletResult = results[0] is Map
        ? results[0] as Map<String, dynamic>
        : <String, dynamic>{};
    final transResult = results[1] is Map
        ? results[1] as Map<String, dynamic>
        : <String, dynamic>{};
    final currentJobs = results[2] is List ? results[2] as List<dynamic> : [];
    final historyJobs = results[3] is List ? results[3] as List<dynamic> : [];

    final earnings = (walletResult['totalEarnings'] as num?)?.toDouble() ?? 0.0;
    final balance =
        ((walletResult['balance'] ?? walletResult['availableBalance']) as num?)
                ?.toDouble() ??
            0.0;

    final pending = currentJobs.length;
    final completed =
        historyJobs.where((j) => j is Map && j['status'] == 'completed').length;

    final transactions = (transResult['transactions'] as List?) ?? [];
    final trend = _processTrendData(transactions, filter);

    return DashboardData(
      pendingJobs: pending,
      completedJobs: completed,
      totalEarnings: earnings,
      availableBalance: balance,
      earningTrend: trend,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final filter = ref.read(dashboardFilterProvider);
    state = await AsyncValue.guard(() => _fetch(filter, forceRefresh: true));
  }

  List<FlSpot> _processTrendData(List transactions, String filter) {
    if (transactions.isEmpty) return [];

    final now = DateTime.now();
    final Map<DateTime, double> dailyEarnings = {};

    int daysToLookBack = 7;
    if (filter == 'Month') daysToLookBack = 30;
    if (filter == '3M') daysToLookBack = 90;
    if (filter == 'Year') daysToLookBack = 365;

    final startDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: daysToLookBack - 1));

    for (int i = 0; i < daysToLookBack; i++) {
      final date = startDate.add(Duration(days: i));
      dailyEarnings[DateTime(date.year, date.month, date.day)] = 0.0;
    }

    for (var tx in transactions) {
      try {
        if (tx is! Map) continue;
        final dateStr = tx['createdAt'] ?? tx['date'];
        if (dateStr == null) continue;
        final date = DateTime.parse(dateStr);
        final day = DateTime(date.year, date.month, date.day);

        if (dailyEarnings.containsKey(day)) {
          final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
          final type = tx['type']?.toString().toLowerCase();
          if (type == 'credit' || type == 'earning') {
            dailyEarnings[day] = dailyEarnings[day]! + amount;
          }
        }
      } catch (e) {
        continue;
      }
    }

    final List<FlSpot> spots = [];
    final sortedDates = dailyEarnings.keys.toList()..sort();

    for (int i = 0; i < sortedDates.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyEarnings[sortedDates[i]]!));
    }

    return spots;
  }
}
