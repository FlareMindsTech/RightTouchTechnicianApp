import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/task_model.dart';
import 'package:right_touch/data/repositories/job_repository.dart';
import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:right_touch/providers/job_provider.dart';
import 'package:right_touch/screens/job_map_screen.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/rt_loader.dart';
import 'package:right_touch/widgets/service_detail/service_image_picker_slot.dart';
import 'package:right_touch/widgets/service_detail/service_instructions_card.dart';

/// A modular, reusable Service Detail Screen widget for a technician workflow.
class ServiceDetailView extends ConsumerStatefulWidget {
  final TaskModel task;

  const ServiceDetailView({super.key, required this.task});

  @override
  ConsumerState<ServiceDetailView> createState() => _ServiceDetailViewState();
}

class _ServiceDetailViewState extends ConsumerState<ServiceDetailView> {
  late List<bool> _checklistState;
  bool _isSubmitting = false;
  String? _beforeImagePath;
  String? _afterImagePath;

  @override
  void initState() {
    super.initState();
    _checklistState = List.filled(widget.task.checklistItems.length, false);
  }

  bool get _isSubmitEnabled =>
      _checklistState.every((item) => item == true) &&
      _beforeImagePath != null &&
      _afterImagePath != null;

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      final jobRepo = ref.read(jobRepositoryProvider);
      final uploadResult = await jobRepo.uploadWorkImages(
        jobId: widget.task.jobId,
        beforeImagePath: _beforeImagePath!,
        afterImagePath: _afterImagePath!,
      );

      if (uploadResult['success'] != true) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ErrorHandler.showError(
            context,
            'Image upload failed: ${uploadResult['message'] ?? 'Unknown error'}',
          );
        }
        return;
      }

      final additionalData = <String, dynamic>{};
      if (widget.task.locationType != null &&
          widget.task.locationType!.isNotEmpty) {
        additionalData['locationType'] = widget.task.locationType;
      }

      final result = await jobRepo.updateJobStatus(
        widget.task.jobId,
        'completed',
        additionalData: additionalData.isNotEmpty ? additionalData : null,
      );

      if (mounted) {
        if (result['success'] == true) {
          ref.invalidate(currentJobsProvider);
          ref.invalidate(historyJobsProvider);
          ref.invalidate(dashboardDataProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Service completed successfully!',
                style: TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          setState(() => _isSubmitting = false);
          ErrorHandler.showError(
            context,
            result['message'] ?? 'Failed to complete job',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(textTheme),
          const SizedBox(height: 12),
          _buildNavigationButton(),
          const SizedBox(height: 24),
          ServiceImagePickerSlot(
            label: "Before Photo (Mandatory)",
            imagePath: _beforeImagePath,
            onImagePicked: (p) => setState(() => _beforeImagePath = p),
          ),
          const SizedBox(height: 24),
          ServiceInstructionsCard(task: widget.task),
          const SizedBox(height: 16),
          _buildChecklist(textTheme),
          const SizedBox(height: 24),
          ServiceImagePickerSlot(
            label: "After Photo (Mandatory)",
            imagePath: _afterImagePath,
            onImagePicked: (p) => setState(() => _afterImagePath = p),
          ),
          const SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Card(
      elevation: 0,
      color: AppTheme.primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job ID',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        widget.task.jobId,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.task.location,
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist(TextTheme textTheme) {
    if (widget.task.checklistItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Completion Checklist',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.grey.shade300),
          ),
          child: Column(
            children: List.generate(widget.task.checklistItems.length, (index) {
              return CheckboxListTile(
                value: _checklistState[index],
                onChanged: (value) {
                  setState(() {
                    _checklistState[index] = value ?? false;
                  });
                },
                title: Text(
                  widget.task.checklistItems[index],
                  style: textTheme.bodyMedium,
                ),
                activeColor: AppTheme.primaryColor,
                checkColor: AppTheme.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: index == 0
                      ? const BorderRadius.vertical(top: Radius.circular(16))
                      : index == widget.task.checklistItems.length - 1
                          ? const BorderRadius.vertical(
                              bottom: Radius.circular(16))
                          : BorderRadius.zero,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: (_isSubmitEnabled && !_isSubmitting) ? _handleSubmit : null,
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        disabledBackgroundColor: AppTheme.grey.shade300,
      ),
      child: _isSubmitting
          ? const RtLoader.button(color: AppTheme.white)
          : const Text(
              'Submit Completion',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
    );
  }

  Widget _buildNavigationButton() {
    return OutlinedButton.icon(
      onPressed: () {
        final double lat = widget.task.latitude ?? 13.0827;
        final double lng = widget.task.longitude ?? 80.2707;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobMapScreen(
              latitude: lat,
              longitude: lng,
              title: "Directions to ${widget.task.location}",
            ),
          ),
        );
      },
      icon: const Icon(Icons.directions),
      label: const Text("Get Directions"),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: AppTheme.primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
