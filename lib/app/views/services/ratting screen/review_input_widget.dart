import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/utils/theme.dart';

import '../../../../controllers/rating_and_review_controller.dart';

class ReviewScreen extends StatefulWidget {
  final String bookingId;
  final String serviceId;

  const ReviewScreen({
    super.key,
    required this.bookingId,
    required this.serviceId,
    required this.isEdit,
    this.initialRating,
    this.initialComment,
    required this.customerID,
    required this.token,
    required this.zoneID,
    this.initialImage,
  });

  final bool isEdit;
  final int? initialRating;
  final String? initialComment;
  final dynamic initialImage;
  final String customerID;
  final String token;
  final String zoneID;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final bookingController = Get.find<BookingController>();
  final ratingController = Get.find<RatingAndReviewController>();

  final Map<int, String> emojiMap = {
    1: "😡",
    2: "😕",
    3: "😐",
    4: "🙂",
    5: "😍",
  };

  final Map<int, String> ratingText = {
    1: "Very Bad",
    2: "Bad",
    3: "Okay",
    4: "Good",
    5: "Great Job",
  };

  @override
  void initState() {
    super.initState();
    //for dabble option provide
    bookingController.isSubmittingReview.value = false;
    bookingController.selectedImages ??= <XFile>[].obs;

    if (widget.isEdit) {
      bookingController.userRating.value =
          widget.initialRating ?? 0;

      bookingController.reviewController.text =
          widget.initialComment ?? "";
    } else {
      bookingController.userRating.value = 0;
      bookingController.reviewController.clear();
    }
    //for only taken review
    // bookingController.userRating.value = 0;
    // bookingController.reviewController.clear();
    // bookingController.isSubmittingReview.value = false;
    // bookingController.selectedImages ??= <XFile>[].obs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xE21C6791),
        toolbarHeight: widget.isEdit?85:60,
        title: Text(widget.isEdit ? "Edit Review" : "Write a Review"),
      ),
      body: SafeArea(
        child: Obx(() => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How was your experience?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              /// Emoji Row + Rating Text
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: emojiMap.entries.map((entry) {
                      final isSelected = bookingController.userRating.value == entry.key;
                      return GestureDetector(
                        onTap: () => bookingController.userRating.value = entry.key,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.shade100 : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            entry.value,
                            style: TextStyle(fontSize: isSelected ? 42 : 32),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ratingText[bookingController.userRating.value] ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Images Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookingController.selectedImages.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () => bookingController.pickImages(maxImages: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
                      ),
                    );
                  }
                  final image = bookingController.selectedImages[index - 1];
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(image.path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                          onPressed: () => bookingController.removeImage(image),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              /// Review TextField
              TextField(
                controller: bookingController.reviewController,
                maxLines: null,
                minLines: 4,
                textAlignVertical: TextAlignVertical.top,
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

              const SizedBox(height: 20),

              /// Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: bookingController.userRating.value == 0 ||
                      bookingController.isSubmittingReview.value
                      ? null
                      : () async {
                    bookingController.isSubmittingReview.value = true;
                    //single option
                    // await bookingController.saveBookingReview();
                    //given both option
                    if (widget.isEdit) {

                      await ratingController.editReview(
                        customerID: widget.customerID,
                        token: widget.token,
                        zoneID: widget.zoneID,
                        payload: {
                          "rating":
                          bookingController.userRating.value.toString(),

                          "comment":
                          bookingController.reviewController.text.trim(),
                        },
                        context: context,
                      );

                    } else {

                      await bookingController.saveBookingReview();

                    }
                    bookingController.isSubmittingReview.value = false;

                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle, color: Colors.green, size: 60),
                            SizedBox(height: 10),
                            Text(
                              "Thank You!",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

                    await bookingController.getBookingReview(widget.bookingId);
                    Future.delayed(const Duration(seconds: 2), () {
                      Get.back();
                      Get.back();
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
                      Text("Submitting..."),
                    ],
                  )
                    : Text(
                    widget.isEdit
                        ? "Update Review"//both option provide edit and give review
                        : "Submit Review",
                    style: const TextStyle(fontSize: 16),
                  //for one take review
                  //   const Text(
                    // "Submit Review",
                    // style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}