import 'package:flutter/material.dart';
import 'package:right_touch/data/models/task_model.dart';
import 'package:right_touch/utils/app_theme.dart';

class ServiceInstructionsCard extends StatelessWidget {
  final TaskModel task;

  const ServiceInstructionsCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.faultReason.isNotEmpty) ...[
          _buildFaultReason(textTheme),
          const SizedBox(height: 16),
        ],
        if (task.toolsRequired.isNotEmpty) ...[
          _buildToolsRequired(textTheme),
          const SizedBox(height: 16),
        ],
        if (task.rectifySteps.isNotEmpty) ...[
          _buildRectifyMethod(textTheme),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildFaultReason(TextTheme textTheme) {
    final reasons = task.faultReason.split('\n• ');

    return Card(
      elevation: 0,
      color: AppTheme.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.red.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppTheme.red.shade700),
                const SizedBox(width: 12),
                Text(
                  'Fault Reason',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppTheme.red.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...reasons.map((reason) => Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reasons.length > 1) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.red.shade700,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          reason.trim(),
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.red.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsRequired(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Tools & Equipment',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: task.toolsRequired.map((tool) {
            return Chip(
              label: Text(tool),
              backgroundColor: AppTheme.white,
              labelStyle: textTheme.labelMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
              side: BorderSide(color: AppTheme.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRectifyMethod(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Rectify Method',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: task.rectifySteps.length,
          itemBuilder: (context, index) {
            return IntrinsicHeight(
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ),
                      if (index != task.rectifySteps.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        task.rectifySteps[index],
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
