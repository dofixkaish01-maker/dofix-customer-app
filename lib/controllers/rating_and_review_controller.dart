import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../helper/rating_and_review_service.dart';
import '../widgets/common_loading.dart';
import 'booking_controller.dart';

class RatingAndReviewController extends GetxController {
  final CustomerReviewService _service = CustomerReviewService();

  bool isLoading = false;
  String message = "";

  Future<void> editReview({
    required String customerID,
    required String token,
    required String zoneID,
    required Map<String, dynamic> payload,
    required BuildContext context
  }) async {
    try {
      isLoading = true;
      // showLoading("edit review");
      update();

      final result = await _service.editReviewService(
        customerID,
        token,
        zoneID,
        payload,
      );

      if (result['success'] == true) {
        message = result['data']?['errors'] ?? "Review updated successfully";

        if (Get.isBottomSheetOpen ?? false) {
          Navigator.pop(context, true);
        }

        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar(
            "Success",
            message,
            snackPosition: SnackPosition.BOTTOM,
          );
        });
      }else {
        message = result['message'] ?? "Something went wrong";
        Get.snackbar("Error", message);
      }
    } catch (e) {
      message = "Something went wrong";
      Get.snackbar("Error", message);

      // debug ke liye
      print("Edit Review Error: $e");
    } finally {
      isLoading = false;
      // hideLoading("edit review");
      update();
    }
  }
}