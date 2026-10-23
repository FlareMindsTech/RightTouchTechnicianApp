import 'package:flutter/material.dart';
import 'skeleton.dart';

class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Skeleton(width: 80, height: 20),
              Skeleton(width: 60, height: 20),
            ],
          ),
          SizedBox(height: 16),
          Skeleton(width: double.infinity, height: 24),
          SizedBox(height: 8),
          Skeleton(width: 150, height: 20),
          SizedBox(height: 4),
          Row(
            children: [
              Skeleton(width: 14, height: 14),
              SizedBox(width: 4),
              Skeleton(width: 200, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
