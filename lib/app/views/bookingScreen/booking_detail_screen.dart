import 'dart:convert';
import 'dart:developer';
import 'package:do_fix/app/views/bookingScreen/widgets/custom_invoide_button.dart';
import 'package:do_fix/app/views/helpSupport/faq_support_screen.dart';
import 'package:do_fix/app/widgets/custom_appbar.dart';
import 'package:do_fix/app/widgets/custom_booking_details_items.dart';
import 'package:do_fix/app/views/services/ratting%20screen/review_input_widget.dart';
import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/model/booking_model.dart';
import 'package:do_fix/model/review_rating_model.dart';
import 'package:do_fix/utils/app_constants.dart';
import 'package:do_fix/utils/string_extensions.dart';
import 'package:do_fix/widgets/custom_edit_review_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/rating_and_review_controller.dart';
import '../../../utils/date_converter.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/theme.dart';
import '../../../widgets/custom_snack_bar.dart';
import '../cart_screen/SubScreen/final_screen.dart';

import '../services/service_details_screen.dart';

//use for open razor pay payment getway

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
    required this.booking,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final dashBoardController = Get.find<DashBoardController>();
  final bookController = Get.find<BookingController>();
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  final bookingController = Get.find<BookingController>();
  late String comment = widget.booking?.message ?? "";

  _showReviewDialog() {
    Get.to(() => ReviewScreen(
          bookingId: widget.booking?.id ?? "",
          serviceId: widget.booking?.servicemanId ?? "",
        ));
  }

  Map<String, dynamic> _buildPaymentData() {
    final booking = widget.booking!;
    final dashController = Get.find<DashBoardController>();
    final address = booking.serviceAddress;

    return {
      "service_address_id": booking.serviceAddressId,
      "contact_person_name": address?.contactPersonName ??
          "${dashController.userModel.firstName} ${dashController.userModel.lastName}",
      "contact_person_number":
          address?.contactPersonNumber ?? dashController.userModel.phone,
      "name": address?.contactPersonName ??
          "${dashController.userModel.firstName} ${dashController.userModel.lastName}",
      "mobile_number": address?.contactPersonNumber?.replaceAll("+91", "") ??
          dashController.userModel.phone.replaceAll("+91", ""),
      "email": dashController.userModel.email,
      "address_label": address?.addressLabel,
      "address": address?.address,
      "lat": address?.lat,
      "lon": address?.lon,
      "lng": address?.lon,
      "zone_id": booking.zoneId,
      "message": booking.message,
      "payment_method": "razor_pay",
      "date": DateConverter.dateTimeForCoupon(selectedDate).toString(),
      "time": formatTimeOfDay24Hour(selectedTime ?? TimeOfDay.now()).toString(),
    };
  }

  // Future<void> _payWithRazorpay() async {
  //   final booking = widget.booking!;
  //   final dashController = Get.find<DashBoardController>();
  //
  //   if (booking.serviceAddressId == null) {
  //     log("ERROR: serviceAddressId is null");
  //     return;
  //   }
  //
  //   await dashController.getUserInfo(false);
  //
  //   final paymentData = _buildPaymentData();
  //   log("RAZORPAY PAYMENT DATA => ${jsonEncode(paymentData)}");
  //
  //   await makeDigitalPayment(
  //     bookingId: booking.id!,
  //     isPartial: 0,
  //     data: paymentData,
  //     onPressed: () async {
  //       await dashController.getBookingDetails(booking.id!);
  //       setState(() {});
  //     },
  //   );
  // }

  Future<void> _payWithRazorpay() async {
    final booking = widget.booking!;
    final dashController = Get.find<DashBoardController>();

    if (booking.serviceAddressId == null) {
      log("ERROR: serviceAddressId is null");
      return;
    }

    await dashController.getUserInfo(false);

    final paymentData = _buildPaymentData();

    log("RAZORPAY PAYMENT DATA => ${jsonEncode(paymentData)}");
    log("BOOKING ID => ${booking.id}");
    log("SERVICE ADDRESS ID => ${booking.serviceAddressId}");
    log("ZONE ID => ${booking.zoneId}");

    try {
      await makeDigitalPayment(
        bookingId: booking.id!,
        isPartial: 0,
        data: paymentData,
        onPressed: () async {
          await dashController.getBookingDetails(booking.id!);
          setState(() {});
        },
      );
      log("makeDigitalPayment called from Razorpay option");
    } catch (e, st) {
      log("Razorpay click error => $e");
      debugPrintStack(stackTrace: st);
    }
  }

  void _showPaymentOptionsBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Choose Payment Option",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.qr_code, color: Colors.green),
                ),
                title: const Text(
                  "Pay via QR",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text("Scan QR code and complete payment"),
                onTap: () async {
                  final bookingId = widget.booking?.id ?? "";

                  final amount = dashBoardController
                          .bookingResponse?.content?.totalBookingAmount ??
                      0;

                  final uri = Uri.parse(
                    'upi://pay?pa=yespay.mabs0736619ikit1232@yesbankltd'
                    '&pn=Dofix%20Technologies%20Private%20Limited'
                    '&am=$amount'
                    '&cu=INR'
                    '&tn=Dofix%20Service%20Booking%20$bookingId',
                  );

                  try {
                    final launched = await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );

                    if (!launched) {
                      showCustomSnackBar("Unable to open UPI app");
                    }
                  } catch (e) {
                    showCustomSnackBar("Unable to open UPI app");
                  }
                }),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.account_balance_wallet, color: Colors.blue),
              ),
              title: const Text(
                "Razorpay",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text("Pay online using Razorpay"),
              onTap: () async {
                Get.back();
                await _payWithRazorpay();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

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
    log("📦 SERVICE ADDRESS OBJECT => ${widget.booking?.serviceAddress}");

    log("📍 LAT RAW => ${widget.booking?.serviceAddress?.lat}");
    log("📍 LON RAW => ${widget.booking?.serviceAddress?.lon}");

    log("🏷 ADDRESS LABEL => ${widget.booking?.serviceAddress?.addressLabel}");
    log("🏠 ADDRESS => ${widget.booking?.serviceAddress?.address}");
    log("🏠 Booking Id => ${widget.booking?.id}");

    log("👤 CONTACT NAME => ${widget.booking?.serviceAddress?.contactPersonName}");
    log("📞 CONTACT NUMBER => ${widget.booking?.serviceAddress?.contactPersonNumber}");

    log("LIST LENGTH : ${dashBoardController.bookingResponse?.content?.detail?.length}");
    log("Current Booking status : ${widget.booking?.bookingStatus}");
    final details = dashBoardController.bookingResponse?.content?.detail ?? [];
    final mainServices = details.where((d) => d.isAddOn == 0).toList();
    final addOnServices = details.where((d) => d.isAddOn == 1).toList();

    return SafeArea(
      top: false,
      child: Scaffold(
        bottomNavigationBar: Builder(
          builder: (context) {
            final bookingStatus =
                (widget.booking?.bookingStatus ?? "").toLowerCase();
            final paymentMethod =
                (widget.booking?.paymentMethod ?? "").toLowerCase();
            final isPaid = widget.booking?.isPaid == 1;
            final isUnpaid = widget.booking?.isPaid == 0;
            final isCompleted = bookingStatus == "completed";
            final isCancelled = bookingStatus == "canceled";
            final isPending = bookingStatus == "pending";

            final isOnline = paymentMethod == "razor_pay";
            final isCash = paymentMethod == "cash" ||
                paymentMethod == "cash_after_service" ||
                paymentMethod == "cash_on_delivery";

            // 1. Cancelled -> nothing
            if (isCancelled) {
              return const SizedBox.shrink();
            }

            // 2. Paid + completed -> show invoice
            if (isPaid && isCompleted) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 19),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          final uri =
                              "${AppConstants.baseUrl}${AppConstants.regularBookingInvoiceUrl}${widget.booking?.id}";
                          _launchUrl(uri);
                        },
                        child: CustomInvoiceButton(),
                      ),
                    ),
                  ],
                ),
              );
            }

            // 3. Unpaid + completed + online -> Pay Now -> open bottomsheet with QR + Razorpay
            if (isUnpaid && isCompleted && isOnline) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 19),
                child: InkWell(
                  onTap: () async {
                    _showPaymentOptionsBottomSheet();

                    // final bookingId = widget.booking?.id ?? "";
                    // final totalAmount = dashBoardController
                    //     .bookingResponse?.content?.totalBookingAmount
                    //     .toString();
                    // final uri = Uri.parse(
                    //   'upi://pay?pa=merchantaumb100007568@aubank'
                    //   '&pn=Dofix%20Technologies%20Private%20Limited'
                    //   '&am=$totalAmount'
                    //   '&cu=INR'
                    //   '&tn=Dofix%20Service%20Booking%20$bookingId',
                    // );
                    //
                    // try {
                    //   final launched = await launchUrl(
                    //     uri,
                    //     mode: LaunchMode.externalApplication,
                    //   );
                    //
                    //   if (!launched) {
                    //     showCustomSnackBar("Unable to open UPI app");
                    //   }
                    // } catch (e) {
                    //   showCustomSnackBar("Unable to open UPI app");
                    // }
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF207FA8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        "Pay Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeDefault,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            // 4. Unpaid + completed + cash -> Pay Now -> only QR
            if (isUnpaid && isCompleted && isCash) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 19),
                child: InkWell(
                  // onTap: () async {
                  //   final bookingId = widget.booking?.id ?? "";
                  //   final totalAmount = dashBoardController
                  //       .bookingResponse?.content?.totalBookingAmount
                  //       .toString();
                  //   final uri = Uri.parse(
                  //     'upi://pay?pa=merchantaumb100007568@aubank'
                  //     '&pn=Dofix%20Technologies%20Private%20Limited'
                  //     '&am=$totalAmount'
                  //     '&cu=INR'
                  //     '&tn=Dofix%20Service%20Booking%20$bookingId',
                  //   );
                  //
                  //   try {
                  //     final launched = await launchUrl(
                  //       uri,
                  //       mode: LaunchMode.externalApplication,
                  //     );
                  //
                  //     if (!launched) {
                  //       showCustomSnackBar("Unable to open UPI app");
                  //     }
                  //   } catch (e) {
                  //     showCustomSnackBar("Unable to open UPI app");
                  //   }
                  // },
                  onTap: () async {
                    final bookingId = widget.booking?.id ?? "";

                    final amount = dashBoardController
                        .bookingResponse?.content?.totalBookingAmount
                        .toString();

                    final uri = Uri.parse(
                      'upi://pay?pa=yespay.mabs0736619ikit1232@yesbankltd'
                      '&pn=Dofix%20Technologies%20Private%20Limited'
                      '&am=$amount'
                      '&cu=INR'
                      '&tn=Dofix%20Service%20Booking%20$bookingId',
                    );

                    try {
                      final launched = await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );

                      if (!launched) {
                        showCustomSnackBar("Unable to open UPI app");
                      }
                    } catch (e) {
                      showCustomSnackBar("Unable to open UPI app");
                    }
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        "Pay Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeDefault,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            // 5. cases -> nothing
            return const SizedBox.shrink();
          },
        ),
        // bottomNavigationBar:
        //     // CANCELLED → NOTHING
        //     (widget.booking?.bookingStatus == 'canceled')
        //         ? const SizedBox.shrink()
        //
        //         // PAYMENT NOT DONE → PAY NOW
        //         : (widget.booking?.isPaid == 0 &&
        //                 widget.booking?.paymentMethod == 'razor_pay')
        //             ? Padding(
        //                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 19),
        //                 child: InkWell(
        //                   // onTap: () async {
        //                   //   final booking = widget.booking!;
        //                   //   final dashController = Get.find<DashBoardController>();
        //                   //
        //                   //   log("BOOKING ID : ${booking.id}");
        //                   //   log("IS PAID : ${booking.isPaid}");
        //                   //
        //                   //   await makeDigitalPayment(
        //                   //     bookingId: booking.id!, //  IMPORTANT
        //                   //     isPartial: 0,
        //                   //     data: {
        //                   //       "name":
        //                   //       "${dashController.userModel.firstName} ${dashController.userModel.lastName}",
        //                   //       "mobile_number": dashController
        //                   //           .userModel.phone
        //                   //           .replaceFirst("+91", ""),
        //                   //       "email": dashController.userModel.email,
        //                   //       "address_label": "service",
        //                   //       "address": widget.locationAddress,
        //                   //       "lat": booking.serviceAddress?.lat,
        //                   //       "lng": booking.serviceAddress?.lon,
        //                   //       "zone_id": booking.zoneId,
        //                   //       "message": booking.message ?? "",
        //                   //       "date": DateConverter.dateTimeForCoupon(selectedDate).toString(),
        //                   //       "time": formatTimeOfDay24Hour(
        //                   //         selectedTime ?? TimeOfDay.now(),
        //                   //       ).toString(),
        //                   //       "city": booking.serviceAddress?.city,
        //                   //       "zip_code": booking.serviceAddress?.zipCode,
        //                   //       "country": booking.serviceAddress?.country,
        //                   //       "street": booking.serviceAddress?.street,
        //                   //       "house": booking.serviceAddress?.house,
        //                   //       "floor": booking.serviceAddress?.floor,
        //                   //     },
        //                   //       onPressed: () async {
        //                   //       await dashController.getBookingDetails(booking.id!);
        //                   //       setState(() {});
        //                   //     },
        //                   //
        //                   //   );
        //                   //   log("makeDigitalPayment CALLED");
        //                   // },
        //                   // onTap: () async {
        //                   //   final booking = widget.booking!;
        //                   //
        //                   //   if (booking.serviceAddressId == null) {
        //                   //     log("ERROR: serviceAddressId is null");
        //                   //     return;
        //                   //   }
        //                   //
        //                   //   await makeBookingPayment(
        //                   //     bookingId: booking.id!,
        //                   //     serviceAddressId: booking.serviceAddressId.toString(),
        //                   //     zoneId: booking.zoneId.toString(),
        //                   //   );
        //                   //   log("SERVICE ADDRESS ID: ${widget.booking?.serviceAddressId}");
        //                   //   log("BOOKING ID TYPE: ${booking.id.runtimeType}");
        //                   //   log("ZONE ID TYPE: ${booking.zoneId.runtimeType}");
        //                   //
        //                   // },
        //                   // onTap: () async {
        //                   //   final booking = widget.booking!;
        //                   //   final dashController = Get.find<DashBoardController>();
        //                   //
        //                   //   log("🔥 BUTTON TAPPED");
        //                   //
        //                   //   if (booking.serviceAddressId == null) {
        //                   //     log("❌ ERROR: serviceAddressId is null");
        //                   //     return;
        //                   //   }
        //                   //
        //                   //   log("✅ SERVICE ADDRESS ID: ${booking.serviceAddressId}");
        //                   //
        //                   //   // Build data map
        //                   //   final Map<String, dynamic> paymentData = {
        //                   //     "service_address_id": booking.serviceAddressId,
        //                   //
        //                   //     "name":
        //                   //     "${dashController.userModel.firstName} ${dashController.userModel.lastName}",
        //                   //     "mobile_number":
        //                   //     dashController.userModel.phone.replaceFirst("+91", ""),
        //                   //     "email": dashController.userModel.email,
        //                   //     "address_label": "service",
        //                   //     "address": widget.locationAddress,
        //                   //     "lat": booking.serviceAddress?.lat,
        //                   //     "lng": booking.serviceAddress?.lon,
        //                   //     "zone_id": booking.zoneId,
        //                   //     "message": booking.message ?? "",
        //                   //     "date": DateConverter.dateTimeForCoupon(selectedDate).toString(),
        //                   //     "time": formatTimeOfDay24Hour(
        //                   //       selectedTime ?? TimeOfDay.now(),
        //                   //     ).toString(),
        //                   //     "city": booking.serviceAddress?.city,
        //                   //     "zip_code": booking.serviceAddress?.zipCode,
        //                   //     "country": booking.serviceAddress?.country,
        //                   //     "street": booking.serviceAddress?.street,
        //                   //     "house": booking.serviceAddress?.house,
        //                   //     "floor": booking.serviceAddress?.floor,
        //                   //   };
        //                   //
        //                   //   // 🔍 PRINT FULL DATA
        //                   //   log("📦 PAYMENT DATA => ${jsonEncode(paymentData)}");
        //                   //
        //                   //   // 🔍 Individual important fields
        //                   //   log("📍 LAT => ${paymentData["lat"]}");
        //                   //   log("📍 LNG => ${paymentData["lng"]}");
        //                   //   log("🏷 ADDRESS LABEL => ${paymentData["address_label"]}");
        //                   //   log("🏠 ADDRESS => ${paymentData["address"]}");
        //                   //   log("👤 NAME => ${paymentData["name"]}");
        //                   //   log("📞 MOBILE => ${paymentData["mobile_number"]}");
        //                   //   log("🆔 SERVICE ADDRESS ID => ${paymentData["service_address_id"]}");
        //                   //
        //                   //   await makeDigitalPayment(
        //                   //     bookingId: booking.id!,
        //                   //     isPartial: 0,
        //                   //     data: paymentData,
        //                   //     onPressed: () async {
        //                   //       await dashController.getBookingDetails(booking.id!);
        //                   //       setState(() {});
        //                   //     },
        //                   //   );
        //                   //
        //                   //   log("🚀 makeDigitalPayment CALLED");
        //                   // },
        //
        //                   onTap: () async {
        //                     // "lat": null,
        //                     // "lon": null,
        //                     // "address_label": null,
        //                     // "address": null,
        //
        //                     log("📍 LON RAW => ${widget.booking?.serviceAddress?.lon}");
        //                     log("📍 LAT RAW => ${widget.booking?.serviceAddress?.lat}");
        //                     log("📍 ADDRESS LABEL RAW => ${widget.booking?.serviceAddress?.lon}");
        //                     log("📍 ADDRESS RAW => ${widget.booking?.serviceAddress?.lon}");
        //                     // log("SERVICE ADDRESS OBJECT => ${widget.booking?.serviceAddress}");
        //                     // log("SERVICE ADDRESS ID => ${widget.booking?.serviceAddressId}");
        //                     // log("✔️ BOOKING OBJECT => ${jsonEncode(widget.booking)}");
        //
        //                     final booking = widget.booking!;
        //                     final dashController =
        //                         Get.find<DashBoardController>();
        //
        //                     log("BUTTON TAPPED");
        //                     log("log lng: ${widget.booking?.serviceAddress?.lon}");
        //
        //                     if (booking.serviceAddressId == null) {
        //                       log("ERROR: serviceAddressId is null");
        //                       return;
        //                     }
        //
        //                     await dashController.getUserInfo(false);
        //
        //                     final address = booking.serviceAddress;
        //
        //                     log("ADDRESS MODEL => ${jsonEncode(address?.toJson())}");
        //
        //                     final Map<String, dynamic> paymentData = {
        //                       "service_address_id": booking.serviceAddressId,
        //
        //                       "contact_person_name": address
        //                               ?.contactPersonName ??
        //                           "${dashController.userModel.firstName} ${dashController.userModel.lastName}",
        //
        //                       "contact_person_number":
        //                           address?.contactPersonNumber ??
        //                               dashController.userModel.phone,
        //
        //                       "name": address?.contactPersonName ??
        //                           "${dashController.userModel.firstName} ${dashController.userModel.lastName}",
        //
        //                       "mobile_number": address?.contactPersonNumber
        //                               ?.replaceAll("+91", "") ??
        //                           dashController.userModel.phone
        //                               .replaceAll("+91", ""),
        //
        //                       "email": dashController.userModel.email,
        //
        //                       //*********** Working ***********
        //                       "address_label": address?.addressLabel,
        //                       "address": address?.address,
        //
        //                       "lat": address?.lat,
        //                       "lon": address?.lon,
        //
        //                       "zone_id": booking.zoneId,
        //                       "message": booking.message,
        //
        //                       "date":
        //                           DateConverter.dateTimeForCoupon(selectedDate)
        //                               .toString(),
        //                       "time": formatTimeOfDay24Hour(
        //                               selectedTime ?? TimeOfDay.now())
        //                           .toString(),
        //                     };
        //
        //                     log("PAYMENT DATA => ${jsonEncode(paymentData)}");
        //
        //                     await makeDigitalPayment(
        //                       bookingId: booking.id!,
        //                       isPartial: 0,
        //                       data: paymentData,
        //                       onPressed: () async {
        //                         await dashController
        //                             .getBookingDetails(booking.id!);
        //                         setState(() {});
        //                       },
        //                     );
        //
        //                     log("makeDigitalPayment CALLED");
        //                   },
        //
        //                   child: Container(
        //                     height: 48,
        //                     decoration: BoxDecoration(
        //                       color: const Color(0xFF207FA8),
        //                       borderRadius: BorderRadius.circular(8),
        //                     ),
        //                     child: const Center(
        //                       child: Text(
        //                         "Pay Now",
        //                         style: TextStyle(
        //                           color: Colors.white,
        //                           fontSize: Dimensions.fontSizeDefault,
        //                           fontWeight: FontWeight.w600,
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               )
        //
        //             /// CASE 2: PAYMENT DONE + SERVICE COMPLETED → SHOW INVOICE
        //             : (widget.booking?.isPaid == 1 &&
        //                     widget.booking?.bookingStatus == 'completed')
        //                 ? Padding(
        //                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 19),
        //                     child: Row(
        //                       children: [
        //                         Expanded(
        //                           child: InkWell(
        //                             onTap: () {
        //                               final uri =
        //                                   "${AppConstants.baseUrl}${AppConstants.regularBookingInvoiceUrl}${widget.booking?.id}";
        //                               _launchUrl(uri);
        //                             },
        //                             child: CustomInvoiceButton(),
        //                           ),
        //                         ),
        //                         // ---- Cancel button (COMMENTED as requested) ----
        //                         // Visibility(
        //                         //   visible: ((widget.booking?.bookingStatus == 'pending') &&
        //                         //       widget.booking?.isPaid == 0),
        //                         //   child: Expanded(
        //                         //     child: InkWell(
        //                         //       onTap: () async {
        //                         //         await bookController
        //                         //             .cancelBookingController(widget.booking?.id);
        //                         //         await Get.find<DashBoardController>()
        //                         //             .getBookingDetails(widget.booking?.id ?? "");
        //                         //         await Get.find<BookingController>()
        //                         //             .getBookingReview(widget.booking?.id ?? "");
        //                         //         Get.back();
        //                         //       },
        //                         //       child: CustomCancelledButton(),
        //                         //     ),
        //                         //   ),
        //                         // ),
        //                       ],
        //                     ),
        //                   )
        //
        //                 /// ⚪ ELSE → NOTHING
        //                 : const SizedBox.shrink(),
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
                        height: 10,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: mainServices.length,
                        itemBuilder: (context, index) {
                          final detail = mainServices[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: GestureDetector(
                              onTap: () async {
                                // Fetch service details for clicked item
                                await Get.find<DashBoardController>()
                                    .getServicesDetails(detail.serviceId ?? "");
                              },
                              child: CustomBookingDetailsItems(detail: detail),
                            ),
                          );
                        },
                      )
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
                            child: GestureDetector(
                                onTap: () async {
                                  // Fetch service details for clicked item
                                  await Get.find<DashBoardController>()
                                      .getServicesDetails(
                                          detail.serviceId ?? "");
                                },
                                child:
                                    CustomBookingDetailsItems(detail: detail)),
                          );
                        },
                      ),
                    ],
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Text(
                      "Scheduled on",
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
                  height: 8,
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
                    Spacer(),
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
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000).withAlpha((0.8 * 255).toInt())),
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.comment, size: 14),
                        SizedBox(width: 3),
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
                    SizedBox(height: 6),
                    Text(
                      comment.trim().isNotEmpty
                          ? comment
                          : "No additional comment provided.",
                      style: TextStyle(
                        fontSize: Dimensions.fontSize12,
                        fontWeight: FontWeight.w500,
                        color: comment.trim().isNotEmpty
                            ? Color(0xFF000000).withAlpha((0.6 * 255).toInt())
                            : Colors.grey, //  placeholder color
                        fontStyle: comment.trim().isNotEmpty
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                  ],
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
                  (widget.booking?.paymentMethod ?? "").toLowerCase() ==
                          "razor_pay"
                      ? "Online Payment"
                      : "Cash Payment",
                  style: TextStyle(
                    fontSize: Dimensions.fontSize12,
                    fontWeight: FontWeight.w500,
                    color:
                        (widget.booking?.paymentMethod ?? "").toLowerCase() ==
                                "razor_pay"
                            ? const Color(0xFF207FA8)
                            : Colors.orange,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      // "Payment Method",
                      "Payment Status",
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
                  widget.booking?.isPaid == 1
                      ? "Paid"
                      : widget.booking?.bookingStatus?.toLowerCase() ==
                              "completed"
                          ? "Pending Payment"
                          : "Pending",
                  style: TextStyle(
                    fontSize: Dimensions.fontSize12,
                    fontWeight: FontWeight.w500,
                    color: widget.booking?.isPaid == 1
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                SizedBox(
                  height: 10,
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
                // Status wise color handling
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
                Row(
                  children: [
                    Text(
                      "Total Amount",
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
                Obx(() {
                  final reviewModel = bookController.reviewRatingModel.value;

                  if (reviewModel != null &&
                      reviewModel.content != null &&
                      reviewModel.content!.isNotEmpty &&
                      reviewModel.content![0].reviews != null &&
                      reviewModel.content![0].reviews!.isNotEmpty &&
                      widget.booking?.bookingStatus == 'completed') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Ratings & Review',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: Dimensions.fontSizeDefault,
                                fontWeight: FontWeight.bold,
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
                        SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index <
                                        (reviewModel.content?[0].reviews?[0]
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
                              "${reviewModel.content?[0].reviews?[0].reviewRating ?? 0} stars",
                            ),
                            Spacer(),

                            /// EDIT BUTTON (same as yours)
                            IconButton(
                              onPressed: () async {
                                Get.put(RatingAndReviewController());
                                final dashBoardController =
                                    Get.find<DashBoardController>();

                                final token = dashBoardController
                                        .authRepo.apiClient.token ??
                                    "";
                                final zoneID =
                                    dashBoardController.zoneIdForBooking;

                                final review =
                                    reviewModel.content?[0].reviews?[0];

                                final result = await Get.bottomSheet(
                                  EditReviewBottomSheet(
                                    initialRating: review?.reviewRating ?? 0,
                                    initialComment: review?.reviewComment ?? "",
                                    customerID: review!.id ?? "",
                                    token: token,
                                    zoneID: zoneID,
                                  ),
                                  isScrollControlled: true,
                                );

                                if (result == true) {
                                  await bookController
                                      .getBookingReview(widget.booking?.id);
                                }
                              },
                              icon: Icon(Icons.edit,
                                  color: primaryColor, size: 18),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Review : ${reviewModel.content?[0].reviews?[0].reviewComment ?? "No review"}",
                        ),
                      ],
                    );
                  }

                  return SizedBox.shrink();
                }),
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
                SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    _showHelpBottomSheet();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.support_agent, color: primaryBlue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Need help regarding this service?",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpBottomSheet() {
    const supportNumber = "8383849293";
    final bookingId = widget.booking?.id ?? "N/A";

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- Title ----
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const Text(
              "Service Support",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ---- Call Support ----
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.call, color: Colors.green),
              ),
              title: const Text(
                "Call Support",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text("Talk directly with our support team"),
              onTap: () async {
                final Uri uri = Uri.parse("tel:+91$supportNumber");
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),

            const SizedBox(height: 8),

            // ---- WhatsApp Support ----
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE0F2F1),
                child: Icon(Icons.chat, color: Colors.teal),
              ),
              title: const Text(
                "WhatsApp Support",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text("Chat with us on WhatsApp"),
              onTap: () async {
                final Uri uri = Uri.parse(
                  "https://wa.me/91$supportNumber?text="
                  "Hi, I need help with booking ID: $bookingId",
                );

                if (await canLaunchUrl(uri)) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

Future<void> _launchUrl(String urlString) async {
  final Uri url = Uri.parse(urlString);
  await launchUrl(url, mode: LaunchMode.externalApplication);
}

// Future<void> makeBookingPayment({
//   required String bookingId,
//   required String serviceAddressId,
//   required String zoneId,
// }) async {
//
//   final url =
//       '${AppConstants.baseUrl}payment?payment_method=razor_pay'
//       '&booking_id=$bookingId'
//       '&zone_id=$zoneId'
//       '&service_address_id=$serviceAddressId'
//       '&callback=https://panel.dofix.in'
//       '&is_partial=0'
//       '&payment_platform=app';
//
//   debugPrint("FINAL PAYMENT URL: $url");
//
//   Get.to(() => PaymentScreen(
//     url: url,
//     onPressed: null,
//     data: {},
//   ));
// }
