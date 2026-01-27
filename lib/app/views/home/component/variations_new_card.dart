import 'package:do_fix/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/model/service_model.dart';
import 'package:do_fix/utils/html_utils.dart';

import '../../../../helper/route_helper.dart';
import '../../services/extra service/add_extra_service_sheet.dart';

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
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: Colors.black.withAlpha((0.25 * 255).toInt()),
          width: 0.25,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  widget.serviceVariationName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                if (widget.serviceRatings != "0.0") const SizedBox(height: 8),
                if (widget.serviceRatings != "0.0")
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Color(0xFFFFAC33),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.serviceRatings}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        " (${widget.serviceReviewCount} Reviews)",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withAlpha((0.30 * 255).toInt()),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    Text(
                      "₹${widget.serviceDiscountedPrice}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    if (widget.serviceMrpPrice != "0.0" &&
                        widget.serviceMrpPrice != "null" &&
                        widget.serviceMrpPrice != "0")
                      Column(
                        children: [
                          SizedBox(
                            height: 1,
                          ),
                          Text(
                            "₹${widget.serviceMrpPrice}",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                              decorationStyle: TextDecorationStyle.solid,
                              color:
                                  Colors.black.withAlpha((0.60 * 255).toInt()),
                            ),
                          ),
                        ],
                      ),
                    if (widget.serviceTimeDuration != "null")
                      Text(
                        _formatDuration(widget.serviceTimeDuration),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  HtmlUtils.stripHtmlIfPresent(widget.serviceDescription),
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: Colors.black.withAlpha((0.52 * 255).toInt()),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10)
              ],
            ),
          ),
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

                return SizedBox(
                  height: 30,
                  width: 70,
                  child: isInCart
                      ? GestureDetector(
                          onTap: removeFromCart,
                          child: Container(
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5))),
                            child: Center(
                              child: Text(
                                "Remove",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                    onTap: () {
                      final variations = widget.serviceModel.variations ?? [];

                      /// 🟢 CASE 1: No extra service → normal add to cart
                      if (variations.isEmpty) {
                        addToCart(); // tumhara existing method
                        return;
                      }

                      /// 🟢 CASE 2: Only ONE extra service → direct add + cart
                      if (variations.length == 1) {
                        final v = variations.first;

                        dashboardController.addToCart(
                          {
                            "service_id": widget.serviceModel.id,
                            "category_id": widget.serviceModel.categoryId,
                            "sub_category_id": widget.serviceModel.subCategoryId,
                            "quantity": "1",
                            "extras": [v.toJson()],
                          },
                          [widget.variantKey],
                        );

                        Get.toNamed(
                          RouteHelper.getDashboardRoute(),
                          arguments: {"pageIndex": 2}, // cart tab
                        );
                        return;
                      }

                      /// 🟡 CASE 3: Multiple extra services → open bottom sheet
                      showAddExtraServiceSheet(
                        context,
                        widget.serviceModel,
                        widget.variantKey,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF207FA8),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: const Center(
                        child: Text(
                          "Add",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              })
        ],
      ),
    );
  }
}
void showAddExtraServiceSheet(
    BuildContext context,
    ServiceModel service,
    String variantKey,
    ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return AddExtraServiceSheet(
        service: service,
        variantKey: variantKey,
      );
    },
  );
}
