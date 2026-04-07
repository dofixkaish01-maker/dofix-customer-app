import 'dart:developer';

import 'package:do_fix/data/api/api.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';

class BookingRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  BookingRepo({
    required this.apiClient,
    required this.sharedPreferences,
  });

  Future<Response> fetchBookingReview({required String bookingId}) async {
    final Response res = await apiClient.getData(
      AppConstants.getCustomerBookingReview,
      query: {"booking_id": bookingId},
      method: "GET",
    );

    log("BOOKING REVIEW RESPONSE => ${res.body}");
    return res;
  }

  Future<Response> getBookingSetupRepo() async {
    return await apiClient.getData(
      AppConstants.getBookingSetupApi,
      method: "GET",
    );
  }


  Future<Response> saveBookingReview({
    required String bookingId,
    required String serviceId,
    required String reviewRating,
    String? reviewImage,
    String? reviewComment,
  }) async {

    Map<String, String> body = {
      'booking_id': bookingId,
      'service_id': serviceId,
      'review_rating': reviewRating,
      'review_image': reviewImage ?? "",
    };

    if (reviewComment != null && reviewComment.isNotEmpty) {
      body['review_comment'] = reviewComment;
    }
    if (reviewImage != null && reviewImage.isNotEmpty) {
      body['review_image'] = reviewImage;
    }

    log("REVIEW BODY: $body");

    return await apiClient.postData(
      AppConstants.saveCustomerReview,
      body,
    );
  }

  Future<Response> fetchServiceReview({
    required String serviceId,
  }) async {
    return await apiClient.getData(
      "${AppConstants.showServiceReviews}/$serviceId",
      query: {
        "limit": "40",
        "offset": "1",
      },
      method: "GET",
    );
  }

  Future<Response> cancelBooking({
    required String bookingId,
    required String bookingStatus,
  }) async {
    return await apiClient.getData(
      "${AppConstants.cancelBookingApi}/$bookingId",
      query: {
        "booking_status": bookingStatus,
      },
      method: "PUT",
    );
  }
}

