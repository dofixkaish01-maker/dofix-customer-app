import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NetworkImageWithShimmer extends StatelessWidget {
  final String imageUrl;
  final BorderRadius borderRadius;

  const NetworkImageWithShimmer({
    super.key,
    required this.imageUrl,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame != null) {
            return child; // image loaded
          }

          /// 🔥 SHIMMER PLACEHOLDER
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              color: Colors.grey,
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image),
        ),
      ),
    );
  }
}
