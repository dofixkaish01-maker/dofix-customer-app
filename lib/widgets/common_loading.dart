import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../utils/theme.dart';

void showLoading() {
  if (!Get.isDialogOpen!) {
    Get.dialog(
      Center(child: CircularProgressIndicator(color: light.primaryColorDark)),
      barrierDismissible: false,
    );
    Future.delayed(Duration(seconds: 30), () {
      if (Get.isDialogOpen!) {
        Get.back();
      }
    });
  }
}

void hideLoading() {
  if (Get.isDialogOpen!) {
    Get.back();
  }
}
