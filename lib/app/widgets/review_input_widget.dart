import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewInputWidget extends StatefulWidget {
  // final Function(int rating, String review) onSubmit;
  final String bookingId;
  final String serviceId;
  const ReviewInputWidget({
    super.key,
    required this.bookingId,
    required this.serviceId,
  });

  @override
  State<ReviewInputWidget> createState() => _ReviewInputWidgetState();
}

class _ReviewInputWidgetState extends State<ReviewInputWidget> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Please rate your experience',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            )),
        SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
            (index) => IconButton(
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
        SizedBox(height: 8),
        TextField(
          controller: bookingController.reviewController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Share your experience...",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(primaryBlue),
            ),
            onPressed: bookingController.isSubmittingReview.value
                ? null
                : () async {
                    if (bookingController.userRating == 0 ||
                        bookingController.reviewController.text
                            .trim()
                            .isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please provide a rating and review.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.8),
                        colorText: Colors.white,
                      );
                      return;
                    }
                    bookingController.isSubmittingReview.value = true;
                    await bookingController.saveBookingReview();
                    await bookingController.getBookingReview(
                      widget.bookingId,
                    );
                    Navigator.of(context).pop();
                  },
            child: bookingController.isSubmittingReview.value
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Submit'),
          ),
        ),
      ],
    );
  }
}
