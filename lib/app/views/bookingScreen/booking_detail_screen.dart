import 'dart:developer';
import 'package:do_fix/app/views/bookingScreen/widgets/custom_cancel_button.dart';
import 'package:do_fix/app/views/bookingScreen/widgets/custom_invoide_button.dart';
import 'package:do_fix/app/widgets/custom_appbar.dart';
import 'package:do_fix/app/widgets/custom_booking_details_items.dart';
import 'package:do_fix/app/widgets/review_input_widget.dart';
import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/model/booking_model.dart';
import 'package:do_fix/utils/app_constants.dart';
import 'package:do_fix/utils/string_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/dimensions.dart';
import '../home/component/variations_new_card.dart';

class BookingDetailScreen extends StatefulWidget {
  final String? formattedTime;
  final String? formattedDate;
  final String locationAddress;
  final String userComments;
  final String paymentMethod;
  final Booking? booking;

  const BookingDetailScreen({
    super.key,
    this.formattedTime,
    this.formattedDate,
    required this.locationAddress,
    required this.paymentMethod,
    required this.userComments,
    this.booking,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final dashBoardController = Get.find<DashBoardController>();
  final bookController = Get.find<BookingController>();

  void _showReviewDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ],
              ),
              ReviewInputWidget(
                serviceId: widget.booking?.servicemanId ?? "",
                bookingId: widget.booking?.id ?? "",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _showCancelBookingDialog() {
  //   Get.dialog(
  //     Dialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       child: Container(
  //         padding: EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(
  //               Icons.warning_amber_rounded,
  //               color: Colors.orange,
  //               size: 48,
  //             ),
  //             SizedBox(height: 16),
  //             Text(
  //               'Cancel Booking',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black,
  //               ),
  //             ),
  //             SizedBox(height: 12),
  //             Text(
  //               'Are you sure you want to cancel this booking? You will be charged ${bookController.cancellationChargesPercentage.value}% of the booking amount as cancellation fee.',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 fontSize: Dimensions.fontSize14,
  //                 color: Colors.black54,
  //                 height: 1.4,
  //               ),
  //             ),
  //             SizedBox(height: 24),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: OutlinedButton(
  //                     onPressed: () {
  //                       Get.back();
  //                     },
  //                     style: OutlinedButton.styleFrom(
  //                       side: BorderSide(color: Colors.grey),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       padding: EdgeInsets.symmetric(vertical: 12),
  //                     ),
  //                     child: Text(
  //                       'No',
  //                       style: TextStyle(
  //                         color: Colors.grey[700],
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 12),
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     onPressed: () async {
  //                       Get.back();
  //                       await bookController
  //                           .cancelBookingController(widget.booking?.id);
  //                       await Get.find<DashBoardController>()
  //                           .getBookingDetails(widget.booking?.id ?? "");
  //                       await Get.find<BookingController>()
  //                           .getBookingReview(widget.booking?.id ?? "");
  //                       Get.back();
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.red,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       padding: EdgeInsets.symmetric(vertical: 12),
  //                     ),
  //                     child: Text(
  //                       'Yes',
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green; // success
      case 'ongoing':
        return Colors.blue; // in progress
      case 'accepted':
        return Colors.blueAccent; // accepted
      case 'pending':
        return Colors.orange; // waiting
      case 'canceled':
        return Colors.red; // cancelled
      default:
        return Colors.grey;
    }
  }
  @override
  Widget build(BuildContext context) {
    log("LIST LENGTH : ${dashBoardController.bookingResponse?.content?.detail?.length}");
    log("Current Booking status : ${widget.booking?.bookingStatus}");
    final details = dashBoardController.bookingResponse?.content?.detail ?? [];
    final mainServices = details.where((d) => d.isAddOn == 0).toList();
    final addOnServices = details.where((d) => d.isAddOn == 1).toList();

    return SafeArea(
      top: false,
      child: Scaffold(
        bottomNavigationBar: (widget.booking?.bookingStatus == 'completed' ||
                widget.booking?.isPaid == 1)
            ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 19),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          String uri = "";
                          uri =
                              "${AppConstants.baseUrl}${AppConstants.regularBookingInvoiceUrl}${widget.booking?.id}";

                          if (kDebugMode) {
                            print("Uri : $uri");
                          }
                          _launchUrl(uri);
                        },
                        child: CustomInvoiceButton(),
                      ),
                    ),
                    Visibility(
                      child: SizedBox(width: 10),
                      visible: (widget.booking?.bookingStatus == 'pending'),
                    ),
                    Visibility(
                      visible: ((widget.booking?.bookingStatus == 'pending') &&
                          widget.booking?.isPaid == 0),
                      child: Expanded(
                        child: InkWell(
                          onTap: () async {
                            await bookController
                                .cancelBookingController(widget.booking?.id);
                            await Get.find<DashBoardController>()
                                .getBookingDetails(widget.booking?.id ?? "");
                            await Get.find<BookingController>()
                                .getBookingReview(widget.booking?.id ?? "");
                            Get.back();
                          },
                          child: CustomCancelledButton(),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : ((widget.booking?.bookingStatus == 'pending') &&
                    widget.booking?.isPaid == 0)
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 19),
                    child: InkWell(
                        onTap: () async {
                          await bookController
                              .cancelBookingController(widget.booking?.id);
                          await Get.find<DashBoardController>()
                              .getBookingDetails(widget.booking?.id ?? "");
                          await Get.find<BookingController>()
                              .getBookingReview(widget.booking?.id ?? "");
                          Get.back();
                        },
                        child: CustomCancelledButton()),
                  )
                : (widget.booking?.bookingStatus == 'ongoing')
          ? Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 19),
        child: InkWell(
          onTap: () {
            // 🔹 TODO: open add extra service bottom sheet / API
            // showAddExtraServiceSheet(
            //   context,
            //   widget.booking!,
            // );
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFF207FA8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                "Add Extra Work",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      )
          : SizedBox.shrink(),
      appBar: CustomAppBar(
          title: 'Booking Details',
          isSearchButtonExist: false,
          isBackButtonExist: true,
          isCartButtonExist: false,
          isAddressExist: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ListView.builder(
                //   shrinkWrap: true,
                //   physics: NeverScrollableScrollPhysics(),
                //   itemCount: dashBoardController
                //           .bookingResponse?.content?.detail?.length ??
                //       0,
                //   itemBuilder: (context, index) {
                //     final detail = dashBoardController
                //         .bookingResponse?.content?.detail?[index];
                //     if (detail == null) return const SizedBox.shrink();

                //     return Padding(
                //       padding: const EdgeInsets.only(bottom: 16.0),
                //       child: CustomBookingDetailsItems(
                //         detail: detail,
                //       ),
                //     );
                //   },
                // ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mainServices.isNotEmpty) ...[
                      Row(
                        children: [
                          Text(
                            "Main Service",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Dimensions.fontSizeDefault,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.black.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: mainServices.length,
                        itemBuilder: (context, index) {
                          final detail = mainServices[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: CustomBookingDetailsItems(detail: detail),
                          );
                        },
                      ),
                    ],
                    if (addOnServices.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            "Add on Service",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.black.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: addOnServices.length,
                        itemBuilder: (context, index) {
                          final detail = addOnServices[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: CustomBookingDetailsItems(detail: detail),
                          );
                        },
                      ),
                    ],
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Scheduled on",
                  style: TextStyle(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Divider(
                  height: 0.5,
                  color: Colors.black.withAlpha((0.1 * 255).toInt()),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      widget.formattedDate ?? "No Date Found",
                      style: TextStyle(
                        fontSize: Dimensions.fontSize14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF227FA8),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Container(
                      height: 26,
                      width: 0.25,
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      widget.formattedTime ?? "No Time Found",
                      style: TextStyle(
                        fontSize: Dimensions.fontSize14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF227FA8),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      "Location  For Services ",
                      style: TextStyle(
                        fontSize: Dimensions.fontSize14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  widget.locationAddress,
                  style: TextStyle(
                      fontSize: Dimensions.fontSize12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000).withAlpha((0.3 * 255).toInt())),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.comment,
                      size: 14,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      "Additional Comment",
                      style: TextStyle(
                        fontSize: Dimensions.fontSize14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  widget.booking?.message ?? "No Comments found",
                  style: TextStyle(
                      fontSize: Dimensions.fontSize12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000).withAlpha((0.3 * 255).toInt())),
                  ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.payment,
                      size: 16,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      // "Payment Method",
                      "Payment Type",
                      style: TextStyle(
                        fontSize: Dimensions.fontSize14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  widget.paymentMethod == "razor_pay"
                      ? (widget.booking?.isPaid == 1
                      ? "Online Payment (Pending)"
                      : "Online Payment (Pending)")
                      : "Cash Payment (Pending)",
                  style: TextStyle(
                    fontSize: Dimensions.fontSize12,
                    fontWeight: FontWeight.w500,
                    color: widget.booking?.isPaid == 1
                        ? Colors.green // paid
                        : Colors.orange, // pending
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.work,
                      size: 16,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      "Service Status",
                      style: TextStyle(
                        fontSize: Dimensions.fontSize14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 6,
                ),
                // 🔵🟡🟢🔴 Status wise color handling
                Text(
                  widget.booking?.bookingStatus?.toLowerCase() == "canceled"
                      ? "Cancelled"
                      : capitalizeFirst(widget.booking?.bookingStatus ?? ""),
                  style: TextStyle(
                    fontSize: Dimensions.fontSize12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(widget.booking?.bookingStatus),
                  ),
                ),

                SizedBox(
                  height: 16,
                ),
                Divider(
                  color: Colors.black.withAlpha((0.3 * 255).toInt()),
                  height: 0.75,
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.booking?.isPaid == 1
                          ? "Amount Paid"
                          : "Amount to Pay",
                      style: TextStyle(
                          fontSize: Dimensions.fontSize14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000)
                              .withAlpha((0.71 * 255).toInt())),
                    ),
                    Text(
                      "₹${dashBoardController.bookingResponse?.content?.totalBookingAmount.toString() ?? "NIL"}",
                      style: TextStyle(
                        fontSize: Dimensions.fontSize14,
                        fontWeight: FontWeight.bold,
                        color: widget.booking?.isPaid == 1
                            ? Colors.green
                            : Color(0xFF207FA8),
                      ),
                    ),
                  ],
                ),
                // SizedBox(
                //   height: 20,
                // ),
                // Text(
                //   "Ratings & Review",
                //   style: TextStyle(
                //     fontSize: Dimensions.fontSizeDefault,
                //     fontWeight: FontWeight.bold,
                //     color: Color(0xFF000000),
                //   ),
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                // Divider(
                //   color: Colors.black.withAlpha((0.3 * 255).toInt()),
                //   height: 0.75,
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                // Text(
                //   "Review  : The Service Was Done Properly",
                //   style: TextStyle(
                //     fontSize: Dimensions.fontSize14,
                //     fontWeight: FontWeight.normal,
                //     color: Color(0xFF000000),
                //   ),
                // ),
                SizedBox(
                  height: 16,
                ),
                if (bookController.reviewRatingModel.value != null &&
                    bookController.reviewRatingModel.value!.content != null &&
                    bookController
                        .reviewRatingModel.value!.content!.isNotEmpty &&
                    bookController
                            .reviewRatingModel.value!.content![0].reviews !=
                        null &&
                    bookController.reviewRatingModel.value!.content![0].reviews!
                        .isNotEmpty &&
                    widget.booking?.bookingStatus == 'completed')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ratings & Review',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: Dimensions.fontSizeDefault,
                          fontFamily: 'Albert Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index <
                                      (bookController
                                              .reviewRatingModel
                                              .value
                                              ?.content?[0]
                                              .reviews?[0]
                                              .reviewRating ??
                                          0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            bookController.reviewRatingModel.value?.content?[0]
                                        .reviews?[0].reviewRating !=
                                    null
                                ? "${bookController.reviewRatingModel.value?.content?[0].reviews?[0].reviewRating} stars"
                                : "No rating",
                            style: TextStyle(
                              fontSize: Dimensions.fontSize14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        bookController.reviewRatingModel.value?.content?[0]
                                    .reviews?[0].reviewComment !=
                                null
                            ? "Review : ${bookController.reviewRatingModel.value?.content?[0].reviews?[0].reviewComment}"
                            : "No review provided.",
                        style: TextStyle(
                          fontSize: Dimensions.fontSize14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                if ((bookController.reviewRatingModel.value == null ||
                        bookController.reviewRatingModel.value!.content ==
                            null ||
                        bookController
                            .reviewRatingModel.value!.content!.isEmpty ||
                        (bookController
                                .reviewRatingModel.value!.content!.isNotEmpty &&
                            bookController.reviewRatingModel.value!.content![0]
                                    .reviews ==
                                null) ||
                        (bookController
                                .reviewRatingModel.value!.content!.isNotEmpty &&
                            bookController.reviewRatingModel.value!.content![0]
                                    .reviews !=
                                null &&
                            bookController.reviewRatingModel.value!.content![0]
                                .reviews!.isEmpty)) &&
                    widget.booking?.bookingStatus == 'completed')
                  Divider(height: 32),
                Obx(() {
                  // Directly access the observable value
                  final reviewModel = bookController.reviewRatingModel.value;
                  final content = reviewModel?.content;
                  final reviews = content?.firstOrNull?.reviews;

                  // Check if there are no reviews
                  final hasNoReviews = content == null ||
                      content.isEmpty ||
                      reviews == null ||
                      reviews.isEmpty;

                  // Show review widget only if booking is completed, there are no reviews and no successful submission
                  final shouldShowReview =
                      widget.booking?.bookingStatus == 'completed' &&
                          hasNoReviews;
                  return shouldShowReview
                      ? GestureDetector(
                          onTap: () => _showReviewDialog(),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFF207FA8).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF207FA8).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.star_outline,
                                    color: Color(0xFF207FA8),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rate your experience',
                                        style: TextStyle(
                                          fontSize: Dimensions.fontSize14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Share your experience with this service',
                                        style: TextStyle(
                                          fontSize: Dimensions.fontSize12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF207FA8),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _launchUrl(String urlString) async {
  final Uri url = Uri.parse(urlString);
  await launchUrl(url, mode: LaunchMode.externalApplication);
}
