import 'package:do_fix/app/views/bookingScreen/booking_screen.dart';
import 'package:do_fix/widgets/custom_dot_loader.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../model/service_model.dart';
import '../../widgets/custom_appbar.dart';
import '../dashboard/dashboard_screen.dart';
import 'SubScreen/header_component.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<CartItem?> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      final data =
          Get.find<DashBoardController>().cartModel.content?.cart?.data ?? [];
      setState(() {
        _items = [];
      });
      for (int i = 0; i < data.length; i++) {
        Future.delayed(Duration(milliseconds: 150 * i), () {
          _items.insert(i, data[i]);
          _listKey.currentState?.insertItem(i);
        });
      }

      // Show loader for 3 seconds before showing empty cart message
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    });
  }

  void removeItem(int index) {
    final removedItem = _items[index];
    _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(1.0, 0.0), // slide out to right
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: FadeTransition(
          opacity: animation,
          child: HeaderComponent(
            serviceModel: removedItem,
            function: (index) {},
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(builder: (controller){
      final cartModel = controller.cartModel;
      final content = cartModel.content;
      final cart = content?.cart;

      double itemTotal = 0.0;
      double discount = 0.0;
      double couponDiscount = 0.0;

      double totalLabourCharge = 0.0;
      /// API se tax
      double tax = (content?.taxAmount ?? 0).toDouble();

      if (cart != null && cart.data != null && cart.data!.isNotEmpty) {
        final items = cart.data!;
        double parse(dynamic val) {
          if (val is num) return val.toDouble();
          if (val is String) return double.tryParse(val) ?? 0.0;
          return 0.0;
        }
        for (var item in items) {
          itemTotal += parse(item.serviceCost) * parse(item.quantity);
          discount += parse(item.discountAmount);
          couponDiscount += parse(item.couponDiscount);

          //Labour charge safe
          final labour = item.service?['labour_charge'];
          totalLabourCharge += parse(labour);
        }
        }
        // final double grandTotal = (content?.totalCost ?? 0).toDouble() + tax;
      final double grandTotal =
          (content?.totalCost ?? 0).toDouble() + tax + totalLabourCharge;

      final double wallet = (content?.walletBalance ?? 0).toDouble();
      final double referral = (content?.referralAmount ?? 0).toDouble();
      final int itemCount = cart?.data?.length ?? 0;

        final media = MediaQuery.of(context);
        final shortest = media.size.shortestSide;
        final isTablet = shortest >= 600;
        final horizontalPadding = isTablet ? 24.0 : 16.0;
        final maxContentWidth = isTablet ? 760.0 : double.infinity;

        Widget priceRow(String title, double amount,
            {bool isBold = false, Color? color}) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  "₹ ${amount.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    color: color ?? Colors.black,
                  ),
                ),
              ],
            ),
          );
        }

      final bool showBottomBar = _items.isNotEmpty;

      return SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          appBar: CustomAppBar(
            title: "Cart",
            isBackButtonExist: true,
            isSearchButtonExist: false,
            isCartButtonExist: false,
            showNotificationIcon: false,
          ),

          ///  FIXED BOTTOM BAR
          bottomNavigationBar: showBottomBar
              ? SafeArea(
                  top: false,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withOpacity(0.12),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "To Pay",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "₹ ${grandTotal.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF207FA7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Get.to(
                                BookingScreen(cartTotalPrice: grandTotal),
                              );
                            },
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF207FA7),
                                    Color(0xFF2FA4D9),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF207FA7)
                                        .withOpacity(0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  "Continue to Booking",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,

          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    showBottomBar ? 110 : 20,
                  ),
                  child: _items.isEmpty
                      ? SizedBox(
                          height: Get.size.height * 0.8,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _isLoading
                                  ? DotWaveLoader(
                                      text: 'Loading cart..',
                                    )
                                  : Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 24),
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F8FB),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 90,
                                                width: 90,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.shopping_cart_outlined,
                                                  size: 50,
                                                  color: Color(0xFF207FA7),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              const Text(
                                                "Your cart is empty",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              const Text(
                                                "Looks like you haven’t added any service yet",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(() =>
                                                DashboardScreen(pageIndex: 0));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF207FA7),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              "Add Service",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            const SizedBox(height: 8),
                            AnimatedList(
                              key: _listKey,
                              initialItemCount: _items.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index, animation) {
                                return Column(
                                  children: [
                                    SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                      child: HeaderComponent(
                                        serviceModel: _items[index],
                                        function: (i) {
                                          removeItem(index);
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                /// PRICE DETAILS HEADER
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Price Details ($itemCount items)",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// BILLING CARD
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7FAFC),
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                        color: const Color(0xFFE6EBEF)),
                                  ),
                                  child: Column(
                                    children: [
                                      priceRow("Item Total", itemTotal),
                                      const SizedBox(height: 6),
                                      priceRow(
                                        "Coupon Discount",
                                        couponDiscount,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(height: 6),
                                      priceRow("Tax & Fee", tax),
                                      const SizedBox(height: 6),
                                      if (totalLabourCharge > 0)
                                        priceRow("Labour Charge", totalLabourCharge),                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        child: DottedBorder(
                                          color: const Color(0xFFD0D7DE),
                                          strokeWidth: 1,
                                          dashPattern: const [6, 4],
                                          customPath: (size) {
                                            return Path()
                                              ..moveTo(0, 0)
                                              ..lineTo(size.width, 0);
                                          },
                                          child: const SizedBox(
                                            width: double.infinity,
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                      priceRow(
                                        "Total Amount",
                                        grandTotal,
                                        isBold: true,
                                        color: const Color(0xFF207FA7),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Widget flipkartSummaryCard(DashBoardController controller) {
//   final cartModel = controller.cartModel;
//   final content = cartModel.content;
//   final cart = content?.cart;
//
//   double itemTotal = 0.0;
//   double discount = 0.0;
//   double couponDiscount = 0.0;
//   double tax = 0.0;
//   double mrpTotal = 0.0;
//
//   if (cart != null && cart.data != null && cart.data!.isNotEmpty) {
//     for (var item in cart.data!) {
//       double price = item.serviceCost.toDouble();
//       double qty = item.quantity!.toDouble();
//
//       // double mrp = (item.mrpPrice ?? item.serviceCost).toDouble();
//
//       itemTotal += price * qty;
//       // mrpTotal += mrp * qty;
//
//       discount += item.discountAmount.toDouble();
//       couponDiscount += item.couponDiscount.toDouble();
//       tax += item.taxAmount.toDouble();
//     }
//   }
//
//   double totalSaved = (mrpTotal - itemTotal) + couponDiscount;
//
//   return Container(
//     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(14),
//       boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Price Details",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const Divider(),
//         _row("MRP Total", mrpTotal),
//         _row("Selling Price", itemTotal),
//         _row("Product Discount", -(mrpTotal - itemTotal)),
//         _row("Coupon Discount", -couponDiscount),
//         _row("Tax", tax),
//         const Divider(),
//         _row("Total Payable", content?.totalCost?.toDouble() ?? 0,
//             isBold: true),
//         const SizedBox(height: 6),
//         Text(
//           "You saved ₹${totalSaved.toStringAsFixed(0)} on this order",
//           style:
//           const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
//         ),
//       ],
//     ),
//   );
// }

Widget _row(String title, double amount, {bool isBold = false, Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Text(
          "₹ ${amount.toStringAsFixed(0)}",
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    ),
  );
}

// import 'package:do_fix/app/views/bookingScreen/booking_screen.dart';
// import 'package:do_fix/app/views/home/home_screen.dart';
// import 'package:do_fix/widgets/custom_dot_loader.dart';
//
// // import 'package:do_fix/app/views/cart_screen/SubScreen/final_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // import 'package:get/get_core/src/get_main.dart';
//
// // import '../../../booking/add_more_service_bottom_sheet.dart';
// import '../../../controllers/dashboard_controller.dart';
// import '../../../model/service_model.dart';
// import '../../widgets/custom_appbar.dart';
// import '../dashboard/dashboard_screen.dart';
// import 'SubScreen/header_component.dart';
//
// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});
//
//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }
//
// class _CartScreenState extends State<CartScreen> {
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
//   List<CartItem?> _items = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(milliseconds: 200), () {
//       final data =
//           Get.find<DashBoardController>().cartModel.content?.cart?.data ?? [];
//       setState(() {
//         _items = [];
//       });
//       for (int i = 0; i < data.length; i++) {
//         Future.delayed(Duration(milliseconds: 150 * i), () {
//           _items.insert(i, data[i]);
//           _listKey.currentState?.insertItem(i);
//         });
//       }
//
//       // Show loader for 3 seconds before showing empty cart message
//       Future.delayed(const Duration(seconds: 3), () {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       });
//     });
//   }
//
//   void removeItem(int index) {
//     final removedItem = _items[index];
//     _items.removeAt(index);
//     _listKey.currentState?.removeItem(
//       index,
//       (context, animation) => SlideTransition(
//         position: Tween<Offset>(
//           begin: Offset.zero,
//           end: const Offset(1.0, 0.0), // slide out to right
//         ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
//         child: FadeTransition(
//           opacity: animation,
//           child: HeaderComponent(
//             serviceModel: removedItem,
//             function: (index) {},
//           ),
//         ),
//       ),
//       duration: const Duration(milliseconds: 400),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<DashBoardController>(builder: (controller) {
//       return SafeArea(
//         top: false,
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           appBar: CustomAppBar(
//             title: "Cart",
//             isBackButtonExist: true,
//             isSearchButtonExist: false,
//             isCartButtonExist: false,
//             showNotificationIcon: false,
//           ),
//           body: SingleChildScrollView(
//             child: _items.isEmpty
//                 ? SizedBox(
//                     height: Get.size.height * 0.8,
//                     width: Get.size.width,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         _isLoading
//                             ? DotWaveLoader(
//                                 text: 'Loading cart..',
//                               )
//                             : Column(
//                                 children: [
//                                   /// EMPTY CARD
//                                   Container(
//                                     margin: const EdgeInsets.symmetric(
//                                         horizontal: 24),
//                                     padding: const EdgeInsets.all(24),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFFF4F8FB),
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     child: Column(
//                                       children: [
//                                         Container(
//                                           height: 90,
//                                           width: 90,
//                                           decoration: const BoxDecoration(
//                                             color: Colors.white,
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: const Icon(
//                                             Icons.shopping_cart_outlined,
//                                             size: 50,
//                                             color: Color(0xFF207FA7),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 16),
//                                         const Text(
//                                           "Your cart is empty",
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 6),
//                                         const Text(
//                                           "Looks like you haven’t added any service yet",
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//
//                                   const SizedBox(height: 24),
//
//                                   /// ADD SERVICE BUTTON
//                                   GestureDetector(
//                                     onTap: () {
//                                       Get.to(
//                                           () => DashboardScreen(pageIndex: 0));
//                                     },
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 32, vertical: 12),
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFF207FA7),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: const Text(
//                                         "Add Service",
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                       ],
//                     ),
//                   )
//
//                 /// ===================== CART LIST ======================
//                 : Column(
//                     children: [
//                       const SizedBox(height: 22),
//
//                       /// CART ITEMS LIST
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Container(
//                           width: Get.size.width,
//                           color: Colors.white,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: AnimatedList(
//                               key: _listKey,
//                               initialItemCount: _items.length,
//                               physics: const NeverScrollableScrollPhysics(),
//                               shrinkWrap: true,
//                               itemBuilder: (context, index, animation) {
//                                 return Column(
//                                   children: [
//                                     SlideTransition(
//                                       position: Tween<Offset>(
//                                         begin: const Offset(1.0, 0.0),
//                                         end: Offset.zero,
//                                       ).animate(CurvedAnimation(
//                                         parent: animation,
//                                         curve: Curves.easeOut,
//                                       )),
//                                       child: HeaderComponent(
//                                         serviceModel: _items[index],
//                                         function: (i) {
//                                           removeItem(index);
//                                         },
//                                       ),
//                                     ),
//                                     const SizedBox(height: 6),
//                                   ],
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       ///  BILLING SUMMARY
//                       GetBuilder<DashBoardController>(
//                         builder: (controller) {
//                           final cartModel = controller.cartModel;
//                           final content = cartModel.content;
//                           final cart = content?.cart;
//
//                           double itemTotal = 0.0;
//                           double discount = 0.0;
//                           double couponDiscount = 0.0;
//
//                           /// API se tax
//                           double tax = (content?.taxAmount ?? 0).toDouble();
//
//                           if (cart != null &&
//                               cart.data != null &&
//                               cart.data!.isNotEmpty) {
//                             final items = cart.data!;
//
//                             for (var item in items) {
//                               itemTotal += (item.serviceCost.toDouble() *
//                                   item.quantity!.toDouble());
//
//                               discount += item.discountAmount.toDouble();
//                               couponDiscount += item.couponDiscount.toDouble();
//                             }
//                           }
//
//                           final double grandTotal =
//                               (content?.totalCost ?? 0).toDouble() + tax;
//
//                           final double wallet =
//                               (content?.walletBalance ?? 0).toDouble();
//
//                           final double referral =
//                               (content?.referralAmount ?? 0).toDouble();
//
//                           Widget priceRow(String title, double amount,
//                               {bool isBold = false, Color? color}) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 2, horizontal: 20),
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     title,
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: isBold
//                                           ? FontWeight.bold
//                                           : FontWeight.normal,
//                                     ),
//                                   ),
//                                   const Spacer(),
//                                   Text(
//                                     "₹ ${amount.toStringAsFixed(0)}",
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: isBold
//                                           ? FontWeight.bold
//                                           : FontWeight.normal,
//                                       color: color ?? Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }
//
//                           return Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 18),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(30),
//                                 topRight: Radius.circular(30),
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.08),
//                                   blurRadius: 20,
//                                   offset: const Offset(0, -5),
//                                 )
//                               ],
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 /// HEADER
//                                 Row(
//                                   children: const [
//                                     Icon(Icons.receipt_long,
//                                         color: Color(0xFF207FA7)),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       "Billing Details",
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 const SizedBox(height: 14),
//
//                                 /// CARD BOX
//                                 Container(
//                                   padding: const EdgeInsets.all(14),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFF7FAFC),
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       priceRow("Item Total", itemTotal),
//                                       priceRow(
//                                           "Coupon Discount", couponDiscount,
//                                           color: Colors.green),
//                                       priceRow("Tax & Fee", tax),
//                                       const Divider(height: 20),
//                                       priceRow("Total Amount", grandTotal,
//                                           isBold: true),
//                                     ],
//                                   ),
//                                 ),
//
//                                 /// WALLET + REFERRAL
//                                 if (wallet > 0 || referral > 0) ...[
//                                   const SizedBox(height: 10),
//                                   Container(
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFFEAF7EF),
//                                       borderRadius: BorderRadius.circular(14),
//                                     ),
//                                     child: Column(
//                                       children: [
//                                         if (wallet > 0)
//                                           priceRow("Wallet Used", -wallet,
//                                               color: Colors.green),
//                                         if (referral > 0)
//                                           priceRow("Referral Used", -referral,
//                                               color: Colors.green),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//
//                                 const SizedBox(height: 14),
//
//                                 /// TOTAL PAY BAR
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 14, vertical: 12),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF207FA7)
//                                         .withOpacity(0.08),
//                                     borderRadius: BorderRadius.circular(14),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       const Text(
//                                         "To Pay",
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.black54,
//                                         ),
//                                       ),
//                                       const Spacer(),
//                                       Text(
//                                         "₹ ${grandTotal.toStringAsFixed(0)}",
//                                         style: const TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                           color: Color(0xFF207FA7),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//
//                                 const SizedBox(height: 18),
//
//                                 /// CONTINUE BUTTON
//                                 InkWell(
//                                   borderRadius: BorderRadius.circular(14),
//                                   onTap: () {
//                                     Get.to(
//                                       BookingScreen(cartTotalPrice: grandTotal),
//                                     );
//                                   },
//                                   child: Container(
//                                     height: 54,
//                                     decoration: BoxDecoration(
//                                       gradient: const LinearGradient(
//                                         colors: [
//                                           Color(0xFF207FA7),
//                                           Color(0xFF2FA4D9),
//                                         ],
//                                       ),
//                                       borderRadius: BorderRadius.circular(14),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: const Color(0xFF207FA7)
//                                               .withOpacity(0.4),
//                                           blurRadius: 12,
//                                           offset: const Offset(0, 6),
//                                         ),
//                                       ],
//                                     ),
//                                     child: const Center(
//                                       child: Text(
//                                         "Continue to Booking",
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                           letterSpacing: 0.3,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//
//                                 const SizedBox(height: 6),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//           ),
//         ),
//       );
//     });
//   }
// }
//
// Widget flipkartSummaryCard(DashBoardController controller) {
//   final cartModel = controller.cartModel;
//   final content = cartModel.content;
//   final cart = content?.cart;
//
//   double itemTotal = 0.0;
//   double discount = 0.0;
//   double couponDiscount = 0.0;
//   double tax = 0.0;
//   double mrpTotal = 0.0;
//
//   if (cart != null && cart.data != null && cart.data!.isNotEmpty) {
//     for (var item in cart.data!) {
//       double price = item.serviceCost.toDouble();
//       double qty = item.quantity!.toDouble();
//
//       // double mrp = (item.mrpPrice ?? item.serviceCost).toDouble();
//
//       itemTotal += price * qty;
//       // mrpTotal += mrp * qty;
//
//       discount += item.discountAmount.toDouble();
//       couponDiscount += item.couponDiscount.toDouble();
//       tax += item.taxAmount.toDouble();
//     }
//   }
//
//   double totalSaved = (mrpTotal - itemTotal) + couponDiscount;
//
//   return Container(
//     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(14),
//       boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Price Details",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const Divider(),
//         _row("MRP Total", mrpTotal),
//         _row("Selling Price", itemTotal),
//         _row("Product Discount", -(mrpTotal - itemTotal)),
//         _row("Coupon Discount", -couponDiscount),
//         _row("Tax", tax),
//         const Divider(),
//         _row("Total Payable", content?.totalCost?.toDouble() ?? 0,
//             isBold: true),
//         const SizedBox(height: 6),
//         Text(
//           "You saved ₹${totalSaved.toStringAsFixed(0)} on this order",
//           style:
//               const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
//         ),
//       ],
//     ),
//   );
// }
//
// Widget _row(String title, double amount, {bool isBold = false, Color? color}) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 3),
//     child: Row(
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         const Spacer(),
//         Text(
//           "₹ ${amount.toStringAsFixed(0)}",
//           style: TextStyle(
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             color: color ?? Colors.black,
//           ),
//         ),
//       ],
//     ),
//   );
// }
