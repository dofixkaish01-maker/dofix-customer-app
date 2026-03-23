import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        title: Text("Write a Review"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please rate your experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 12),

            /// ⭐ Rating Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                    (index) => IconButton(
                  iconSize: 35,
                  icon: Icon(
                    index < bookingController.userRating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      bookingController.userRating = index + 1;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 20),

            /// 📝 Review Input
            TextField(
              controller: bookingController.reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Share your experience (optional)...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
            ),

            Spacer(),

            /// 🔘 Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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

                  /// ✅ Success Bottom Sheet (better than dialog)
                  Get.bottomSheet(
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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

                  /// auto close after 2 sec
                  Future.delayed(Duration(seconds: 2), () {
                    Get.back(); // close bottom sheet
                    Get.back(); // close screen
                  });
                },
                child: bookingController.isSubmittingReview.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Submit Review",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}