import 'package:do_fix/model/service_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/dashboard_controller.dart';
import '../../../../widgets/custom_image_viewer.dart';

class HeaderComponent extends StatefulWidget {
  final CartItem? serviceModel;
  final Function(dynamic index) function;
  const HeaderComponent({
    super.key,
    required this.serviceModel,
    required this.function,
  });

  @override
  State<HeaderComponent> createState() => _HeaderComponentState();
}

class _HeaderComponentState extends State<HeaderComponent> {
  int quantity = 0;
  @override
  void initState() {
    super.initState();
    quantity =
        int.tryParse((widget.serviceModel?.quantity ?? "0").toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(builder: (controller) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Align items at the top
                  children: [
                    CustomNetworkImageWidget(
                      image: widget.serviceModel?.category?.imageFullPath ?? "",
                      height: 60.0, // Fixed height instead of double.infinity
                      width: 69.0,
                    ),
                    const SizedBox(width: 10),
                    // Add spacing between image and text
                    Flexible(
                      // Prevents Row layout error
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        // Avoids unnecessary expansion
                        children: [
                          Text(
                            widget.serviceModel?.category?.name ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          // const SizedBox(height: 5),
                          const SizedBox(height: 5),
                          Text(
                            widget.serviceModel?.variantKey ?? "N/A",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "₹${(double.tryParse((widget.serviceModel?.serviceCost ?? "0").toString())?.toInt() ?? 0)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF207FA7),
                                ),
                              ),
                              // SizedBox(
                              //   width: 5,
                              // ),
                              // Text(
                              //   "₹${(double.tryParse((widget.serviceModel?.discountAmount ?? "0").toString())?.toInt() ?? 0)}",
                              //   style: TextStyle(
                              //     fontSize: 12,
                              //     fontWeight: FontWeight.w400,
                              //     decoration: TextDecoration.lineThrough,
                              //     color: Colors.black
                              //         .withAlpha((0.53 * 255).toInt()),
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),

                          const SizedBox(height: 5),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Expanded(
                          //       child: Text(
                          //         "Tax",
                          //         maxLines: 1,
                          //         overflow: TextOverflow.ellipsis,
                          //         style: const TextStyle(fontSize: 14),
                          //       ),
                          //     ),
                          //     Text(
                          //       "(+) ₹ ${(double.tryParse((widget.serviceModel?.taxAmount ?? "0").toString())?.toInt() ?? 0)}",
                          //       style: const TextStyle(
                          //         fontSize: 14,
                          //         fontWeight: FontWeight.bold,
                          //         color: Color(0xFF207FA7),
                          //       ),
                          //     ),
                          //     SizedBox(
                          //       width: 10,
                          //     )
                          //   ],
                          // ),
                          // const SizedBox(height: 5),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Expanded(
                          //       child: Text(
                          //         "Total Price",
                          //         maxLines: 1,
                          //         overflow: TextOverflow.ellipsis,
                          //         style: const TextStyle(fontSize: 14),
                          //       ),
                          //     ),
                          //     Text(
                          //       "₹ ${(double.tryParse((widget.serviceModel?.totalCost ?? "0").toString())?.toInt() ?? 0)}",
                          //       style: const TextStyle(
                          //         fontSize: 14,
                          //         fontWeight: FontWeight.bold,
                          //         color: Color(0xFF207FA7),
                          //       ),
                          //     ),
                          //     SizedBox(
                          //       width: 10,
                          //     )
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                height: 30,
                decoration: ShapeDecoration(
                  color: const Color(0x19207FA7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () {
                          // Handle decrement action
                          if (widget.serviceModel?.quantity != null &&
                              quantity > 1) {
                            setState(() {
                              quantity = quantity - 1;
                            });
                            Get.find<DashBoardController>().updateQuantity(
                              quantity.toString(),
                              widget.serviceModel?.id ?? "",
                            );
                          } else {
                            Get.dialog(
                              AlertDialog(
                                titlePadding: const EdgeInsets.all(15),
                                title: const Text("Are you sure?"),
                                content: const Text(
                                    "Do you want to remove this item?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(), // Cancel
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .red, // Change to match your theme
                                    ),
                                    onPressed: () {
                                      Get.back(); // Close the dialog first
                                      Get.find<DashBoardController>()
                                          .removeItem(
                                              widget.serviceModel?.id ?? "");
                                      widget.function(
                                          widget.serviceModel?.id ?? "");
                                    },
                                    child: const Text("Remove",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                              barrierDismissible: false,
                            );
                          }
                        },
                        child: Icon(
                          size: 12,
                          quantity == 1 ? Icons.remove : Icons.remove,
                          color: quantity == 1
                              ? Color(0xFF207FA7)
                              : Color(0xFF207FA7),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
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
                        "$quantity",
                        key: ValueKey(
                            quantity), // Trigger reanimation when quantity changes
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF207FA7),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: () {
                          if (quantity < 100) {
                            setState(() {
                              quantity = quantity + 1;
                            });
                            Get.find<DashBoardController>().updateQuantity(
                              quantity.toString(),
                              widget.serviceModel?.id ?? "",
                            );
                          }
                        },
                        child: Icon(
                          size: 12,
                          Icons.add,
                          color: Color(0xFF207FA7),
                        )),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
        ],
      );
    });
  }
}
