import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/theme.dart';
//
// void showLoading() {
//   if (!Get.isDialogOpen!) {
//     Get.dialog(
//       Center(child: CircularProgressIndicator(color: light.primaryColorDark)),
//       barrierDismissible: false,
//     );
//     Future.delayed(Duration(seconds: 30), () {
//       if (Get.isDialogOpen!) {
//         Get.back();
//       }
//     });
//   }
// }
//
// void hideLoading() {
//   if (Get.isDialogOpen!) {
//     Get.back();
//   }
// }

final RxBool _isLoading = false.obs;

void showLoading() {
  _isLoading.value = true;
}

void hideLoading() {
  _isLoading.value = false;
}

Widget GlobalLoader() {
  return Obx(() {
    if (!_isLoading.value) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  });
}

