import 'package:flutter/material.dart';

class CustomCancelledButton extends StatelessWidget {
  const CustomCancelledButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color.fromARGB(255, 230, 0, 0),
        ),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      height: 35,
      child: Center(
        child: Text(
          "Cancel Booking",
          style: TextStyle(
            color: Color.fromARGB(255, 230, 0, 0),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
