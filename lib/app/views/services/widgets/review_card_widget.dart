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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ///  TOP ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ///  Avatar Disabled
              // CircleAvatar(
              //   radius: 18,
              //   backgroundColor: Colors.grey.shade100,
              //   backgroundImage:
              //       imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              //   child: imageUrl.isEmpty
              //       ? Icon(Icons.person_outline,
              //           size: 18, color: Colors.grey.shade500)
              //       : null,
              // ),

              // const SizedBox(width: 10),

              /// Name + Date
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 2),

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

              /// Rating
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

          ///  COMMENT
          Text(
            review.reviewComment ?? 'No review comment provided',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.black.withOpacity(0.7),
            ),
          ),

          ///  REVIEW IMAGES DISABLED
          // if ((review.reviewImages?.isNotEmpty ?? false))
          //   Padding(
          //     padding: const EdgeInsets.only(top: 10),
          //     child: SizedBox(
          //       height: 70,
          //       child: ListView.builder(
          //         scrollDirection: Axis.horizontal,
          //         itemCount: review.reviewImages!.length,
          //         itemBuilder: (context, index) {
          //           final imgUrl =
          //               review.reviewImages![index].toString();
          //
          //           return Container(
          //             margin: const EdgeInsets.only(right: 8),
          //             width: 70,
          //             decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(8),
          //               color: Colors.grey.shade200,
          //               image: imgUrl.isNotEmpty
          //                   ? DecorationImage(
          //                       image: NetworkImage(imgUrl),
          //                       fit: BoxFit.cover,
          //                     )
          //                   : null,
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //   ),
        ],
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