import 'package:do_fix/model/booking_response.dart';
import 'package:do_fix/widgets/custom_image_viewer.dart';
import 'package:flutter/material.dart';

class CustomBookingDetailsItems extends StatelessWidget {
  final ServiceDetail detail;
  const CustomBookingDetailsItems({
    super.key,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomNetworkImageWidget(
              image: detail.service?.coverImageFullPath ?? "",
              height: 53,
              width: 69,
            ),
            SizedBox(
              width: 4,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  detail.variantKey ?? "",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  detail.serviceName ?? "",
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withAlpha((0.3 * 255).toInt()),
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  "₹${detail.serviceCost.toString()}",
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                )
              ],
            )
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 34,
              width: 100,
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Color(0xFF207FA8).withAlpha(
                  (0.1 * 255).toInt(),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "X ${detail.quantity ?? 0}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF207FA8),
                      ),
                    ),
                    Text(
                      " = ${detail.totalCost.toString()}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF207FA8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
