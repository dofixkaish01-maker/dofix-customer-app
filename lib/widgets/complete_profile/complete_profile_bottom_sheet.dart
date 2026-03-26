// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_instance/src/extension_instance.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';
//
// import '../../controllers/auth_controller.dart';
//
// class CompleteProfileBottomSheet extends StatelessWidget {
//   const CompleteProfileBottomSheet({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final firstNameController = TextEditingController();
//     final lastNameController = TextEditingController();
//     final emailController = TextEditingController();
//     final authController = Get.find<AuthController>();
//
//     return Container(
//       padding: EdgeInsets.only(
//         left: 16,
//         right: 16,
//         top: 20,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//       ),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Complete Profile",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "Please complete your profile to continue.",
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: firstNameController,
//               decoration: const InputDecoration(
//                 labelText: "First Name",
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: lastNameController,
//               decoration: const InputDecoration(
//                 labelText: "Last Name",
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: "Email",
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   await authController.register(
//                     emailController.text.trim(),
//                     firstNameController.text.trim(),
//                     lastNameController.text.trim(),
//                     authController.phoneNumber.value,
//                   );
//
//                   if (authController.isRegisterComplete()) {
//                     Get.back();
//                   }
//                 },
//                 child: const Text("Continue"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }