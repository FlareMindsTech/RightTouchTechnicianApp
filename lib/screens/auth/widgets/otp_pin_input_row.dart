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

    for (var controller in widget.controllers) {
      controller.addListener(_onExternalChanged);
    }

    // Auto-focus the input after screen render
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
        // Transparent TextField spanning the full area to retain soft keyboard focus reliably
        Positioned.fill(
          child: Opacity(
            opacity: 0.01,
            child: TextField(
              controller: _masterController,
              focusNode: _masterFocusNode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              maxLength: 4,
              cursorColor: Colors.transparent,
              style: const TextStyle(color: Colors.transparent),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
        ),

        // Visual 4-Digit Display Boxes (Ignore pointer so taps pass straight to TextField)
        IgnorePointer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              final isBoxFilled = index < text.length;
              final isCurrentActive = isFocused &&
                  (index == text.length || (text.length == 4 && index == 3));
              final digit = isBoxFilled ? text[index] : '';

              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: isBoxFilled
                      ? AppTheme.primaryColor.withValues(alpha: 0.06)
                      : (isCurrentActive
                          ? Colors.white
                          : AppTheme.grey.shade50),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isCurrentActive
                        ? AppTheme.primaryColor
                        : (isBoxFilled
                            ? AppTheme.primaryColor.withValues(alpha: 0.5)
                            : AppTheme.grey.shade300),
                    width: isCurrentActive ? 2.5 : 1.5,
                  ),
                  boxShadow: isCurrentActive
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
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
                                width: 2.5,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
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
