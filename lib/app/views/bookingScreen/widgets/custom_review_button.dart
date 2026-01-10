import 'package:flutter/material.dart';

class CustomReviewButton extends StatelessWidget {
  const CustomReviewButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 60,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Color(
          0xFF207FA8,
        ),
      ),
      height: 35,
      child: Center(
        child: Text(
          "Review",
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
