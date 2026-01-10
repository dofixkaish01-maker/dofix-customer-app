import 'package:do_fix/utils/dimensions.dart';
import 'package:flutter/material.dart';

class CustomDecoratedContainer extends StatelessWidget {
  final Color? bgColor;
  final double? padding;
  final double? radius;
  final Color? borderColor;
  final Widget child;
  const CustomDecoratedContainer(
      {super.key,
      this.bgColor,
      this.padding,
      this.radius,
      this.borderColor,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(
          radius ?? Dimensions.radius10,
        ),
        border: Border.all(
          width: 1,
          color: borderColor ?? Colors.white,
        ),
      ),
      child: child,
    );
  }
}
