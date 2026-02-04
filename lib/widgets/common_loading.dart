import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
