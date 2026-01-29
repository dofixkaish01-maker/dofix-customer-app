import 'dart:convert';

import 'package:do_fix/model/variation_model.dart';
import 'category_model.dart';
import 'extra_model.dart';

class ServiceModel {
  final String? id;
  final String? name;
  final String? shortDescription;
  final String? description;
  final String? coverImage;
  final String? thumbnail;
  final String? servicCost;
  final String? categoryId;
  final String? subCategoryId;
  final double? tax;
  final int? orderCount;
  final int? isActive;
  final int? ratingCount;
  final double? avgRating;
  final String? minBiddingPrice;
  final String? quantity;
  final int? isFavorite;
  final String? thumbnailFullPath;
  final String? coverImageFullPath;
  final Category? category;
  final SubCategory? subCategory;
  final List<Variation>? variations;
  final List<ExtraModel>? extras;


  ServiceModel( {
    this.id,
    this.name,
    this.shortDescription,
    this.servicCost,
    this.description,
    this.coverImage,
    this.thumbnail,
    this.categoryId,
    this.subCategoryId,
    this.tax,
    this.orderCount,
    this.isActive,
    this.ratingCount,
    this.avgRating,
    this.minBiddingPrice,
    this.isFavorite,
    this.thumbnailFullPath,
    this.coverImageFullPath,
    this.category,
    this.variations,
    this.subCategory,
    this.quantity, this.extras,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      shortDescription: json['short_description'],
      servicCost: json['service_cost'].toString(),
      description: json['description'],
      coverImage: json['cover_image'],
      thumbnail: json['thumbnail'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      tax: json['tax'] != null ? (json['tax'] as num).toDouble() : null,
      orderCount: json['order_count'],
      isActive: json['is_active'],
      ratingCount: json['rating_count'],
        quantity: json['quantity'].toString(),
      avgRating: json['avg_rating'] != null ? (json['avg_rating'] as num).toDouble() : null,
      minBiddingPrice: json['min_bidding_price'],
      isFavorite: json['is_favorite'],
      thumbnailFullPath: json['thumbnail_full_path'],
      coverImageFullPath: json['cover_image_full_path'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      subCategory: json['sub_category'] != null ? SubCategory.fromJson(json['sub_category']) : null,
      variations: json['variations'] != null
          ? (json['variations'] as List).map((e) => Variation.fromJson(e)).toList()
          : [],
      extras: json['extras'] != null
          ? (json['extras'] as List)
          .map((e) => ExtraModel.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_description': shortDescription,
      'description': description,
      'cover_image': coverImage,
      'thumbnail': thumbnail,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'tax': tax,
      'order_count': orderCount,
      'is_active': isActive,
      'rating_count': ratingCount,
      'avg_rating': avgRating,
      'min_bidding_price': minBiddingPrice,
      'is_favorite': isFavorite,
      'thumbnail_full_path': thumbnailFullPath,
      'cover_image_full_path': coverImageFullPath,
      'category': category?.toJson(),
      'variations': variations?.map((e) => e.toJson()).toList(),
    };
  }
}

class Services {
  List<ServiceModel>? data;

  Services({this.data});

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      data: json['data'] != null
          ? (json['data'] as List).map((e) => ServiceModel.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class SubCategoryModel {
  List<SubCategory>? data;

  SubCategoryModel({this.data});

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      data: json['data'] != null
          ? (json['data'] as List).map((e) => SubCategory.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class SubCategory {
  final String? id;
  final String? name;
  final String? thumbnailFullPath;
  final String? coverImageFullPath;

  SubCategory({
    this.id,
    this.name,
    this.thumbnailFullPath,
    this.coverImageFullPath,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
      thumbnailFullPath: json['image_full_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_full_path': thumbnailFullPath,
    };
  }
}

class CartResponseModel {
  final String? responseCode;
  final String? message;
  final CartContent? content;
  final List<dynamic>? errors;

  CartResponseModel({
    this.responseCode,
    this.message,
    this.content,
    this.errors,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      responseCode: json['response_code'],
      message: json['message'],
      content: json['content'] != null
          ? CartContent.fromJson(json['content'])
          : null,
      errors: json['errors'] ?? [],
    );
  }
}

class CartContent {
  final dynamic totalCost;
  final dynamic referralAmount;
  final dynamic walletBalance;
  final CartData? cart;

  CartContent({
    this.totalCost,
    this.referralAmount,
    this.walletBalance,
    this.cart,
  });

  factory CartContent.fromJson(Map<String, dynamic> json) {
    return CartContent(
      totalCost: json['total_cost'],
      referralAmount: json['referral_amount'],
      walletBalance: json['wallet_balance'],
      cart: json['cart'] != null ? CartData.fromJson(json['cart']) : null,
    );
  }
}

class CartData {
  final int? currentPage;
  final List<CartItem>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<PaginationLink>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  CartData({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    return CartData(
      currentPage: json['current_page'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CartItem.fromJson(e))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: (json['links'] as List<dynamic>?)
          ?.map((e) => PaginationLink.fromJson(e))
          .toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class CartItem {
  final String? id;
  final String? customerId;
  final String? providerId;
  final String? serviceId;
  final String? categoryId;
  final String? subCategoryId;
  final String? variantKey;
  final dynamic serviceCost;
  final int? quantity;
  final dynamic discountAmount;
  final String? couponCode;
  final dynamic couponDiscount;
  final dynamic campaignDiscount;
  final dynamic taxAmount;
  final dynamic totalCost;
  final String? createdAt;
  final String? updatedAt;
  final int? isGuest;
  final String? couponId;
  final Customer? customer;
  final dynamic provider;
  final CategoryCart? category;
  final CategoryCart? subCategory;
  final dynamic service;

  CartItem({
    this.id,
    this.customerId,
    this.providerId,
    this.serviceId,
    this.categoryId,
    this.subCategoryId,
    this.variantKey,
    this.serviceCost,
    this.quantity,
    this.discountAmount,
    this.couponCode,
    this.couponDiscount,
    this.campaignDiscount,
    this.taxAmount,
    this.totalCost,
    this.createdAt,
    this.updatedAt,
    this.isGuest,
    this.couponId,
    this.customer,
    this.provider,
    this.category,
    this.subCategory,
    this.service,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      customerId: json['customer_id'],
      providerId: json['provider_id'],
      serviceId: json['service_id'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      variantKey: json['variant_key'],
      serviceCost: json['service_cost'],
      quantity: json['quantity'],
      discountAmount: json['discount_amount'],
      couponCode: json['coupon_code'],
      couponDiscount: json['coupon_discount'],
      campaignDiscount: json['campaign_discount'],
      taxAmount: json['tax_amount'],
      totalCost: json['total_cost'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isGuest: json['is_guest'],
      couponId: json['coupon_id'],
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
      provider: json['provider'],
      category: json['category'] != null
          ? CategoryCart.fromJson(json['category'])
          : null,
      subCategory: json['sub_category'] != null
          ? CategoryCart.fromJson(json['sub_category'])
          : null,
      service: json['service'],
    );
  }
}

class Customer {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? identificationNumber;
  final String? identificationType;
  final List<dynamic>? identificationImage;
  final String? dateOfBirth;
  final String? gender;
  final String? profileImage;
  final String? fcmToken;
  final int? isPhoneVerified;
  final int? isEmailVerified;
  final String? phoneVerifiedAt;
  final String? emailVerifiedAt;
  final int? isActive;
  final String? userType;
  final String? rememberToken;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;
  final dynamic walletBalance;
  final dynamic loyaltyPoint;
  final String? refCode;
  final String? referredBy;
  final int? loginHitCount;
  final int? isTempBlocked;
  final String? tempBlockTime;
  final String? currentLanguageKey;
  final String? profileImageFullPath;
  final List<dynamic>? identificationImageFullPath;
  final dynamic storage;

  Customer({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.identificationNumber,
    this.identificationType,
    this.identificationImage,
    this.dateOfBirth,
    this.gender,
    this.profileImage,
    this.fcmToken,
    this.isPhoneVerified,
    this.isEmailVerified,
    this.phoneVerifiedAt,
    this.emailVerifiedAt,
    this.isActive,
    this.userType,
    this.rememberToken,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.walletBalance,
    this.loyaltyPoint,
    this.refCode,
    this.referredBy,
    this.loginHitCount,
    this.isTempBlocked,
    this.tempBlockTime,
    this.currentLanguageKey,
    this.profileImageFullPath,
    this.identificationImageFullPath,
    this.storage,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      identificationNumber: json['identification_number'],
      identificationType: json['identification_type'],
      identificationImage: json['identification_image'] ?? [],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      profileImage: json['profile_image'],
      fcmToken: json['fcm_token'],
      isPhoneVerified: json['is_phone_verified'],
      isEmailVerified: json['is_email_verified'],
      phoneVerifiedAt: json['phone_verified_at'],
      emailVerifiedAt: json['email_verified_at'],
      isActive: json['is_active'],
      userType: json['user_type'],
      rememberToken: json['remember_token'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      walletBalance: json['wallet_balance'],
      loyaltyPoint: json['loyalty_point'],
      refCode: json['ref_code'],
      referredBy: json['referred_by'],
      loginHitCount: json['login_hit_count'],
      isTempBlocked: json['is_temp_blocked'],
      tempBlockTime: json['temp_block_time'],
      currentLanguageKey: json['current_language_key'],
      profileImageFullPath: json['profile_image_full_path'],
      identificationImageFullPath:
      json['identification_image_full_path'] ?? [],
      storage: json['storage'],
    );
  }
}

class CategoryCart {
  final String? id;
  final String? parentId;
  final String? name;
  final String? image;
  final int? position;
  final String? description;
  final int? isActive;
  final int? isFeatured;
  final int? topRated;
  final int? quickRepair;
  final String? createdAt;
  final String? updatedAt;
  final String? imageFullPath;
  final List<dynamic>? translations;
  final dynamic storage;

  CategoryCart({
    this.id,
    this.parentId,
    this.name,
    this.image,
    this.position,
    this.description,
    this.isActive,
    this.isFeatured,
    this.topRated,
    this.quickRepair,
    this.createdAt,
    this.updatedAt,
    this.imageFullPath,
    this.translations,
    this.storage,
  });

  factory CategoryCart.fromJson(Map<String, dynamic> json) {
    return CategoryCart(
      id: json['id'],
      parentId: json['parent_id'],
      name: json['name'],
      image: json['image'],
      position: json['position'],
      description: json['description'],
      isActive: json['is_active'],
      isFeatured: json['is_featured'],
      topRated: json['top_rated'],
      quickRepair: json['quick_repair'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      imageFullPath: json['image_full_path'],
      translations: json['translations'],
      storage: json['storage'],
    );
  }
}

class PaginationLink {
  final String? url;
  final String? label;
  final bool? active;

  PaginationLink({
    this.url,
    this.label,
    this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}

