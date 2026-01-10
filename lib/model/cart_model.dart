import 'dart:convert';

class ServiceOrder {
  final String id;
  final String customerId;
  final String? providerId;
  final String serviceId;
  final String categoryId;
  final String subCategoryId;
  final String variantKey;
  final double serviceCost;
  final int quantity;
  final double discountAmount;
  final String? couponCode;
  final double couponDiscount;
  final double campaignDiscount;
  final double taxAmount;
  final double totalCost;
  final String createdAt;
  final String updatedAt;
  final int isGuest;
  final String couponId;
  final Category? category;

  ServiceOrder({
    required this.id,
    required this.customerId,
    this.providerId,
    required this.serviceId,
    required this.categoryId,
    required this.subCategoryId,
    required this.variantKey,
    required this.serviceCost,
    required this.quantity,
    required this.discountAmount,
    this.couponCode,
    required this.couponDiscount,
    required this.campaignDiscount,
    required this.taxAmount,
    required this.totalCost,
    required this.createdAt,
    required this.updatedAt,
    required this.isGuest,
    required this.couponId,
    this.category,
  });

  factory ServiceOrder.fromJson(Map<String, dynamic> json) {
    return ServiceOrder(
      id: json['id'],
      customerId: json['customer_id'],
      providerId: json['provider_id'],
      serviceId: json['service_id'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      variantKey: json['variant_key'],
      serviceCost: (json['service_cost'] as num).toDouble(),
      quantity: json['quantity'],
      discountAmount: (json['discount_amount'] as num).toDouble(),
      couponCode: json['coupon_code'],
      couponDiscount: (json['coupon_discount'] as num).toDouble(),
      campaignDiscount: (json['campaign_discount'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isGuest: json['is_guest'],
      couponId: json['coupon_id'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'provider_id': providerId,
      'service_id': serviceId,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'variant_key': variantKey,
      'service_cost': serviceCost,
      'quantity': quantity,
      'discount_amount': discountAmount,
      'coupon_code': couponCode,
      'coupon_discount': couponDiscount,
      'campaign_discount': campaignDiscount,
      'tax_amount': taxAmount,
      'total_cost': totalCost,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_guest': isGuest,
      'coupon_id': couponId,
      'category': category?.toJson(),
    };
  }
}

class Category {
  final String id;
  final String parentId;
  final String name;
  final String image;
  final int position;
  final String? description;
  final int isActive;
  final int isFeatured;
  final String createdAt;
  final String updatedAt;
  final String imageFullPath;

  Category({
    required this.id,
    required this.parentId,
    required this.name,
    required this.image,
    required this.position,
    this.description,
    required this.isActive,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    required this.imageFullPath,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      parentId: json['parent_id'],
      name: json['name'],
      image: json['image'],
      position: json['position'],
      description: json['description'],
      isActive: json['is_active'],
      isFeatured: json['is_featured'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      imageFullPath: json['image_full_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'image': image,
      'position': position,
      'description': description,
      'is_active': isActive,
      'is_featured': isFeatured,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'image_full_path': imageFullPath,
    };
  }
}
