import 'dart:developer';

import 'package:do_fix/app/widgets/custom_appbar.dart';
import 'package:do_fix/app/widgets/custom_floating_cart_widget.dart';
import 'package:do_fix/app/widgets/service_container.dart';
import 'package:do_fix/controllers/auth_controller.dart';
import 'package:do_fix/model/service_model.dart';
import 'package:do_fix/model/service_reviews_model.dart';
import 'package:do_fix/utils/html_utils.dart';
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
import 'widgets/rating_summary_widget.dart';
import 'widgets/review_card_widget.dart';

class ServiceDetails extends StatefulWidget {
  const ServiceDetails({super.key});

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _visible = false;
  late List<AnimationController> _itemControllers;
  final bookingController = Get.find<BookingController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get service review and details after the build is complete
      final dashboardController = Get.find<DashBoardController>();
      final serviceId = dashboardController.serviceModel.id ?? "";

      Get.find<BookingController>().getServiceReview(serviceId: serviceId);
      dashboardController.getServicesDetails(serviceId);
    });

    _controller = AnimationController(
      duration: Duration(milliseconds: 500), // faster
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    int itemCount =
        Get.find<DashBoardController>().serviceModel.variations?.length ?? 0;

    _itemControllers = List.generate(itemCount, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400), // slightly faster
      );
    });

    // Animate all items quickly in sync with slight stagger
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _itemControllers.length; i++) {
        Future.delayed(Duration(milliseconds: 100 + (i * 80)), () {
          if (mounted) _itemControllers[i].forward();
        });
      }

      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _visible = true;
          });
          _controller.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(
        id: 'service_details',
        builder: (controller) {
          return Material(
            child: WillPopScope(
              onWillPop: () async {
                // Reverse all item animations
                for (final itemController in _itemControllers) {
                  itemController.reverse();
                }

                // Reverse the main slide animation
                await _controller.reverse();
                setState(() {
                  _visible = false;
                });
                // Delay a bit for smoother transition before popping
                await Future.delayed(Duration(milliseconds: 300));

                return true; // now allow the pop
              },
              child: SafeArea(
                top: false,
                child: Scaffold(
                  extendBody: true,
                  appBar: CustomAppBar(
                    title: controller.serviceModel.name ?? "",
                    isSearchButtonExist: false,
                    isBackButtonExist: true,
                    onBackPressed: () async {
                      // Reverse all item animations
                      for (final itemController in _itemControllers) {
                        itemController.reverse();
                      }

                      // Reverse the main slide animation
                      await _controller.reverse();
                      setState(() {
                        _visible = false;
                      });
                      // Delay a bit for smoother transition before popping
                      await Future.delayed(Duration(milliseconds: 300));
                      Get.back();
                    },
                  ),
                  body: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 25),
                            AnimatedBuilder(
                              animation: _slideAnimation,
                              builder: (context, child) {
                                return AnimatedSlide(
                                  offset: _slideAnimation.value,
                                  duration: const Duration(milliseconds: 600),
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 400),
                                    opacity: _visible ? 1.0 : 0.0,
                                    child: Container(
                                      width: Get.size.width,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: GetBuilder<DashBoardController>(
                                        id: 'service_container',
                                        builder: (dashController) {
                                          return ServiceContainer(
                                            showReviews: true,
                                            isButtonShow: true,
                                            serviceModel:
                                                controller.serviceModel,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 5),
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: _visible ? 1.0 : 0.0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'About the Service',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: _visible ? 1.0 : 0.0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: controller.serviceModel.description !=
                                            null &&
                                        HtmlUtils.containsHtml(controller
                                            .serviceModel.description!)
                                    ? HtmlToFlutter(
                                        htmlText: controller
                                                .serviceModel.description ??
                                            "",
                                      )
                                    : Text(
                                        HtmlUtils.stripHtmlIfPresent(controller
                                                .serviceModel.description ??
                                            ""),
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.6),
                                          fontSize: 14,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: _visible ? 1.0 : 0.0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Available Services',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: _visible ? 1.0 : 0.0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: GetBuilder<DashBoardController>(
                                  id: 'service_container',
                                  builder: (dashController) {
                                    return ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: controller.serviceModel
                                              .variations?.length ??
                                          0,
                                      itemBuilder: (context, index) {
                                        final variation = controller
                                            .serviceModel.variations?[index];
                                        return VariationsNewCard(
                                          serviceDescription: (variation
                                                          ?.varDescription !=
                                                      null &&
                                                  variation?.varDescription !=
                                                      "0")
                                              ? variation?.varDescription
                                              : HtmlUtils.stripHtmlIfPresent(
                                                  controller.serviceModel
                                                          .description ??
                                                      ""),
                                          serviceVariationName:
                                              variation?.variant ?? "",
                                          serviceRatings: (controller
                                                      .serviceModel.avgRating ??
                                                  0.0)
                                              .toString(),
                                          serviceReviewCount: (controller
                                                      .serviceModel
                                                      .ratingCount ??
                                                  0)
                                              .toString(),
                                          serviceMrpPrice:
                                              variation?.mrpPrice.toString() ??
                                                  "",
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
                                          variantKey:
                                              variation?.variantKey ?? "",
                                          serviceModel: controller.serviceModel,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            Obx(() {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rating',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    RatingSummary(
                                      avergeRating: bookingController.ratingAvg,
                                      starCounts: bookingController.starCounts,
                                    ),
                                    const SizedBox(height: 20),
                                    if (bookingController
                                            .serviceReviewsModel?.value !=
                                        null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Reviews',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          // InkWell(
                                          //   onTap: () {
                                          //     showReviewFilterBottomSheet(
                                          //       context,
                                          //       selectedRating:
                                          //           bookingController.selectedRating,
                                          //       recentlyAdded:
                                          //           bookingController.recentlyAdded,
                                          //       onApply: (rating, recentlyAdded) {
                                          //         bookingController.applyReviewFilter(
                                          //           rating: rating ?? 0,
                                          //           recentlyAdded: recentlyAdded,
                                          //         );
                                          //       },
                                          //     );
                                          //   },
                                          //   child: const Row(
                                          //     children: [
                                          //       Icon(
                                          //         Icons.filter_list,
                                          //         color: primaryBlue,
                                          //       ),
                                          //       Text(
                                          //         'Filter',
                                          //         style: TextStyle(
                                          //           fontSize: 14,
                                          //           fontWeight: FontWeight.w400,
                                          //           color: primaryBlue,
                                          //         ),
                                          //       )
                                          //     ],
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    if (bookingController
                                            .serviceReviewsModel?.value !=
                                        null)
                                      const SizedBox(height: 10),
                                    if (bookingController
                                            .serviceReviewsModel?.value !=
                                        null)
                                      (bookingController.serviceReviewsModel
                                                      ?.value !=
                                                  null &&
                                              bookingController
                                                      .serviceReviewsModel
                                                      ?.value
                                                      ?.reviews
                                                      ?.length !=
                                                  0)
                                          ? SizedBox(
                                              height: 300,
                                              child: ListView.builder(
                                                physics:
                                                    BouncingScrollPhysics(),
                                                itemCount: bookingController
                                                        .serviceReviewsModel
                                                        ?.value
                                                        ?.reviews
                                                        ?.length ??
                                                    0,
                                                itemBuilder: (context, index) {
                                                  final ServiceReview review =
                                                      bookingController
                                                              .serviceReviewsModel
                                                              ?.value
                                                              ?.reviews?[index] ??
                                                          ServiceReview();
                                                  return ReviewCard(
                                                    review: review,
                                                  );
                                                },
                                              ),
                                            )
                                          : SizedBox(
                                              height: 100,
                                              child: Center(
                                                child: Text(
                                                  "No reviews yet",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: GetBuilder<DashBoardController>(
                          id: 'cart_total',
                          builder: (controller) {
                            // Calculate total amount and item count
                            double totalAmount = 0;
                            int itemCount = 0;
                            if (controller.cartModel.content?.cart?.data !=
                                null) {
                              itemCount = controller
                                  .cartModel.content!.cart!.data!.length;
                              for (var item in controller
                                  .cartModel.content!.cart!.data!) {
                                totalAmount += (item.totalCost ?? 0);
                              }
                            }
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: CustomFloatingCartWidget(
                                totalAmount: totalAmount,
                                itemCount: itemCount,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

void showBookingSheet(
  BuildContext context,
) {
  GoogleMapController? _mapController;
  LatLng _selectedLatLng = LatLng(28.7041, 77.1025); // Default to Delhi
  // DateTime selectedDate = DateTime.now();
  // TimeOfDay? selectedTime;

  Future<void> _getCurrentLocation() async {
    // Mock function: You can implement actual location fetching using Geolocator
    _selectedLatLng = LatLng(28.7041, 77.1025); // Mocking location to Delhi
    Get.find<DashBoardController>().updateLatLong(
      _selectedLatLng.latitude.toString(),
      _selectedLatLng.longitude.toString(),
    );
  }

  showModalBottomSheet(
    context: context,
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          _getCurrentLocation();

          return FractionallySizedBox(
            heightFactor: 0.95, // 95% of available height
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
  int? _selectedRating = selectedRating;
  bool _recentlyAdded = recentlyAdded;

  Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Filter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            Text('View By', style: TextStyle(fontWeight: FontWeight.w600)),
            Row(
              children: [
                Checkbox(
                  value: _recentlyAdded,
                  onChanged: (val) =>
                      setState(() => _recentlyAdded = val ?? false),
                ),
                const Text('Recently Added'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Ratings', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                int rating = index + 1;
                bool isSelected = _selectedRating == rating;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = rating),
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
                  onApply(_selectedRating, _recentlyAdded);
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

void ShowAddToCartSheet(BuildContext context, ServiceModel serviceModel) {
  showModalBottomSheet(
    context: context,
    isDismissible: true,
    enableDrag: false,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
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
                          child: Icon(Icons.arrow_back,
                              size: 30, color: Theme.of(context).primaryColor),
                        ),
                        Spacer(),
                        Text(
                          "Available variations",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        String variant =
                            serviceModel.variations?[index].variant ?? "";
                        String variantKey =
                            serviceModel.variations?[index].variantKey ?? "";
                        String price =
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
                                      style: TextStyle(
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
                              "₹ " + price,
                              style: TextStyle(
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
                          horizontal: 16, vertical: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final authController = Get.find<AuthController>();
                            bool isGuest = await authController.returnIsGuest();
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
                                      item.variantKey ==
                                          selectedVariation, // <-- compare variation too
                                  orElse: () => CartItem(
                                    serviceId: "null",
                                    categoryId: "null",
                                    subCategoryId: "null",
                                    variantKey:
                                        "null", // add this if your CartItem has it
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
                                // .whenComplete(() async {
                                //   showBookingSheet(context);
                                // });
                              } else {
                                showCustomSnackBar(
                                    "Please select at least one variation",
                                    isPending: true);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Add To Cart",
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
