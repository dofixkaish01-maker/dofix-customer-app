import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackBar {
  static void show({
    String title = '',
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 2),
  }) {
    // 🔐 GLOBAL SAFETY
    if (message.trim().isEmpty) return;
    if (Get.isSnackbarOpen) return;
    if (Get.context == null || Get.overlayContext == null) {
      debugPrint("SnackBar skipped (No Overlay): $message");
      return;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      margin: const EdgeInsets.all(12),
    );
  }
}
