import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:right_touch/utils/app_theme.dart';

class BeforeAfterSliderWidget extends StatefulWidget {
  final String? beforeImagePath;
  final String? afterImagePath;
  final ValueChanged<String?> onBeforeChanged;
  final ValueChanged<String?> onAfterChanged;

  const BeforeAfterSliderWidget({
    super.key,
    required this.beforeImagePath,
    required this.afterImagePath,
    required this.onBeforeChanged,
    required this.onAfterChanged,
  });

  @override
  State<BeforeAfterSliderWidget> createState() =>
      _BeforeAfterSliderWidgetState();
}

class _BeforeAfterSliderWidgetState extends State<BeforeAfterSliderWidget> {
  final ImagePicker _picker = ImagePicker();
  double _sliderPosition = 0.5; // 0.0 to 1.0

  Future<void> _pickImage(bool isBefore) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isBefore ? "Select Before Photo" : "Select After Photo",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.camera_alt_rounded,
                      color: AppTheme.primaryColor),
                ),
                title: const Text("Take Photo with Camera"),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.photo_library_rounded,
                      color: Color(0xFF1976D2)),
                ),
                title: const Text("Choose from Gallery"),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (image != null) {
        if (isBefore) {
          widget.onBeforeChanged(image.path);
        } else {
          widget.onAfterChanged(image.path);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasBefore =
        widget.beforeImagePath != null && widget.beforeImagePath!.isNotEmpty;
    final hasAfter =
        widget.afterImagePath != null && widget.afterImagePath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Proof of Work (Mandatory)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            if (hasBefore && hasAfter)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.compare_arrows_rounded,
                        size: 14, color: AppTheme.primaryColor),
                    SizedBox(width: 4),
                    Text(
                      "Interactive Split-View",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (hasBefore && hasAfter)
          _buildInteractiveSlider()
        else
          _buildDualPickerGrid(hasBefore, hasAfter),
      ],
    );
  }

  Widget _buildDualPickerGrid(bool hasBefore, bool hasAfter) {
    return Row(
      children: [
        Expanded(
          child: _buildPickerCard(
            label: "Before Service",
            subtitle: "Mandatory photo",
            path: widget.beforeImagePath,
            isBefore: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPickerCard(
            label: "After Service",
            subtitle: "Mandatory photo",
            path: widget.afterImagePath,
            isBefore: false,
          ),
        ),
      ],
    );
  }

  Widget _buildPickerCard({
    required String label,
    required String subtitle,
    required String? path,
    required bool isBefore,
  }) {
    final hasImage = path != null && path.isNotEmpty;

    return InkWell(
      onTap: () => _pickImage(isBefore),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: hasImage ? null : const Color(0xFFF9FBF9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? AppTheme.primaryColor : const Color(0xFFDCDCDC),
            width: hasImage ? 1.5 : 1,
          ),
          image: hasImage
              ? DecorationImage(
                  image: FileImage(File(path)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            if (!hasImage)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        color: AppTheme.primaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

            // Top Label Pill when image exists
            if (hasImage)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Change Photo Button
            if (hasImage)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveSlider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const height = 240.0;

        return Column(
          children: [
            Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _sliderPosition =
                          (details.localPosition.dx / width).clamp(0.0, 1.0);
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Bottom Image: After Photo
                      Image.file(
                        File(widget.afterImagePath!),
                        fit: BoxFit.cover,
                      ),

                      // Top Image: Before Photo with Custom Clipping
                      ClipRect(
                        clipper: _SliderClipper(width * _sliderPosition),
                        child: Image.file(
                          File(widget.beforeImagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Floating "BEFORE" Badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Opacity(
                          opacity: _sliderPosition > 0.15 ? 1.0 : 0.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F)
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "BEFORE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Floating "AFTER" Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Opacity(
                          opacity: _sliderPosition < 0.85 ? 1.0 : 0.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "AFTER",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Vertical Divider Line
                      Positioned(
                        left: width * _sliderPosition - 1.5,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 3,
                          color: AppTheme.white,
                        ),
                      ),

                      // Draggable Thumb Handle
                      Positioned(
                        left: width * _sliderPosition - 18,
                        top: height / 2 - 18,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.primaryColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.compare_arrows_rounded,
                              size: 20,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Retake & Reset Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _pickImage(true),
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text("Retake Before",
                      style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                ),
                const Text(
                  "⇄ Drag slider to compare",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _pickImage(false),
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text("Retake After",
                      style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double clipWidth;

  _SliderClipper(this.clipWidth);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, clipWidth, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) {
    return oldClipper.clipWidth != clipWidth;
  }
}

