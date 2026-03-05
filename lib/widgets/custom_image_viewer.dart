import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/dimensions.dart';
import '../utils/images.dart';

class CustomNetworkImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String placeholder;
  final double? radius;
  final double? imagePadding;
  final bool onlyTopRadius;

  const CustomNetworkImageWidget({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder = '',
    this.radius,
    this.imagePadding,
    this.onlyTopRadius = false,
  });

  BorderRadius get _borderRadius => onlyTopRadius
      ? BorderRadius.only(
    topLeft: Radius.circular(Dimensions.radius5),
    topRight: Radius.circular(Dimensions.radius5),
  )
      : BorderRadius.circular(radius ?? Dimensions.radius5);

  String get _fallbackAsset =>
      placeholder.isNotEmpty ? placeholder : Images.placeholder;

  bool get _hasValidUrl => image.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final h = height ?? 200;
    final w = width ?? double.infinity;

    return ClipRRect(
      borderRadius: _borderRadius,
      child: SizedBox(
        height: h,
        width: w,
        child: !_hasValidUrl
            ? Padding(
          padding: EdgeInsets.all(imagePadding ?? 0),
          child: Image.asset(_fallbackAsset, fit: fit),
        )
            : CachedNetworkImage(
          imageUrl: image,
          height: h,
          width: w,
          fit: fit,
          fadeInDuration: const Duration(milliseconds: 180),
          fadeOutDuration: const Duration(milliseconds: 120),
          placeholder: (context, url) => ShimmerWidget(
            height: h,
            width: w,
            borderRadius: _borderRadius,
          ),
          errorWidget: (context, url, error) => Padding(
            padding: EdgeInsets.all(imagePadding ?? 0),
            child: Image.asset(_fallbackAsset, fit: fit),
          ),
        ),
      ),
    );
  }
}

class CustomRoundNetworkImage extends StatelessWidget {
  final double? height;
  final double? width;
  final String image;
  final String? placeholder;
  final double? imagePadding;

  const CustomRoundNetworkImage({
    super.key,
    this.height,
    this.width,
    required this.image,
    this.placeholder,
    this.imagePadding,
  });

  bool get _hasValidUrl => image.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final size = (width ?? height ?? 44);

    return ClipOval(
      child: SizedBox(
        height: height ?? size,
        width: width ?? size,
        child: !_hasValidUrl
            ? Padding(
          padding: EdgeInsets.all(imagePadding ?? 0),
          child: Image.asset(
            placeholder ?? Images.placeholder,
            fit: BoxFit.cover,
          ),
        )
            : CachedNetworkImage(
          imageUrl: image,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 180),
          placeholder: (context, url) => ShimmerWidget(
            height: height ?? size,
            width: width ?? size,
            isCircle: true,
          ),
          errorWidget: (context, url, error) => Padding(
            padding: EdgeInsets.all(imagePadding ?? 0),
            child: Image.asset(
              placeholder ?? Images.placeholder,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final bool isCircle;

  const ShimmerWidget({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? 200;
    final w = width ?? double.infinity;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: isCircle
          ? Container(
        height: h,
        width: w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      )
          : ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Container(
          height: h,
          width: w,
          color: Colors.white,
        ),
      ),
    );
  }
}



// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shimmer/shimmer.dart';
//
// import '../utils/dimensions.dart';
// import '../utils/images.dart';
//
// class CustomNetworkImageWidget extends StatelessWidget {
//   final String image;
//   final double? height;
//   final double? width;
//   final BoxFit? fit;
//   final String placeholder;
//   final double? radius;
//   final double? imagePadding;
//   final bool onlyTopRadius;
//
//   const CustomNetworkImageWidget(
//       {super.key,
//       required this.image,
//       this.height,
//       this.width,
//       this.fit = BoxFit.cover,
//       this.placeholder = '',
//       this.radius,
//       this.imagePadding,
//       this.onlyTopRadius = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: height ?? 200,
//       width: width ?? Get.size.width,
//       clipBehavior: Clip.hardEdge,
//       decoration: BoxDecoration(
//         borderRadius: onlyTopRadius
//             ? BorderRadius.only(
//                 topLeft: Radius.circular(Dimensions.radius5),
//                 topRight: Radius.circular(Dimensions.radius5),
//               )
//             : BorderRadius.circular(
//                 radius ?? Dimensions.radius5,
//               ),
//       ),
//       child: CachedNetworkImage(
//         imageUrl: image,
//         height: height,
//         width: width,
//         fit: fit,
//         placeholder: (context, url) => ShimmerWidget(),
//         errorWidget: (context, url, error) => Padding(
//           padding: EdgeInsets.all(imagePadding ?? 0),
//           child: Image.asset(
//               placeholder.isNotEmpty ? placeholder : Images.placeholder,
//               fit: fit),
//         ),
//       ),
//     );
//   }
// }
//
// class CustomRoundNetworkImage extends StatelessWidget {
//   final double? height;
//   final double? width;
//   final String image;
//   final String? placeholder;
//   final double? imagePadding;
//
//   const CustomRoundNetworkImage(
//       {super.key,
//       this.height,
//       this.width,
//       required this.image,
//       this.placeholder,
//       this.imagePadding});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: height,
//       width: width,
//       decoration: BoxDecoration(shape: BoxShape.circle),
//       child:
//       CachedNetworkImage(
//         imageUrl: image,
//         fit: BoxFit.cover,
//         placeholder: (context, url) =>
//             Image.asset(placeholder ?? Images.placeholder, fit: BoxFit.cover),
//         errorWidget: (context, url, error) => Padding(
//           padding: EdgeInsets.all(imagePadding ?? 0),
//           child:
//               Image.asset(placeholder ?? Images.placeholder, fit: BoxFit.cover),
//         ),
//       ),
//     );
//   }
// }
//
// class ShimmerWidget extends StatelessWidget {
//   final double? height;
//   final double? width;
//
//   const ShimmerWidget({super.key, this.height, this.width});
//
//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Container(
//         height: height ?? 200,
//         width: width ?? Get.size.width,
//         color: Colors.white,
//       ),
//     );
//   }
// }
