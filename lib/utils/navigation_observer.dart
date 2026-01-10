import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class CartNavigationObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _refreshCartOnReturn();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // No need to refresh when pushing a new route
  }

  /// Refreshes the cart data when returning to a screen
  void _refreshCartOnReturn() {
    // Use a small delay to ensure the screen is fully popped
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.isRegistered<DashBoardController>()) {
        final controller = Get.find<DashBoardController>();
        controller.getCartListing(
            limit: "100", offset: "1", isRoute: false, showLoader: true);
      }
    });
  }
}
