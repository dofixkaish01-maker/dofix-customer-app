import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackBar(
    String message, {
      String title = "Alert",
      bool isError = true,
    }) {
  //  SAFETY CHECKS
  if (message.trim().isEmpty) return;
  if (Get.isSnackbarOpen) return;
  if (Get.context == null || Get.overlayContext == null) {
    debugPrint("SnackBar skipped (No Overlay): $message");
    return;
  }

  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
    colorText: Colors.white,
    duration: const Duration(seconds: 2),
  );
}
