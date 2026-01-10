import 'package:do_fix/utils/dimensions.dart';
import 'package:do_fix/utils/sizeboxes.dart';
import 'package:do_fix/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButtonWidget extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double radius;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isLoading;

  final Color? borderSideColor;
  const CustomButtonWidget({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.transparent = false,
    this.margin,
    this.width,
    this.height,
    this.fontSize,
    this.radius = 10,
    this.icon,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.borderSideColor,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: onPressed == null
          ? Theme.of(context).disabledColor
          : transparent
              ? Colors.transparent
              : color ?? Theme.of(context).primaryColor,
      minimumSize: Size(width != null ? width! : Dimensions.webMaxWidth,
          height != null ? height! : 50),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: borderSideColor ??
              Theme.of(context).primaryColor, // Specify the color of the border
          width: 1, // Specify the width of the border
        ),
      ),
    );

    return Center(
        child: SizedBox(
            width: width ?? Dimensions.webMaxWidth,
            child: Padding(
              padding: margin == null ? const EdgeInsets.all(0) : margin!,
              child: TextButton(
                onPressed: isLoading ? null : onPressed as void Function()?,
                style: flatButtonStyle,
                child: isLoading
                    ? Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSize10),
                              Text('Loading',
                                  style: albertSansMedium.copyWith(
                                      color: Colors.white)),
                            ]),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            icon != null
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: Icon(
                                      icon,
                                      color: transparent
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).cardColor,
                                      size: Dimensions.fontSizeDefault,
                                    ),
                                  )
                                : const SizedBox(),
                            sizedBoxW5(),
                            Text(buttonText,
                                textAlign: TextAlign.center,
                                style: albertSansRegular.copyWith(
                                    color: textColor ??
                                        (transparent
                                            ? Theme.of(context).primaryColor
                                            : Colors.white),
                                    fontSize: fontSize ?? Dimensions.fontSize14,
                                    fontWeight:
                                        fontWeight ?? FontWeight.normal)),
                          ]),
              ),
            )));
  }
}
