class SpecialUserReviews {
  final String responseCode;
  final String message;
  final Content content;
  final List<dynamic> errors;

  SpecialUserReviews({
    required this.responseCode,
    required this.message,
    required this.content,
    required this.errors,
  });
  factory SpecialUserReviews.fromJson(Map<String, dynamic> json) {
    return SpecialUserReviews(
      responseCode: json['response_code'],
      message: json['message'],
      content: Content.fromJson(json['content']),
      errors: json['errors'] ?? [],
    );
  }
}

class Content {
  final String customerId;
  final String customerName;
  final String customerImage;
  final List<Review> reviews;

  Content({
    required this.customerId,
    required this.customerName,
    required this.customerImage,
    required this.reviews,
  });
  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      customerImage: json['customer_image'],
      reviews: (json['reviews'] as List)
          .map((e) => Review.fromJson(e))
          .toList(),
    );
  }
}

class Review {
  final String id;
  final int readableId;
  final String bookingId;
  final String serviceId;
  final String? providerId;
  final int reviewRating;
  final String? reviewComment;
  final List<dynamic> reviewImages;
  final DateTime bookingDate;
  final int isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String customerId;
  final String? variantKey;
  final String? serviceName;

  Review({
    required this.id,
    required this.readableId,
    required this.bookingId,
    required this.serviceId,
    this.providerId,
    required this.reviewRating,
    this.reviewComment,
    required this.reviewImages,
    required this.bookingDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.customerId,
    this.variantKey,
    this.serviceName,
  });
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      readableId: json['readable_id'],
      bookingId: json['booking_id'],
      serviceId: json['service_id'],
      providerId: json['provider_id'],
      reviewRating: json['review_rating'],
      reviewComment: json['review_comment'],
      reviewImages: json['review_images'] ?? [],
      bookingDate: DateTime.parse(json['booking_date']),
      isActive: json['is_active'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.parse(json['updated_at']),
      customerId: json['customer_id'],
      variantKey: json['variant_key'],
      serviceName: json['service_name'],
    );
  }
}