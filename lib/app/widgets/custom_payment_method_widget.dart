import 'package:do_fix/utils/theme.dart';
import 'package:flutter/material.dart';

class CustomPaymentMethodWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  const CustomPaymentMethodWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: isSelected,
            onChanged: isEnabled ? (_) => onTap?.call() : null,
            activeColor: primaryBlue,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isEnabled
                  ? (isSelected ? primaryBlue : grey.withOpacity(0.60))
                  : Colors.grey.shade400,
              fontWeight:
                  isEnabled && isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
