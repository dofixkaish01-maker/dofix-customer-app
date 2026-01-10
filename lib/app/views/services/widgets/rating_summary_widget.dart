import 'package:do_fix/utils/theme.dart';
import 'package:flutter/material.dart';

class RatingSummary extends StatelessWidget {
  final double avergeRating;
  final Map<int, int> starCounts;
  RatingSummary({
    super.key,
    required this.avergeRating,
    required this.starCounts,
  });
  int get totalReviews =>
      starCounts.values.fold(0, (sum, count) => sum + count);

  Widget buildStarBar(int stars, double percent, String count) {
    return Row(
      children: [
        Text('$stars ★'),
        const SizedBox(width: 4),
        Expanded(
          child: LinearProgressIndicator(
            borderRadius: BorderRadius.circular(4),
            color: ratingsOrange,
            backgroundColor: Colors.black.withOpacity(0.10),
            value: percent,
            minHeight: 6,
          ),
        ),
        const SizedBox(width: 8),
        Text(count),
      ],
    );
  }

  Widget buildStarRow(double averageRating,
      {Color color = ratingsOrange, double? size}) {
    List<Widget> stars = [];
    int fullStars = averageRating.floor();
    bool hasHalfStar = (averageRating - fullStars) >= 0.25 &&
        (averageRating - fullStars) < 0.75;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star_rounded, color: color, size: size));
    }
    if (hasHalfStar) {
      stars.add(Icon(Icons.star_half_rounded, color: color, size: size));
    }
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(Icons.star_border_rounded, color: color, size: size));
    }
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          avergeRating.toStringAsFixed(1),
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
        ),
        buildStarRow(avergeRating),
        const SizedBox(height: 16),
        buildStarBar(
            5,
            (totalReviews > 0) ? (starCounts[5]! / totalReviews) : 0.0,
            '${starCounts[5]}'),
        const SizedBox(height: 4),
        buildStarBar(
            4,
            (totalReviews > 0) ? (starCounts[4]! / totalReviews) : 0.0,
            '${starCounts[4]}'),
        const SizedBox(height: 4),
        buildStarBar(
            3,
            (totalReviews > 0) ? (starCounts[3]! / totalReviews) : 0.0,
            '${starCounts[3]}'),
        const SizedBox(height: 4),
        buildStarBar(
            2,
            (totalReviews > 0) ? (starCounts[2]! / totalReviews) : 0.0,
            '${starCounts[2]}'),
        const SizedBox(height: 4),
        buildStarBar(
            1,
            (totalReviews > 0) ? (starCounts[1]! / totalReviews) : 0.0,
            '${starCounts[1]}'),
      ],
    );
  }
}
