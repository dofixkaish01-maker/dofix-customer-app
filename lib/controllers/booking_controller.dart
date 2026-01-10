import 'dart:convert';
import 'dart:developer';

import 'package:do_fix/data/repo/booking_repo.dart';
import 'package:do_fix/model/booking_setup_model.dart';
import 'package:do_fix/model/cancel_booking_model.dart';
import 'package:do_fix/model/review_rating_model.dart';
import 'package:do_fix/model/service_reviews_model.dart';
import 'package:do_fix/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/common_loading.dart';
import '../widgets/custom_snackbar.dart' hide showCustomSnackBar;

class BookingController extends GetxController implements GetxService {
  final BookingRepo bookingRepo;
  final SharedPreferences sharedPreferences;

  BookingController({
    required this.bookingRepo,
    required this.sharedPreferences,
  });

  int userRating = 0;
  double ratingAvg = 0.0;
  Map<int, int> starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  final TextEditingController reviewController = TextEditingController();
  RxBool isSubmittingReview = false.obs;
  String bookingId = '';
  String serviceId = '';
  Rxn<ReviewRatingModel> reviewRatingModel = Rxn<ReviewRatingModel>();

  Rxn<ServiceReviewsModel>? serviceReviewsModel = Rxn<ServiceReviewsModel>();

  int? selectedRating;
  bool recentlyAdded = false;

  void setSelectedRating(int? rating) {
    selectedRating = rating;
    update();
  }

  void setRecentlyAdded(bool value) {
    recentlyAdded = value;
    update();
  }

  void applyReviewFilter({required int rating, required bool recentlyAdded}) {
    if (rating > 0) {
      userRating = rating;
    } else {
      userRating = 0;
    }
    this.recentlyAdded = recentlyAdded;
    if (recentlyAdded) {
      serviceReviewsModel?.value?.reviews?.sort((a, b) {
        return b.updatedAt?.compareTo(a.updatedAt ?? DateTime.now()) ?? 0;
      });
    }
    update();
  }

  Future<void> getBookingReview(String bookingId) async {
    try {
      Response response =
          await bookingRepo.fetchBookingReview(bookingId: bookingId);
      if (response.statusCode == 200) {
        log("Booking review content: ${response.body}");
        reviewRatingModel.value = ReviewRatingModel.fromJson(response.body);
        hideLoading();
      } else {
        showCustomSnackBar("Failed to fetch review", isError: true);
      }
    } catch (e) {
      showCustomSnackBar("Error: $e", isError: true);
    } finally {
      hideLoading();
      update();
    }
  }

  Future<void> saveBookingReview() async {
    try {
      Response response = await bookingRepo.saveBookingReview(
        bookingId: bookingId,
        serviceId: serviceId,
        reviewRating: userRating.toString(),
        reviewComment: reviewController.text,
      );
      if (response.statusCode == 200) {
        // Handle success (show message, update state, etc.)
        showCustomSnackBar(
          "Review submitted successfully",
          isSuccess: true,
          isError: false,
        );
        log("Review submitted: ${response.body}");
      } else {
        showCustomSnackBar("Failed to submit review", isError: true);
      }
    } catch (e) {
      showCustomSnackBar("Error: $e", isError: true);
    }
  }

  Future<void> getServiceReview({required String serviceId}) async {
    showLoading();
    try {
      starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      log("Service reviews: ${serviceId}");
      Response response =
          await bookingRepo.fetchServiceReview(serviceId: serviceId);
      if (response.statusCode == 200) {
        log("yyyy Service reviews: ${response.body}");
        serviceReviewsModel?.value =
            ServiceReviewsModel.fromJson(jsonDecode(response.body));
        List<ServiceReview> reviews = serviceReviewsModel?.value?.reviews ?? [];

        for (ServiceReview review in reviews) {
          int rating = review.reviewRating ?? 0;
          if (starCounts.containsKey(rating)) {
            starCounts[rating] = starCounts[rating]! + 1;
          }
        }

        int total = 0;
        int count = reviews.length;

        for (var review in reviews) {
          total += review.reviewRating ?? 0;
        }

        ratingAvg = count > 0 ? total / count : 0.0;

        print('Average rating: $ratingAvg');
        print('Star counts: $starCounts');

        update();
      } else {
        showCustomSnackBar('Failed to fetch reviews');
      }
    } catch (e) {
      log("Error fetching service reviews: $e");
      showCustomSnackBar('Failed to fetch reviews due to an error $e',
          isError: true);
    } finally {
      hideLoading();
    }
  }

  Rxn<BookingSetupModel> bookingSetupModel = Rxn<BookingSetupModel>();
  RxDouble partialPaymentPercentage = 0.0.obs;
  RxDouble cancellationChargesPercentage = 0.0.obs;

  Future<void> getBookingSetup() async {
    try {
      Response response = await bookingRepo.getBookingSetupRepo();
      if (response.statusCode == 200) {
        log("Booking setup content: ${response.body}");
        bookingSetupModel.value = BookingSetupModel.fromJson(response.body);

        final contentList = bookingSetupModel.value?.content ?? [];
        final partialPaymentContent = contentList.firstWhere(
          (item) => item.keyName == 'partial_payment',
          orElse: () => contentList.first,
        );

        if (partialPaymentContent.keyName == 'partial_payment' &&
            partialPaymentContent.liveValues != null) {
          partialPaymentPercentage.value =
              double.tryParse(partialPaymentContent.liveValues.toString()) ??
                  0.0;
        } else {
          partialPaymentPercentage.value = 0.0;
        }

        final cancellationChargesContent = contentList.firstWhere(
          (item) => item.keyName == 'cancelation_fee',
          orElse: () => contentList.first,
        );

        if (cancellationChargesContent.keyName == 'cancelation_fee' &&
            cancellationChargesContent.liveValues != null) {
          cancellationChargesPercentage.value = double.tryParse(
                  cancellationChargesContent.liveValues.toString()) ??
              0.0;
        } else {
          cancellationChargesPercentage.value = 0.0;
        }

        log("Partial payment percentage: ${partialPaymentPercentage.value}");
        log("Cancellation payment percentage: ${cancellationChargesPercentage.value}");
        hideLoading();
      } else {
        showCustomSnackBar("Booking setup error occurred", isError: true);
      }
    } catch (e) {
      showCustomSnackBar("Error: $e", isError: true);
    } finally {
      hideLoading();
      update();
    }
  }

  CancelBookingModel? cancelBookingResponse;

  Future<void> cancelBookingController(String id) async {
    showLoading();
    update();
    try {
      Response response = await bookingRepo.cancelBooking(
        bookingId: id,
        bookingStatus: "canceled",
      );
      var responseData = response.body;

      if (responseData == null) {
        throw Exception("Response data is null");
      }

      log("Response data cancel booking: $responseData");
      await Future.delayed(Duration(seconds: 1));
      if (response.statusCode == 200) {
        if (responseData['response_code']
            .toString()
            .contains("status_update_success_200")) {
          cancelBookingResponse = CancelBookingModel.fromJson(responseData);
          hideLoading();
          update();
        } else {
          hideLoading();
          closeSnackBarIfActive();
          showCustomSnackBar(responseData['message'], isError: true);
        }
      } else {
        hideLoading();
        closeSnackBarIfActive();
        showCustomSnackBar(responseData['message'], isError: true);
      }
    } catch (e) {
      hideLoading();
      showCustomSnackBar("Something went wrong. Please try again. $e",
          isError: true);
      debugPrint("Error fetching bookings: $e");
      closeSnackBarIfActive();
    } finally {
      hideLoading();
    }
  }
}
