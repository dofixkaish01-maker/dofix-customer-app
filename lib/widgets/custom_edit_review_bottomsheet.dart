import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import '../controllers/rating_and_review_controller.dart';

class EditReviewBottomSheet extends StatefulWidget {
  final int initialRating;
  final String initialComment;
  final String customerID;
  final String token;
  final String zoneID;

  const EditReviewBottomSheet({
    super.key,
    required this.initialRating,
    required this.initialComment,
    required this.customerID,
    required this.token,
    required this.zoneID,
  });

  @override
  State<EditReviewBottomSheet> createState() => _EditReviewBottomSheetState();
}

class _EditReviewBottomSheetState extends State<EditReviewBottomSheet> {
  int selectedRating = 5;
  late TextEditingController commentController;

  final controller = Get.find<RatingAndReviewController>();

  @override
  void initState() {
    super.initState();
    selectedRating = widget.initialRating;
    commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          // bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: GetBuilder<RatingAndReviewController>(
          builder: (c) {
            return SingleChildScrollView(
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Title
                  const Text(
                    "Edit Review",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      int star = index + 1;
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            selectedRating = star;
                          });
                        },
                        icon: Icon(
                          Icons.star,
                          size: 32,
                          color: star <= selectedRating
                              ? Colors.orange
                              : Colors.grey.shade300,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Comment Field
                  TextField(
                    controller: commentController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Write your review...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: c.isLoading
                          ? null
                          : () async {
                              //  STEP 1: UI ko turant update karo
                              final bookController =
                                  Get.find<BookingController>();

                              bookController
                                  .reviewRatingModel
                                  .value
                                  ?.content?[0]
                                  .reviews?[0]
                                  .reviewRating = selectedRating;

                              bookController
                                  .reviewRatingModel
                                  .value
                                  ?.content?[0]
                                  .reviews?[0]
                                  .reviewComment = commentController.text;

                              bookController.reviewRatingModel.refresh();

                              //  STEP 2: API call karo (background me)
                              await controller.editReview(
                                customerID: widget.customerID,
                                token: widget.token,
                                zoneID: widget.zoneID,
                                payload: {
                                  "rating": selectedRating.toString(),
                                  "comment": commentController.text.trim(),
                                },
                                context: context,
                              );
                            },
                      child: c.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Update Review"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
