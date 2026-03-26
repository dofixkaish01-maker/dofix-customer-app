import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/utils/theme.dart';
import '../views/helpSupport/faq_support_screen.dart';

class ReviewScreen extends StatefulWidget {
  final String bookingId;
  final String serviceId;

  const ReviewScreen({
    super.key,
    required this.bookingId,
    required this.serviceId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final bookingController = Get.find<BookingController>();

  @override
  void initState() {
    super.initState();
    bookingController.userRating = 0;
    bookingController.reviewController.clear();
    bookingController.isSubmittingReview.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Write a Review"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please rate your experience',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            /// Rating Bar
            RatingBar.builder(
              unratedColor: Colors.grey,
              initialRating: bookingController.userRating.toDouble(),
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                bookingController.userRating = rating.toInt();
              },
            ),

            const SizedBox(height: 20),

            /// Review Input
            TextField(
              controller: bookingController.reviewController,
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: "Share your experience (optional)...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const Spacer(),

            /// Submit Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: bookingController.isSubmittingReview.value
                    ? null
                    : () async {
                  if (bookingController.userRating == 0) {
                    Get.snackbar(
                      'Error',
                      'Please provide a rating.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                    );
                    return;
                  }

                  bookingController.isSubmittingReview.value = true;

                  await bookingController.saveBookingReview();

                  Get.bottomSheet(
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 60),
                          SizedBox(height: 10),
                          Text(
                            "Thank You!",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Your review has been submitted successfully 😊",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );

                  await bookingController.getBookingReview(
                    widget.bookingId,
                  );

                  Future.delayed(const Duration(seconds: 2), () {
                    Get.back(); // close bottom sheet
                    Get.back(); // close screen
                  });
                },
                child: bookingController.isSubmittingReview.value
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text("Submitting...")
                  ],
                )
                    : const Text(
                  "Submit Review",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
