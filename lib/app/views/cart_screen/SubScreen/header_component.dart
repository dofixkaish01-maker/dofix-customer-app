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
  double parse(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  late final labourCharge = parse(widget.serviceModel?.service?['labour_charge']);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(builder: (controller) {
      return GestureDetector(
        onTap: () async {
          await Get.find<DashBoardController>()
              .getServicesDetails(widget.serviceModel?.serviceId ?? "");
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF207FA7).withOpacity(0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE + DETAILS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE
                  Container(
                    height: 100,
                    width: 100,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomNetworkImageWidget(
                        image:
                            widget.serviceModel?.category?.imageFullPath ?? "",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// CATEGORY NAME
                        Text(
                          widget.serviceModel?.category?.name ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        /// VARIANT
                        Text(
                          widget.serviceModel?.variantKey ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// PRICE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₹${(double.tryParse((widget.serviceModel?.serviceCost ?? "0").toString())?.toInt() ?? 0)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF207FA7),
                                  ),
                                ),
                              ],
                            ),

                            /// Labour Charge (only if exists)
                            if (labourCharge > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "+ ₹${labourCharge.toStringAsFixed(0)} labour charge",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// QUANTITY + VIEW DETAILS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// QUANTITY CONTROLLER
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5FAFD),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF207FA7)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _circleButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (widget.serviceModel?.quantity != null &&
                                quantity > 1) {
                              setState(() => quantity--);

                              Get.find<DashBoardController>().updateQuantity(
                                quantity.toString(),
                                widget.serviceModel?.id ?? "",
                              );
                            } else {
                              /// REMOVE DIALOG
                              Get.dialog(
                                Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          "Remove Item?",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          "Do you want to remove this item from your cart?",
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                },
                                                child: const Text("Cancel"),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop();

                                                  Get.find<
                                                          DashBoardController>()
                                                      .removeItem(widget
                                                              .serviceModel
                                                              ?.id ??
                                                          "");

                                                  widget.function(null);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: const Text("Remove"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                barrierDismissible: false,
                              );
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            "$quantity",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF207FA7),
                            ),
                          ),
                        ),
                        _circleButton(
                          icon: Icons.add,
                          onTap: () {
                            if (quantity < 100) {
                              setState(() => quantity++);

                              Get.find<DashBoardController>().updateQuantity(
                                quantity.toString(),
                                widget.serviceModel?.id ?? "",
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  /// VIEW DETAILS
                  GestureDetector(
                    onTap: () async {
                      await Get.find<DashBoardController>().getServicesDetails(
                          widget.serviceModel?.serviceId ?? "");
                    },
                    child: Row(
                      children: const [
                        Text(
                          "View Details",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF207FA7),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFF207FA7),
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
    });
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFF207FA7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

// class HeaderComponent extends StatefulWidget {
//   final CartItem? serviceModel;
//   final Function(dynamic index) function;
//
//   const HeaderComponent({
//     super.key,
//     required this.serviceModel,
//     required this.function,
//   });
//
//   @override
//   State<HeaderComponent> createState() => _HeaderComponentState();
// }
//
// class _HeaderComponentState extends State<HeaderComponent> {
//   int quantity = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     quantity =
//         int.tryParse((widget.serviceModel?.quantity ?? "0").toString()) ?? 0;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<DashBoardController>(builder: (controller) {
//       return GestureDetector(
//         onTap: () async {
//           await Get.find<DashBoardController>()
//               .getServicesDetails(widget.serviceModel?.serviceId ?? "");
//         },
//         child: Container(
//           height: 240,
//           width: double.infinity,
//           margin: const EdgeInsets.symmetric(vertical: 2),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(
//               color: const Color(0xFF207FA7).withOpacity(0.5),
//               // primary color, thoda halki shade
//               width: 1.2,
//             ),
//             boxShadow: [
//               // main shadow
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.12),
//                 // thoda zyada visible shadow
//                 blurRadius: 12,
//                 // spread out blur
//                 spreadRadius: 1,
//                 offset: const Offset(0, 6), // bottom shadow
//               ),
//               // light top highlight
//               BoxShadow(
//                 color: Colors.white.withOpacity(0.7),
//                 blurRadius: 6,
//                 offset: const Offset(0, -2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// IMAGE
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     height: 160,
//                     width: 140,
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF3F4F6), // soft grey
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: CustomNetworkImageWidget(
//                       image: widget.serviceModel?.category?.imageFullPath ?? "",
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//
//                   /// DETAILS
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.serviceModel?.category?.name ?? "",
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           widget.serviceModel?.variantKey ?? "",
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "₹${(double.tryParse((widget.serviceModel?.serviceCost ?? "0").toString())?.toInt() ?? 0)}",
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF207FA7),
//                           ),
//                         ),
//
//                         // working*********
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//
//               /// QUANTITY CONTROLLER (BIG & CLICKABLE)
//               /// ~~~~~~~~~~
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     height: 40,
//                     padding: const EdgeInsets.symmetric(horizontal: 6),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF5FAFD),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: const Color(0xFF207FA7)),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         _circleButton(
//                           icon: Icons.remove,
//                           onTap: () {
//                             if (widget.serviceModel?.quantity != null &&
//                                 quantity > 1) {
//                               setState(() => quantity--);
//                               Get.find<DashBoardController>().updateQuantity(
//                                 quantity.toString(),
//                                 widget.serviceModel?.id ?? "",
//                               );
//                             } else {
//                               Get.dialog(
//                                 Dialog(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   elevation: 10,
//                                   backgroundColor: Colors.white,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(20),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         const Text(
//                                           "Remove Item?",
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 12),
//                                         const Text(
//                                           "Do you want to remove this item from your cart?",
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.black54,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 20),
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: OutlinedButton(
//                                                 onPressed: () {
//                                                   // Close the dialog safely
//                                                   Navigator.of(context,
//                                                           rootNavigator: true)
//                                                       .pop();
//                                                 }, // Cancel
//                                                 style: OutlinedButton.styleFrom(
//                                                   side: const BorderSide(
//                                                       color: Colors.grey),
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             8),
//                                                   ),
//                                                   padding: const EdgeInsets
//                                                       .symmetric(vertical: 12),
//                                                 ),
//                                                 child: const Text(
//                                                   "Cancel",
//                                                   style: TextStyle(
//                                                       color: Colors.black87),
//                                                 ),
//                                               ),
//                                             ),
//                                             const SizedBox(width: 12),
//                                             Expanded(
//                                               child: ElevatedButton(
//                                                 onPressed: () {
//                                                   //  Close dialog safely
//                                                   Navigator.of(context,
//                                                           rootNavigator: true)
//                                                       .pop();
//
//                                                   //  Remove item from controller
//                                                   Get.find<
//                                                           DashBoardController>()
//                                                       .removeItem(widget
//                                                               .serviceModel
//                                                               ?.id ??
//                                                           "");
//
//                                                   //  Trigger parent function for AnimatedList remove
//                                                   widget.function(null);
//                                                 },
//                                                 style: ElevatedButton.styleFrom(
//                                                   backgroundColor: Colors.red,
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             8),
//                                                   ),
//                                                   padding: const EdgeInsets
//                                                       .symmetric(vertical: 12),
//                                                 ),
//                                                 child: const Text(
//                                                   "Remove",
//                                                   style: TextStyle(
//                                                       color: Colors.white),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 barrierDismissible: false,
//                               );
//                             }
//                           },
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 14),
//                           child: Text(
//                             "$quantity",
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               color: Color(0xFF207FA7),
//                             ),
//                           ),
//                         ),
//                         _circleButton(
//                           icon: Icons.add,
//                           onTap: () {
//                             if (quantity < 100) {
//                               setState(() => quantity++);
//                               Get.find<DashBoardController>().updateQuantity(
//                                 quantity.toString(),
//                                 widget.serviceModel?.id ?? "",
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () async {
//                       await Get.find<DashBoardController>().getServicesDetails(
//                           widget.serviceModel?.serviceId ?? "");
//                     },
//                     child: Row(
//                       children: [
//                         Text(
//                           "View Details",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: const Color(0xFF207FA7),
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                         const SizedBox(width: 4),
//                         const Icon(
//                           Icons.arrow_forward_ios,
//                           size: 14,
//                           color: Color(0xFF207FA7),
//                         )
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
//   Widget _circleButton({
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(20),
//       onTap: onTap,
//       child: Container(
//         height: 32,
//         width: 32,
//         alignment: Alignment.center,
//         decoration: const BoxDecoration(
//           color: Color(0xFF207FA7),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           icon,
//           size: 18,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
