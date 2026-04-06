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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        ///  TOP SUMMARY
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Left: Rating Number
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: isSmall ? 32 : 36,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 4),

                buildStarRow(averageRating),

                const SizedBox(height: 4),

                Text(
                  "$ratingCount Reviews",
                  style: TextStyle(
                    fontSize: isSmall ? 11 : 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 20),

            /// Right: Distribution Bars
            Expanded(
              child: Column(
                children: List.generate(5, (index) {
                  int star = 5 - index;
                  int count = starCounts[star] ?? 0;

                  double percent =
                  ratingCount == 0 ? 0 : count / ratingCount;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [

                        /// Star + Number
                        SizedBox(
                          width: 30,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: ratingColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "$star",
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Progress Bar
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: percent,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor:
                              const AlwaysStoppedAnimation(ratingColor),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// Count
                        SizedBox(
                          width: 30,
                          child: Text(
                            count.toString(),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),

        ///  Old Card Container (kept for reference)
        // Container(
        //   padding: const EdgeInsets.all(1),
        //   decoration: BoxDecoration(
        //     color: Colors.grey.shade50,
        //     borderRadius: BorderRadius.circular(16),
        //   ),
        // )
      ],
    );
  }
}