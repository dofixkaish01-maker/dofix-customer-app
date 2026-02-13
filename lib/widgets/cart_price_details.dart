import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/cart_model.dart';

Widget cartPriceDetails(CartResponseModel cartModel) {
  final content = cartModel.content;
  final cart = content?.cart;

  double itemTotal = 0.0;
  double discount = 0.0;
  double couponDiscount = 0.0;
  double tax = 0.0;

  final items = cart?.data ?? [];

  for (var item in items) {
    final double serviceCost = item.serviceCost.toDouble();
    final double qty = item.quantity.toDouble();
    final double dis = item.discountAmount.toDouble();
    final double coup = item.couponDiscount.toDouble();
    final double taxAmt = item.taxAmount.toDouble();

    itemTotal += serviceCost * qty;
    discount += dis;
    couponDiscount += coup;
    tax += taxAmt;
  }

  final double grandTotal = content?.totalCost.toDouble() ?? 0.0;
  final double wallet = content?.walletBalance.toDouble() ?? 0.0;
  final double referral = content?.referralAmount.toDouble() ?? 0.0;

  return Container(
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200,
          blurRadius: 6,
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Price Details",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const Divider(),

        _priceRow("Price (${items.length} items)", itemTotal),

        _priceRow("Discount", -discount),

        _priceRow("Coupon Discount", -couponDiscount),

        _priceRow("Tax", tax),

        const Divider(),

        _priceRow("Total Amount", grandTotal, isBold: true),

        if (wallet > 0)
          _priceRow("Wallet Balance", -wallet, color: Colors.green),

        if (referral > 0)
          _priceRow("Referral Amount", -referral, color: Colors.green),

        const SizedBox(height: 6),

        Text(
          "You will save ₹${(discount + couponDiscount).toStringAsFixed(2)}",
          style: const TextStyle(
              color: Colors.green, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

Widget _priceRow(String title, double amount,
    {bool isBold = false, Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          "₹ ${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    ),
  );
}


