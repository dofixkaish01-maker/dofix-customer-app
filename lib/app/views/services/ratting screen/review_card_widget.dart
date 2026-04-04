  import 'package:do_fix/app/views/services/ratting%20screen/user_profile_screen.dart';
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

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ///AVATAR (LEFT SIDE FIXED)
            GestureDetector(
              onTap: () {
                if (review.customer?.id != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(),
                    ),
                  );
                }
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.shade50,
                child: ClipOval(
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Colors.grey.shade600,
                      );
                    },
                  )
                      : Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// RIGHT SIDE CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ///NAME + RATING ROW
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// NAME + DATE
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${customer?.firstName ?? 'Anonymous'} ${customer?.lastName ?? ''}'
                                  .trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              review.updatedAt != null
                                  ? DateFormat('dd MMM yyyy')
                                  .format(review.updatedAt!.toLocal())
                                  : 'Reviewed recently',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      ///RATING
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                              (index) => Icon(
                            index < (review.reviewRating ?? 0)
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 16,
                            color: const Color(0xFFFFB800),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  ///COMMENT
                  Text(
                    review.reviewComment ?? 'No review comment provided',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.black.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );  }


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