import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/utils/app_theme.dart';

class WeeklyDayData {
  final String dayName;
  final double amount;
  final int jobCount;

  WeeklyDayData({
    required this.dayName,
    required this.amount,
    required this.jobCount,
  });
}

class WeeklyEarningsChart extends StatefulWidget {
  final List<WeeklyDayData>? weeklyData;

  const WeeklyEarningsChart({super.key, this.weeklyData});

  @override
  State<WeeklyEarningsChart> createState() => _WeeklyEarningsChartState();
}

class _WeeklyEarningsChartState extends State<WeeklyEarningsChart> {
  int? _selectedBarIndex;

  List<WeeklyDayData> get _data {
    if (widget.weeklyData != null && widget.weeklyData!.isNotEmpty) {
      return widget.weeklyData!;
    }
    // Realistic fallback/sample distribution for Mon - Sun
    return [
      WeeklyDayData(dayName: "Mon", amount: 850, jobCount: 2),
      WeeklyDayData(dayName: "Tue", amount: 1400, jobCount: 3),
      WeeklyDayData(dayName: "Wed", amount: 1950, jobCount: 4),
      WeeklyDayData(dayName: "Thu", amount: 1100, jobCount: 2),
      WeeklyDayData(dayName: "Fri", amount: 2400, jobCount: 5),
      WeeklyDayData(dayName: "Sat", amount: 3100, jobCount: 6),
      WeeklyDayData(dayName: "Sun", amount: 2200, jobCount: 4),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    double maxAmount = 0;
    for (var d in data) {
      if (d.amount > maxAmount) maxAmount = d.amount;
    }
    if (maxAmount <= 0) maxAmount = 1000;

    final selected = _selectedBarIndex != null &&
            _selectedBarIndex! < data.length
        ? data[_selectedBarIndex!]
        : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly Performance",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Daily earnings distribution",
                    style: TextStyle(fontSize: 11.5, color: AppTheme.grey),
                  ),
                ],
              ),
              if (selected != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${selected.dayName}: ₹${selected.amount.toInt()} (${selected.jobCount} jobs)",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Bar Chart Canvas
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(data.length, (index) {
                final day = data[index];
                final ratio = (day.amount / maxAmount).clamp(0.1, 1.0);
                final isSelected = _selectedBarIndex == index;
                final isMax = day.amount == maxAmount;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedBarIndex = isSelected ? null : index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isMax)
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            height: 80 * ratio,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isMax || isSelected
                                    ? [
                                        AppTheme.primaryColor,
                                        const Color(0xFF66BB6A),
                                      ]
                                    : [
                                        Colors.grey.shade400,
                                        Colors.grey.shade300,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isMax || isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryColor
                                            .withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            day.dayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected || isMax
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected || isMax
                                  ? AppTheme.primaryColor
                                  : AppTheme.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

