import 'package:do_fix/app/views/bookingScreen/booking_screen.dart';
import 'package:do_fix/app/views/cart_screen/SubScreen/final_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../booking/add_more_service_bottom_sheet.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../model/service_model.dart';
import '../../widgets/custom_appbar.dart';
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
          ),
          body: _items.isEmpty
              ? Container(
                  height: Get.size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _isLoading
                          ? Center(
                              child: SizedBox(
                                height: 300,
                                width: 300,
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(
                                      color: Color(0xFF207FA7),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Loading cart...",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Cart is Empty!",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                    ],
                  ),
                )
              : Visibility(
                  visible: _items.isNotEmpty,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 22,
                        ),
                        //add more service
                        // GestureDetector(
                        //   onTap: () {
                        //     showModalBottomSheet(
                        //       context: context,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        //       ),
                        //       builder: (_) {
                        //         return AddMoreServiceBottomSheet();
                        //       },
                        //     );// user ko service list par le jao
                        //   },
                        //   child: Padding(
                        //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        //     child: Row(
                        //       children: const [
                        //         Icon(Icons.add, color: Color(0xFF207FA7)),
                        //         SizedBox(width: 6),
                        //         Text(
                        //           "Add more services",
                        //           style: TextStyle(
                        //             color: Color(0xFF207FA7),
                        //             fontSize: 14,
                        //             fontWeight: FontWeight.w500,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        Padding 
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            width: Get.size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
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
                                          }, // trigger removal
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: _items.isNotEmpty
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
                          border: BoxBorder.all(
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
                          //             child: child,
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
                          // Divider(
                          //   thickness: 3,
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
                                  "₹ ${controller.cartModel.content?.totalCost}",
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
                                        cartTotalPrice: double.tryParse(
                                                controller.cartModel.content
                                                        ?.totalCost
                                                        .toString() ??
                                                    "0.0") ??
                                            0.0,
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
    });
  }
}
