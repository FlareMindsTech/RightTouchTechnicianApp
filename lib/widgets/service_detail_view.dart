import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../providers/job_provider.dart';
import '../providers/dashboard_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_theme.dart';
import '../utils/error_handler.dart';
import '../screens/job_map_screen.dart';

/// A modular, reusable Service Detail Screen widget for a technician workflow.
/// Designed for Material 3 and ready for future API integration.
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
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checklistState = List.filled(widget.task.checklistItems.length, false);
  }



  bool get _isSubmitEnabled =>
      _checklistState.every((item) => item == true) &&
      _beforeImagePath != null &&
      _afterImagePath != null;

  Future<void> _pickImage(ImageSource source, bool isBefore) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (photo != null) {
        setState(() {
          if (isBefore) {
            _beforeImagePath = photo.path;
          } else {
            _afterImagePath = photo.path;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageOptions(bool isBefore, String? currentPath) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentPath != null)
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Preview Image'),
                onTap: () {
                  Navigator.pop(context);
                  _showImagePreview(currentPath);
                },
              ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isBefore);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isBefore);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(path)),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final AuthService _authService = AuthService();

  void _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      // 1. Upload Images
      final uploadResult = await _authService.uploadWorkImages(
        jobId: widget.task.jobId,
        beforeImagePath: _beforeImagePath!,
        afterImagePath: _afterImagePath!,
      );

      if (!uploadResult['success']) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ErrorHandler.showError(
            context,
            'Image upload failed: ${uploadResult['message'] ?? 'Unknown error'}',
          );
        }
        return;
      }

      // 2. Complete Job
      // Prepare additional data required by backend validation
      final additionalData = <String, dynamic>{};

      if (widget.task.customerId != null &&
          widget.task.customerId!.isNotEmpty) {
        additionalData['customerId'] = widget.task.customerId;
      }

      if (widget.task.locationType != null &&
          widget.task.locationType!.isNotEmpty) {
        additionalData['locationType'] = widget.task.locationType;
      }

      final result = await _authService.updateJobStatus(
        widget.task.jobId,
        'completed',
        additionalData: additionalData.isNotEmpty ? additionalData : null,
      );

      if (mounted) {
        if (result['success']) {
          // Refresh data across the app
          ref.invalidate(currentJobsProvider);
          ref.invalidate(historyJobsProvider);
          ref.invalidate(dashboardDataProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Service completed successfully!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
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
          _buildImageSlot("Before Photo (Mandatory)", _beforeImagePath, true),
          const SizedBox(height: 24),
          _buildFaultReason(textTheme),
          const SizedBox(height: 16),
          _buildToolsRequired(textTheme),
          const SizedBox(height: 16),
          _buildRectifyMethod(textTheme),
          const SizedBox(height: 16),
          _buildChecklist(textTheme),
          const SizedBox(height: 24),
          _buildImageSlot("After Photo (Mandatory)", _afterImagePath, false),
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

  Widget _buildFaultReason(TextTheme textTheme) {
    // Split into individual reasons (they're joined with '\n• ')
    final reasons = widget.task.faultReason.split('\n• ');

    return Card(
      elevation: 0,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Text(
                  'Fault Reason',
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.red.shade900,
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
                          color: Colors.red.shade700,
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
                        color: Colors.red.shade900,
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
          children: widget.task.toolsRequired.map((tool) {
            return Chip(
              label: Text(tool),
              backgroundColor: Colors.white,
              labelStyle: textTheme.labelMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
              side: BorderSide(color: Colors.grey.shade300),
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
          itemCount: widget.task.rectifySteps.length,
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
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (index != widget.task.rectifySteps.length - 1)
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
                        widget.task.rectifySteps[index],
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

  Widget _buildChecklist(TextTheme textTheme) {
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
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade300),
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
                checkColor: Colors.white,
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
        disabledBackgroundColor: Colors.grey.shade300,
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'Submit Completion',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildImageSlot(String label, String? path, bool isBefore) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _showImageOptions(isBefore, path),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    path != null ? AppTheme.primaryColor : Colors.grey.shade300,
                width: path != null ? 2 : 1,
              ),
            ),
            child: path != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(path), fit: BoxFit.cover),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: Colors.grey),
                      SizedBox(height: 4),
                      Text("Capture", style: TextStyle(fontSize: 12)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton() {
    return OutlinedButton.icon(
      onPressed: () {
        // Use fallback coordinates if none provided (Default to Chennai)
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
