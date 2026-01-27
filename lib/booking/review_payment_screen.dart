// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../controllers/dashboard_controller.dart';
//
// class ReviewPaymentScreen extends StatelessWidget {
//   const ReviewPaymentScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<DashBoardController>(
//       builder: (controller) {
//         final cart = controller.cartModel.content;
//         final items = cart?.cart?.data ?? [];
//
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text("Review & Payment"),
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//
//                 /// 🧾 SERVICES
//                 const Text(
//                   "Selected Services",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//
//                 ...items.map((item) {
//                   return Card(
//                     child: ListTile(
//                       title: Text(item.service?.name ?? ""),
//                       subtitle: Text(item.subCategory?.name ?? ""),
//                       trailing: Text("₹${item.totalCost}"),
//                     ),
//                   );
//                 }).toList(),
//
//                 const SizedBox(height: 20),
//                 const Divider(),
//
//                 ///  PAYMENT BREAKDOWN
//                 PaymentRow(title: "Service Total", amount: cart?.totalCost ?? 0),
//                 PaymentRow(title: "Discount", amount: cart?.referralAmount ?? 0, isDiscount: true),
//                 PaymentRow(title: "Wallet", amount: cart?.walletBalance ?? 0, isDiscount: true),
//                 PaymentRow(title: "Tax", amount: _calculateTax(items)),
//
//                 const Divider(),
//
//                 PaymentRow(
//                   title: "Total Payable",
//                   amount: cart?.totalCost?.toDouble() ?? 0,
//                   isTotal: true,
//                 ),
//               ],
//             ),
//           ),
//
//           ///  BOTTOM ACTIONS
//           bottomNavigationBar: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//
//                 OutlinedButton(
//                   onPressed: () => _showAddMoreSheet(),
//                   child: const Text("Add More Services"),
//                 ),
//
//                 const SizedBox(height: 10),
//
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 50),
//                   ),
//                   onPressed: () {
//                     // TODO: payment API call
//                   },
//                   child: const Text("Proceed to Pay"),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   double _calculateTax(List items) {
//     double tax = 0;
//     for (var item in items) {
//       tax += (item.taxAmount ?? 0).toDouble();
//     }
//     return tax;
//   }
//
//   void _showAddMoreSheet() {
//     Get.bottomSheet(
//       const AddMoreServiceSheet(),
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//     );
//   }
// }
//
// class AddMoreServiceSheet extends StatelessWidget {
//   const AddMoreServiceSheet({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<DashBoardController>();
//     final suggestedServices = controller.suggestedServices ?? [];
//
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.75,
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           /// Header
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Add More Services",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () => Get.back(),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 10),
//
//           /// List of suggested services
//           Expanded(
//             child: suggestedServices.isEmpty
//                 ? const Center(child: Text("No additional services available"))
//                 : ListView.builder(
//               itemCount: suggestedServices.length,
//               itemBuilder: (context, index) {
//                 final service = suggestedServices[index];
//
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 6),
//                   child: ListTile(
//                     leading: service.coverImage != null
//                         ? Image.network(
//                       service.coverImage!,
//                       width: 50,
//                       height: 50,
//                       fit: BoxFit.cover,
//                     )
//                         : const Icon(Icons.build),
//                     title: Text(service.name ?? ""),
//                     subtitle: Text("₹${service.price ?? 0}"),
//                     trailing: ElevatedButton(
//                       onPressed: () async {
//                         // Add service to cart
//                         await controller.addServiceToCart(service.id);
//
//                         // Refresh cart
//                         controller.getCartList();
//
//                         // Optional: show snackbar
//                         Get.snackbar(
//                           "Service Added",
//                           "${service.name} added to cart",
//                           snackPosition: SnackPosition.BOTTOM,
//                         );
//                       },
//                       child: const Text("Add"),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class PaymentRow extends StatelessWidget {
//   final String title;
//   final double amount;
//   final bool isTotal;
//   final bool isDiscount;
//
//   const PaymentRow({
//     super.key,
//     required this.title,
//     required this.amount,
//     this.isTotal = false,
//     this.isDiscount = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: isTotal ? 16 : 14,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
//             ),
//           ),
//           Text(
//             "${isDiscount ? "-" : ""}₹${amount.toStringAsFixed(0)}",
//             style: TextStyle(
//               fontSize: isTotal ? 16 : 14,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
//               color: isTotal
//                   ? Colors.green
//                   : isDiscount
//                   ? Colors.red
//                   : Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
