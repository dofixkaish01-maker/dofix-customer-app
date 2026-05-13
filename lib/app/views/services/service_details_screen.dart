import 'dart:developer';
import 'package:do_fix/app/views/services/ratting%20screen/rating_summary.dart';
import 'package:do_fix/app/widgets/custom_appbar.dart';
import 'package:do_fix/app/widgets/custom_floating_cart_widget.dart';
import 'package:do_fix/app/widgets/service_container.dart';
import 'package:do_fix/controllers/auth_controller.dart';
import 'package:do_fix/model/service_model.dart';
import 'package:do_fix/model/retting%20&%20review%20model/service_reviews_model.dart' hide RatingSummary;
import 'package:do_fix/utils/html_utils.dart';
import 'package:do_fix/utils/sizeboxes.dart';
import 'package:do_fix/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../controllers/dashboard_controller.dart';
import '../../../controllers/booking_controller.dart';
import '../../../widgets/HtmlToFlutter.dart';
import '../cart_screen/SubScreen/final_screen.dart';
import '../home/component/variations_new_card.dart';
import 'ratting screen/review_card_widget.dart';

class ServiceDetails extends StatefulWidget {
  const ServiceDetails({super.key});

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  // with TickerProviderStateMixin { // Removed animation mixin for better performance

  // late AnimationController _controller; // Unused after removing top animation
  // late Animation<Offset> _slideAnimation; // Unused after removing top animation
  // bool _visible = false; // Unused after removing top animation
  // late List<AnimationController> _itemControllers; // Unused after removing top animation

  final BookingController bookingController = Get.find<BookingController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashController = Get.find<DashBoardController>();
      final serviceId = dashController.serviceModel.id;

      log("SERVICE ID FROM CONTROLLER: $serviceId");

      if (serviceId != null && serviceId.isNotEmpty) {
        bookingController.getServiceReview(serviceId: serviceId);
      } else {
        log("SERVICE ID FROM CONTROLLER IS NULL OR EMPTY");
      }
    });

    // _controller = AnimationController(
    //   duration: const Duration(milliseconds: 500),
    //   vsync: this,
    // );
    //
    // _slideAnimation = Tween<Offset>(
    //   begin: const Offset(1.0, 0.0),
    //   end: Offset.zero,
    // ).animate(
    //   CurvedAnimation(
    //     parent: _controller,
    //     curve: Curves.easeOutCubic,
    //   ),
    // );
    //
    // final int itemCount =
    //     Get.find<DashBoardController>().serviceModel.variations?.length ?? 0;
    //
    // _itemControllers = List.generate(
    //   itemCount,
    //       (index) => AnimationController(
    //     vsync: this,
    //     duration: const Duration(milliseconds: 400),
    //   ),
    // );
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   for (int i = 0; i < _itemControllers.length; i++) {
    //     Future.delayed(Duration(milliseconds: 100 + (i * 80)), () {
    //       if (mounted) {
    //         _itemControllers[i].forward();
    //       }
    //     });
    //   }
    //
    //   Future.delayed(const Duration(milliseconds: 100), () {
    //     if (mounted) {
    //       setState(() {
    //         _visible = true;
    //       });
    //       _controller.forward();
    //     }
    //   });
    // });
  }

  // @override
  // void initState() {
  //   super.initState();
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final args = Get.arguments;
  //     final serviceId = args?["service_id"];
  //
  //     log("SERVICE DETAILS ARGS: $args");
  //     log("SERVICE ID FROM ARGS: $serviceId");
  //
  //     if (serviceId != null) {
  //       bookingController.getServiceReview(serviceId: serviceId);
  //     } else {
  //       log("SERVICE ID IS NULL");
  //     }
  //   });
  //
  //   _controller = AnimationController(
  //     duration: const Duration(milliseconds: 500),
  //     vsync: this,
  //   );
  //
  //   _slideAnimation = Tween<Offset>(
  //     begin: const Offset(1.0, 0.0),
  //     end: Offset.zero,
  //   ).animate(
  //     CurvedAnimation(
  //       parent: _controller,
  //       curve: Curves.easeOutCubic,
  //     ),
  //   );
  //
  //   final int itemCount =
  //       Get.find<DashBoardController>().serviceModel.variations?.length ?? 0;
  //
  //   _itemControllers = List.generate(
  //     itemCount,
  //         (index) => AnimationController(
  //       vsync: this,
  //       duration: const Duration(milliseconds: 400),
  //     ),
  //   );
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     for (int i = 0; i < _itemControllers.length; i++) {
  //       Future.delayed(Duration(milliseconds: 100 + (i * 80)), () {
  //         if (mounted) {
  //           _itemControllers[i].forward();
  //         }
  //       });
  //     }
  //
  //     Future.delayed(const Duration(milliseconds: 100), () {
  //       if (mounted) {
  //         setState(() {
  //           _visible = true;
  //         });
  //         _controller.forward();
  //       }
  //     });
  //   });
  // }

  @override
  void dispose() {
    // for (final controller in _itemControllers) {
    //   controller.dispose();
    // }
    // _controller.dispose();
    super.dispose();
  }

  double parse(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 700;
    return GetBuilder<DashBoardController>(
      id: 'service_details',
      builder: (controller) {
        return Material(
          color: const Color(0xFFF7F8FA),
          child: WillPopScope(
            onWillPop: () async {
              // for (final itemController in _itemControllers) {
              //   itemController.reverse();
              // }
              //
              // await _controller.reverse();
              //
              // setState(() {
              //   _visible = false;
              // });
              //
              // await Future.delayed(const Duration(milliseconds: 300));
              return true;
            },
            child: SafeArea(
              top: false,
              child: Scaffold(
                backgroundColor: const Color(0xFFF7F8FA),
                extendBody: true,
                appBar: CustomAppBar(
                  title: controller.serviceModel.name ?? "",
                  isSearchButtonExist: false,
                  isBackButtonExist: true,
                ),
                body: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: isTablet ? 24 : 14,
                        right: isTablet ? 24 : 14,
                        top: 14,
                        bottom: 110,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 820 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Top Service Card
                              GetBuilder<DashBoardController>(
                                id: 'service_container',
                                builder: (dashController) {
                                  return ServiceContainer(
                                    showReviews: true,
                                    isButtonShow: true,
                                    serviceModel: controller.serviceModel,
                                  );
                                },
                              ),

                              const SizedBox(height: 18),

                              /// Available Services
                              _buildSectionHeader("Available Services"),
                              const SizedBox(height: 10),
                              GetBuilder<DashBoardController>(
                                id: 'service_container',
                                builder: (dashController) {
                                  return ListView.separated(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: controller
                                            .serviceModel.variations?.length ??
                                        0,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final variation = controller
                                          .serviceModel.variations?[index];

                                      return VariationsNewCard(
                                        serviceDescription:
                                            (variation?.varDescription !=
                                                        null &&
                                                    variation?.varDescription !=
                                                        "0")
                                                ? variation?.varDescription
                                                : HtmlUtils.stripHtmlIfPresent(
                                                    controller.serviceModel
                                                            .description ??
                                                        "",
                                                  ),
                                        serviceVariationName:
                                            variation?.variant ?? "",
                                        serviceRatings: (controller
                                                    .serviceModel.avgRating ??
                                                0.0)
                                            .toString(),
                                        serviceReviewCount: (controller
                                                    .serviceModel.ratingCount ??
                                                0)
                                            .toString(),
                                        serviceMrpPrice:
                                            variation?.mrpPrice.toString() ??
                                                "",
                                        labourCharge: controller
                                                .serviceModel.labourCharge
                                                ?.toDouble() ??
                                            0.0,
                                        serviceDiscountedPrice:
                                            variation?.price.toString() ?? "",
                                        serviceTimeDuration: (variation
                                                        ?.durationHour !=
                                                    "0" &&
                                                variation?.durationMinute !=
                                                    "0" &&
                                                variation?.durationHour !=
                                                    null &&
                                                variation?.durationMinute !=
                                                    null)
                                            ? "${variation?.durationHour}:${variation?.durationMinute}"
                                            : "",
                                        variantKey: variation?.variantKey ?? "",
                                        serviceModel: controller.serviceModel,
                                        serviceCoverImage:
                                            variation?.coverImage ?? "",
                                        taxAmount: 79,
                                      );
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              /// About Service
                              _buildSectionHeader("About the Service"),
                              const SizedBox(height: 10),
                              controller.serviceModel.description != null &&
                                      HtmlUtils.containsHtml(
                                        controller.serviceModel.description!,
                                      )
                                  ? HtmlToFlutter(
                                      htmlText:
                                          controller.serviceModel.description ??
                                              "",
                                    )
                                  : Text(
                                      HtmlUtils.stripHtmlIfPresent(
                                        controller.serviceModel.description ??
                                            "",
                                      ),
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.68),
                                        fontSize: isTablet ? 14.5 : 13.2,
                                        height: 1.6,
                                      ),
                                    ),

                              const SizedBox(height: 20),
//
                              /// Ratings & Reviews
                              _buildSectionHeader("Ratings & Reviews"),
                              const SizedBox(height: 10),
                              Obx(() {
                                final List<ServiceReview> reviews =
                                    bookingController.serviceReviewsModel.value
                                            ?.content?.reviews?.data ??
                                        [];

                                final bool hasReviews = reviews.isNotEmpty;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RatingSummary(
                                      averageRating:
                                          controller.serviceModel.avgRating ??
                                              0.0,
                                      ratingCount:
                                          controller.serviceModel.ratingCount ??
                                              0,
                                    ),

                                    const SizedBox(height: 16),
                                    if ((controller.serviceModel.ratingCount ??
                                            0) >
                                        0)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 2),
                                        child: Text(
                                          'Reviews',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                      ),

                                    if (hasReviews) const SizedBox(height: 12),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFFFFF).withOpacity(0.7),
                                            Color(0xFFF1F5F9).withOpacity(0.6),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 20,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF6366F1),
                                                      Color(0xFF8B5CF6),
                                                    ],
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.auto_awesome,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 12),

                                              Expanded(
                                                child: Text(
                                                  "Something Awesome is Coming ✨",
                                                  style: TextStyle(
                                                    fontSize: 15.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 14),

                                          Text(
                                            "We're crafting a smarter and more helpful review experience just for you. "
                                                "Very soon, you'll be able to explore genuine feedback, ratings, and insights "
                                                "from real users to make better decisions.",
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              color: Color(0xFF475569),
                                              height: 1.5,
                                            ),
                                          ),

                                          const SizedBox(height: 16),

                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF6366F1).withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.rocket_launch, size: 16, color: Color(0xFF6366F1)),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "Launching very soon",
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF6366F1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),                                    // if (hasReviews)
                                    //   Builder(
                                    //     builder: (context) {
                                    //       /// STEP 1: SORT (5 top)
                                    //       final sortedReviews = [...reviews];
                                    //       sortedReviews.sort((a, b) =>
                                    //           (b.reviewRating ?? 0).compareTo(a.reviewRating ?? 0));
                                    //
                                    //       /// STEP 2: FILTER (optional - negative hata sakti ho)
                                    //       final filteredReviews = sortedReviews
                                    //           .where((r) => (r.reviewRating ?? 0) >= 3)
                                    //           .toList();
                                    //
                                    //       /// STEP 3: LIMIT (max 10)
                                    //       final int displayCount =
                                    //       filteredReviews.length > 10 ? 10 : filteredReviews.length;
                                    //
                                    //       /// STEP 4: SEE MORE CHECK
                                    //       final bool hasMore = filteredReviews.length > 10;
                                    //
                                    //       return Column(
                                    //         children: [
                                    //           ListView.separated(
                                    //             physics:
                                    //                 const NeverScrollableScrollPhysics(),
                                    //             shrinkWrap: true,
                                    //             itemCount: displayCount,
                                    //             //  updated
                                    //             separatorBuilder: (_, __) =>
                                    //                 Divider(
                                    //               thickness: 0.8,
                                    //               color: Colors.grey.shade300,
                                    //             ),
                                    //             itemBuilder: (context, index) {
                                    //               final ServiceReview review =
                                    //                   filteredReviews[
                                    //                       index]; //  updated
                                    //               return ReviewCard(
                                    //                   review: review);
                                    //             },
                                    //           ),
                                    //
                                    //           //  See More
                                    //           if (hasMore)
                                    //             TextButton(
                                    //               onPressed: () {
                                    //                 // TODO: Navigate or expand list
                                    //               },
                                    //               child: const Text("See More"),
                                    //             ),
                                    //         ],
                                    //       );
                                    //     },
                                    //   )
                                    // else
                                    //   const Center(
                                    //     child: Padding(
                                    //       padding: EdgeInsets.only(top: 40),
                                    //       child: Text(
                                    //         "No reviews yet",
                                    //         style: TextStyle(
                                    //           fontSize: 15,
                                    //           color: Colors.grey,
                                    //           fontWeight: FontWeight.w500,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    //
                                    // if ((controller.serviceModel.ratingCount ??
                                    //     0) >
                                    //     0)
                                    //   const Padding(
                                    //     padding: EdgeInsets.only(left: 2),
                                    //     child: Text(
                                    //       'Reviews',
                                    //       style: TextStyle(
                                    //         fontSize: 16,
                                    //         fontWeight: FontWeight.w700,
                                    //         color: Color(0xFF111827),
                                    //       ),
                                    //     ),
                                    //   ),
                                    //
                                    // if (hasReviews) const SizedBox(height: 12),
                                    //
                                    // if (hasReviews)
                                    //
                                    //   ListView.separated(
                                    //     physics:
                                    //     const NeverScrollableScrollPhysics(),
                                    //     shrinkWrap: true,
                                    //     itemCount: reviews.length,
                                    //     separatorBuilder: (_, __) =>
                                    //      Divider(thickness: 0.8,color: Colors.grey.shade300,),
                                    //     itemBuilder: (context, index) {
                                    //       final ServiceReview review =
                                    //       reviews[index];
                                    //       return ReviewCard(review: review);
                                    //     },
                                    //   )
                                    //
                                    // else
                                    //   Container(
                                    //     width: double.infinity,
                                    //     padding: const EdgeInsets.symmetric(
                                    //       vertical: 28,
                                    //       horizontal: 16,
                                    //     ),
                                    //     decoration: BoxDecoration(
                                    //       color: Colors.white,
                                    //       borderRadius:
                                    //       BorderRadius.circular(16),
                                    //       border: Border.all(
                                    //         color: Colors.grey.shade200,
                                    //       ),
                                    //     ),
                                    //     child: const Center(
                                    //       child: Text(
                                    //         "No reviews yet",
                                    //         style: TextStyle(
                                    //           fontSize: 15,
                                    //           color: Colors.grey,
                                    //           fontWeight: FontWeight.w500,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),

                                    sizedBox65(),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// Floating Cart
                    Positioned(
                      bottom: 16,
                      left: 12,
                      right: 12,
                      child: GetBuilder<DashBoardController>(
                        id: 'cart_total',
                        builder: (controller) {
                          double totalAmount = 0;
                          int itemCount = 0;

                          if (controller.cartModel.content?.cart?.data !=
                              null) {
                            itemCount = controller
                                .cartModel.content!.cart!.data!.length;

                            for (final item
                                in controller.cartModel.content!.cart!.data!) {
                              totalAmount += (item.totalCost ?? 0);
                            }
                          }

                          return Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isTablet ? 820 : double.infinity,
                              ),
                              child: CustomFloatingCartWidget(
                                totalAmount: totalAmount,
                                itemCount: itemCount,
                              ),
                            ),
                          );

                          // return AnimatedSwitcher(
                          //   duration: const Duration(milliseconds: 300),
                          //   transitionBuilder:
                          //       (Widget child, Animation<double> animation) {
                          //     return SlideTransition(
                          //       position: Tween<Offset>(
                          //         begin: const Offset(0, 1),
                          //         end: Offset.zero,
                          //       ).animate(animation),
                          //       child: FadeTransition(
                          //         opacity: animation,
                          //         child: child,
                          //       ),
                          //     );
                          //   },
                          //   child: CustomFloatingCartWidget(
                          //     totalAmount: totalAmount,
                          //     itemCount: itemCount,
                          //   ),
                          // );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

void showBookingSheet(BuildContext context) {
  LatLng selectedLatLng = const LatLng(28.7041, 77.1025);

  Future<void> getCurrentLocation() async {
    selectedLatLng = const LatLng(28.7041, 77.1025);
    Get.find<DashBoardController>().updateLatLong(
      selectedLatLng.latitude.toString(),
      selectedLatLng.longitude.toString(),
    );
  }

  showModalBottomSheet(
    context: context,
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          getCurrentLocation();

          return const FractionallySizedBox(
            heightFactor: 0.95,
            child: BookingSheet(),
          );
        },
      );
    },
  );
}

void showReviewFilterBottomSheet(
  BuildContext context, {
  int? selectedRating,
  bool recentlyAdded = false,
  required Function(int? rating, bool recentlyAdded) onApply,
}) {
  int? selectedRating0 = selectedRating;
  bool recentlyAdded0 = recentlyAdded;

  Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Filter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'View By',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Checkbox(
                  value: recentlyAdded0,
                  onChanged: (val) =>
                      setState(() => recentlyAdded0 = val ?? false),
                ),
                const Text('Recently Added'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Ratings',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final int rating = index + 1;
                final bool isSelected = selectedRating0 == rating;

                return GestureDetector(
                  onTap: () => setState(() => selectedRating0 = rating),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.white,
                    ),
                    child: Text(
                      rating.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue : Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  onApply(selectedRating0, recentlyAdded0);
                },
                child: const Text('Apply Filter'),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

void showAddToCartSheet(BuildContext context, ServiceModel serviceModel) {
  showModalBottomSheet(
    context: context,
    isDismissible: true,
    enableDrag: false,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (
          BuildContext context,
          void Function(void Function()) setState,
        ) {
          String? selectedVariation =
              Get.find<DashBoardController>().selectedVariations.isNotEmpty
                  ? Get.find<DashBoardController>().selectedVariations.first
                  : null;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "Available variations",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final String variant =
                            serviceModel.variations?[index].variant ?? "";
                        final String variantKey =
                            serviceModel.variations?[index].variantKey ?? "";
                        final String price =
                            serviceModel.variations?[index].price.toString() ??
                                "";
                        return Row(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Radio<String>(
                                    value: variantKey,
                                    groupValue: selectedVariation,
                                    onChanged: (String? value) {
                                      setState(() {
                                        log("Selected variation: $value");
                                        selectedVariation = value;
                                        Get.find<DashBoardController>()
                                            .selectedVariations
                                            .clear();

                                        if (value != null) {
                                          Get.find<DashBoardController>()
                                              .addVariation(value);
                                        }
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      variant,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      softWrap: true,
                                      maxLines: null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "₹ $price",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: serviceModel.variations?.length ?? 0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final authController = Get.find<AuthController>();
                            final bool isGuest =
                                await authController.returnIsGuest();

                            if (isGuest) {
                              authController.checkIfGuest();
                            } else {
                              final data = Get.find<DashBoardController>()
                                      .cartModel
                                      .content
                                      ?.cart
                                      ?.data ??
                                  [];

                              if (data.isNotEmpty) {
                                final selectedVariation =
                                    Get.find<DashBoardController>()
                                            .selectedVariations
                                            .isNotEmpty
                                        ? Get.find<DashBoardController>()
                                            .selectedVariations
                                            .first
                                        : null;

                                final existingService = data.firstWhere(
                                  (item) =>
                                      item.serviceId == serviceModel.id &&
                                      item.categoryId ==
                                          serviceModel.categoryId &&
                                      item.subCategoryId ==
                                          serviceModel.subCategoryId &&
                                      item.variantKey == selectedVariation,
                                  orElse: () => CartItem(
                                    serviceId: "null",
                                    categoryId: "null",
                                    subCategoryId: "null",
                                    variantKey: "null",
                                  ),
                                );

                                if (existingService.serviceId != "null" &&
                                    existingService.categoryId != "null" &&
                                    existingService.subCategoryId != "null" &&
                                    existingService.variantKey != "null") {
                                  showCustomSnackBar(
                                    "This service with the selected variation is already in your cart",
                                    isError: true,
                                  );
                                  return;
                                }
                              }

                              if (Get.find<DashBoardController>()
                                  .selectedVariations
                                  .isNotEmpty) {
                                Get.back();
                                Get.find<DashBoardController>().addToCart(
                                  {
                                    "service_id": serviceModel.id,
                                    "category_id": serviceModel.categoryId,
                                    "sub_category_id":
                                        serviceModel.subCategoryId,
                                  },
                                  Get.find<DashBoardController>()
                                      .selectedVariations,
                                );
                              } else {
                                showCustomSnackBar(
                                  "Please select at least one variation",
                                  isPending: true,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Add To Cart",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

String formatTimeOfDay24Hour(TimeOfDay time) {
  final now = DateTime.now();
  final dateTime =
      DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat('HH:mm').format(dateTime);
}

// import 'dart:developer';
// import 'package:do_fix/app/views/services/rating_summary.dart';
// import 'package:do_fix/app/widgets/custom_appbar.dart';
// import 'package:do_fix/app/widgets/custom_floating_cart_widget.dart';
// import 'package:do_fix/app/widgets/service_container.dart';
// import 'package:do_fix/controllers/auth_controller.dart';
// import 'package:do_fix/model/service_model.dart';
// import 'package:do_fix/model/service_reviews_model.dart';
// import 'package:do_fix/utils/html_utils.dart';
// import 'package:do_fix/utils/sizeboxes.dart';
// import 'package:do_fix/widgets/custom_snack_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl/intl.dart';
// import '../../../../controllers/dashboard_controller.dart';
// import '../../../controllers/booking_controller.dart';
// import '../../../widgets/HtmlToFlutter.dart';
// import '../cart_screen/SubScreen/final_screen.dart';
// import '../home/component/variations_new_card.dart';
// import 'widgets/review_card_widget.dart';
//
// class ServiceDetails extends StatefulWidget {
//   const ServiceDetails({super.key});
//
//   @override
//   State<ServiceDetails> createState() => _ServiceDetailsState();
// }
//
// class _ServiceDetailsState extends State<ServiceDetails>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _slideAnimation;
//   bool _visible = false;
//   late List<AnimationController> _itemControllers;
//   final bookingController = Get.find<BookingController>();
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final args = Get.arguments;
//       final serviceId = args?["service_id"];
//
//       if (serviceId != null) {
//         Get.find<BookingController>().getServiceReview(serviceId: serviceId);
//       }
//     });
//
//     _controller = AnimationController(
//       duration: Duration(milliseconds: 500),
//       vsync: this,
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: Offset(1.0, 0.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutCubic,
//     ));
//
//     int itemCount =
//         Get.find<DashBoardController>().serviceModel.variations?.length ?? 0;
//
//     _itemControllers = List.generate(itemCount, (index) {
//       return AnimationController(
//         vsync: this,
//         duration: Duration(milliseconds: 400), // slightly faster
//       );
//     });
//
//     // Animate all items quickly in sync with slight stagger
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       for (int i = 0; i < _itemControllers.length; i++) {
//         Future.delayed(Duration(milliseconds: 100 + (i * 80)), () {
//           if (mounted) _itemControllers[i].forward();
//         });
//       }
//
//       Future.delayed(Duration(milliseconds: 100), () {
//         if (mounted) {
//           setState(() {
//             _visible = true;
//           });
//           _controller.forward();
//         }
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     for (final controller in _itemControllers) {
//       controller.dispose();
//     }
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<DashBoardController>(
//         id: 'service_details',
//         builder: (controller) {
//           return Material(
//             child: WillPopScope(
//               onWillPop: () async {
//                 // Reverse all item animations
//                 for (final itemController in _itemControllers) {
//                   itemController.reverse();
//                 }
//
//                 // Reverse the main slide animation
//                 await _controller.reverse();
//                 setState(() {
//                   _visible = false;
//                 });
//                 // Delay a bit for smoother transition before popping
//                 await Future.delayed(Duration(milliseconds: 300));
//
//                 return true; // now allow the pop
//               },
//               child: SafeArea(
//                 top: false,
//                 child: Scaffold(
//                   extendBody: true,
//                   appBar: CustomAppBar(
//                     title: controller.serviceModel.name ?? "",
//                     isSearchButtonExist: false,
//                     isBackButtonExist: true,
//                   ),
//                   body: Stack(
//                     children: [
//                       SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             const SizedBox(height: 25),
//                             // image
//                             AnimatedBuilder(
//                               animation: _slideAnimation,
//                               builder: (context, child) {
//                                 return AnimatedSlide(
//                                   offset: _slideAnimation.value,
//                                   duration: const Duration(milliseconds: 400),
//                                   child: AnimatedOpacity(
//                                     duration: const Duration(milliseconds: 200),
//                                     opacity: _visible ? 1.0 : 0.0,
//                                     child: Container(
//                                       width: double.infinity,
//                                       color: Colors.white,
//                                       child: GetBuilder<DashBoardController>(
//                                         id: 'service_container',
//                                         builder: (dashController) {
//                                           return ServiceContainer(
//                                             showReviews: true,
//                                             isButtonShow: true,
//                                             serviceModel:
//                                                 controller.serviceModel,
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//
//                             // AnimatedBuilder(
//                             //   animation: _slideAnimation,
//                             //   builder: (context, child) {
//                             //     return AnimatedSlide(
//                             //       offset: _slideAnimation.value,
//                             //       duration: const Duration(milliseconds: 600),
//                             //       child: AnimatedOpacity(
//                             //         duration: const Duration(milliseconds: 400),
//                             //         opacity: _visible ? 1.0 : 0.0,
//                             //         child: Container(
//                             //           width: Get.size.width,
//                             //           decoration: BoxDecoration(
//                             //             color: Colors.white,
//                             //           ),
//                             //           child: GetBuilder<DashBoardController>(
//                             //             id: 'service_container',
//                             //             builder: (dashController) {
//                             //               return ServiceContainer(
//                             //                 showReviews: true,
//                             //                 isButtonShow: true,
//                             //                 serviceModel:
//                             //                     controller.serviceModel,
//                             //               );
//                             //             },
//                             //           ),
//                             //         ),
//                             //       ),
//                             //     );
//                             //   },
//                             // ),
//
//                             const SizedBox(height: 15),
//                             AnimatedOpacity(
//                               duration: Duration(milliseconds: 300),
//                               opacity: _visible ? 1.0 : 0.0,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 16.0),
//                                 child: Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Text(
//                                     'Available Services',
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w800,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//
//                             /// Available Services
//                             //******* working ********
//                             AnimatedOpacity(
//                               duration: Duration(milliseconds: 300),
//                               opacity: _visible ? 1.0 : 0.0,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 16.0),
//                                 child: GetBuilder<DashBoardController>(
//                                   id: 'service_container',
//                                   builder: (dashController) {
//                                     return ListView.builder(
//                                       physics: NeverScrollableScrollPhysics(),
//                                       shrinkWrap: true,
//                                       itemCount: controller.serviceModel
//                                               .variations?.length ??
//                                           0,
//                                       itemBuilder: (context, index) {
//                                         final variation = controller
//                                             .serviceModel.variations?[index];
//
//                                         return VariationsNewCard(
//                                           serviceDescription: (variation
//                                                           ?.varDescription !=
//                                                       null &&
//                                                   variation?.varDescription !=
//                                                       "0")
//                                               ? variation?.varDescription
//                                               : HtmlUtils.stripHtmlIfPresent(
//                                                   controller.serviceModel
//                                                           .description ??
//                                                       ""),
//                                           serviceVariationName:
//                                               variation?.variant ?? "",
//                                           serviceRatings: (controller
//                                                       .serviceModel.avgRating ??
//                                                   0.0)
//                                               .toString(),
//                                           serviceReviewCount: (controller
//                                                       .serviceModel
//                                                       .ratingCount ??
//                                                   0)
//                                               .toString(),
//                                           serviceMrpPrice:
//                                               variation?.mrpPrice.toString() ??
//                                                   "",
//                                           serviceDiscountedPrice:
//                                               variation?.price.toString() ?? "",
//                                           serviceTimeDuration: (variation
//                                                           ?.durationHour !=
//                                                       "0" &&
//                                                   variation?.durationMinute !=
//                                                       "0" &&
//                                                   variation?.durationHour !=
//                                                       null &&
//                                                   variation?.durationMinute !=
//                                                       null)
//                                               ? "${variation?.durationHour}:${variation?.durationMinute}"
//                                               : "",
//                                           variantKey:
//                                               variation?.variantKey ?? "",
//                                           serviceModel: controller.serviceModel,
//                                           serviceCoverImage:
//                                               variation?.coverImage ?? "",
//                                           taxAmount: 79,
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 5),
//                             AnimatedOpacity(
//                               duration: Duration(milliseconds: 300),
//                               opacity: _visible ? 1.0 : 0.0,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 16.0),
//                                 child: Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Text(
//                                     'About the Service:-',
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w800,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             AnimatedOpacity(
//                               duration: Duration(milliseconds: 300),
//                               opacity: _visible ? 1.0 : 0.0,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: controller.serviceModel.description !=
//                                             null &&
//                                         HtmlUtils.containsHtml(controller
//                                             .serviceModel.description!)
//                                     ? HtmlToFlutter(
//                                         htmlText: controller
//                                                 .serviceModel.description ??
//                                             "",
//                                       )
//                                     : Text(
//                                         HtmlUtils.stripHtmlIfPresent(controller
//                                                 .serviceModel.description ??
//                                             ""),
//                                         style: TextStyle(
//                                           color: Colors.black.withOpacity(0.6),
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                             // Obx(() {
//                             //   return Padding(
//                             //     padding: const EdgeInsets.all(16.0),
//                             //     child: Column(
//                             //       crossAxisAlignment: CrossAxisAlignment.start,
//                             //       children: [
//                             //         Text(
//                             //           'Rating',
//                             //           style: TextStyle(
//                             //               fontSize: 16,
//                             //               fontWeight: FontWeight.w500),
//                             //         ),
//                             //         RatingSummary(
//                             //           avergeRating: bookingController.ratingAvg.toDouble(),
//                             //           starCounts: bookingController.starCounts,
//                             //         ),
//                             //         // RatingSummary(
//                             //         //   avergeRating: double.parse(bookingController.ratingAvg.toStringAsFixed(1)),
//                             //         //   starCounts: bookingController.starCounts,
//                             //         // ),
//                             //         const SizedBox(height: 20),
//                             //         if (bookingController
//                             //                 .serviceReviewsModel.value !=
//                             //             null)
//                             //           Row(
//                             //             mainAxisAlignment:
//                             //                 MainAxisAlignment.spaceBetween,
//                             //             children: [
//                             //               const Text(
//                             //                 'Reviews',
//                             //                 style: TextStyle(
//                             //                   fontSize: 16,
//                             //                   fontWeight: FontWeight.w500,
//                             //                 ),
//                             //               ),
//                             //               // InkWell(
//                             //               //   onTap: () {
//                             //               //     showReviewFilterBottomSheet(
//                             //               //       context,
//                             //               //       selectedRating:
//                             //               //           bookingController.selectedRating,
//                             //               //       recentlyAdded:
//                             //               //           bookingController.recentlyAdded,
//                             //               //       onApply: (rating, recentlyAdded) {
//                             //               //         bookingController.applyReviewFilter(
//                             //               //           rating: rating ?? 0,
//                             //               //           recentlyAdded: recentlyAdded,
//                             //               //         );
//                             //               //       },
//                             //               //     );
//                             //               //   },
//                             //               //   child: const Row(
//                             //               //     children: [
//                             //               //       Icon(
//                             //               //         Icons.filter_list,
//                             //               //         color: primaryBlue,
//                             //               //       ),
//                             //               //       Text(
//                             //               //         'Filter',
//                             //               //         style: TextStyle(
//                             //               //           fontSize: 14,
//                             //               //           fontWeight: FontWeight.w400,
//                             //               //           color: primaryBlue,
//                             //               //         ),
//                             //               //       )
//                             //               //     ],
//                             //               //   ),
//                             //               // ),
//                             //             ],
//                             //           ),
//                             //         if (bookingController
//                             //                 .serviceReviewsModel.value !=
//                             //             null)
//                             //           const SizedBox(height: 10),
//                             //         if (bookingController
//                             //                 .serviceReviewsModel.value !=
//                             //             null)
//                             //           (bookingController.serviceReviewsModel
//                             //                           .value !=
//                             //                       null &&
//                             //                   bookingController
//                             //                           .serviceReviewsModel
//                             //                           .value
//                             //                           ?.reviews
//                             //                           ?.length !=
//                             //                       0)
//                             //               ? SizedBox(
//                             //                   height: 300,
//                             //                   child: ListView.builder(
//                             //                     physics:
//                             //                         BouncingScrollPhysics(),
//                             //                     itemCount: bookingController
//                             //                             .serviceReviewsModel
//                             //                             .value
//                             //                             ?.reviews
//                             //                             ?.length ??
//                             //                         0,
//                             //                     itemBuilder: (context, index) {
//                             //                       final ServiceReview review =
//                             //                           bookingController
//                             //                                   .serviceReviewsModel
//                             //                                   .value
//                             //                                   ?.reviews?[index] ??
//                             //                               ServiceReview();
//                             //                       return ReviewCard(
//                             //                         review: review,
//                             //                       );
//                             //                     },
//                             //                   ),
//                             //                 )
//                             //               : SizedBox(
//                             //                   height: 100,
//                             //                   child: Center(
//                             //                     child: Text(
//                             //                       "No reviews yet",
//                             //                       style: TextStyle(
//                             //                         fontSize: 16,
//                             //                         color: Colors.grey,
//                             //                       ),
//                             //                     ),
//                             //                   ),
//                             //                 ),
//                             //         sizedBox65()
//                             //       ],
//                             //     ),
//                             //   );
//                             // }),
//                             Obx(() {
//                               return Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     /// Title Row
//                                         Text(
//                                           "Ratings & Reviews",
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                     const SizedBox(height: 10),
//
//                                     RatingSummary(
//                                       averageRating:
//                                           controller.serviceModel.avgRating ??
//                                               0.0, //4.8
//                                       ratingCount:
//                                           controller.serviceModel.ratingCount ??
//                                               0, //24
//                                     ),
//
//                                     const SizedBox(height: 20),
//
//                                     /// Reviews Title
//                                     if ((controller.serviceModel.ratingCount ??
//                                             0) >
//                                         0)
//                                       const Text(
//                                         'Reviews',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//
//                                     if ((bookingController.serviceReviewsModel
//                                             .value?.reviews?.isNotEmpty ??
//                                         false))
//                                       const SizedBox(height: 10),
//
//                                     /// Reviews List
//                                     if ((bookingController.serviceReviewsModel
//                                             .value?.reviews?.isNotEmpty ??
//                                         false))
//                                       SizedBox(
//                                         height: 300,
//                                         child: ListView.builder(
//                                           physics:
//                                               const BouncingScrollPhysics(),
//                                           itemCount: bookingController
//                                                   .serviceReviewsModel
//                                                   .value
//                                                   ?.reviews
//                                                   ?.length ??
//                                               0,
//                                           itemBuilder: (context, index) {
//                                             final ServiceReview review =
//                                                 bookingController
//                                                         .serviceReviewsModel
//                                                         .value
//                                                         ?.reviews?[index] ??
//                                                     ServiceReview();
//
//                                             return ReviewCard(
//                                               review: review,
//                                             );
//                                           },
//                                         ),
//                                       )
//                                     else
//                                       const SizedBox(
//                                         height: 100,
//                                         child: Center(
//                                           child: Text(
//                                             "No reviews yet",
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.grey,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//
//                                     sizedBox65(),
//                                   ],
//                                 ),
//                               );
//                             })
//                           ],
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 16,
//                         left: 0,
//                         right: 0,
//                         child: GetBuilder<DashBoardController>(
//                           id: 'cart_total',
//                           builder: (controller) {
//                             // Calculate total amount and item count
//                             double totalAmount = 0;
//                             int itemCount = 0;
//                             if (controller.cartModel.content?.cart?.data !=
//                                 null) {
//                               itemCount = controller
//                                   .cartModel.content!.cart!.data!.length;
//                               for (var item in controller
//                                   .cartModel.content!.cart!.data!) {
//                                 totalAmount += (item.totalCost ?? 0);
//                               }
//                             }
//                             return AnimatedSwitcher(
//                               duration: const Duration(milliseconds: 300),
//                               transitionBuilder:
//                                   (Widget child, Animation<double> animation) {
//                                 return SlideTransition(
//                                   position: Tween<Offset>(
//                                     begin: const Offset(0, 1),
//                                     end: Offset.zero,
//                                   ).animate(animation),
//                                   child: FadeTransition(
//                                     opacity: animation,
//                                     child: child,
//                                   ),
//                                 );
//                               },
//                               child: CustomFloatingCartWidget(
//                                 totalAmount: totalAmount,
//                                 itemCount: itemCount,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         });
//   }
// }
//
// void showBookingSheet(
//   BuildContext context,
// ) {
//   // GoogleMapController? _mapController;
//   LatLng selectedLatLng = LatLng(28.7041, 77.1025); // Default to Delhi
//   // DateTime selectedDate = DateTime.now();
//   // TimeOfDay? selectedTime;
//
//   Future<void> getCurrentLocation() async {
//     // Mock function: You can implement actual location fetching using Geolocator
//     selectedLatLng = LatLng(28.7041, 77.1025); // Mocking location to Delhi
//     Get.find<DashBoardController>().updateLatLong(
//       selectedLatLng.latitude.toString(),
//       selectedLatLng.longitude.toString(),
//     );
//   }
//
//   showModalBottomSheet(
//     context: context,
//     isDismissible: true,
//     enableDrag: true,
//     isScrollControlled: true,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           getCurrentLocation();
//
//           return FractionallySizedBox(
//             heightFactor: 0.95, // 95% of available height
//             child: BookingSheet(),
//           );
//         },
//       );
//     },
//   );
// }
//
// void showReviewFilterBottomSheet(
//   BuildContext context, {
//   int? selectedRating,
//   bool recentlyAdded = false,
//   required Function(int? rating, bool recentlyAdded) onApply,
// }) {
//   int? selectedRating0 = selectedRating;
//   bool recentlyAdded0 = recentlyAdded;
//
//   Get.bottomSheet(
//     StatefulBuilder(
//       builder: (context, setState) => Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Text(
//                 'Filter',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text('View By', style: TextStyle(fontWeight: FontWeight.w600)),
//             Row(
//               children: [
//                 Checkbox(
//                   value: recentlyAdded0,
//                   onChanged: (val) =>
//                       setState(() => recentlyAdded0 = val ?? false),
//                 ),
//                 const Text('Recently Added'),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text('Ratings', style: TextStyle(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(5, (index) {
//                 int rating = index + 1;
//                 bool isSelected = selectedRating0 == rating;
//                 return GestureDetector(
//                   onTap: () => setState(() => selectedRating0 = rating),
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: isSelected ? Colors.blue : Colors.grey,
//                         width: 2,
//                       ),
//                       borderRadius: BorderRadius.circular(8),
//                       color: isSelected
//                           ? Colors.blue.withOpacity(0.1)
//                           : Colors.white,
//                     ),
//                     child: Text(
//                       rating.toString(),
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: isSelected ? Colors.blue : Colors.black,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Get.back();
//                   onApply(selectedRating0, recentlyAdded0);
//                 },
//                 child: const Text('Apply Filter'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//     isScrollControlled: true,
//   );
// }
//
// void ShowAddToCartSheet(BuildContext context, ServiceModel serviceModel) {
//   showModalBottomSheet(
//     context: context,
//     isDismissible: true,
//     enableDrag: false,
//     isScrollControlled: true,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (context) {
//       return StatefulBuilder(
//         builder:
//             (BuildContext context, void Function(void Function()) setState) {
//           String? selectedVariation =
//               Get.find<DashBoardController>().selectedVariations.isNotEmpty
//                   ? Get.find<DashBoardController>().selectedVariations.first
//                   : null;
//
//           return SafeArea(
//             child: Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//                 left: 16,
//                 right: 16,
//                 top: 16,
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             Get.back();
//                           },
//                           child: Icon(Icons.arrow_back,
//                               size: 30, color: Theme.of(context).primaryColor),
//                         ),
//                         Spacer(),
//                         Text(
//                           "Available variations",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Spacer(),
//                       ],
//                     ),
//                     ListView.separated(
//                       physics: NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemBuilder: (context, index) {
//                         String variant =
//                             serviceModel.variations?[index].variant ?? "";
//                         String variantKey =
//                             serviceModel.variations?[index].variantKey ?? "";
//                         String price =
//                             serviceModel.variations?[index].price.toString() ??
//                                 "";
//
//                         return Row(
//                           children: [
//                             Expanded(
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   Radio<String>(
//                                     value: variantKey,
//                                     groupValue: selectedVariation,
//                                     onChanged: (String? value) {
//                                       setState(() {
//                                         log("Selected variation: $value");
//                                         selectedVariation = value;
//                                         Get.find<DashBoardController>()
//                                             .selectedVariations
//                                             .clear();
//                                         if (value != null) {
//                                           Get.find<DashBoardController>()
//                                               .addVariation(value);
//                                         }
//                                       });
//                                     },
//                                   ),
//                                   Expanded(
//                                     child: Text(
//                                       variant,
//                                       style: TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                       softWrap: true,
//                                       maxLines: null,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Text(
//                               "₹ $price",
//                               style: TextStyle(
//                                 color: Colors.blue,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                       separatorBuilder: (_, __) => const SizedBox(height: 10),
//                       itemCount: serviceModel.variations?.length ?? 0,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 10),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final authController = Get.find<AuthController>();
//                             bool isGuest = await authController.returnIsGuest();
//                             if (isGuest) {
//                               authController.checkIfGuest();
//                             } else {
//                               final data = Get.find<DashBoardController>()
//                                       .cartModel
//                                       .content
//                                       ?.cart
//                                       ?.data ??
//                                   [];
//                               if (data.isNotEmpty) {
//                                 final selectedVariation =
//                                     Get.find<DashBoardController>()
//                                             .selectedVariations
//                                             .isNotEmpty
//                                         ? Get.find<DashBoardController>()
//                                             .selectedVariations
//                                             .first
//                                         : null;
//
//                                 final existingService = data.firstWhere(
//                                   (item) =>
//                                       item.serviceId == serviceModel.id &&
//                                       item.categoryId ==
//                                           serviceModel.categoryId &&
//                                       item.subCategoryId ==
//                                           serviceModel.subCategoryId &&
//                                       item.variantKey == selectedVariation,
//                                   // <-- compare variation too
//                                   orElse: () => CartItem(
//                                     serviceId: "null",
//                                     categoryId: "null",
//                                     subCategoryId: "null",
//                                     variantKey:
//                                         "null", // add this if your CartItem has it
//                                   ),
//                                 );
//
//                                 if (existingService.serviceId != "null" &&
//                                     existingService.categoryId != "null" &&
//                                     existingService.subCategoryId != "null" &&
//                                     existingService.variantKey != "null") {
//                                   showCustomSnackBar(
//                                     "This service with the selected variation is already in your cart",
//                                     isError: true,
//                                   );
//                                   return;
//                                 }
//                               }
//                               if (Get.find<DashBoardController>()
//                                   .selectedVariations
//                                   .isNotEmpty) {
//                                 Get.back();
//                                 Get.find<DashBoardController>().addToCart(
//                                   {
//                                     "service_id": serviceModel.id,
//                                     "category_id": serviceModel.categoryId,
//                                     "sub_category_id":
//                                         serviceModel.subCategoryId,
//                                   },
//                                   Get.find<DashBoardController>()
//                                       .selectedVariations,
//                                 );
//                                 // .whenComplete(() async {
//                                 //   showBookingSheet(context);
//                                 // });
//                               } else {
//                                 showCustomSnackBar(
//                                     "Please select at least one variation",
//                                     isPending: true);
//                               }
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: 16),
//                             backgroundColor: Theme.of(context).primaryColor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: Text(
//                             "Add To Cart",
//                             style: TextStyle(fontSize: 16, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     },
//   );
// }
//
// String formatTimeOfDay24Hour(TimeOfDay time) {
//   final now = DateTime.now();
//   final dateTime =
//       DateTime(now.year, now.month, now.day, time.hour, time.minute);
//   return DateFormat('HH:mm').format(dateTime);
// }
