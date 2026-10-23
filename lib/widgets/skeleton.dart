import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:right_touch/utils/app_theme.dart';

class Skeleton extends StatelessWidget {
  final double? height, width;
  final double borderRadius;

  const Skeleton({super.key, this.height, this.width, this.borderRadius = 8});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.grey[300]!,
      highlightColor: AppTheme.grey[100]!,
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
      ),
    );
  }
}
