import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int? reviewsCount;
  final double size;
  final Color color;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewsCount,
    this.size = 16.0,
    this.color = AppTheme.starGold,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = [];
    int floor = rating.floor();
    double remainder = rating - floor;

    for (int i = 1; i <= 5; i++) {
      if (i <= floor) {
        stars.add(Icon(Icons.star, size: size, color: color));
      } else if (i == floor + 1 && remainder >= 0.25 && remainder < 0.75) {
        stars.add(Icon(Icons.star_half, size: size, color: color));
      } else if (i == floor + 1 && remainder >= 0.75) {
        stars.add(Icon(Icons.star, size: size, color: color));
      } else {
        stars.add(Icon(Icons.star_outline, size: size, color: color));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: stars,
        ),
        if (reviewsCount != null) ...[
          const SizedBox(width: 4),
          Text(
            reviewsCount.toString(),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.linkBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
