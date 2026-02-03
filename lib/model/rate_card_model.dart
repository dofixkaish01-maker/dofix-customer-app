import 'package:flutter/cupertino.dart';
class DofixRateCart {
  final String responseCode;
  final String message;
  final List<RateCardModel> content;

  DofixRateCart({
    required this.responseCode,
    required this.message,
    required this.content,
  });

  factory DofixRateCart.fromJson(Map<String, dynamic> json) {
    return DofixRateCart(
      responseCode: json['response_code'] ?? '',
      message: json['message'] ?? '',
      content: (json['content'] as List).map((e) => RateCardModel.fromJson(e)).toList(),
    );
  }
}

class RateCardModel {
  final String id;
  final String categoryId;
  final String image;
  final String name;
  final String price;
  final int status;
  final String createdAt;
  final String updatedAt;

  RateCardModel({
    required this.id,
    required this.categoryId,
    required this.image,
    required this.name,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON → Dart
  factory RateCardModel.fromJson(Map<String, dynamic> json) {
    return RateCardModel(
      id: json['id'] ?? '',
      categoryId: json['category_id'] ?? '',
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
