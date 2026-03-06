import 'package:do_fix/app/views/services/details_screen.dart';
import 'package:do_fix/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/model/service_model.dart';
import 'package:do_fix/utils/html_utils.dart';
import '../../../../utils/dimensions.dart';
import 'get_rate_card_screen.dart';

class VariationsNewCard extends StatefulWidget {
  final String serviceVariationName;
  final String serviceRatings;
  final String serviceCoverImage;
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
    required this.serviceCoverImage,
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
  final DashBoardController dashboardController = Get.find<DashBoardController>();
  bool isInCart = false;
  String coverVariantImagePath = "https://panel.dofix.in/storage/service/variant/";

  // Format duration from "18:30" to "18 Hours 30 Mins"
  // String _formatDuration(String duration) {
  //   if (duration.contains(':')) {
  //     try {
  //       final parts = duration.split(':');
  //       if (parts.length == 2) {
  //         final hours = int.tryParse(parts[0]);
  //         final minutes = int.tryParse(parts[1]);
  //
  //         if (hours != null && minutes != null) {
  //           String result = '';
  //           if (hours > 0) {
  //             result += '$hours ${hours == 1 ? 'Hr' : 'Hrs'}';
  //           }
  //           if (minutes > 0) {
  //             if (result.isNotEmpty) result += ' ';
  //             result += '$minutes ${minutes == 1 ? 'Min' : 'Mins'}';
  //           }
  //           return result.isNotEmpty ? result : duration;
  //         }
  //       }
  //     } catch (e) {
  //       print('Error formatting duration: $e');
  //     }
  //   }
  //   if (duration == "0" || duration == "0:0" || duration == "null") return "";
  //   return duration;
  // }

  @override
  void initState() {
    super.initState();
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return GestureDetector(
      onTap: () {
        Get.to(() => DetailsScreen(
          serviceModel: widget.serviceModel,
          variationName: widget.serviceVariationName,
          coverImage: widget.serviceCoverImage,
          rating: widget.serviceRatings,
          reviewCount: widget.serviceReviewCount,
          mrpPrice: widget.serviceMrpPrice,
          discountedPrice: widget.serviceDiscountedPrice,
          duration: widget.serviceTimeDuration,
          description: widget.serviceDescription,
          variantKey: widget.variantKey,
        ));
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          vertical: Dimensions.paddingSize7,
          horizontal: isTablet ? Dimensions.paddingSize10 : 0,
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSize12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          border: Border.all(
            color: Colors.black.withOpacity(0.08),
            width: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /// 1st Column: Image
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radius10),
                  child: Image.network(
                    coverVariantImagePath + widget.serviceCoverImage,
                    width: isTablet ? 180 : 130, // keep width fixed if needed
                    fit: BoxFit.contain, // <-- shows full image without cropping
                    errorBuilder: (_, __, ___) => Container(
                      height: isTablet ? 160 : 180,
                      width: isTablet ? 200 : 160,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 30, color: Colors.grey),
                    ),
                  ),
                ),
                /// 1st Line: Title
                SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    Text(
                      widget.serviceVariationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTablet ? Dimensions.fontSize15 : Dimensions.fontSize14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.9),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    /// 3rd Line: Rating and Price in one row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Rating
                        Row(
                          children: [
                            if (widget.serviceRatings != "0.0") ...[
                              const Icon(Icons.star, size: 14, color: Color(0xFFFFAC33)),
                              const SizedBox(width: 4),
                              Text(
                                widget.serviceRatings,
                                style: const TextStyle(
                                  fontSize: Dimensions.fontSize12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                " (${widget.serviceReviewCount})",
                                style: TextStyle(
                                  fontSize: Dimensions.fontSize10,
                                  color: Colors.black.withOpacity(0.45),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    /// Price Section
                    Row(
                      children: [
                        Text(
                          "₹${widget.serviceDiscountedPrice}",
                          style: TextStyle(
                            fontSize: isTablet ? Dimensions.fontSize18 : Dimensions.fontSize15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF207FA8),
                          ),
                        ),
                        if (widget.serviceMrpPrice != "0.0" &&
                            widget.serviceMrpPrice != "null" &&
                            widget.serviceMrpPrice != "0") ...[
                          const SizedBox(width: 6),
                          Text(
                            "₹${widget.serviceMrpPrice}",
                            style: TextStyle(
                              fontSize: Dimensions.fontSize10,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: Dimensions.paddingSize12),
            SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 2nd Column: Details

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 2nd Line: Description
                      Text(
                        HtmlUtils.stripHtmlIfPresent(widget.serviceDescription),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Dimensions.fontSize12,
                          height: 1.4,
                          color: Colors.black.withOpacity(0.55),
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// 4th Line: View Rate Card and Add Button in one row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Rate Card Link
                          GestureDetector(
                            onTap: () {
                              Get.to(() => GetRateCardScreen(
                                categoryId: widget.serviceModel.categoryId ?? "",
                              ));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                "View Rate Card",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2B7EA5),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),

                          /// Add Button
                          GetBuilder<DashBoardController>(
                            id: 'cart_${widget.serviceModel.id}_${widget.variantKey}',
                            builder: (controller) {
                              bool itemInCart = false;
                              if (controller.cartModel.content?.cart?.data != null) {
                                for (var item in controller.cartModel.content!.cart!.data!) {
                                  if (item.serviceId == widget.serviceModel.id &&
                                      item.variantKey == widget.variantKey) {
                                    itemInCart = true;
                                    break;
                                  }
                                }
                              }
                              isInCart = itemInCart;

                              return GestureDetector(
                                onTap: isInCart ? removeFromCart : addToCart,
                                child: Container(
                                  height: 30,
                                  width: 85,
                                  decoration: BoxDecoration(
                                    color: isInCart ? Colors.red.shade400 : const Color(0xFF207FA8),
                                    borderRadius: BorderRadius.circular(Dimensions.radius5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    isInCart ? "Remove" : "Add",
                                    style: const TextStyle(
                                      fontSize: Dimensions.fontSize10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
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
