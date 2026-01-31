  import 'package:do_fix/controllers/auth_controller.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:do_fix/controllers/dashboard_controller.dart';
  import 'package:do_fix/model/service_model.dart';
  import 'package:do_fix/utils/html_utils.dart';
  import 'package:google_fonts/google_fonts.dart';
  import '../../../../utils/dimensions.dart';
  import 'get_rate_card_screen.dart';
  
  class VariationsNewCard extends StatefulWidget {
    final String serviceVariationName;
    final String serviceRatings;
    final String serviceReviewCount;
    final String serviceMrpPrice;
    final String serviceDiscountedPrice;
    final String serviceTimeDuration;
    final String serviceDescription;
    final String variantKey;
    final ServiceModel serviceModel;
  
    const VariationsNewCard({
      super.key,
      required this.serviceDescription,
      required this.serviceVariationName,
      required this.serviceRatings,
      required this.serviceReviewCount,
      required this.serviceMrpPrice,
      required this.serviceDiscountedPrice,
      required this.serviceTimeDuration,
      required this.variantKey,
      required this.serviceModel,
    });
  
    @override
    State<VariationsNewCard> createState() => _VariationsNewCardState();
  }
  
  class _VariationsNewCardState extends State<VariationsNewCard> {
    final DashBoardController dashboardController =
        Get.find<DashBoardController>();
    bool isInCart = false;
  
    // Format duration from "18:30" to "18 Hours 30 Mins"
    String _formatDuration(String duration) {
      if (duration.contains(':')) {
        try {
          final parts = duration.split(':');
          if (parts.length == 2) {
            final hours = int.tryParse(parts[0]);
            final minutes = int.tryParse(parts[1]);
  
            if (hours != null && minutes != null) {
              String result = '';
              if (hours > 0) {
                result += '$hours ${hours == 1 ? 'Hour' : 'Hours'}';
              }
              if (minutes > 0) {
                if (result.isNotEmpty) result += ' ';
                result += '$minutes ${minutes == 1 ? 'Min' : 'Mins'}';
              }
              return result.isNotEmpty ? result : duration;
            }
          }
        } catch (e) {
          print('Error formatting duration: $e');
        }
      }
      if (duration == "0") return "";
      if (duration == "0:0") return "";
      return duration;
    }
  
    @override
    void initState() {
      super.initState();
      // Use post-frame callback to ensure the widget is fully built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkIfInCart();
      });
    }
  
    void checkIfInCart() {
      bool foundInCart = false;
      if (dashboardController.cartModel.content?.cart?.data != null) {
        for (var item in dashboardController.cartModel.content!.cart!.data!) {
          if (item.serviceId == widget.serviceModel.id &&
              item.variantKey == widget.variantKey) {
            foundInCart = true;
            break;
          }
        }
      }
  
      // Only update if there's a change to prevent unnecessary rebuilds
      if (isInCart != foundInCart) {
        setState(() {
          isInCart = foundInCart;
        });
      }
    }
  
    Future<void> addToCart() async {
      final authController = Get.find<AuthController>();
      bool isGuest = await authController.returnIsGuest();
      if (isGuest) {
        authController.checkIfGuest();
      } else {
        dashboardController.selectedVariations.clear();
        dashboardController.addVariation(widget.variantKey);
  
        dashboardController.addToCart(
          {
            "service_id": widget.serviceModel.id,
            "category_id": widget.serviceModel.categoryId,
            "sub_category_id": widget.serviceModel.subCategoryId,
            "quantity": "1",
          },
          dashboardController.selectedVariations,
        );
  
        setState(() {
          isInCart = true;
        });
      }
    }
  
    void removeFromCart() {
      if (dashboardController.cartModel.content?.cart?.data != null) {
        for (var item in dashboardController.cartModel.content!.cart!.data!) {
          if (item.serviceId == widget.serviceModel.id &&
              item.variantKey == widget.variantKey) {
            dashboardController.removeItem(item.id ?? "");
            setState(() {
              isInCart = false;
            });
            break;
          }
        }
      }
    }
  
    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSize7),
        padding: const EdgeInsets.all(Dimensions.paddingSize10),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius10),
        border: Border.all(
          color: Colors.black.withAlpha((0.08 * 255).toInt()), // 🔹 lighter border
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).toInt()),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= LEFT CONTENT =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
  
                  /// 🔹 Service Name
                  Text(
                    widget.serviceVariationName,
                    style: const TextStyle(
                      fontSize: Dimensions.fontSize14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
  
                  /// 🔹 Rating
                  if (widget.serviceRatings != "0.0") ...[
                    const SizedBox(height: Dimensions.paddingSize5),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFAC33),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.serviceRatings,
                          style: const TextStyle(
                            fontSize: Dimensions.fontSize12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          " (${widget.serviceReviewCount} Reviews)",
                          style: TextStyle(
                            fontSize: Dimensions.fontSize10,
                            color: Colors.black.withAlpha((0.45 * 255).toInt()),
                          ),
                        ),
                      ],
                    ),
                  ],
  
                  const SizedBox(height: Dimensions.paddingSize7),
  
                  /// 🔹 Price Row
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "₹${widget.serviceDiscountedPrice}",
                        style: const TextStyle(
                          fontSize: Dimensions.fontSize15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
  
                      if (widget.serviceMrpPrice != "0.0" &&
                          widget.serviceMrpPrice != "null" &&
                          widget.serviceMrpPrice != "0")
                        Text(
                          "₹${widget.serviceMrpPrice}",
                          style: TextStyle(
                            fontSize: Dimensions.fontSize10,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.black.withAlpha((0.5 * 255).toInt()),
                          ),
                        ),
  
                      if (widget.serviceTimeDuration != "null")
                        Text(
                          _formatDuration(widget.serviceTimeDuration),
                          style: TextStyle(
                            fontSize: Dimensions.fontSize10,
                            color: Colors.black.withAlpha((0.7 * 255).toInt()),
                          ),
                        ),
                    ],
                  ),
  
                  const SizedBox(height: Dimensions.paddingSize7),
  
                  /// 🔹 Description
                  Text(
                    HtmlUtils.stripHtmlIfPresent(widget.serviceDescription),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Dimensions.fontSize10,
                      height: 1.4,
                      color: Colors.black.withAlpha((0.55 * 255).toInt()),
                    ),
                  ),
  
                  const SizedBox(height: Dimensions.paddingSize5),
  
                  /// 🔹 Rate Card Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "The Dofix Rate Card",
                          style: GoogleFonts.gulzar(
                            fontSize: Dimensions.fontSize12,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: Colors.amber, // 🔸 Yellow color
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
  
            /// ================= ADD / REMOVE BUTTON =================
            GetBuilder<DashBoardController>(
              id: 'cart_${widget.serviceModel.id}_${widget.variantKey}',
              builder: (controller) {
  
                bool itemFoundInCart = false;
                if (controller.cartModel.content?.cart?.data != null) {
                  for (var item in controller.cartModel.content!.cart!.data!) {
                    if (item.serviceId == widget.serviceModel.id &&
                        item.variantKey == widget.variantKey) {
                      itemFoundInCart = true;
                      break;
                    }
                  }
                }
                isInCart = itemFoundInCart;
  
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  verticalDirection: VerticalDirection.down,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 32,
                      width: 75,
                      child: GestureDetector(
                        onTap: isInCart ? removeFromCart : () async {
                          await dashboardController.addToCart(
                            {
                              "service_id": widget.serviceModel.id,
                              "category_id": widget.serviceModel.categoryId,
                              "sub_category_id": widget.serviceModel.subCategoryId,
                              "quantity": "1",
                              "extras": [],
                            },
                            [widget.variantKey],
                          );
                          setState(() => isInCart = true);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isInCart ? Colors.red : const Color(0xFF207FA8),
                            borderRadius: BorderRadius.circular(Dimensions.radius5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isInCart ? "Remove" : "Add",
                            style: const TextStyle(
                              fontSize: Dimensions.fontSize12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    /// 🔹 VIEW LINK (Add ke niche)
                    SizedBox(height: 80),
                    GestureDetector(
                      onTap: () {
                        Get.to(()=> const GetRateCardScreen());
                      },
                      child: Text(
                        "View",
                        style: TextStyle(
                          fontSize: Dimensions.fontSize12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2B7EA5), // 🔹 Blue clickable link
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: Dimensions.paddingSize10),
          ],
        ),
      );
    }
  }

// Future<bool?> showAddExtraServiceSheet(
//     BuildContext context,
//     ServiceModel service,
//     String variantKey,
//     ) {
//   return showModalBottomSheet<bool>(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (_) {
//       return AddExtraServiceSheet(
//         service: service,
//         variantKey: variantKey,
//       );
//     },
//   );
// }

