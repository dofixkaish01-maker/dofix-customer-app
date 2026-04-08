import 'dart:io';
import 'package:camera/camera.dart';
import 'package:do_fix/utils/sizeboxes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/utils/theme.dart';

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
    bookingController.userRating.value = 0;
    bookingController.reviewController.clear();
    bookingController.isSubmittingReview.value = false;
    bookingController.selectedImages ??= <XFile>[].obs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xE21C6791),
        title: const Text("Write a Review"),
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

              Text(
                "${bookingController.selectedImages.length}/5 images selected",
                style: TextStyle(color: Colors.grey),
              ),
              sizedBox10(),
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

                    await bookingController.saveBookingReview();

                    if (bookingController.userRating.value == 0) return;

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
                      Navigator.pop(context);
                    });
                  },
                  // onPressed: bookingController.userRating.value == 0 ||
                  //     bookingController.isSubmittingReview.value
                  //     ? null
                  //     : () async {
                  //   bookingController.isSubmittingReview.value = true;
                  //   await bookingController.saveBookingReview();
                  //   bookingController.isSubmittingReview.value = false;
                  //
                  //   Get.bottomSheet(
                  //     Container(
                  //       padding: const EdgeInsets.all(20),
                  //       decoration: const BoxDecoration(
                  //         color: Colors.white,
                  //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  //       ),
                  //       child: Column(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: const [
                  //           Icon(Icons.check_circle, color: Colors.green, size: 60),
                  //           SizedBox(height: 10),
                  //           Text(
                  //             "Thank You!",
                  //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  //           ),
                  //           SizedBox(height: 5),
                  //           Text(
                  //             "Your review has been submitted successfully 😊",
                  //             textAlign: TextAlign.center,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   );
                  //
                  //   await bookingController.getBookingReview(widget.bookingId);
                  //   Future.delayed(const Duration(seconds: 2), () {
                  //     Navigator.pop(context);
                  //   });
                  // },
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
                      : const Text(
                    "Submit Review",
                    style: TextStyle(fontSize: 16),
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