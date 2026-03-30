import 'package:do_fix/app/views/helpSupport/faq_support_screen.dart';
import 'package:do_fix/app/views/services/details_screen.dart';
import 'package:do_fix/controllers/auth_controller.dart';
import 'package:do_fix/utils/theme.dart';
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
  final String
      serviceCoverImage; // UI me use nahi ho raha, details screen ke liye kept
  final String serviceReviewCount;
  final String serviceMrpPrice;
  final String serviceDiscountedPrice;
  final String serviceTimeDuration;
  final String serviceDescription;
  final String variantKey;
  final ServiceModel serviceModel;
  final int
      taxAmount; // Kept for compatibility, current addToCart logic still uses hardcoded 79

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

  int getACCount(String name) {
    final regex = RegExp(r'(\d+)-AC');
    final match = regex.firstMatch(name);

    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 1;
    }
    return 1; // default single AC
  }

  String getPricePerUnit(String price, String name) {
    int totalPrice = int.tryParse(price.split('.').first) ?? 0;

    int acCount = getACCount(name);

    if (acCount > 1) {
      int perUnit = (totalPrice / acCount).round();
      return "₹$perUnit / AC";
    }

    return "₹$totalPrice";
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
      widget.serviceMrpPrice != "0" &&
      widget.serviceMrpPrice.trim().isNotEmpty;

  bool get _showDuration =>
      widget.serviceTimeDuration != "0" &&
      widget.serviceTimeDuration != "0:0" &&
      widget.serviceTimeDuration != "null" &&
      widget.serviceTimeDuration.trim().isNotEmpty;

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
            vertical: 6,
            horizontal: isTablet ? 8 : 0,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 14,
            vertical: isTablet ? 14 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE8EDF2),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 340;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///  Title + Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.serviceVariationName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isTablet ? 15.5 : 14.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (_showRating) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFAC33).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Color(0xFFFFAC33),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                widget.serviceRatings,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                " (${widget.serviceReviewCount})",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black.withOpacity(0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  ///  Price + Duration Row
                  Row(
                    children: [
                      if (_showMrp)
                        Text(
                          getPricePerUnit(
                            widget.serviceMrpPrice,
                            widget.serviceVariationName,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (_showMrp) const SizedBox(width: 6),
                      Text(
                        getPricePerUnit(
                          widget.serviceDiscountedPrice,
                          widget.serviceVariationName,
                        ),
                        style: TextStyle(
                          fontSize: isTablet ? 14.5 : 13.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (getACCount(widget.serviceVariationName) > 1) ...[
                        const SizedBox(width: 10),
                        Text(
                          "₹${widget.serviceDiscountedPrice}",
                          style: TextStyle(
                              fontSize: 14,
                              color: primaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                      const Spacer(),
                      if (_showDuration)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F8FB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.serviceTimeDuration,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4B7EA8),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// 🔹 Description
                  Text(
                    HtmlUtils.stripHtmlIfPresent(widget.serviceDescription),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.4,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 🔹 Bottom Row
                  Row(
                    children: [
                      Expanded(child: _buildRateCardButton(compact: compact)),
                      // GestureDetector(
                      //   onTap: () {
                      //     // rate card
                      //   },
                      //   child: Text(
                      //     "View Rate Card",
                      //     style: TextStyle(
                      //       fontSize: 11.5,
                      //       fontWeight: FontWeight.w600,
                      //       color: const Color(0xFF207FA8),
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(
                        width: 20,
                      ),
                      _buildCartButton(
                        width: compact ? 78 : 86,
                        height: 34,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ));
  }

  Widget _buildRateCardButton({required bool compact}) {
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
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF207FA8).withOpacity(0.22),
          ),
          color: const Color(0xFF207FA8).withOpacity(0.04),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 15,
              color: Color(0xFF207FA8),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                "View Rate Card",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF207FA8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartButton({
    required double width,
    required double height,
  }) {
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
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isInCart ? Colors.red.shade400 : const Color(0xFF207FA8),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: (isInCart ? Colors.red : const Color(0xFF207FA8))
                      .withOpacity(0.14),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              isInCart ? "Remove" : "Add",
              style: const TextStyle(
                fontSize: 11.5,
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
