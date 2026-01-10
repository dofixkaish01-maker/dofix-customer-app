class ServiceReviewsModel {
  final List<ServiceReview>? reviews;

  ServiceReviewsModel({
    this.reviews,
  });

  factory ServiceReviewsModel.fromJson(Map<String, dynamic> json) {
    return ServiceReviewsModel(
      reviews: (json['reviews'] as List)
          .map((e) => ServiceReview.fromJson(e))
          .toList(),
    );
  }
}

class ServiceReview {
  final String? id;
  final int? readableId;
  final String? bookingId;
  final String? serviceId;
  final String? providerId;
  final int? reviewRating;
  final String? reviewComment;
  final List<dynamic>? reviewImages;
  final DateTime? bookingDate;
  final int? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? customerId;
  final Customer? customer;

  ServiceReview({
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
    this.customer,
  });

  factory ServiceReview.fromJson(Map<String, dynamic> json) {
    return ServiceReview(
      id: json['id'],
      readableId: json['readable_id'],
      bookingId: json['booking_id'],
      serviceId: json['service_id'],
      providerId: json['provider_id'],
      reviewRating: json['review_rating'],
      reviewComment: json['review_comment'],
      reviewImages: json['review_images'],
      bookingDate: json['booking_date'] != null
          ? DateTime.parse(json['booking_date'])
          : null,
      isActive: json['is_active'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      customerId: json['customer_id'],
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
    );
  }
}

class Customer {
  final String? id;
  final String? firstName;
  final String? lastName;
  final dynamic profileImageFullPath;
  final List<dynamic>? identificationImageFullPath;

  Customer({
    this.id,
    this.firstName,
    this.lastName,
    this.profileImageFullPath,
    this.identificationImageFullPath,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImageFullPath: json['profile_image_full_path'],
      identificationImageFullPath:
          json['identification_image_full_path'] != null
              ? List<dynamic>.from(json['identification_image_full_path'])
              : null,
    );
  }
}
