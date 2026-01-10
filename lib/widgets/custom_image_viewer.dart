import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  const CustomNetworkImageWidget(
      {super.key,
      required this.image,
      this.height,
      this.width,
      this.fit = BoxFit.cover,
      this.placeholder = '',
      this.radius,
      this.imagePadding,
      this.onlyTopRadius = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 200,
      width: width ?? Get.size.width,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: onlyTopRadius
            ? BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radius5),
                topRight: Radius.circular(Dimensions.radius5),
              )
            : BorderRadius.circular(
                radius ?? Dimensions.radius5,
              ),
      ),
      child: CachedNetworkImage(
        imageUrl: image,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => ShimmerWidget(),
        errorWidget: (context, url, error) => Padding(
          padding: EdgeInsets.all(imagePadding ?? 0),
          child: Image.asset(
              placeholder.isNotEmpty ? placeholder : Images.placeholder,
              fit: fit),
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
  const CustomRoundNetworkImage(
      {super.key,
      this.height,
      this.width,
      required this.image,
      this.placeholder,
      this.imagePadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Image.asset(placeholder ?? Images.placeholder, fit: BoxFit.cover),
        errorWidget: (context, url, error) => Padding(
          padding: EdgeInsets.all(imagePadding ?? 0),
          child:
              Image.asset(placeholder ?? Images.placeholder, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class ShimmerWidget extends StatelessWidget {
  final double? height;
  final double? width;
  const ShimmerWidget({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height ?? 200,
        width: width ?? Get.size.width,
        color: Colors.white,
      ),
    );
  }
}
