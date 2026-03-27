import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helper/network_service.dart';

class NetworkBanner extends StatelessWidget {
  const NetworkBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NetworkController>();

    return Obx(() {
      final isVisible = controller.showBanner.value;
      final isOffline = controller.isOffline.value;
      final isSlow = controller.isSlow.value;
      final isBackOnline = controller.isBackOnline.value;

      Color startColor;
      Color endColor;
      IconData icon;
      String message;

      if (isOffline) {
        startColor = Colors.red.shade600;
        endColor = Colors.red.shade500;
        icon = Icons.wifi_off;
        message = "No Internet Connection";
      } else if (isSlow) {
        startColor = Colors.orange.shade600;
        endColor = Colors.orange.shade500;
        icon = Icons.network_check_rounded;
        message = "Slow Internet Connection";
      } else if (isBackOnline) {
        startColor = Colors.green.shade600;
        endColor = Colors.green.shade500;
        icon = Icons.wifi;
        message = "You're Back Online";
      } else {
        startColor = Colors.green.shade600;
        endColor = Colors.green.shade500;
        icon = Icons.wifi;
        message = "Connected";
      }

      return AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: isVisible ? Offset.zero : const Offset(0, -1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isVisible ? 1 : 0,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    message,
                    textScaleFactor: 1.0,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}