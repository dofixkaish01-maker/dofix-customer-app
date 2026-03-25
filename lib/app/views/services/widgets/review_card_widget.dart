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
    final customer = review.customer;

    /// SMART IMAGE URL
    final imageUrl = _getSmartImageUrl(customer);

    /// DEBUG
    debugPrint("=== REVIEW DEBUG ===");
    debugPrint("Customer: $customer");
    debugPrint("FirstName: ${customer?.firstName}");
    debugPrint("Image Filename: ${customer?.profileImage}");
    debugPrint("Image FullPath: ${customer?.profileImageFullPath}");
    debugPrint("Final URL: $imageUrl");
    debugPrint("====================");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP ROW: Avatar + Name + Date + Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// PROFILE AVATAR
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : null,
                  child: imageUrl.isEmpty
                      ? Icon(Icons.person_outline,
                      color: Colors.grey.shade500, size: 24)
                      : null,
                ),

                const SizedBox(width: 12),

                /// NAME + DATE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${customer?.firstName ?? 'Anonymous'} ${customer?.lastName ?? ''}'.trim(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        review.updatedAt != null
                            ? DateFormat('dd MMM yyyy').format(review.updatedAt!.toLocal())
                            : 'Reviewed recently',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                /// STAR RATING
                Row(
                  mainAxisSize: MainAxisSize.min,
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

            const SizedBox(height: 12),

            /// REVIEW COMMENT
            Padding(
              padding: const EdgeInsets.only(left: 74.0), // Align with avatar
              child: Text(
                review.reviewComment ?? 'No review comment provided',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.75),
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            /// REVIEW IMAGES (if any)
            if ((review.reviewImages?.isNotEmpty ?? false) && review.reviewImages!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 74),
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.reviewImages!.length,
                    itemBuilder: (context, index) {
                      final img = review.reviewImages![index];
                      final imgUrl = img.toString();
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: imgUrl.isNotEmpty
                              ? DecorationImage(
                            image: NetworkImage(imgUrl),
                            fit: BoxFit.cover,
                          )
                              : null,
                          color: Colors.grey.shade200,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// SMART IMAGE URL GENERATOR
  String _getSmartImageUrl(Customer? customer) {
    if (customer == null) return "";

    // Priority 1: Direct full path
    if (customer.profileImageFullPath?.isNotEmpty == true) {
      return customer.profileImageFullPath!;
    }

    // Priority 2: Construct Review API URL
    if (customer.profileImage?.isNotEmpty == true) {
      return "https://panel.dofix.in/customer/profile_img/${customer.profileImage}";
    }

    return "";
  }
}