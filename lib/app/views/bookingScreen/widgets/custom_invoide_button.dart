import 'package:flutter/material.dart';

class CustomInvoiceButton extends StatelessWidget {
  const CustomInvoiceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(
            0xFF207FA8,
          ),
        ),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      height: 35,
      child: Center(
        child: Text(
          "Download Invoice",
          style: TextStyle(
            color: Color(
              0xFF207FA8,
            ),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
