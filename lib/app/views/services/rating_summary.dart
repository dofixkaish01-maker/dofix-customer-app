import 'package:flutter/material.dart';

class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int ratingCount;

  const RatingSummary({
    super.key,
    required this.averageRating,
    required this.ratingCount,
  });

  /// Generate approximate star distribution from average rating
  Map<int, int> _generateStarCounts() {
    Map<int, int> counts = {
      5: 0,
      4: 0,
      3: 0,
      2: 0,
      1: 0,
    };

    if (ratingCount == 0) return counts;

    int fiveStar = (ratingCount * (averageRating / 5)).round();
    int remaining = ratingCount - fiveStar;

    counts[5] = fiveStar;
    counts[4] = (remaining * 0.5).round();
    counts[3] = (remaining * 0.3).round();
    counts[2] = (remaining * 0.15).round();
    counts[1] = (remaining * 0.05).round();

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final starCounts = _generateStarCounts();
    int totalReviews = ratingCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Average rating
        Row(
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.star, color: Colors.orange, size: 30),
          ],
        ),

        Text(
          "$totalReviews Reviews",
          style: const TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 12),

        /// Star bars
        Column(
          children: List.generate(5, (index) {
            int star = 5 - index;
            int count = starCounts[star] ?? 0;

            double percent =
            totalReviews == 0 ? 0 : count / totalReviews;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [

                  Text("$star ⭐"),

                  const SizedBox(width: 8),

                  Expanded(
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                      const AlwaysStoppedAnimation(Colors.orange),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(count.toString()),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}