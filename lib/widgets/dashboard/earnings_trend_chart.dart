import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class EarningsTrendChart extends ConsumerWidget {
  final AsyncValue<DashboardData> asyncData;

  const EarningsTrendChart({
    super.key,
    required this.asyncData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(dashboardFilterProvider);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings Trend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: asyncData.when(
              loading: () => const Center(child: RtLoader(size: 36)),
              error: (e, s) => Center(child: Text("Error: $e")),
              data: (data) => data.earningTrend.isEmpty
                  ? Center(
                      child: Text(
                        'No data available for this period',
                        style: TextStyle(color: AppTheme.grey[400], fontSize: 12),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: _getInterval(filter),
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    _getBottomTitle(value, filter),
                                    style: const TextStyle(
                                      color: AppTheme.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: data.earningTrend,
                            isCurved: true,
                            color: AppTheme.primaryColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static double _getInterval(String filter) {
    if (filter == 'Week') return 1;
    if (filter == 'Month') return 5;
    if (filter == '3M') return 15;
    if (filter == 'Year') return 30;
    return 1;
  }

  static String _getBottomTitle(double value, String filter) {
    if (filter == 'Week') {
      final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      int idx = value.toInt() % 7;
      return days[idx];
    }
    return value.toInt().toString();
  }
}
