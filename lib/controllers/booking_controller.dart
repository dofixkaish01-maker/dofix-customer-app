import 'dart:convert';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:do_fix/data/repo/booking_repo.dart';
import 'package:do_fix/model/booking_setup_model.dart';
import 'package:do_fix/model/cancel_booking_model.dart';
import 'package:do_fix/model/review_rating_model.dart';
import 'package:do_fix/model/service_reviews_model.dart';
import 'package:do_fix/widgets/common_loading.dart';
import 'package:do_fix/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/booking_model.dart';

class BookingController extends GetxController implements GetxService {
  final BookingRepo bookingRepo;
  final SharedPreferences sharedPreferences;

  BookingController({
    required this.bookingRepo,
    required this.sharedPreferences,
  });

  // ================= REVIEW FORM =================
  int? selectedRating;
  bool recentlyAdded = false;
  int totalReviews = 0;
  double ratingAvg = 0.0;

  RxInt userRating = 0.obs;
  RxBool isSubmittingReview = false.obs;
  RxList<XFile> selectedImages = <XFile>[].obs;
  final TextEditingController reviewController = TextEditingController();

  String bookingId = '';
  String serviceId = '';

  // ================= MODELS =================
  Rxn<ReviewRatingModel> reviewRatingModel = Rxn<ReviewRatingModel>();
  Rxn<ServiceReviewResponseModel> serviceReviewsModel =
      Rxn<ServiceReviewResponseModel>();
  Rxn<BookingSetupModel> bookingSetupModel = Rxn<BookingSetupModel>();

  CancelBookingModel? cancelBookingResponse;

  // ================= DATA =================
  List<BookingModel> bookingList = [];
  Map<int, int> starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  RxDouble partialPaymentPercentage = 0.0.obs;
  RxDouble cancellationChargesPercentage = 0.0.obs;

  // ================= UI HELPERS =================

  final ImagePicker _picker = ImagePicker();

  /// Pick multiple images (maxImages optional)
  Future<void> pickImages({int maxImages = 5}) async {
    try {
      final List<XFile>? images =
          await _picker.pickMultiImage(imageQuality: 70);
      if (images != null) {
        // Limit total images to maxImages
        final availableSlots = maxImages - selectedImages.length;
        if (availableSlots <= 0) {
          Get.snackbar(
            "Limit Reached",
            "You can select up to $maxImages images only.",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // Add only available number of images
        selectedImages.addAll(images.take(availableSlots));
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick images: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Remove image by object
  void removeImage(XFile image) {
    selectedImages.remove(image);
  }

  Future<void> saveBookingReview() async {
    isSubmittingReview.value = true;
    // API call here
    await Future.delayed(const Duration(seconds: 2));
    isSubmittingReview.value = false;
  }

  void setSelectedRating(int? rating) {
    selectedRating = rating;
    update();
  }

  void setRecentlyAdded(bool value) {
    recentlyAdded = value;
    update();
  }

  void applyReviewFilter({
    required int rating,
    required bool recentlyAdded,
  }) {
    userRating = (rating > 0 ? rating : 0) as RxInt;
    this.recentlyAdded = recentlyAdded;

    final reviews = serviceReviewsModel.value?.content?.reviews?.data ?? [];

    if (recentlyAdded) {
      reviews.sort((a, b) {
        final bDate = b.updatedAt ?? DateTime(2000);
        final aDate = a.updatedAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
    }

    update();
  }

  void resetReviewStats() {
    ratingAvg = 0.0;
    totalReviews = 0;
    starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  }

  // ================= BOOKING REVIEW =================

  Future<void> getBookingReview(String bookingId) async {
    showLoading();
    update();

    try {
      final Response response =
          await bookingRepo.fetchBookingReview(bookingId: bookingId);

      log("Booking Review API Response: ${response.body}");

      if (response.statusCode != 200) {
        showCustomSnackBar("Failed to fetch booking review", isError: true);
        return;
      }

      final body = _parseResponseBody(response.body);

      if (body == null) {
        showCustomSnackBar("Invalid review response format", isError: true);
        return;
      }

      if (body["content"] == null) {
        reviewRatingModel.value = null;
        totalReviews = 0;
        ratingAvg = 0.0;
        update();
        return;
      }

      reviewRatingModel.value = ReviewRatingModel.fromJson(body);

      final firstContent = reviewRatingModel.value?.content?.isNotEmpty == true
          ? reviewRatingModel.value?.content?.first
          : null;

      totalReviews = firstContent?.ratingCount ?? 0;
      ratingAvg = (firstContent?.avgRating ?? 0).toDouble();

      update();
    } catch (e, stackTrace) {
      log("Error in getBookingReview: $e", stackTrace: stackTrace);
      showCustomSnackBar("Error fetching booking review: $e", isError: true);
    } finally {
      hideLoading();
      update();
    }
  }

  // ================= SERVICE REVIEW =================

  Future<void> getServiceReview({required String serviceId}) async {
    log("getServiceReview() CALLED with serviceId: $serviceId");

    serviceReviewsModel.value = null;
    resetReviewStats();
    update();

    try {
      showLoading();

      log("Fetching Service Reviews for serviceId: $serviceId");

      final Response response =
          await bookingRepo.fetchServiceReview(serviceId: serviceId);

      log("Service Review API Response: ${response.body}");

      if (response.statusCode != 200) {
        showCustomSnackBar("Failed to fetch reviews", isError: true);
        return;
      }

      final body = _parseResponseBody(response.body);
      log("PARSED BODY: $body");
      log("CONTENT: ${body?["content"]}");
      log("REVIEWS OBJECT: ${body?["content"]?["reviews"]}");
      log("REVIEWS DATA: ${body?["content"]?["reviews"]?["data"]}");

      if (body == null) {
        showCustomSnackBar("Invalid service review response", isError: true);
        return;
      }

      if (body["content"] == null) {
        showCustomSnackBar("Review data not found", isError: true);
        return;
      }

      serviceReviewsModel.value = ServiceReviewResponseModel.fromJson(body);

      final List<ServiceReview> reviews =
          serviceReviewsModel.value?.content?.reviews?.data ?? [];

      starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (final review in reviews) {
        final int rating = review.reviewRating ?? 0;
        if (starCounts.containsKey(rating)) {
          starCounts[rating] = starCounts[rating]! + 1;
        }
      }

      final ratingData = body["content"]["rating"];
      if (ratingData != null) {
        ratingAvg =
            double.tryParse(ratingData["average_rating"].toString()) ?? 0.0;
        totalReviews = ratingData["review_count"] ?? reviews.length;
      } else {
        totalReviews = reviews.length;

        int total = 0;
        for (final review in reviews) {
          total += review.reviewRating ?? 0;
        }

        ratingAvg = reviews.isNotEmpty ? total / reviews.length : 0.0;
      }

      log("Parsed reviews count: ${reviews.length}");
      log("Average rating: $ratingAvg");
      log("Star counts: $starCounts");

      update();
    } catch (e, stackTrace) {
      log("Error in getServiceReview: $e", stackTrace: stackTrace);
      showCustomSnackBar(
        "Failed to fetch reviews. Please try again.",
        isError: true,
      );
    } finally {
      hideLoading();
      update();
    }
  }

  // ================= BOOKING SETUP =================

  Future<void> getBookingSetup() async {
    showLoading();
    update();

    try {
      final Response response = await bookingRepo.getBookingSetupRepo();

      log("Booking Setup API Response: ${response.body}");

      if (response.statusCode != 200) {
        showCustomSnackBar("Booking setup error occurred", isError: true);
        return;
      }

      final body = _parseResponseBody(response.body);

      if (body == null) {
        showCustomSnackBar("Invalid booking setup response", isError: true);
        return;
      }

      bookingSetupModel.value = BookingSetupModel.fromJson(body);

      final contentList = bookingSetupModel.value?.content ?? [];

      if (contentList.isEmpty) {
        partialPaymentPercentage.value = 0.0;
        cancellationChargesPercentage.value = 0.0;
        update();
        return;
      }

      final partialPaymentContent = contentList.firstWhereOrNull(
        (item) => item.keyName == 'partial_payment',
      );

      partialPaymentPercentage.value = double.tryParse(
            partialPaymentContent?.liveValues?.toString() ?? '0',
          ) ??
          0.0;

      final cancellationChargesContent = contentList.firstWhereOrNull(
        (item) => item.keyName == 'cancelation_fee',
      );

      cancellationChargesPercentage.value = double.tryParse(
            cancellationChargesContent?.liveValues?.toString() ?? '0',
          ) ??
          0.0;

      log("Partial payment percentage: ${partialPaymentPercentage.value}");
      log("Cancellation payment percentage: ${cancellationChargesPercentage.value}");

      update();
    } catch (e, stackTrace) {
      log("Error in getBookingSetup: $e", stackTrace: stackTrace);
      showCustomSnackBar("Error fetching booking setup: $e", isError: true);
    } finally {
      hideLoading();
      update();
    }
  }

  // ================= CANCEL BOOKING =================

  Future<void> cancelBookingController(String id) async {
    showLoading();
    update();

    try {
      final Response response = await bookingRepo.cancelBooking(
        bookingId: id,
        bookingStatus: "canceled",
      );

      final body = _parseResponseBody(response.body);

      if (body == null) {
        throw Exception("Invalid cancel booking response");
      }

      log("Cancel Booking API Response: $body");

      if (response.statusCode == 200 &&
          body['response_code']
              .toString()
              .contains("status_update_success_200")) {
        cancelBookingResponse = CancelBookingModel.fromJson(body);

        showCustomSnackBar(
          body['message'] ?? "Booking cancelled successfully",
          isSuccess: true,
          isError: false,
        );
      } else {
        closeSnackBarIfActive();
        showCustomSnackBar(
          body['message'] ?? "Failed to cancel booking",
          isError: true,
        );
      }

      update();
    } catch (e, stackTrace) {
      log("Error in cancelBookingController: $e", stackTrace: stackTrace);
      closeSnackBarIfActive();
      showCustomSnackBar(
        "Something went wrong. Please try again.",
        isError: true,
      );
    } finally {
      hideLoading();
      update();
    }
  }

  // ================= COMMON HELPER =================

  Map<String, dynamic>? _parseResponseBody(dynamic responseBody) {
    try {
      if (responseBody == null) return null;

      if (responseBody is Map<String, dynamic>) {
        return responseBody;
      }

      if (responseBody is String) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      log("Response parse error: $e");
      return null;
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
