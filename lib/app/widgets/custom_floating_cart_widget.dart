import 'package:do_fix/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:do_fix/app/views/cart_screen/cart_screen.dart';
import 'package:do_fix/utils/styles.dart';
import 'package:do_fix/utils/dimensions.dart';

class CustomFloatingCartWidget extends StatelessWidget {
  final int itemCount;
  final double totalAmount;

  const CustomFloatingCartWidget({
    Key? key,
    required this.itemCount,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only show when there's at least one item in cart
    if (itemCount <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
      decoration: BoxDecoration(
        color: Color(0xFF207FA7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0x1E000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$itemCount ${itemCount > 1 ? 'items' : 'item'} in cart",
                style: albertSansRegular.copyWith(
                  fontSize: Dimensions.fontSize12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "₹${totalAmount.toStringAsFixed(2)}",
                style: albertSansRegular.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              final authController = Get.find<AuthController>();
              bool isGuest = await authController.returnIsGuest();
              if (isGuest) {
                authController.checkIfGuest();
              } else {
                Get.to(() => CartScreen());
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "View Cart",
                style: albertSansRegular.copyWith(
                  fontSize: Dimensions.fontSize14,
                  color: Color(0xFF207FA7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
