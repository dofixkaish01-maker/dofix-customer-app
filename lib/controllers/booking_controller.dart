import 'dart:convert';
import 'dart:developer';

import 'package:do_fix/data/repo/booking_repo.dart';
import 'package:do_fix/model/booking_setup_model.dart';
import 'package:do_fix/model/cancel_booking_model.dart';
import 'package:do_fix/model/review_rating_model.dart';
import 'package:do_fix/model/service_reviews_model.dart';
import 'package:do_fix/widgets/common_loading.dart';
import 'package:do_fix/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  int userRating = 0;
  int? selectedRating;
  bool recentlyAdded = false;
  int totalReviews = 0;
  double ratingAvg = 0.0;

  final TextEditingController reviewController = TextEditingController();
  RxBool isSubmittingReview = false.obs;

  String bookingId = '';
  String serviceId = '';

  // ================= MODELS =================
  Rxn<ReviewRatingModel> reviewRatingModel = Rxn<ReviewRatingModel>();
  Rxn<ServiceReviewResponseModel> serviceReviewsModel = Rxn<ServiceReviewResponseModel>();
  Rxn<BookingSetupModel> bookingSetupModel = Rxn<BookingSetupModel>();

  CancelBookingModel? cancelBookingResponse;

  // ================= DATA =================
  List<BookingModel> bookingList = [];
  Map<int, int> starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  RxDouble partialPaymentPercentage = 0.0.obs;
  RxDouble cancellationChargesPercentage = 0.0.obs;

  // ================= UI HELPERS =================

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
    userRating = rating > 0 ? rating : 0;
    this.recentlyAdded = recentlyAdded;

    final reviews = serviceReviewsModel.value?.content?.reviews?.data??[];

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

  Future<void> saveBookingReview() async {
    if (bookingId.isEmpty || serviceId.isEmpty) {
      showCustomSnackBar("Booking or service details are missing", isError: true);
      return;
    }

    if (userRating <= 0) {
      showCustomSnackBar("Please select a rating", isError: true);
      return;
    }

    isSubmittingReview.value = true;
    update();

    try {
      final Response response = await bookingRepo.saveBookingReview(
        bookingId: bookingId,
        serviceId: serviceId,
        reviewRating: userRating.toString(),
        reviewComment: reviewController.text.trim(),
      );

      log("Save Review API Response: ${response.body}");

      if (response.statusCode == 200) {
        showCustomSnackBar(
          "Review submitted successfully",
          isSuccess: true,
          isError: false,
        );

        reviewController.clear();
        selectedRating = null;
        userRating = 0;

        update();
      } else {
        final body = _parseResponseBody(response.body);
        final message = body?['message'] ?? "Failed to submit review";
        showCustomSnackBar(message, isError: true);
      }
    } catch (e, stackTrace) {
      log("Error in saveBookingReview: $e", stackTrace: stackTrace);
      showCustomSnackBar("Error submitting review: $e", isError: true);
    } finally {
      isSubmittingReview.value = false;
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

      serviceReviewsModel.value =
          ServiceReviewResponseModel.fromJson(body);

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
      log(
          "Cancellation payment percentage: ${cancellationChargesPercentage.value}");

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


// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:do_fix/data/repo/booking_repo.dart';
// import 'package:do_fix/model/booking_setup_model.dart';
// import 'package:do_fix/model/cancel_booking_model.dart';
// import 'package:do_fix/model/review_rating_model.dart';
// import 'package:do_fix/model/service_reviews_model.dart';
// import 'package:do_fix/widgets/custom_snack_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../model/booking_model.dart';
// import '../widgets/common_loading.dart';
//
// class BookingController extends GetxController implements GetxService {
//   final BookingRepo bookingRepo;
//   final SharedPreferences sharedPreferences;
//
//   BookingController({
//     required this.bookingRepo,
//     required this.sharedPreferences,
//   });
//
//   int userRating = 0;
//   double ratingAvg = 0.0;
//   Map<int, int> starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
//   final TextEditingController reviewController = TextEditingController();
//   RxBool isSubmittingReview = false.obs;
//   String bookingId = '';
//   String serviceId = '';
//   Rxn<ReviewRatingModel> reviewRatingModel = Rxn<ReviewRatingModel>();
//   List<BookingModel> bookingList = [];
//   Rxn<ServiceReviewsModel> serviceReviewsModel = Rxn<ServiceReviewsModel>();
//
//   int? selectedRating;
//   bool recentlyAdded = false;
//   int totalReviews = 0;
//
//   void setSelectedRating(int? rating) {
//     selectedRating = rating;
//     update();
//   }
//
//   void setRecentlyAdded(bool value) {
//     recentlyAdded = value;
//     update();
//   }
//
//   void applyReviewFilter({required int rating, required bool recentlyAdded}) {
//     if (rating > 0) {
//       userRating = rating;
//     } else {
//       userRating = 0;
//     }
//     this.recentlyAdded = recentlyAdded;
//     if (recentlyAdded) {
//       serviceReviewsModel.value?.reviews?.sort((a, b) {
//         return b.updatedAt?.compareTo(a.updatedAt ?? DateTime.now()) ?? 0;
//       });
//     }
//     update();
//   }
//
//   Future<void> getBookingReview(String bookingId) async {
//     try {
//       Response response =
//       await bookingRepo.fetchBookingReview(bookingId: bookingId);
//
//       if (response.statusCode == 200) {
//
//         log("API RESPONSE: ${response.body}");
//
//         if (response.body["content"] != null) {
//           reviewRatingModel.value =
//               ReviewRatingModel.fromJson(response.body);
//
//           totalReviews =
//               reviewRatingModel.value?.content?.first.ratingCount ?? 0;
//
//           ratingAvg =
//               (reviewRatingModel.value?.content?.first.avgRating ?? 0).toDouble();
//         } else {
//           totalReviews = 0;
//           ratingAvg = 0.0;
//         }
//       }
//     } catch (e) {
//       showCustomSnackBar("Error: $e", isError: true);
//     } finally {
//       hideLoading();
//       update();
//     }
//   }
//
//   Future<void> saveBookingReview() async {
//     try {
//       Response response = await bookingRepo.saveBookingReview(
//         bookingId: bookingId,
//         serviceId: serviceId,
//         reviewRating: userRating.toString(),
//         reviewComment: reviewController.text,
//       );
//       if (response.statusCode == 200) {
//         // Handle success (show message, update state, etc.)
//         showCustomSnackBar(
//           "Review submitted successfully",
//           isSuccess: true,
//           isError: false,
//         );
//         log("Review submitted: ${response.body}");
//       } else {
//         showCustomSnackBar("Failed to submit review", isError: true);
//       }
//     } catch (e) {
//       showCustomSnackBar("Error: $e", isError: true);
//     }
//   }
//
//   Future<void> getServiceReview({required String serviceId}) async {
//
//     serviceReviewsModel.value = null;
//     ratingAvg = 0.0;
//     starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
//
//     update();
//
//     showLoading();
//     try {
//
//       log("Service reviews: $serviceId");
//
//       Response response =
//       await bookingRepo.fetchServiceReview(serviceId: serviceId);
//
//       log("API RESPONSE: ${response.body}");
//
//       if (response.statusCode == 200) {
//
//         final decoded = jsonDecode(response.body);
//
//         serviceReviewsModel.value =
//             ServiceReviewsModel.fromJson(decoded["content"]);
//
//         List<ServiceReview> reviews =
//             serviceReviewsModel.value?.reviews ?? [];
//
//         log("REVIEWS: ${decoded["content"]["reviews"]}");
//
//         ///  count stars
//         for (ServiceReview review in reviews) {
//           int rating = review.reviewRating ?? 0;
//
//           if (starCounts.containsKey(rating)) {
//             starCounts[rating] = starCounts[rating]! + 1;
//           }
//         }
//
//         ///  calculate average
//         int total = 0;
//         int count = reviews.length;
//
//         for (var review in reviews) {
//           total += review.reviewRating ?? 0;
//         }
//
//         ratingAvg = count > 0 ? total / count : 0.0;
//
//         print('Average rating: $ratingAvg');
//         print('Star counts: $starCounts');
//
//         update();
//
//       } else {
//         showCustomSnackBar('Failed to fetch reviews');
//       }
//
//     } catch (e) {
//
//       log("Error fetching service reviews: $e");
//
//       showCustomSnackBar(
//         'Failed to fetch reviews due to an error $e',
//         isError: true,
//       );
//
//     } finally {
//       hideLoading();
//     }
//   }
//   Rxn<BookingSetupModel> bookingSetupModel = Rxn<BookingSetupModel>();
//   RxDouble partialPaymentPercentage = 0.0.obs;
//   RxDouble cancellationChargesPercentage = 0.0.obs;
//
//   Future<void> getBookingSetup() async {
//     try {
//       Response response = await bookingRepo.getBookingSetupRepo();
//       if (response.statusCode == 200) {
//         log("Booking setup content: ${response.body}");
//         bookingSetupModel.value = BookingSetupModel.fromJson(response.body);
//
//         final contentList = bookingSetupModel.value?.content ?? [];
//         final partialPaymentContent = contentList.firstWhere(
//           (item) => item.keyName == 'partial_payment',
//           orElse: () => contentList.first,
//         );
//
//         if (partialPaymentContent.keyName == 'partial_payment' &&
//             partialPaymentContent.liveValues != null) {
//           partialPaymentPercentage.value =
//               double.tryParse(partialPaymentContent.liveValues.toString()) ??
//                   0.0;
//         } else {
//           partialPaymentPercentage.value = 0.0;
//         }
//
//         final cancellationChargesContent = contentList.firstWhere(
//           (item) => item.keyName == 'cancelation_fee',
//           orElse: () => contentList.first,
//         );
//
//         if (cancellationChargesContent.keyName == 'cancelation_fee' &&
//             cancellationChargesContent.liveValues != null) {
//           cancellationChargesPercentage.value = double.tryParse(
//                   cancellationChargesContent.liveValues.toString()) ??
//               0.0;
//         } else {
//           cancellationChargesPercentage.value = 0.0;
//         }
//
//         log("Partial payment percentage: ${partialPaymentPercentage.value}");
//         log("Cancellation payment percentage: ${cancellationChargesPercentage.value}");
//         hideLoading();
//       } else {
//         showCustomSnackBar("Booking setup error occurred", isError: true);
//       }
//     } catch (e) {
//       showCustomSnackBar("Error: $e", isError: true);
//     } finally {
//       hideLoading();
//       update();
//     }
//   }
//
//   CancelBookingModel? cancelBookingResponse;
//
//   Future<void> cancelBookingController(String id) async {
//     showLoading();
//     update();
//     try {
//       Response response = await bookingRepo.cancelBooking(
//         bookingId: id,
//         bookingStatus: "canceled",
//       );
//       var responseData = response.body;
//
//       if (responseData == null) {
//         throw Exception("Response data is null");
//       }
//
//       log("Response data cancel booking: $responseData");
//       await Future.delayed(Duration(seconds: 1));
//       if (response.statusCode == 200) {
//         if (responseData['response_code']
//             .toString()
//             .contains("status_update_success_200")) {
//           cancelBookingResponse = CancelBookingModel.fromJson(responseData);
//           hideLoading();
//           update();
//         } else {
//           hideLoading();
//           closeSnackBarIfActive();
//           showCustomSnackBar(responseData['message'], isError: true);
//         }
//       } else {
//         hideLoading();
//         closeSnackBarIfActive();
//         showCustomSnackBar(responseData['message'], isError: true);
//       }
//     } catch (e) {
//       hideLoading();
//       showCustomSnackBar("Something went wrong. Please try again. $e",
//           isError: true);
//       debugPrint("Error fetching bookings: $e");
//       closeSnackBarIfActive();
//     } finally {
//       hideLoading();
//     }
//   }
// }
