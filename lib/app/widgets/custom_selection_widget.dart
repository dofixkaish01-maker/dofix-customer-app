import 'package:do_fix/utils/theme.dart';
import 'package:flutter/material.dart';

class CustomSelectionWidget extends StatelessWidget {
  final String title;
  final String? text;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomSelectionWidget({
    required this.title,
    this.text,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: text == null
            ? EdgeInsets.fromLTRB(12, 14, 12, 0)
            : EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.black.withOpacity(0.30),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              textAlign: TextAlign.center,
              title,
              style: TextStyle(
                fontSize: 14,
                color:
                    isSelected ? primaryBlue : Colors.black.withOpacity(0.50),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (text != null || text != "")
              Text(
                textAlign: TextAlign.center,
                text ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isSelected ? primaryBlue : Colors.black.withOpacity(0.50),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
