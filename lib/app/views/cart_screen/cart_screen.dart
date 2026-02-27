import 'package:do_fix/app/views/bookingScreen/booking_screen.dart';
import 'package:do_fix/app/views/home/home_screen.dart';
// import 'package:do_fix/app/views/cart_screen/SubScreen/final_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';

// import '../../../booking/add_more_service_bottom_sheet.dart';
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
    return GetBuilder<DashBoardController>(builder: (controller) {
      return SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: "Cart",
            isBackButtonExist: true,
            isSearchButtonExist: false,
            isCartButtonExist: false,
            showNotificationIcon: false,
          ),
          body: SingleChildScrollView(
            child: _items.isEmpty
                ? SizedBox(
              height: Get.size.height * 0.8,
              width: Get.size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isLoading
                      ? Column(
                    children: const [
                      CircularProgressIndicator(
                        color: Color(0xFF207FA7),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Loading cart...",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                      : Column(
                    children: [
                      /// EMPTY CARD
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F8FB),
                          borderRadius: BorderRadius.circular(16),
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

                      /// ADD SERVICE BUTTON
                      GestureDetector(
                        onTap: () {
                          Get.to(() => DashboardScreen(pageIndex: 0));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF207FA7),
                            borderRadius: BorderRadius.circular(8),
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

            /// ===================== CART LIST ======================
                : Column(
              children: [
                const SizedBox(height: 22),

                /// CART ITEMS LIST
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    width: Get.size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedList(
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
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOut,
                                )),
                                child: HeaderComponent(
                                  serviceModel: _items[index],
                                  function: (i) {
                                    removeItem(index);
                                  },
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                ///  BILLING SUMMARY (SCROLLABLE NOW)
                GetBuilder<DashBoardController>(
                  builder: (controller) {
                    final cartModel = controller.cartModel;
                    final content = cartModel.content;
                    final cart = content?.cart;

                    double itemTotal = 0.0;
                    double discount = 0.0;
                    double couponDiscount = 0.0;
                    double tax = 0.0;

                    if (cart != null && cart.data != null && cart.data!.isNotEmpty) {
                      final items = cart.data!;

                      for (var item in items) {
                        itemTotal += (item.serviceCost.toDouble() *
                            item.quantity?.toDouble());

                        discount += item.discountAmount.toDouble();
                        couponDiscount += item.couponDiscount.toDouble();
                        tax += item.taxAmount.toDouble();
                      }
                    }

                    final double grandTotal =
                        (content?.totalCost ?? 0).toDouble() + tax;

                    final double wallet =
                    (content?.walletBalance ?? 0).toDouble();

                    final double referral =
                    (content?.referralAmount ?? 0).toDouble();

                    Widget priceRow(String title, double amount,
                        {bool isBold = false, Color? color}) {
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                isBold ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "₹ ${amount.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                isBold ? FontWeight.bold : FontWeight.normal,
                                color: color ?? Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          /// HEADER
                          Row(
                            children: const [
                              Icon(Icons.receipt_long, color: Color(0xFF207FA7)),
                              SizedBox(width: 8),
                              Text(
                                "Billing Details",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          /// 🔷 CARD BOX
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAFC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                priceRow("Item Total", itemTotal),
                                priceRow("Coupon Discount", couponDiscount, color: Colors.green),
                                priceRow("Tax & Fee", tax),

                                const Divider(height: 20),

                                priceRow("Total Amount", grandTotal, isBold: true),
                              ],
                            ),
                          ),

                          /// 🔷 WALLET + REFERRAL
                          if (wallet > 0 || referral > 0) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF7EF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  if (wallet > 0)
                                    priceRow("Wallet Used", -wallet, color: Colors.green),
                                  if (referral > 0)
                                    priceRow("Referral Used", -referral, color: Colors.green),
                                ],
                              ),
                            ),
                          ],

                          // const SizedBox(height: 8),

                          // /// 🔷 SAVING TEXT
                          // Text(
                          //   "You saved ₹${(discount + couponDiscount).toStringAsFixed(0)} on this order",
                          //   style: const TextStyle(
                          //     color: Colors.green,
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),

                          const SizedBox(height: 14),

                          /// 🔷 TOTAL PAY BAR
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF207FA7).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "To Pay",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "₹ ${grandTotal.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF207FA7),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          /// 🔷 CONTINUE BUTTON (MODERN)
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Get.to(BookingScreen(cartTotalPrice: grandTotal));
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
                                    color: const Color(0xFF207FA7).withOpacity(0.4),
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }
}



Widget flipkartSummaryCard(DashBoardController controller) {
  final cartModel = controller.cartModel;
  final content = cartModel.content;
  final cart = content?.cart;

  double itemTotal = 0.0;
  double discount = 0.0;
  double couponDiscount = 0.0;
  double tax = 0.0;
  double mrpTotal = 0.0;

  if (cart != null && cart.data != null && cart.data!.isNotEmpty) {
    for (var item in cart.data!) {
      double price = item.serviceCost.toDouble();
      double qty = item.quantity!.toDouble();

      // double mrp = (item.mrpPrice ?? item.serviceCost).toDouble();

      itemTotal += price * qty;
      // mrpTotal += mrp * qty;

      discount += item.discountAmount.toDouble();
      couponDiscount += item.couponDiscount.toDouble();
      tax += item.taxAmount.toDouble();
    }
  }

  double totalSaved = (mrpTotal - itemTotal) + couponDiscount;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(color: Colors.grey.shade200, blurRadius: 6)
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Price Details",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const Divider(),

        _row("MRP Total", mrpTotal),
        _row("Selling Price", itemTotal),
        _row("Product Discount", -(mrpTotal - itemTotal)),
        _row("Coupon Discount", -couponDiscount),
        _row("Tax", tax),

        const Divider(),

        _row("Total Payable", content?.totalCost?.toDouble() ?? 0,
            isBold: true),

        const SizedBox(height: 6),

        Text(
          "You saved ₹${totalSaved.toStringAsFixed(0)} on this order",
          style: const TextStyle(
              color: Colors.green, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

Widget _row(String title, double amount,
    {bool isBold = false, Color? color}) {
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
