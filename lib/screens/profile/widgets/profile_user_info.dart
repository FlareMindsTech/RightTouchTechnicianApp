import 'package:flutter/material.dart';
import 'package:right_touch/utils/app_theme.dart';

class ProfileUserInfo extends StatelessWidget {
  final String name;
  final String role;
  final double rating;
  final int ratingCount;

  const ProfileUserInfo({
    super.key,
    required this.name,
    required this.role,
    required this.rating,
    required this.ratingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          role,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF9E9E9E),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        _buildRatingStars(rating, ratingCount),
      ],
    );
  }

  Widget _buildRatingStars(double rating, int count) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(
          fullStars,
          (index) => const Icon(Icons.star, color: Color(0xFFFFC107), size: 20),
        ),
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Color(0xFFFFC107), size: 20),
        ...List.generate(
          (5 - rating.ceil()).clamp(0, 5),
          (index) =>
              const Icon(Icons.star_border, color: Color(0xFFFFC107), size: 20),
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.black87,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Text(
            "($count)",
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}
