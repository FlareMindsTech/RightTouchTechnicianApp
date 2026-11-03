import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/utils/app_theme.dart';

class OtpPinInputRow extends StatefulWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(String value, int index) onChanged;
  final ValueChanged<String>? onOtpPasted;

  const OtpPinInputRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    this.onOtpPasted,
  });

  @override
  State<OtpPinInputRow> createState() => _OtpPinInputRowState();
}

class _OtpPinInputRowState extends State<OtpPinInputRow>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _masterController;
  late final FocusNode _masterFocusNode;
  late AnimationController _cursorBlinkController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    final initialText = widget.controllers.map((c) => c.text).join();
    _masterController = TextEditingController(text: initialText);
    _masterFocusNode = FocusNode();

    _cursorBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _masterController.addListener(_onMasterChanged);
    _masterFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    // Listen to changes on external controllers (e.g. when cleared or updated externally)
    for (var controller in widget.controllers) {
      controller.addListener(_onExternalChanged);
    }

    // Auto-focus after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _masterFocusNode.requestFocus();
      }
    });
  }

  void _onMasterChanged() {
    if (_isSyncing) return;
    _isSyncing = true;

    final text = _masterController.text;

    // Sync to external controllers for backward compatibility
    for (int i = 0; i < 4; i++) {
      final char = i < text.length ? text[i] : '';
      if (widget.controllers[i].text != char) {
        widget.controllers[i].text = char;
      }
    }

    if (mounted) {
      setState(() {});
    }

    final currentIndex = text.isEmpty ? 0 : (text.length - 1).clamp(0, 3);
    widget.onChanged(text, currentIndex);

    if (text.length == 4) {
      widget.onOtpPasted?.call(text);
    }

    _isSyncing = false;
  }

  void _onExternalChanged() {
    if (_isSyncing) return;
    final externalText = widget.controllers.map((c) => c.text).join();
    if (_masterController.text != externalText) {
      _isSyncing = true;
      _masterController.text = externalText;
      if (mounted) setState(() {});
      _isSyncing = false;
    }
  }

  @override
  void dispose() {
    _cursorBlinkController.dispose();
    _masterController.removeListener(_onMasterChanged);
    for (var controller in widget.controllers) {
      controller.removeListener(_onExternalChanged);
    }
    _masterController.dispose();
    _masterFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _masterController.text;
    final isFocused = _masterFocusNode.hasFocus;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Hidden single input capturing Gboard suggestions, SMS autofill & keyboard
        Opacity(
          opacity: 0.0,
          child: SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              controller: _masterController,
              focusNode: _masterFocusNode,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              maxLength: 4,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        // Visual 4-Digit Display Boxes
        GestureDetector(
          onTap: () {
            if (!_masterFocusNode.hasFocus) {
              _masterFocusNode.requestFocus();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              final isBoxFilled = index < text.length;
              final isCurrentActive = isFocused &&
                  (index == text.length || (text.length == 4 && index == 3));
              final digit = isBoxFilled ? text[index] : '';

              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: isBoxFilled
                      ? AppTheme.primaryColor.withValues(alpha: 0.05)
                      : AppTheme.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrentActive
                        ? AppTheme.primaryColor
                        : (isBoxFilled
                            ? AppTheme.primaryColor.withValues(alpha: 0.4)
                            : AppTheme.grey.shade300),
                    width: isCurrentActive ? 2.2 : 1.5,
                  ),
                ),
                child: Center(
                  child: isBoxFilled
                      ? Text(
                          digit,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        )
                      : (isCurrentActive
                          ? FadeTransition(
                              opacity: _cursorBlinkController,
                              child: Container(
                                width: 2,
                                height: 26,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : const SizedBox.shrink()),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
