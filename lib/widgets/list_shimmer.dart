import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:right_touch/utils/app_theme.dart';

class ListShimmer extends StatelessWidget {
  final int itemCount;
  const ListShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: AppTheme.grey[200]!,
            highlightColor: AppTheme.grey[50]!,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}
