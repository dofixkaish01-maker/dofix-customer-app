import 'package:do_fix/widgets/custom_dot_loader.dart';
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

void showLoading([String from = "unknown"]) {
  debugPrint("SHOW LOADING FROM: $from");
  _isLoading.value = true;
}

void hideLoading([String from = "unknown"]) {
  debugPrint("HIDE LOADING FROM: $from");
  _isLoading.value = false;
}

Widget globalLoader() {
  return Obx(() {
    if (!_isLoading.value) return const SizedBox.shrink();

    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: ColoredBox(
          color: Colors.black38,
          child: const Center(
            child: DotWaveLoader(),
          ),
        ),
      ),
    );
  });
}

