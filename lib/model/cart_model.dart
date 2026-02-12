// import 'dart:convert';
//
// class ServiceOrder {
//   final String id;
//   final String customerId;
//   final String? providerId;
//   final String serviceId;
//   final String categoryId;
//   final String subCategoryId;
//   final String variantKey;
//   final double serviceCost;
//   final int quantity;
//   final double discountAmount;
//   final String? couponCode;
//   final double couponDiscount;
//   final double campaignDiscount;
//   final double taxAmount;
//   final double totalCost;
//   final String createdAt;
//   final String updatedAt;
//   final int isGuest;
//   final String couponId;
//   final Category? category;
//
//   ServiceOrder({
//     required this.id,
//     required this.customerId,
//     this.providerId,
//     required this.serviceId,
//     required this.categoryId,
//     required this.subCategoryId,
//     required this.variantKey,
//     required this.serviceCost,
//     required this.quantity,
//     required this.discountAmount,
//     this.couponCode,
//     required this.couponDiscount,
//     required this.campaignDiscount,
//     required this.taxAmount,
//     required this.totalCost,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.isGuest,
//     required this.couponId,
//     this.category,
//   });
//
//   factory ServiceOrder.fromJson(Map<String, dynamic> json) {
//     return ServiceOrder(
//       id: json['id'],
//       customerId: json['customer_id'],
//       providerId: json['provider_id'],
//       serviceId: json['service_id'],
//       categoryId: json['category_id'],
//       subCategoryId: json['sub_category_id'],
//       variantKey: json['variant_key'],
//       serviceCost: (json['service_cost'] as num).toDouble(),
//       quantity: json['quantity'],
//       discountAmount: (json['discount_amount'] as num).toDouble(),
//       couponCode: json['coupon_code'],
//       couponDiscount: (json['coupon_discount'] as num).toDouble(),
//       campaignDiscount: (json['campaign_discount'] as num).toDouble(),
//       taxAmount: (json['tax_amount'] as num).toDouble(),
//       totalCost: (json['total_cost'] as num).toDouble(),
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       isGuest: json['is_guest'],
//       couponId: json['coupon_id'],
//       category: json['category'] != null ? Category.fromJson(json['category']) : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'customer_id': customerId,
//       'provider_id': providerId,
//       'service_id': serviceId,
//       'category_id': categoryId,
//       'sub_category_id': subCategoryId,
//       'variant_key': variantKey,
//       'service_cost': serviceCost,
//       'quantity': quantity,
//       'discount_amount': discountAmount,
//       'coupon_code': couponCode,
//       'coupon_discount': couponDiscount,
//       'campaign_discount': campaignDiscount,
//       'tax_amount': taxAmount,
//       'total_cost': totalCost,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'is_guest': isGuest,
//       'coupon_id': couponId,
//       'category': category?.toJson(),
//     };
//   }
// }
//
// class Category {
//   final String id;
//   final String parentId;
//   final String name;
//   final String image;
//   final int position;
//   final String? description;
//   final int isActive;
//   final int isFeatured;
//   final String createdAt;
//   final String updatedAt;
//   final String imageFullPath;
//
//   Category({
//     required this.id,
//     required this.parentId,
//     required this.name,
//     required this.image,
//     required this.position,
//     this.description,
//     required this.isActive,
//     required this.isFeatured,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.imageFullPath,
//   });
//
//   factory Category.fromJson(Map<String, dynamic> json) {
//     return Category(
//       id: json['id'],
//       parentId: json['parent_id'],
//       name: json['name'],
//       image: json['image'],
//       position: json['position'],
//       description: json['description'],
//       isActive: json['is_active'],
//       isFeatured: json['is_featured'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       imageFullPath: json['image_full_path'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'parent_id': parentId,
//       'name': name,
//       'image': image,
//       'position': position,
//       'description': description,
//       'is_active': isActive,
//       'is_featured': isFeatured,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'image_full_path': imageFullPath,
//     };
//   }
// }

// New version Cart Model For best cart Ui
class CartResponseModel {
  final String responseCode;
  final String message;
  final CartContent? content;
  final List<dynamic> errors;

  CartResponseModel({
    required this.responseCode,
    required this.message,
    this.content,
    required this.errors,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      responseCode: json['response_code'] ?? '',
      message: json['message'] ?? '',
      content: json['content'] != null
          ? CartContent.fromJson(json['content'])
          : null,
      errors: json['errors'] ?? [],
    );
  }
}
class CartContent {
  final double totalCost;
  final double referralAmount;
  final double walletBalance;
  final CartData? cart;

  CartContent({
    required this.totalCost,
    required this.referralAmount,
    required this.walletBalance,
    this.cart,
  });

  factory CartContent.fromJson(Map<String, dynamic> json) {
    return CartContent(
      totalCost: double.tryParse(json['total_cost'].toString()) ?? 0.0,
      referralAmount:
      double.tryParse(json['referral_amount'].toString()) ?? 0.0,
      walletBalance:
      double.tryParse(json['wallet_balance'].toString()) ?? 0.0,
      cart: json['cart'] != null
          ? CartData.fromJson(json['cart'])
          : null,
    );
  }
}
class CartData {
  final int currentPage;
  final List<CartItem> data;
  final int total;

  CartData({
    required this.currentPage,
    required this.data,
    required this.total,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    return CartData(
      currentPage: json['current_page'] ?? 1,
      total: json['total'] ?? 0,
      data: json['data'] != null
          ? List<CartItem>.from(
          json['data'].map((x) => CartItem.fromJson(x)))
          : [],
    );
  }
}
class CartItem {
  final String id;
  final String customerId;
  final String? providerId;
  final String serviceId;
  final String categoryId;
  final String subCategoryId;

  final String variantKey;
  final int variationId;

  final double serviceCost;
  final int quantity;
  final double discountAmount;
  final String? couponCode;
  final double couponDiscount;
  final double campaignDiscount;
  final double taxAmount;
  final double totalCost;

  final double partialAmount;
  final bool isPartial;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Service? service;
  final Category? category;
  final SubCategory? subCategory;

  CartItem({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.serviceId,
    required this.categoryId,
    required this.subCategoryId,
    required this.variantKey,
    required this.variationId,
    required this.serviceCost,
    required this.quantity,
    required this.discountAmount,
    required this.couponCode,
    required this.couponDiscount,
    required this.campaignDiscount,
    required this.taxAmount,
    required this.totalCost,
    required this.partialAmount,
    required this.isPartial,
    required this.createdAt,
    required this.updatedAt,
    this.service,
    this.category,
    this.subCategory,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      providerId: json['provider_id'],
      serviceId: json['service_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      subCategoryId: json['sub_category_id'] ?? '',
      variantKey: json['variant_key'] ?? '',
      variationId: int.tryParse(json['variation_id'].toString()) ?? 0,

      serviceCost: double.tryParse(json['service_cost'].toString()) ?? 0.0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      discountAmount:
      double.tryParse(json['discount_amount'].toString()) ?? 0.0,
      couponCode: json['coupon_code'],
      couponDiscount:
      double.tryParse(json['coupon_discount'].toString()) ?? 0.0,
      campaignDiscount:
      double.tryParse(json['campaign_discount'].toString()) ?? 0.0,
      taxAmount:
      double.tryParse(json['tax_amount'].toString()) ?? 0.0,
      totalCost:
      double.tryParse(json['total_cost'].toString()) ?? 0.0,

      partialAmount:
      double.tryParse(json['partial_amount'].toString()) ?? 0.0,
      isPartial: json['is_partial'] == 1,

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,

      service:
      json['service'] != null ? Service.fromJson(json['service']) : null,
      category:
      json['category'] != null ? Category.fromJson(json['category']) : null,
      subCategory: json['sub_category'] != null
          ? SubCategory.fromJson(json['sub_category'])
          : null,
    );
  }
}
class Service {
  final String id;
  final String name;
  final String shortDescription;
  final String description;
  final String thumbnailFullPath;
  final String coverImageFullPath;
  final double tax;
  final double avgRating;
  final int ratingCount;
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.thumbnailFullPath,
    required this.coverImageFullPath,
    required this.tax,
    required this.avgRating,
    required this.ratingCount,
    required this.isActive,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      shortDescription: json['short_description'] ?? '',
      description: json['description'] ?? '',
      thumbnailFullPath: json['thumbnail_full_path'] ?? '',
      coverImageFullPath: json['cover_image_full_path'] ?? '',
      tax: double.tryParse(json['tax'].toString()) ?? 0.0,
      avgRating: double.tryParse(json['avg_rating'].toString()) ?? 0.0,
      ratingCount: int.tryParse(json['rating_count'].toString()) ?? 0,
      isActive: json['is_active'] == 1,
    );
  }
}
class Category {
  final String id;
  final String name;
  final String imageFullPath;
  final bool isFeatured;

  Category({
    required this.id,
    required this.name,
    required this.imageFullPath,
    required this.isFeatured,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageFullPath: json['image_full_path'] ?? '',
      isFeatured: json['is_featured'] == 1,
    );
  }
}
class SubCategory {
  final String id;
  final String name;
  final String description;
  final String imageFullPath;

  SubCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageFullPath,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageFullPath: json['image_full_path'] ?? '',
    );
  }
}
