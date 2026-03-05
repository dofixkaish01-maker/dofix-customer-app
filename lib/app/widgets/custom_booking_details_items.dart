import 'package:do_fix/model/booking_response.dart';
import 'package:do_fix/widgets/custom_image_viewer.dart';
import 'package:flutter/material.dart';
import '../../utils/dimensions.dart';

class CustomBookingDetailsItems extends StatelessWidget {
  final ServiceDetail detail;

  const CustomBookingDetailsItems({
    super.key,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// LEFT SIDE (Image + Details)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomNetworkImageWidget(
                image: detail.service?.coverImageFullPath ?? "",
                height: 65,
                width: 80,
              ),

              const SizedBox(width: 8),

              /// 🔹 TEXT SECTION
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Variant Key
                    Text(
                      detail.variantKey ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Dimensions.fontSize14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: Dimensions.paddingSize4),

                    /// Service Name
                    Text(
                      detail.serviceName ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Dimensions.fontSize12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),

                    SizedBox(height: Dimensions.paddingSize4),

                    /// Price
                    Text(
                      "₹${detail.serviceCost ?? 0}",
                      style: TextStyle(
                        fontSize: Dimensions.fontSize13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        /// 🔹 RIGHT SIDE (Quantity Box)
        Container(
          height: 34,
          constraints: const BoxConstraints(minWidth: 90),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF207FA8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "X ${detail.quantity ?? 0} = ₹${detail.totalCost ?? 0}",
                style: TextStyle(
                  fontSize: Dimensions.fontSize14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF207FA8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
