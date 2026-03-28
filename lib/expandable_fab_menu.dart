import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import 'app/views/helpSupport/help_and_support_screen.dart';
import 'app/views/home/refer screen/refer_earn_screen.dart';
import 'controllers/auth_controller.dart';

class ExpandableFabMenu extends StatefulWidget {
  const ExpandableFabMenu({super.key});

  @override
  State<ExpandableFabMenu> createState() => _ExpandableFabMenuState();
}

class _ExpandableFabMenuState extends State<ExpandableFabMenu> {
  String activeButton = ""; // "refer" or "help"

  void handleTap(String type) async {
    final authController = Get.find<AuthController>();

    /// FIRST CLICK → animation
    if (activeButton != type) {
      setState(() {
        activeButton = type;
      });
      return;
    }

    /// SECOND CLICK → navigate
    if (type == "refer") {
      bool isGuest = await authController.returnIsGuest();
      if (isGuest) {
        authController.checkIfGuest();
      } else {
        Get.to(() => ReferEarnScreen());
      }
    } else {
      Get.to(() => const HelpSupportScreen());
    }

    /// reset
    setState(() {
      activeButton = "";
    });
  }

  Widget buildButton({
    required String type,
    required IconData icon,
    required Color color,
  }) {
    bool isActive = activeButton == type;

    return GestureDetector(
      onTap: () => handleTap(type),

      /// PRESS EFFECT
      onTapDown: (_) {
        setState(() {
          activeButton = type;
        });
      },
      onTapUp: (_) {
        setState(() {});
      },
      onTapCancel: () {
        setState(() {
          activeButton = "";
        });
      },

      child: AnimatedScale(
        scale: isActive ? 0.9 : 1, // press shrink
        duration: const Duration(milliseconds: 120),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 12),
          height: isActive ? 64 : 56,
          width: isActive ? 64 : 56,

          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? color.withOpacity(0.6)
                    : Colors.black.withOpacity(0.2),
                blurRadius: isActive ? 20 : 10,
                spreadRadius: isActive ? 2 : 0,
                offset: const Offset(0, 5),
              )
            ],
          ),

          child: Icon(
            icon,
            color: Colors.white,
            size: isActive ? 28 : 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          /// REFER
          // buildButton(
          //   type: "refer",
          //   icon: Icons.card_giftcard,
          //   color: const Color(0xff1f7aa8),
          // ),

          /// HELP
          buildButton(
            type: "help",
            icon: Icons.support_agent,
            color: Color(0xff1f7aa8),
          ),
        ],
      ),
    );
  }
}