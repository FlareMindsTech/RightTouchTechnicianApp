import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/money.dart';

class DailyGoalCard extends StatefulWidget {
  final Money todayEarnings;
  final VoidCallback? onTargetReached;

  const DailyGoalCard({
    super.key,
    required this.todayEarnings,
    this.onTargetReached,
  });

  @override
  State<DailyGoalCard> createState() => _DailyGoalCardState();
}

class _DailyGoalCardState extends State<DailyGoalCard> {
  double _dailyTarget = 2500.0;

  void _showEditGoalDialog() {
    final controller =
        TextEditingController(text: _dailyTarget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Set Daily Earnings Target"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Challenge yourself by setting a daily earning milestone.",
              style: TextStyle(fontSize: 12, color: AppTheme.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                prefixText: "₹ ",
                hintText: "2500",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              if (parsed != null && parsed > 0) {
                setState(() => _dailyTarget = parsed);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.white,
              elevation: 0,
            ),
            child: const Text("Save Target"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final earned = widget.todayEarnings.inRupees;
    final progress = (earned / _dailyTarget).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();
    final remaining = (_dailyTarget - earned).clamp(0.0, _dailyTarget);
    final isCompleted = earned >= _dailyTarget;

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
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFE8F5E9),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? const Color(0xFFFFB300) : AppTheme.primaryColor,
                  ),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$percentage%",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                      Text(
                        isCompleted ? "DONE!" : "GOAL",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? const Color(0xFFFF8F00)
                              : AppTheme.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),

          // Details & Milestone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Daily Target",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showEditGoalDialog();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "₹${_dailyTarget.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.edit_outlined,
                              size: 13,
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted
                      ? "🎉 Awesome! You've achieved your daily earnings goal!"
                      : "₹${remaining.toStringAsFixed(0)} remaining to hit your milestone today.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),

                // Sub-pill status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFFFFF8E1)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.star_rounded
                            : Icons.trending_up_rounded,
                        size: 13,
                        color: isCompleted
                            ? const Color(0xFFFF8F00)
                            : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCompleted
                            ? "Target Unlocked"
                            : "Earned ${widget.todayEarnings.formatted} Today",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? const Color(0xFFFF8F00)
                              : AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

