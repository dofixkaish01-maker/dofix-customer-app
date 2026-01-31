import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;
  final Color? color;
  final IconData? icon;
  final bool transparent;
  final double? width;

  const CustomButtonWidget({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.color,
    this.icon,
    this.transparent = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(transparent ? 0 : 2),

          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) {
              if (transparent) {
                return Colors.transparent;
              }
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey.shade400; // ✅ disabled gray
              }
              return color ?? Theme.of(context).primaryColor;
            },
          ),

          foregroundColor: MaterialStateProperty.all(
            transparent
                ? Theme.of(context).primaryColor
                : Colors.white,
          ),

          side: transparent
              ? MaterialStateProperty.all(
            BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(buttonText),
          ],
        ),
      ),
    );
  }
}
