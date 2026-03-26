import 'package:flutter/material.dart';

class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int ratingCount;

  const RatingSummary({
    super.key,
    required this.averageRating,
    required this.ratingCount,
  });
  static const Color ratingColor = Color(0xFFFFA000);

  Map<int, int> _generateStarCounts() {
    Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

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

  Widget buildStarRow(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final starCounts = _generateStarCounts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// TOP SUMMARY
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            buildStarRow(averageRating),

            const SizedBox(height: 6),

            Text(
              "$ratingCount Reviews",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        /// DISTRIBUTION CARD
        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(5, (index) {
              int star = 5 - index;
              int count = starCounts[star] ?? 0;

              double percent =
              ratingCount == 0 ? 0 : count / ratingCount;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [

                    const Icon(
                      Icons.star,
                      size: 18,
                      color: ratingColor,
                    ),

                    const SizedBox(width: 4),

                    Text("$star"),

                    const SizedBox(width: 8),

                    Expanded(
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation(ratingColor),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(count.toString()),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}