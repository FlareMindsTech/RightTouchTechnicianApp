import 'package:flutter/material.dart';
import 'package:right_touch/utils/app_theme.dart';

class KycStepIndicator extends StatelessWidget {
  final int activeStep; // 0: Profile, 1: KYC, 2: Bank

  const KycStepIndicator({
    super.key,
    this.activeStep = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.textTertiary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          _stepItem("Profile", activeStep == 0, activeStep > 0),
          _stepDivider(activeStep >= 1),
          _stepItem("KYC", activeStep == 1, activeStep > 1),
          _stepDivider(activeStep >= 2),
          _stepItem("Bank", activeStep == 2, activeStep > 2),
        ],
      ),
    );
  }

  Widget _stepItem(String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppTheme.primaryColor
                : isActive
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : AppTheme.white,
            border: Border.all(
              color: isCompleted || isActive
                  ? AppTheme.primaryColor
                  : AppTheme.textTertiary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: AppTheme.white)
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isActive ? AppTheme.primaryColor : AppTheme.transparent,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                isActive || isCompleted ? FontWeight.w600 : FontWeight.normal,
            color: isActive || isCompleted
                ? AppTheme.primaryColor
                : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _stepDivider(bool isCompleted) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Divider(
          color: isCompleted
              ? AppTheme.primaryColor
              : AppTheme.textTertiary.withValues(alpha: 0.3),
          thickness: 2,
        ),
      ),
    );
  }
}
