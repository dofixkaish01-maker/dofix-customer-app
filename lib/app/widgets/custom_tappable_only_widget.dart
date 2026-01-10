import 'package:do_fix/utils/theme.dart';
import 'package:flutter/material.dart';

class CustomTappableOnlyWidget extends StatelessWidget {
  final Widget leading;
  final String title;
  final VoidCallback onTap;

  const CustomTappableOnlyWidget({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: grey.withOpacity(0.15),
          ),
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: grey.withOpacity(0.30),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
