import 'package:flutter/material.dart';

class RatingSummary extends StatelessWidget {
  final double avergeRating;
  final Map<int, int> starCounts;

  const RatingSummary({
    super.key,
    required this.avergeRating,
    required this.starCounts,
  });

  @override
  Widget build(BuildContext context) {

    int totalReviews = starCounts.values.fold(0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Average rating
        Row(
          children: [
            Text(
              avergeRating.toStringAsFixed(1),
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

        const SizedBox(height: 10),

        /// Star bars
        Column(
          children: List.generate(5, (index) {

            int star = 5 - index;
            int count = starCounts[star] ?? 0;

            double percent =
            totalReviews == 0 ? 0 : count / totalReviews;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
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