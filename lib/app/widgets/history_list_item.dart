import 'package:do_fix/app/views/bookingScreen/booking_detail_screen.dart';
import 'package:do_fix/controllers/booking_controller.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/booking_model.dart';
import '../../utils/string_extensions.dart';

class HistoryListItem extends StatefulWidget {
  final Booking? booking;

  const HistoryListItem({
    super.key,
    required this.booking,
  });

  @override
  State<HistoryListItem> createState() => _HistoryListItemState();
}

class _HistoryListItemState extends State<HistoryListItem> {
  final bookController = Get.find<BookingController>();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,      // ✅ ADD
      highlightColor: Colors.transparent,   // ✅ ADD
      hoverColor: Colors.transparent,       // ✅ ADD
      focusColor: Colors.transparent,       // ✅ ADD
      onTap: () async {
        await Get.find<DashBoardController>()
            .getBookingDetails(widget.booking?.id ?? "");
        await Get.find<BookingController>()
            .getBookingReview(widget.booking?.id ?? "");
        if (Get.find<DashBoardController>().bookingResponse != null) {
          final booking =
              Get.find<DashBoardController>().bookingResponse?.content;
          bookController.bookingId = booking.id;
          bookController.serviceId = Get.find<DashBoardController>()
                  .bookingResponse
                  ?.content
                  .detail[0]
                  .serviceId
                  .toString() ??
              "";
          String rawDateTime = booking.serviceSchedule.toString();
          DateTime dateTime = DateTime.parse(rawDateTime);

          String formattedDate =
              DateFormat("d MMMM y").format(dateTime); // 9 September 2025

          String formattedTime =
              DateFormat("hh:mm a").format(dateTime); // 06:00 PM

          final result = await Get.to(BookingDetailScreen(
            formattedDate: formattedDate,
            formattedTime: formattedTime,
            locationAddress:
                booking.serviceAddress?.address ?? "Address Not Available",
            userComments: booking.message ?? "No Comments",
            paymentMethod: booking.paymentMethod ?? "No Payment Method",
            booking: widget.booking,
          ));

          // If result contains refresh request, trigger a refresh
          if (result != null && result is Map && result['refresh'] == true) {
            final controller = Get.find<DashBoardController>();
            String status = result['status'] ?? 'all';

            // Refresh the booking data
            await controller.getBooking({
              "limit": "100",
              "offset": "1",
              "booking_status": status,
              "service_type": "all"
            });
            controller.update();
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 9),
        // height: 154,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 35,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: Color(0xFFE8F1F8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "${widget.booking?.category?.name.toString() ?? "0"} - ${widget.booking?.subCategory?.name.toString() ?? "0"}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Booking ID :",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Spacer(),
                Text(
                  // DateFormat('dd-MM-yyyy').format(
                  //   DateTime.parse(widget.booking!.serviceSchedule!),
                  // ),
                  "#${widget.booking!.readableId.toString()}",
                  // widget.booking!.serviceSchedule ?? DateTime.now()),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(children: [
              Text(
                "Scheduled Time :",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Spacer(),
              Text(
                DateFormat('dd-MM-yyyy').format(
                  DateTime.parse(widget.booking!.serviceSchedule!),
                ),
                // widget.booking!.serviceSchedule ?? DateTime.now()),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                DateFormat('hh:mm a').format(
                  DateTime.parse(widget.booking!.serviceSchedule!),
                ),
                // widget.booking!.serviceSchedule ?? DateTime.now()),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ]),
            SizedBox(height: 12),
            /// 🔵 Service Status
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Service Status :",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),

                Spacer(), // GAP HERE

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getServiceStatusColor(widget.booking?.bookingStatus)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.booking?.bookingStatus?.toLowerCase() == "canceled"
                        ? "Cancelled"
                        : capitalizeFirst(widget.booking?.bookingStatus ?? ""),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getServiceStatusColor(widget.booking?.bookingStatus),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            /// 💰 Payment Status
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Payment Status :",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),

                Spacer(), // GAP HERE

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(widget.booking?.isPaid)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.booking?.isPaid == 1 ? "Paid" : "Pending",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getPaymentStatusColor(widget.booking?.isPaid),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Divider(
              height: 0.75,
              color: Color(0xFFCECECE),
            ),
            SizedBox(height: 9),
            Row(
              children: [
                Text(
                  '₹ ${widget.booking?.totalBookingAmount}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0077B6),
                  ),
                ),
                Spacer(),
                InkWell(
                  // onTap: () async {
                  //   await Get.find<DashBoardController>()
                  //       .getBookingDetails(widget.booking?.id ?? "");
                  //   if (Get.find<DashBoardController>().bookingResponse !=
                  //       null) {
                  //     final booking = Get.find<DashBoardController>()
                  //         .bookingResponse
                  //         ?.content;

                  //     String rawDateTime = booking.serviceSchedule.toString();
                  //     DateTime dateTime = DateTime.parse(rawDateTime);

                  //     // Format the date
                  //     String formattedDate = DateFormat("d MMMM y")
                  //         .format(dateTime); // 16 April 2025

                  //     // Format the time
                  //     String formattedTime =
                  //         DateFormat("h:mm a").format(dateTime); // 5:00 PM

                  //     Get.bottomSheet(
                  //       Container(
                  //           height: Get.size.height * 0.7,
                  //           padding: EdgeInsets.all(16),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.vertical(
                  //                 top: Radius.circular(20)),
                  //           ),
                  //           child: SingleChildScrollView(
                  //             child: Column(
                  //               children: [
                  //                 Row(
                  //                   mainAxisAlignment: MainAxisAlignment.center,
                  //                   children: [
                  //                     Text("Booking Details",
                  //                         style: TextStyle(
                  //                           fontSize: 20,
                  //                           fontWeight: FontWeight.bold,
                  //                         )),
                  //                   ],
                  //                 ),
                  //                 SizedBox(
                  //                   height: 10,
                  //                 ),
                  //                 Row(
                  //                   mainAxisAlignment: MainAxisAlignment.start,
                  //                   children: [
                  //                     CustomNetworkImageWidget(
                  //                       image: widget.booking?.subCategory
                  //                               ?.thumbnailFullPath ??
                  //                           "",
                  //                       height: 91,
                  //                       width: 97,
                  //                     ),
                  //                     SizedBox(
                  //                       width: 10,
                  //                     ),
                  //                     Expanded(
                  //                       child: Column(
                  //                         mainAxisAlignment:
                  //                             MainAxisAlignment.start,
                  //                         crossAxisAlignment:
                  //                             CrossAxisAlignment.start,
                  //                         children: [
                  //                           Row(
                  //                             children: [
                  //                               Expanded(
                  //                                 child: Text(
                  //                                   booking
                  //                                       .detail[0].serviceName,
                  //                                   maxLines: 2,
                  //                                   overflow:
                  //                                       TextOverflow.ellipsis,
                  //                                   style: const TextStyle(
                  //                                       fontSize: 16,
                  //                                       fontWeight:
                  //                                           FontWeight.bold,
                  //                                       color: Colors.black),
                  //                                 ),
                  //                               ),
                  //                             ],
                  //                           ),
                  //                           SizedBox(
                  //                             height: 25,
                  //                           ),
                  //                           SizedBox(
                  //                             height: 50,
                  //                             child: Row(
                  //                               children: [
                  //                                 /// Left - Date
                  //                                 Expanded(
                  //                                   child: Column(
                  //                                     crossAxisAlignment:
                  //                                         CrossAxisAlignment
                  //                                             .start,
                  //                                     mainAxisAlignment:
                  //                                         MainAxisAlignment
                  //                                             .center,
                  //                                     children: [
                  //                                       Text(
                  //                                         'Scheduled on',
                  //                                         style: TextStyle(
                  //                                           color: Colors.black
                  //                                               .withAlpha(128),
                  //                                           fontSize: 14,
                  //                                           fontFamily:
                  //                                               'Albert Sans',
                  //                                           fontWeight:
                  //                                               FontWeight.w400,
                  //                                         ),
                  //                                       ),
                  //                                       Text(
                  //                                         formattedDate,
                  //                                         style: TextStyle(
                  //                                           color: const Color(
                  //                                               0xFF207FA7),
                  //                                           fontSize: 14,
                  //                                           fontFamily:
                  //                                               'Albert Sans',
                  //                                           fontWeight:
                  //                                               FontWeight.w500,
                  //                                         ),
                  //                                       ),
                  //                                     ],
                  //                                   ),
                  //                                 ),

                  //                                 /// Vertical Divider with spacing
                  //                                 SizedBox(
                  //                                   height: 40,
                  //                                   child: VerticalDivider(
                  //                                     color: Colors.grey,
                  //                                     thickness: 1,
                  //                                   ),
                  //                                 ),

                  //                                 /// Right - Time
                  //                                 Expanded(
                  //                                   child: Column(
                  //                                     crossAxisAlignment:
                  //                                         CrossAxisAlignment
                  //                                             .end,
                  //                                     mainAxisAlignment:
                  //                                         MainAxisAlignment
                  //                                             .center,
                  //                                     children: [
                  //                                       Text(
                  //                                         'Time Slot',
                  //                                         style: TextStyle(
                  //                                           color: Colors.black
                  //                                               .withAlpha(128),
                  //                                           fontSize: 14,
                  //                                           fontFamily:
                  //                                               'Albert Sans',
                  //                                           fontWeight:
                  //                                               FontWeight.w400,
                  //                                         ),
                  //                                       ),
                  //                                       Text(
                  //                                         formattedTime,
                  //                                         style: TextStyle(
                  //                                           color: const Color(
                  //                                               0xFF207FA7),
                  //                                           fontSize: 14,
                  //                                           fontFamily:
                  //                                               'Albert Sans',
                  //                                           fontWeight:
                  //                                               FontWeight.w500,
                  //                                         ),
                  //                                       ),
                  //                                     ],
                  //                                   ),
                  //                                 ),
                  //                               ],
                  //                             ),
                  //                           )
                  //                         ],
                  //                       ),
                  //                     ),
                  //                     SizedBox(
                  //                       height: 25,
                  //                     ),
                  //                   ],
                  //                 ),
                  //                 SizedBox(
                  //                   height: 10,
                  //                 ),
                  //                 Row(
                  //                   children: [
                  //                     Expanded(
                  //                       child: Stack(
                  //                         children: [
                  //                           Padding(
                  //                             padding: const EdgeInsets.only(
                  //                                 left: 20.0),
                  //                             child: Column(
                  //                               crossAxisAlignment:
                  //                                   CrossAxisAlignment.start,
                  //                               children: [
                  //                                 Text(
                  //                                   'Location for service',
                  //                                   style: TextStyle(
                  //                                     color: Colors.black,
                  //                                     fontSize: 16,
                  //                                     fontFamily: 'Albert Sans',
                  //                                     fontWeight:
                  //                                         FontWeight.bold,
                  //                                   ),
                  //                                 ),
                  //                                 Row(
                  //                                   children: [
                  //                                     Expanded(
                  //                                       child: Text(
                  //                                         booking.serviceAddress
                  //                                                 ?.address ??
                  //                                             "Address Not Available",
                  //                                       ),
                  //                                     ),
                  //                                   ],
                  //                                 )
                  //                               ],
                  //                             ),
                  //                           ),
                  //                           Positioned(
                  //                             left: 0,
                  //                             top: 5,
                  //                             child: Icon(
                  //                               Icons.location_pin,
                  //                               size: 15,
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //                 SizedBox(
                  //                   height: 20,
                  //                 ),
                  //                 Row(
                  //                   children: [
                  //                     Expanded(
                  //                       child: Stack(
                  //                         children: [
                  //                           Padding(
                  //                             padding: const EdgeInsets.only(
                  //                                 left: 25),
                  //                             child: Column(
                  //                               crossAxisAlignment:
                  //                                   CrossAxisAlignment.start,
                  //                               children: [
                  //                                 Text(
                  //                                   'Problem description',
                  //                                   style: TextStyle(
                  //                                     color: Colors.black,
                  //                                     fontSize: 16,
                  //                                     fontFamily: 'Albert Sans',
                  //                                     fontWeight:
                  //                                         FontWeight.bold,
                  //                                   ),
                  //                                 ),
                  //                                 Row(
                  //                                   children: [
                  //                                     Expanded(
                  //                                       child: Text(
                  //                                         booking.message ??
                  //                                             "No description provided",
                  //                                       ),
                  //                                     ),
                  //                                   ],
                  //                                 )
                  //                               ],
                  //                             ),
                  //                           ),
                  //                           Positioned(
                  //                             left: 0,
                  //                             top: 5,
                  //                             child: Image.asset(
                  //                               "assets/icons/ic_tool.png",
                  //                               height: 15,
                  //                               width: 15,
                  //                             ),
                  //                           )
                  //                         ],
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //                 SizedBox(
                  //                   height: 25,
                  //                 ),
                  //                 Row(
                  //                   children: [
                  //                     Expanded(
                  //                       child: Stack(
                  //                         children: [
                  //                           Padding(
                  //                             padding: const EdgeInsets.only(
                  //                                 left: 30),
                  //                             child: Column(
                  //                               crossAxisAlignment:
                  //                                   CrossAxisAlignment.start,
                  //                               children: [
                  //                                 Text(
                  //                                   'Payment Method',
                  //                                   style: TextStyle(
                  //                                     color: Colors.black,
                  //                                     fontSize: 16,
                  //                                     fontFamily: 'Albert Sans',
                  //                                     fontWeight:
                  //                                         FontWeight.bold,
                  //                                   ),
                  //                                 ),
                  //                                 Row(
                  //                                   children: [
                  //                                     Expanded(
                  //                                       child: Text(
                  //                                         booking.paymentMethod ==
                  //                                                 'razor_pay'
                  //                                             ? 'Online Payment'
                  //                                             : 'Pay after Service',
                  //                                       ),
                  //                                     ),
                  //                                   ],
                  //                                 )
                  //                               ],
                  //                             ),
                  //                           ),
                  //                           Positioned(
                  //                             top: 0,
                  //                             left: 0,
                  //                             child: Icon(Icons.wallet),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //                 SizedBox(
                  //                   height: 100,
                  //                 ),
                  //                 Row(
                  //                   mainAxisAlignment:
                  //                       MainAxisAlignment.spaceBetween,
                  //                   children: [
                  //                     Expanded(
                  //                       child: Text(
                  //                         'Total Cost:',
                  //                         style: TextStyle(
                  //                           color: Colors.black
                  //                               .withValues(alpha: 128),
                  //                           fontSize: 14,
                  //                           fontFamily: 'Albert Sans',
                  //                           fontWeight: FontWeight.w400,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                     Text(
                  //                       '₹ ${booking.detail[0].totalCost}',
                  //                       style: TextStyle(
                  //                         color: const Color(0xFF207FA7),
                  //                         fontSize: 20,
                  //                         fontFamily: 'Albert Sans',
                  //                         fontWeight: FontWeight.w700,
                  //                       ),
                  //                     )
                  //                   ],
                  //                 ),
                  //                 Divider(
                  //                   thickness: 2,
                  //                 ),
                  //                 CustomButtonWidget(
                  //                   buttonText: "Download Invoice",
                  //                   onPressed: () {
                  //                     String uri = "";

                  //                     uri =
                  //                         "${AppConstants.baseUrl}${AppConstants.regularBookingInvoiceUrl}${widget.booking?.id}";

                  //                     if (kDebugMode) {
                  //                       print("Uri : $uri");
                  //                     }
                  //                     _launchUrl(uri);
                  //                   },
                  //                 )
                  //               ],
                  //             ),
                  //           )),
                  //       isScrollControlled: true,
                  //       backgroundColor: Colors.transparent,
                  //     );
                  //   }
                  // },
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0077B6),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Future<void> _launchUrl(String urlString) async {
//   final Uri url = Uri.parse(urlString);
//   await launchUrl(url, mode: LaunchMode.externalApplication);
// }

Color _getServiceStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'completed':
      return Colors.green;
    case 'ongoing':
      return Colors.blue;
    case 'accepted':
      return Colors.blueAccent;
    case 'pending':
      return Colors.orange;
    case 'canceled':
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

Color _getPaymentStatusColor(int? isPaid) {
  return isPaid == 1 ? Colors.green : Colors.orange;
}
