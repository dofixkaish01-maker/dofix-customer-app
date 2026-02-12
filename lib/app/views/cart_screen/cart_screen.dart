import 'package:do_fix/app/views/bookingScreen/booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../widgets/custom_appbar.dart';
import 'SubScreen/header_component.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  // List<CartItem?> _items = [];
  // bool isCartLoading = true;
  //
  // @override
  // void initState() {
  //   super.initState();
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final controller = Get.find<DashBoardController>();
  //
  //     final data =
  //         controller.cartModel.content?.cart?.data ?? [];
  //
  //     if (!mounted) return;
  //
  //     setState(() {
  //       _items.clear();
  //       isCartLoading = false; // Loader immediately off (no fake delay)
  //     });
  //
  //     for (int i = 0; i < data.length; i++) {
  //       _items.add(data[i]);
  //       _listKey.currentState?.insertItem(i,
  //           duration: const Duration(milliseconds: 300));
  //     }
  //   });
  // }
  //
  // void removeItem(int index) {
  //   final removedItem = _items[index];
  //   _items.removeAt(index);
  //   _listKey.currentState?.removeItem(
  //     index,
  //     (context, animation) => SlideTransition(
  //       position: Tween<Offset>(
  //         begin: Offset.zero,
  //         end: const Offset(1.0, 0.0), // slide out to right
  //       ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
  //       child: FadeTransition(
  //         opacity: animation,
  //         child: HeaderComponent(
  //           serviceModel: removedItem,
  //           function: (index) {},
  //         ),
  //       ),
  //     ),
  //     duration: const Duration(milliseconds: 400),
  //   );
  // }

  Widget priceDetailsSection(DashBoardController controller) {

    final subTotal = controller.subTotal;
    final discount = controller.discount;
    final tax = controller.vat;
    final total = controller.cartModel.content?.totalCost ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "PRICE DETAILS",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 15),

          _priceRow("Price", subTotal),
          const SizedBox(height: 8),

          _priceRow("Discount", -discount, isDiscount: true),
          const SizedBox(height: 8),

          _priceRow("Tax", tax),
          const SizedBox(height: 12),

          const Divider(),

          const SizedBox(height: 10),

          _priceRow("Total Amount", total, isBold: true),

          if (discount > 0) ...[
            const SizedBox(height: 8),
            Text(
              "You saved ₹${discount.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]
        ],
      ),
    );
  }
  Widget _priceRow(
      String title,
      double value, {
        bool isDiscount = false,
        bool isBold = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          "${value < 0 ? "- " : ""}₹ ${value.abs().toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isDiscount ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashBoardController>();
    final cartItems = controller.cartModel.content?.cart?.data ?? [];
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
          body: cartItems.isEmpty
              ? _buildEmptyCart()
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: HeaderComponent(
                  serviceModel: cartItems[index],
                  // function: (i) {
                  //   controller.removeItem(
                  //     cartItems[index].id.toString(),
                  //   );
                  // },
                  function: (i) async {
                    final id = cartItems[index].id;
                    if (id != null) {
                      await controller.removeItem(id.toString());
                    }
                  },

                ),
              );
            },
          ),
          bottomNavigationBar: cartItems.isNotEmpty
              ? GetBuilder<DashBoardController>(
                  builder: (controller) {
                    return Container(
                      width: double.infinity,
                      height: 130,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                          border: Border.all(
                            color: Color(0xFFB8B8B8),
                            width: 1,
                          )),
                      child: Column(
                        children: [
                          // Row(
                          //   children: [
                          //     const SizedBox(width: 20),
                          //     Text(
                          //       'Discount',
                          //       style: TextStyle(
                          //         color: Colors.black.withAlpha(128),
                          //         fontSize: 12,
                          //         fontFamily: 'Albert Sans',
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //     ),
                          //     const Spacer(),
                          //     AnimatedSwitcher(
                          //       duration: const Duration(milliseconds: 400),
                          //       transitionBuilder: (Widget child,
                          //           Animation<double> animation) {
                          //         return SlideTransition(
                          //           position: Tween<Offset>(
                          //             begin: const Offset(0.0, 0.5),
                          //             end: Offset.zero,
                          //           ).animate(animation),
                          //           child: FadeTransition(
                          //             opacity: animation,
                          //             child: child,F
                          //           ),
                          //         );
                          //       },
                          //       child: Text(
                          //         "(-) ₹ ${controller.discount}",
                          //         key: ValueKey(controller
                          //             .discount), // Trigger reanimation when quantity changes
                          //         style: const TextStyle(
                          //           fontSize: 14,
                          //           fontWeight: FontWeight.bold,
                          //           color: Color(0xFF207FA7),
                          //         ),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 20),
                          //   ],
                          // ),
                          // Row(
                          //   children: [
                          //     const SizedBox(width: 20),
                          //     Text(
                          //       'Tax',
                          //       style: TextStyle(
                          //         color: Colors.black.withAlpha(128),
                          //         fontSize: 12,
                          //         fontFamily: 'Albert Sans',
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //     ),
                          //     const Spacer(),
                          //     AnimatedSwitcher(
                          //       duration: const Duration(milliseconds: 400),
                          //       transitionBuilder: (Widget child,
                          //           Animation<double> animation) {
                          //         return SlideTransition(
                          //           position: Tween<Offset>(
                          //             begin: const Offset(0.0, 0.5),
                          //             end: Offset.zero,
                          //           ).animate(animation),
                          //           child: FadeTransition(
                          //             opacity: animation,
                          //             child: child,
                          //           ),
                          //         );
                          //       },
                          //       child: Text(
                          //         "(+) ₹ ${controller.vat}",
                          //         key: ValueKey(controller
                          //             .vat), // Trigger reanimation when quantity changes
                          //         style: const TextStyle(
                          //           fontSize: 14,
                          //           fontWeight: FontWeight.bold,
                          //           color: Color(0xFF207FA7),
                          //         ),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 20),
                          //   ],
                          // ),
                          // Row(
                          //   children: [
                          //     const SizedBox(width: 20),
                          //     Text(
                          //       'Sub Total:',
                          //       style: TextStyle(
                          //         color: Colors.black.withAlpha(128),
                          //         fontSize: 12,
                          //         fontFamily: 'Albert Sans',
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //     ),
                          //     const Spacer(),
                          //     AnimatedSwitcher(
                          //       duration: const Duration(milliseconds: 400),
                          //       transitionBuilder: (Widget child,
                          //           Animation<double> animation) {
                          //         return SlideTransition(
                          //           position: Tween<Offset>(
                          //             begin: const Offset(0.0, 0.5),
                          //             end: Offset.zero,
                          //           ).animate(animation),
                          //           child: FadeTransition(
                          //             opacity: animation,
                          //             child: child,
                          //           ),
                          //         );
                          //       },
                          //       child: Text(
                          //         "₹ ${controller.subTotal}",
                          //         key: ValueKey(controller
                          //             .subTotal), // Trigger reanimation when quantity changes
                          //         style: const TextStyle(
                          //           fontSize: 14,
                          //           fontWeight: FontWeight.bold,
                          //           color: Color(0xFF207FA7),
                          //         ),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 20),
                          //   ],
                          // ),
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              Text(
                                'Amount to Pay',
                                style: TextStyle(
                                  color: Colors.black.withAlpha(128),
                                  fontSize: 14,
                                  fontFamily: 'Albert Sans',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.5),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  "₹ ${(controller.cartModel.content?.totalCost ?? 0).toStringAsFixed(2)}",
                                  key: ValueKey(
                                      controller.cartModel.content?.totalCost),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF207FA7),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      debugPrint("Continue");
                                      Get.to(BookingScreen(
                                        cartTotalPrice:
                                        controller.cartModel.content?.totalCost ?? 0.0,
                                      ));
                                      // showBookingSheet(context);
                                    },
                                    child: Container(
                                      height: 50,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF207FA7),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Continue',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'Albert Sans',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : null,
        ),
      );
    }
  }
Widget _buildEmptyCart() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shopping_cart_outlined,
            size: 70, color: Color(0xFF207FA7)),
        const SizedBox(height: 16),
        const Text(
          "Your cart is empty",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
