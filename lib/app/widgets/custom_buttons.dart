
import 'package:do_fix/utils/dimensions.dart';
import 'package:flutter/material.dart';

import '../../utils/images.dart';

class CustomNotificationButton extends StatelessWidget {
  final Function() tap;
  final IconData? icon;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  const CustomNotificationButton({super.key, required this.tap, this.icon, this.color, this.padding});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tap,
      child: Container(
        width: 32,
        height: 32,
        padding: padding,
        decoration:  BoxDecoration(
           image: DecorationImage(
             image: AssetImage(Images.icImages),
             fit: BoxFit.cover
           )
        ),
      ),
    );
  }
}


