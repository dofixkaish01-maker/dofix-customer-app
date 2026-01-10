
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/sizeboxes.dart';

class CommonButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isLightColor;
  final bool isShowIcon;
  final Widget text;
  final double? width;
  final double? height;
  const CommonButton({super.key, this.onPressed, required this.isLightColor, required this.text, this.width = 380, this.height = 55, required this.isShowIcon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: InkRipple.splashFactory,
      splashColor: Colors.white.withOpacity(0.3),
      onTap: onPressed,
      child: Container(
        // width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isLightColor ? Color(0xFFBA7270) : Color(0xFF86413F),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            text,
            sizedBoxW5(),
            Visibility(
                visible: isShowIcon,
                child: Icon(Icons.arrow_forward_ios, color: Colors.white))
          ],
        ),
      ),
    );
  }
}
