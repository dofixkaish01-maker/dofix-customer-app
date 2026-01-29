// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../controllers/dashboard_controller.dart';
// import '../../../../helper/route_helper.dart';
// import '../../../../model/service_model.dart';
// import '../../cart_screen/cart_screen.dart';
//
// class AddExtraServiceSheet extends StatefulWidget {
//   final ServiceModel service;
//   final String? variantKey;
//
//   const AddExtraServiceSheet({
//     super.key,
//     required this.service,
//     this.variantKey,
//   });
//
//   @override
//   State<AddExtraServiceSheet> createState() => _AddExtraServiceSheetState();
// }
//
// class _AddExtraServiceSheetState extends State<AddExtraServiceSheet> {
//   /// store extraId -> selected
//   final Map<String, bool> selectedExtras = {};
//   bool isAdding = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final extras = widget.service.extras ?? [];
//     final hasExtras = extras.isNotEmpty;
//
//     return FractionallySizedBox(
//       heightFactor: hasExtras ? 0.85 : 0.45,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// drag handle
//             Center(
//               child: Container(
//                 width: 50,
//                 height: 5,
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//
//             /// header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Select Extra Services',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close), onPressed: () {
//                     Get.back();
//                 },
//
//                 )
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             /// ================= EXTRAS LIST =================
//             Expanded(
//               child: hasExtras
//                   ? ListView.separated(
//                 itemCount: extras.length,
//                 separatorBuilder: (_, __) =>
//                     Divider(color: Colors.grey[300]),
//                 itemBuilder: (context, index) {
//                   final extra = extras[index];
//                   final String extraId = extra.id ?? '';
//
//                   final isSelected = selectedExtras[extraId] ?? false;
//
//                   return InkWell(
//                     borderRadius: BorderRadius.circular(10),
//                     onTap: () {
//                       setState(() {
//                         selectedExtras[extraId] = !isSelected;
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? Colors.blue.withOpacity(0.1)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Checkbox(
//                             value: isSelected,
//                             activeColor: const Color(0xff227FA8),
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedExtras[extraId] = value ?? false;
//                               });
//                             },
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   extra.name ?? '',
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   '₹${extra.price}',
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                     color: Color(0xff227FA8),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               )
//                   : const Center(
//                 child: Text(
//                   "No extra services available",
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             ),
//
//             /// ================= ACTION BUTTONS =================
//             Row(
//               children: [
//                 /// SKIP & CONTINUE
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: isAdding
//                         ? null
//                         : () async {
//                       setState(() => isAdding = true);
//
//                       final controller = Get.find<DashBoardController>();
//
//                       await controller.addToCart(
//                         {
//                           "service_id": widget.service.id,
//                           "category_id": widget.service.categoryId,
//                           "sub_category_id": widget.service.subCategoryId,
//                           "quantity": extras.length.toString(),
//                         },
//                         widget.variantKey != null ? [widget.variantKey!] : [],
//                       );
//
//                       Get.to(()=>CartScreen());
//                     },
//                     style: OutlinedButton.styleFrom(
//                       padding:
//                       const EdgeInsets.symmetric(vertical: 14),
//                       side: const BorderSide(
//                           color: Color(0xff227FA8)),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       "Skip & Continue",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Color(0xff227FA8),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(width: 12),
//
//                 /// ADD / ADD ALL
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: isAdding ||
//                         selectedExtras.values.where((v) => v).isEmpty
//                         ? null
//                         : () async {
//                       setState(() => isAdding = true);
//
//                       final controller = Get.find<DashBoardController>();
//
//                       final selectedExtrasList = extras
//                           .where((e) => selectedExtras[e.id] == true)
//                           .map((e) => e.toJson())
//                           .toList();
//
//                       await controller.addToCart(
//                         {
//                           "service_id": widget.service.id,
//                           "category_id": widget.service.categoryId,
//                           "sub_category_id": widget.service.subCategoryId,
//                           "quantity": extras.length.toString(),
//                           "extras": selectedExtrasList,
//                         },
//                         widget.variantKey != null ? [widget.variantKey!] : [],
//                       );
//
//                       Get.to(() => CartScreen());
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                       const Color(0xff227FA8),
//                       padding:
//                       const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: isAdding
//                         ? const SizedBox(
//                       height: 18,
//                       width: 18,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                         : Text(
//                       selectedExtras.values
//                           .where((v) => v)
//                           .length ==
//                           extras.length
//                           ? "Add All (${selectedExtras.values.where((v) => v).length})"
//                           : "Add (${selectedExtras.values.where((v) => v).length})",
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
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
