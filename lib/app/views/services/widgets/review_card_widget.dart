import 'package:do_fix/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../model/service_reviews_model.dart';

class ReviewCard extends StatelessWidget {
  final ServiceReview review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {

    /// SAFE IMAGE URL
    final imageUrl =
        review.customer?.profileImageFullPath?.toString() ?? "";

    /// DEBUG (optional)
    debugPrint("PROFILE IMAGE URL: $imageUrl");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ///  TOP ROW
            Row(
              children: [
                ///  PROFILE IMAGE
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),

                const SizedBox(width: 10),

                /// NAME + DATE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${review.customer?.firstName ?? ''} ${review.customer?.lastName ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),

                    Text(
                      review.updatedAt != null
                          ? DateFormat('dd-MM-yyyy')
                          .format(review.updatedAt!.toLocal())
                          : 'Reviewed on N/A',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.70),
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                /// RATING
                Row(
                  children: List.generate(
                    5,
                        (index) => Icon(
                      index < (review.reviewRating ?? 0)
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: ratingsOrange,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// COMMENT
            Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: Text(
                review.reviewComment ?? 'No review comment provided',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}