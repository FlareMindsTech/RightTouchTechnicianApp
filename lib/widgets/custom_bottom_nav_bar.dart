import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/utils/app_theme.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  double _dragOffset = 0.0;
  bool _isDragging = false;

  final List<IconData> _icons = [
    Icons.store_rounded,
    Icons.business_center_rounded,
    Icons.calendar_today_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = [
    "Home",
    "New",
    "Schedule",
    "Earnings",
    "Profile",
  ];

  static const double _marginHorizontal = 20.0;
  static const double _indicatorWidth = 54.0;
  static const int _itemCount = 5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double barWidth = totalWidth - (_marginHorizontal * 2);
        final double itemWidth = barWidth / _itemCount;
        final double maxLimit = (_itemCount - 1) * itemWidth;
        final double bottomPadding = MediaQuery.of(context).padding.bottom;
        final double bottomMargin = bottomPadding > 0 ? bottomPadding : 24.0;

        if (!_isDragging) {
          _dragOffset = widget.currentIndex * itemWidth;
        }

        return Container(
          margin: EdgeInsets.fromLTRB(
            _marginHorizontal,
            0,
            _marginHorizontal,
            bottomMargin,
          ),
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: Theme.of(context).brightness == Brightness.light
                ? [
                    BoxShadow(
                      color: AppTheme.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppTheme.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Active Indicator
              AnimatedPositioned(
                duration: _isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: _dragOffset + (itemWidth - _indicatorWidth) / 2,
                top: (72 - _indicatorWidth) / 2,
                child: Container(
                  width: _indicatorWidth,
                  height: _indicatorWidth,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16), // Curvy Square
                  ),
                ),
              ),

              GestureDetector(
                onHorizontalDragStart: (_) =>
                    setState(() => _isDragging = true),
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragOffset = (_dragOffset + details.delta.dx).clamp(
                      0.0,
                      maxLimit,
                    );
                  });
                },
                onHorizontalDragEnd: (details) {
                  final int nearestIndex = (_dragOffset / itemWidth)
                      .round()
                      .clamp(0, _itemCount - 1);
                  setState(() => _isDragging = false);
                  if (nearestIndex != widget.currentIndex) {
                    widget.onTap(nearestIndex);
                    HapticFeedback.mediumImpact();
                  } else {
                    setState(() => _dragOffset = nearestIndex * itemWidth);
                  }
                },
                child: Row(
                  children: List.generate(_itemCount, (index) {
                    final isSelected = widget.currentIndex == index;
                    return Expanded(
                      child: Semantics(
                        button: true,
                        label: '${_labels[index]} tab',
                        selected: isSelected,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (!isSelected) {
                              widget.onTap(index);
                              HapticFeedback.selectionClick();
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            AnimatedScale(
                              scale: isSelected ? 1.1 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              child: Icon(
                                _icons[index],
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.grey.shade400,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.grey.shade400,
                                  letterSpacing: 0.1,
                                  fontFamily: 'Inter',
                                ),
                                child: Text(
                                  _labels[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
      },
    );
  }
}
