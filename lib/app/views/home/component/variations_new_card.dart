import 'package:do_fix/app/views/services/details_screen.dart';
import 'package:do_fix/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/model/service_model.dart';
import 'package:do_fix/utils/html_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/dimensions.dart';
// import 'get_rate_card_screen.dart'; // Unused

class VariationsNewCard extends StatefulWidget {
  final String serviceVariationName;
  final String serviceRatings;
  final String serviceCoverImage; // Removed from UI, keeping commented as requested
  final String serviceReviewCount;
  final String serviceMrpPrice;
  final String serviceDiscountedPrice;
  final String serviceTimeDuration;
  final String serviceDescription;
  final String variantKey;
  final ServiceModel serviceModel;
  final int taxAmount; // Kept for compatibility, current addToCart logic still uses hardcoded 79

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
    required this.taxAmount,
  });

  @override
  State<VariationsNewCard> createState() => _VariationsNewCardState();
}

class _VariationsNewCardState extends State<VariationsNewCard> {
  final DashBoardController dashboardController =
  Get.find<DashBoardController>();

  bool isInCart = false;

  // String coverVariantImagePath =
  //     "https://panel.dofix.in/storage/service/variant/"; // Unused after removing image UI

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
          "tax_amount": 79,
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

  bool get _showRating => widget.serviceRatings != "0.0";

  bool get _showMrp =>
      widget.serviceMrpPrice != "0.0" &&
          widget.serviceMrpPrice != "null" &&
          widget.serviceMrpPrice != "0";

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final bool isSmallPhone = screenWidth < 360;

    return GestureDetector(
      onTap: () {
        Get.to(
              () => DetailsScreen(
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
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          vertical: Dimensions.paddingSize7,
          horizontal: isTablet ? Dimensions.paddingSize10 : 0,
        ),
        padding: EdgeInsets.all(isTablet ? 18 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF207FA8).withOpacity(0.10),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxWidth < 340;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.serviceVariationName,
                        maxLines: isTablet ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 17 : 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallPhone ? 8 : 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF207FA8).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF207FA8).withOpacity(0.18),
                        ),
                      ),
                      child: Text(
                        "₹${widget.serviceDiscountedPrice}",
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF207FA8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// Rating + MRP + Duration chip space
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_showRating)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFAC33).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: Color(0xFFFFAC33),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.serviceRatings,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              " (${widget.serviceReviewCount})",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black.withOpacity(0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_showMrp)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "MRP ₹${widget.serviceMrpPrice}",
                          style: TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (widget.serviceTimeDuration != "0" &&
                        widget.serviceTimeDuration != "0:0" &&
                        widget.serviceTimeDuration != "null" &&
                        widget.serviceTimeDuration.trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF6FA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.serviceTimeDuration,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2B7EA5),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Description
                Text(
                  HtmlUtils.stripHtmlIfPresent(widget.serviceDescription),
                  maxLines: isTablet ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    height: 1.5,
                    color: Colors.black.withOpacity(0.60),
                  ),
                ),

                const SizedBox(height: 14),

                /// Bottom actions
                compact
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRateCardLink(),
                    const SizedBox(height: 10),
                    _buildCartButton(fullWidth: true),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildRateCardLink()),
                    const SizedBox(width: 12),
                    _buildCartButton(),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRateCardLink() {
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(
          "https://ac-repair-landing-page.dofix.in/rateCard.html",
        );

        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.inAppWebView,
          );
        } else {
          print("Could not launch $url");
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 16,
              color: Color(0xFF2B7EA5),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                "View Rate Card",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B7EA5),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartButton({bool fullWidth = false}) {
    return GetBuilder<DashBoardController>(
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
            height: 42,
            width: fullWidth ? double.infinity : 110,
            decoration: BoxDecoration(
              color:
              isInCart ? Colors.red.shade400 : const Color(0xFF207FA8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isInCart ? Colors.red : const Color(0xFF207FA8))
                      .withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              isInCart ? "Remove" : "Add",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}



// import 'package:do_fix/app/views/services/details_screen.dart';
// import 'package:do_fix/controllers/auth_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:do_fix/controllers/dashboard_controller.dart';
// import 'package:do_fix/model/service_model.dart';
// import 'package:do_fix/utils/html_utils.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../../utils/dimensions.dart';
// import 'get_rate_card_screen.dart';
//
// class VariationsNewCard extends StatefulWidget {
//   final String serviceVariationName;
//   final String serviceRatings;
//   final String serviceCoverImage;
//   final String serviceReviewCount;
//   final String serviceMrpPrice;
//   final String serviceDiscountedPrice;
//   final String serviceTimeDuration;
//   final String serviceDescription;
//   final String variantKey;
//   final ServiceModel serviceModel;
//   final int taxAmount;
//
//   const VariationsNewCard({
//     super.key,
//     required this.serviceDescription,
//     required this.serviceVariationName,
//     required this.serviceRatings,
//     required this.serviceReviewCount,
//     required this.serviceCoverImage,
//     required this.serviceMrpPrice,
//     required this.serviceDiscountedPrice,
//     required this.serviceTimeDuration,
//     required this.variantKey,
//     required this.serviceModel,
//     required this.taxAmount
//   });
//
//   @override
//   State<VariationsNewCard> createState() => _VariationsNewCardState();
// }
//
// class _VariationsNewCardState extends State<VariationsNewCard> {
//   final DashBoardController dashboardController = Get.find<DashBoardController>();
//   bool isInCart = false;
//   String coverVariantImagePath = "https://panel.dofix.in/storage/service/variant/";
//
//   // Format duration from "18:30" to "18 Hours 30 Mins"
//   // String _formatDuration(String duration) {
//   //   if (duration.contains(':')) {
//   //     try {
//   //       final parts = duration.split(':');
//   //       if (parts.length == 2) {
//   //         final hours = int.tryParse(parts[0]);
//   //         final minutes = int.tryParse(parts[1]);
//   //
//   //         if (hours != null && minutes != null) {
//   //           String result = '';
//   //           if (hours > 0) {
//   //             result += '$hours ${hours == 1 ? 'Hr' : 'Hrs'}';
//   //           }
//   //           if (minutes > 0) {
//   //             if (result.isNotEmpty) result += ' ';
//   //             result += '$minutes ${minutes == 1 ? 'Min' : 'Mins'}';
//   //           }
//   //           return result.isNotEmpty ? result : duration;
//   //         }
//   //       }
//   //     } catch (e) {
//   //       print('Error formatting duration: $e');
//   //     }
//   //   }
//   //   if (duration == "0" || duration == "0:0" || duration == "null") return "";
//   //   return duration;
//   // }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       checkIfInCart();
//     });
//   }
//
//   void checkIfInCart() {
//     bool foundInCart = false;
//     if (dashboardController.cartModel.content?.cart?.data != null) {
//       for (var item in dashboardController.cartModel.content!.cart!.data!) {
//         if (item.serviceId == widget.serviceModel.id &&
//             item.variantKey == widget.variantKey) {
//           foundInCart = true;
//           break;
//         }
//       }
//     }
//
//     if (isInCart != foundInCart) {
//       setState(() {
//         isInCart = foundInCart;
//       });
//     }
//   }
//
//   Future<void> addToCart() async {
//     final authController = Get.find<AuthController>();
//     bool isGuest = await authController.returnIsGuest();
//     if (isGuest) {
//       authController.checkIfGuest();
//     } else {
//       dashboardController.selectedVariations.clear();
//       dashboardController.addVariation(widget.variantKey);
//
//       dashboardController.addToCart(
//         {
//           "service_id": widget.serviceModel.id,
//           "category_id": widget.serviceModel.categoryId,
//           "sub_category_id": widget.serviceModel.subCategoryId,
//           "tax_amount":79,
//           "quantity": "1",
//         },
//         dashboardController.selectedVariations,
//       );
//
//       setState(() {
//         isInCart = true;
//       });
//     }
//   }
//
//   void removeFromCart() {
//     if (dashboardController.cartModel.content?.cart?.data != null) {
//       for (var item in dashboardController.cartModel.content!.cart!.data!) {
//         if (item.serviceId == widget.serviceModel.id &&
//             item.variantKey == widget.variantKey) {
//           dashboardController.removeItem(item.id ?? "");
//           setState(() {
//             isInCart = false;
//           });
//           break;
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final bool isTablet = screenWidth >= 600;
//
//     return GestureDetector(
//       onTap: () {
//         Get.to(() => DetailsScreen(
//           serviceModel: widget.serviceModel,
//           variationName: widget.serviceVariationName,
//           coverImage: widget.serviceCoverImage,
//           rating: widget.serviceRatings,
//           reviewCount: widget.serviceReviewCount,
//           mrpPrice: widget.serviceMrpPrice,
//           discountedPrice: widget.serviceDiscountedPrice,
//           duration: widget.serviceTimeDuration,
//           description: widget.serviceDescription,
//           variantKey: widget.variantKey,
//         ));
//       },
//       child: Container(
//         width: double.infinity,
//         margin: EdgeInsets.symmetric(
//           vertical: Dimensions.paddingSize7,
//           horizontal: isTablet ? Dimensions.paddingSize10 : 0,
//         ),
//         padding: const EdgeInsets.all(Dimensions.paddingSize12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(Dimensions.radius10),
//           border: Border.all(
//             color: Colors.black.withOpacity(0.08),
//             width: 0.6,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(Dimensions.radius10),
//                   child: Image.network(
//                     coverVariantImagePath + widget.serviceCoverImage,
//                     width: isTablet ? 180 : 130,
//                     fit: BoxFit.contain,
//                     errorBuilder: (_, __, ___) => Container(
//                       height: isTablet ? 160 : 180,
//                       width: isTablet ? 200 : 160,
//                       color: Colors.grey.shade200,
//                       child: const Icon(Icons.image, size: 30, color: Colors.grey),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(width: 10),
//
//                 /// FIX HERE
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//
//                       Text(
//                         widget.serviceVariationName,
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: isTablet ? Dimensions.fontSize15 : Dimensions.fontSize14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black.withOpacity(0.9),
//                           height: 1.2,
//                         ),
//                       ),
//
//                       const SizedBox(height: 4),
//
//                       Row(
//                         children: [
//                           if (widget.serviceRatings != "0.0") ...[
//                             const Icon(Icons.star, size: 14, color: Color(0xFFFFAC33)),
//                             const SizedBox(width: 4),
//                             Text(
//                               widget.serviceRatings,
//                               style: const TextStyle(
//                                 fontSize: Dimensions.fontSize12,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             Text(
//                               " (${widget.serviceReviewCount})",
//                               style: TextStyle(
//                                 fontSize: Dimensions.fontSize10,
//                                 color: Colors.black.withOpacity(0.45),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//
//                       const SizedBox(height: 8),
//
//                       Row(
//                         children: [
//                           Text(
//                             "₹${widget.serviceDiscountedPrice}",
//                             style: TextStyle(
//                               fontSize: isTablet ? Dimensions.fontSize18 : Dimensions.fontSize15,
//                               fontWeight: FontWeight.w800,
//                               color: const Color(0xFF207FA8),
//                             ),
//                           ),
//                           if (widget.serviceMrpPrice != "0.0" &&
//                               widget.serviceMrpPrice != "null" &&
//                               widget.serviceMrpPrice != "0") ...[
//                             const SizedBox(width: 6),
//                             Text(
//                               "₹${widget.serviceMrpPrice}",
//                               style: TextStyle(
//                                 fontSize: Dimensions.fontSize10,
//                                 decoration: TextDecoration.lineThrough,
//                                 color: Colors.black.withOpacity(0.4),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(width: Dimensions.paddingSize12),
//             SizedBox(height: 10,),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// 2nd Column: Details
//
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//
//                       /// 2nd Line: Description
//                       Text(
//                         HtmlUtils.stripHtmlIfPresent(widget.serviceDescription),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: Dimensions.fontSize12,
//                           height: 1.4,
//                           color: Colors.black.withOpacity(0.55),
//                         ),
//                       ),
//
//                       const SizedBox(height: 8),
//
//                       /// 4th Line: View Rate Card and Add Button in one row
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           /// Rate Card Link
//                           GestureDetector(
//                             onTap: () async {
//                               final Uri url = Uri.parse(
//                                   "https://ac-repair-landing-page.dofix.in/rateCard.html");
//
//                               if (await canLaunchUrl(url)) {
//                                 await launchUrl(
//                                   url,
//                                   mode: LaunchMode.inAppWebView, // browser me open hoga
//                                 );
//                               } else {
//                                 print("Could not launch $url");
//                               }
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 4),
//                               child: Text(
//                                 "View Rate Card",
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.bold,
//                                   color: const Color(0xFF2B7EA5),
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           /// Add Button
//                           GetBuilder<DashBoardController>(
//                             id: 'cart_${widget.serviceModel.id}_${widget.variantKey}',
//                             builder: (controller) {
//                               bool itemInCart = false;
//                               if (controller.cartModel.content?.cart?.data != null) {
//                                 for (var item in controller.cartModel.content!.cart!.data!) {
//                                   if (item.serviceId == widget.serviceModel.id &&
//                                       item.variantKey == widget.variantKey) {
//                                     itemInCart = true;
//                                     break;
//                                   }
//                                 }
//                               }
//                               isInCart = itemInCart;
//
//                               return GestureDetector(
//                                 onTap: isInCart ? removeFromCart : addToCart,
//                                 child: Container(
//                                   height: 30,
//                                   width: 85,
//                                   decoration: BoxDecoration(
//                                     color: isInCart ? Colors.red.shade400 : const Color(0xFF207FA8),
//                                     borderRadius: BorderRadius.circular(Dimensions.radius5),
//                                   ),
//                                   alignment: Alignment.center,
//                                   child: Text(
//                                     isInCart ? "Remove" : "Add",
//                                     style: const TextStyle(
//                                       fontSize: Dimensions.fontSize10,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
