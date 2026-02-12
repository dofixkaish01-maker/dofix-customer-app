import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../widgets/custom_appbar.dart';
import '../home/component/get_rate_card_screen.dart';

class DetailsScreen extends StatelessWidget {
  final dynamic serviceModel;
  final String variationName;
  final String rating;
  final String reviewCount;
  final String mrpPrice;
  final String discountedPrice;
  final String duration;
  final String description;
  final String variantKey;

  const DetailsScreen({
    super.key,
    required this.serviceModel,
    required this.variationName,
    required this.rating,
    required this.reviewCount,
    required this.mrpPrice,
    required this.discountedPrice,
    required this.duration,
    required this.description,
    required this.variantKey,
  });

  @override
  Widget build(BuildContext context) {

    /// 🔥 Percentage Calculation
    double mrp = double.tryParse(mrpPrice) ?? 0;
    double discountPrice = double.tryParse(discountedPrice) ?? 0;

    int percentOff = 0;
    if (mrp > 0) {
      percentOff = (((mrp - discountPrice) / mrp) * 100).round();
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: CustomAppBar(
        title: "Service Details",
        isBackButtonExist: true,
        isSearchButtonExist: false,
        isCartButtonExist: true,
        showNotificationIcon: false,
      ),

      body: Stack(
        children: [

          /// 🔥 MAIN SCROLL AREA
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔥 PREMIUM IMAGE HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [

                          Positioned.fill(
                            child: Image.network(
                              serviceModel?.coverImageFullPath ?? "",
                              fit: BoxFit.cover,
                            ),
                          ),

                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 20,
                            bottom: 20,
                            right: 20,
                            child: Text(
                              variationName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🔥 PREMIUM RATING CARD
                      if (rating != "0")
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [

                              Row(
                                children: List.generate(5, (index) {
                                  double ratingValue = double.tryParse(rating) ?? 0.0;

                                  if (index < ratingValue.floor()) {
                                    return const Icon(Icons.star,
                                        color: Colors.amber, size: 20);
                                  } else if (index < ratingValue &&
                                      index + 1 > ratingValue) {
                                    return const Icon(Icons.star_half,
                                        color: Colors.amber, size: 20);
                                  } else {
                                    return const Icon(Icons.star_border,
                                        color: Colors.amber, size: 20);
                                  }
                                }),
                              ),

                              const SizedBox(width: 10),

                              Text(
                                rating,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(width: 8),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "$reviewCount Reviews",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const Spacer(),

                              const Icon(Icons.verified,
                                  color: Colors.green, size: 18),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      /// 🔥 PREMIUM PRICE CARD
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [

                                Text(
                                  "₹$discountedPrice",
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Text(
                                  "₹$mrpPrice",
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                if (percentOff > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xff5e838f),
                                          Color(0xff468aa5),
                                        ],
                                      ),


                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "$percentOff% OFF",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),


                                const Spacer(),

                                if (duration.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 18, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        duration,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                              ],
                            ),

                            const SizedBox(height: 8),

                            if (percentOff > 0)
                              Text(
                                "You save ₹${(mrp - discountPrice).toStringAsFixed(0)} on this service",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "About Service",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        description,
                        style: const TextStyle(
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 🔥 BOTTOM ADD / REMOVE BUTTON
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  )
                ],
              ),
              child: GetBuilder<DashBoardController>(
                id: 'cart_${serviceModel.id}_$variantKey',
                builder: (controller) {

                  bool isInCart = false;

                  if (controller.cartModel.content?.cart?.data != null) {
                    for (var item in controller.cartModel.content!.cart!.data!) {
                      if (item.serviceId == serviceModel.id &&
                          item.variantKey == variantKey) {
                        isInCart = true;
                        break;
                      }
                    }
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      /// 🔥 ADD / REMOVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            isInCart ? Colors.red : const Color(0xff3683ab),
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {

                            if (isInCart) {
                              /// 🔥 REMOVE
                              await controller.removeFromCart(
                                serviceModel.id,
                                variantKey,
                              );

                            } else {

                              /// 🔥 ADD
                              await controller.addToCart(
                                {
                                  "service_id": serviceModel.id,
                                  "category_id": serviceModel.categoryId,
                                  "sub_category_id":
                                  serviceModel.subCategoryId,
                                  "quantity": "1",
                                  "extras": [],
                                },
                                [variantKey],
                              );
                            }

                            controller.update(
                                ['cart_${serviceModel.id}_$variantKey']);
                          },
                          child: Text(
                            isInCart ? "Remove from Cart" : "Add to Cart",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Get.to(() => GetRateCardScreen(
                            categoryId: serviceModel.categoryId ?? "",
                          ));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xff3683ab).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xff3683ab).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [

                              Icon(
                                Icons.receipt_long_rounded,
                                size: 18,
                                color: Color(0xff3683ab),
                              ),

                              SizedBox(width: 8),

                              Text(
                                "View Rate Card",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff3683ab),
                                ),
                              ),

                              SizedBox(width: 6),

                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Color(0xff3683ab),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 18),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
