import 'dart:convert';

ReviewRatingModel reviewRatingModelFromJson(String str) =>
    ReviewRatingModel.fromJson(json.decode(str));

String reviewRatingModelToJson(ReviewRatingModel data) =>
    json.encode(data.toJson());

class ReviewRatingModel {
  String? responseCode;
  String? message;
  List<Content>? content;
  List<dynamic>? errors;

  ReviewRatingModel({
    this.responseCode,
    this.message,
    this.content,
    this.errors,
  });

  factory ReviewRatingModel.fromJson(Map<String, dynamic> json) =>
      ReviewRatingModel(
        responseCode: json["response_code"],
        message: json["message"],
        content: json["content"] == null
            ? []
            : List<Content>.from(
                json["content"]!.map((x) => Content.fromJson(x))),
        errors: json["errors"] == null
            ? []
            : List<dynamic>.from(json["errors"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "response_code": responseCode,
        "message": message,
        "content": content == null
            ? []
            : List<dynamic>.from(content!.map((x) => x.toJson())),
        "errors":
            errors == null ? [] : List<dynamic>.from(errors!.map((x) => x)),
      };
}

class Content {
  String? id;
  String? name;
  String? shortDescription;
  String? description;
  String? coverImage;
  String? thumbnail;
  String? categoryId;
  String? subCategoryId;
  int? tax;
  int? orderCount;
  int? isActive;
  int? ratingCount;
  int? avgRating;
  int? minBiddingPrice;
  dynamic deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? thumbnailFullPath;
  String? coverImageFullPath;
  List<Review>? reviews;
  List<dynamic>? translations;
  dynamic storageThumbnail;
  dynamic storageCoverImage;

  Content({
    this.id,
    this.name,
    this.shortDescription,
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
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.thumbnailFullPath,
    this.coverImageFullPath,
    this.reviews,
    this.translations,
    this.storageThumbnail,
    this.storageCoverImage,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        id: json["id"],
        name: json["name"],
        shortDescription: json["short_description"],
        description: json["description"],
        coverImage: json["cover_image"],
        thumbnail: json["thumbnail"],
        categoryId: json["category_id"],
        subCategoryId: json["sub_category_id"],
        tax: json["tax"] is int
            ? json["tax"]
            : int.tryParse(json["tax"].toString()),
        orderCount: json["order_count"] is int
            ? json["order_count"]
            : int.tryParse(json["order_count"].toString()),
        isActive: json["is_active"] is int
            ? json["is_active"]
            : int.tryParse(json["is_active"].toString()),
        ratingCount: json["rating_count"] is int
            ? json["rating_count"]
            : int.tryParse(json["rating_count"].toString()),
        avgRating: json["avg_rating"] is int
            ? json["avg_rating"]
            : int.tryParse(json["avg_rating"].toString()),
        minBiddingPrice: json["min_bidding_price"] is int
            ? json["min_bidding_price"]
            : int.tryParse(json["min_bidding_price"].toString()),
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        thumbnailFullPath: json["thumbnail_full_path"],
        coverImageFullPath: json["cover_image_full_path"],
        reviews: json["reviews"] == null
            ? []
            : List<Review>.from(
                json["reviews"]!.map((x) => Review.fromJson(x))),
        translations: json["translations"] == null
            ? []
            : List<dynamic>.from(json["translations"].map((x) => x)),
        storageThumbnail: json["storage_thumbnail"],
        storageCoverImage: json["storage_cover_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "short_description": shortDescription,
        "description": description,
        "cover_image": coverImage,
        "thumbnail": thumbnail,
        "category_id": categoryId,
        "sub_category_id": subCategoryId,
        "tax": tax,
        "order_count": orderCount,
        "is_active": isActive,
        "rating_count": ratingCount,
        "avg_rating": avgRating,
        "min_bidding_price": minBiddingPrice,
        "deleted_at": deletedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "thumbnail_full_path": thumbnailFullPath,
        "cover_image_full_path": coverImageFullPath,
        "reviews": reviews == null
            ? []
            : List<dynamic>.from(reviews!.map((x) => x.toJson())),
        "translations": translations == null
            ? []
            : List<dynamic>.from(translations!.map((x) => x)),
        "storage_thumbnail": storageThumbnail,
        "storage_cover_image": storageCoverImage,
      };
}

class Review {
  String? id;
  String? readableId;
  String? bookingId;
  String? serviceId;
  String? providerId;
  int? reviewRating;
  String? reviewComment;
  List<dynamic>? reviewImages;
  DateTime? bookingDate;
  int? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? customerId;
  dynamic reviewReply;

  Review({
    this.id,
    this.readableId,
    this.bookingId,
    this.serviceId,
    this.providerId,
    this.reviewRating,
    this.reviewComment,
    this.reviewImages,
    this.bookingDate,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.customerId,
    this.reviewReply,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        readableId: json["readable_id"].toString(),
        bookingId: json["booking_id"],
        serviceId: json["service_id"],
        providerId: json["provider_id"],
        reviewRating: json["review_rating"] is int
            ? json["review_rating"]
            : int.tryParse(json["review_rating"].toString()),
        reviewComment: json["review_comment"],
        reviewImages: json["review_images"] == null
            ? []
            : List<dynamic>.from(json["review_images"]!.map((x) => x)),
        isActive: json["is_active"] is int
            ? json["is_active"]
            : int.tryParse(json["is_active"].toString()),
        bookingDate: json["booking_date"] == null
            ? null
            : DateTime.tryParse(json["booking_date"].toString()),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"].toString()),
        customerId: json["customer_id"],
        reviewReply: json["review_reply"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "readable_id": readableId,
        "booking_id": bookingId,
        "service_id": serviceId,
        "provider_id": providerId,
        "review_rating": reviewRating,
        "review_comment": reviewComment,
        "review_images": reviewImages == null
            ? []
            : List<dynamic>.from(reviewImages!.map((x) => x)),
        "booking_date": bookingDate?.toIso8601String(),
        "is_active": isActive,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "customer_id": customerId,
        "review_reply": reviewReply,
      };
}
