class ServiceReviewResponseModel {
  final String? responseCode;
  final String? message;
  final ServiceReviewContent? content;
  final List<dynamic>? errors;

  ServiceReviewResponseModel({
    this.responseCode,
    this.message,
    this.content,
    this.errors,
  });

  factory ServiceReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return ServiceReviewResponseModel(
      responseCode: json['response_code'],
      message: json['message'],
      content: json['content'] != null
          ? ServiceReviewContent.fromJson(json['content'])
          : null,
      errors: json['errors'] != null ? List<dynamic>.from(json['errors']) : [],
    );
  }
}

class ServiceReviewContent {
  final ReviewPagination? reviews;
  final RatingSummary? rating;

  ServiceReviewContent({
    this.reviews,
    this.rating,
  });

  factory ServiceReviewContent.fromJson(Map<String, dynamic> json) {
    return ServiceReviewContent(
      reviews: json['reviews'] != null
          ? ReviewPagination.fromJson(json['reviews'])
          : null,
      rating: json['rating'] != null
          ? RatingSummary.fromJson(json['rating'])
          : null,
    );
  }
}

class ReviewPagination {
  final int? currentPage;
  final List<ServiceReview>? data;
  final int? total;
  final int? perPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  ReviewPagination({
    this.currentPage,
    this.data,
    this.total,
    this.perPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory ReviewPagination.fromJson(Map<String, dynamic> json) {
    return ReviewPagination(
      currentPage: json['current_page'],
      data: json['data'] != null
          ? List<ServiceReview>.from(
        json['data'].map((e) => ServiceReview.fromJson(e)),
      )
          : [],
      total: json['total'],
      perPage: json['per_page'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
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
  final ProviderData? provider;
  final dynamic reviewReply;

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
    this.provider,
    this.reviewReply,
  });

  factory ServiceReview.fromJson(Map<String, dynamic> json) {
    return ServiceReview(
      id: json['id'],
      readableId: json['readable_id'],
      bookingId: json['booking_id'],
      serviceId: json['service_id'],
      providerId: json['provider_id'],
      reviewRating: json['review_rating'] != null
          ? int.tryParse(json['review_rating'].toString())
          : null,
      reviewComment: json['review_comment'],
      reviewImages: json['review_images'] == null
          ? []
          : List<dynamic>.from(json['review_images']),
      bookingDate: json['booking_date'] != null
          ? DateTime.tryParse(json['booking_date'].toString())
          : null,
      isActive: json['is_active'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      customerId: json['customer_id'],
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
      provider: json['provider'] != null
          ? ProviderData.fromJson(json['provider'])
          : null,
      reviewReply: json['review_reply'],
    );
  }
}

class Customer {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final dynamic profileImageFullPath;


  Customer({
    this.id,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.profileImageFullPath,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
      profileImageFullPath: json['full_profile_path'],
    );
  }
}

class ProviderData {
  final String? id;
  final String? fullName;
  final String? companyName;
  final double? avgRating;
  final int? ratingCount;

  ProviderData({
    this.id,
    this.fullName,
    this.companyName,
    this.avgRating,
    this.ratingCount,
  });

  factory ProviderData.fromJson(Map<String, dynamic> json) {
    return ProviderData(
      id: json['id'],
      fullName: json['full_name'],
      companyName: json['company_name'],
      avgRating: json['avg_rating'] != null
          ? double.tryParse(json['avg_rating'].toString())
          : null,
      ratingCount: json['rating_count'],
    );
  }
}

class RatingSummary {
  final int? ratingCount;
  final int? reviewCount;
  final double? averageRating;
  final List<RatingGroupCount>? ratingGroupCount;

  RatingSummary({
    this.ratingCount,
    this.reviewCount,
    this.averageRating,
    this.ratingGroupCount,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      ratingCount: json['rating_count'],
      reviewCount: json['review_count'],
      averageRating: json['average_rating'] != null
          ? double.tryParse(json['average_rating'].toString())
          : null,
      ratingGroupCount: json['rating_group_count'] != null
          ? List<RatingGroupCount>.from(
        json['rating_group_count'].map(
              (e) => RatingGroupCount.fromJson(e),
        ),
      )
          : [],
    );
  }
}

class RatingGroupCount {
  final int? reviewRating;
  final int? totalComment;
  final int? total;

  RatingGroupCount({
    this.reviewRating,
    this.totalComment,
    this.total,
  });

  factory RatingGroupCount.fromJson(Map<String, dynamic> json) {
    return RatingGroupCount(
      reviewRating: json['review_rating'],
      totalComment: json['total_comment'],
      total: json['total'],
    );
  }
}



// class ServiceReviewsModel {
//   final List<ServiceReview>? reviews;
//
//   ServiceReviewsModel({
//     this.reviews,
//   });
//
//   factory ServiceReviewsModel.fromJson(Map<String, dynamic> json) {
//     return ServiceReviewsModel(
//       reviews: json['reviews'] != null
//           ? List<ServiceReview>.from(
//           json['reviews'].map((e) => ServiceReview.fromJson(e)))
//           : [],
//     );
//   }
// }
//
// class ServiceReview {
//   final String? id;
//   final int? readableId;
//   final String? bookingId;
//   final String? serviceId;
//   final String? providerId;
//   final int? reviewRating;
//   final String? reviewComment;
//   final List<dynamic>? reviewImages;
//   final DateTime? bookingDate;
//   final int? isActive;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final String? customerId;
//   final Customer? customer;
//
//   ServiceReview({
//     this.id,
//     this.readableId,
//     this.bookingId,
//     this.serviceId,
//     this.providerId,
//     this.reviewRating,
//     this.reviewComment,
//     this.reviewImages,
//     this.bookingDate,
//     this.isActive,
//     this.createdAt,
//     this.updatedAt,
//     this.customerId,
//     this.customer,
//   });
//
//   factory ServiceReview.fromJson(Map<String, dynamic> json) {
//
//     /// DEBUG PRINTS
//     print("--------- REVIEW DATA ---------");
//     print("ID: ${json['id']}");
//     print("Rating Raw: ${json['review_rating']}");
//     print("Comment: ${json['review_comment']}");
//     print("Customer: ${json['customer']}");
//     print("-------------------------------");
//
//     return ServiceReview(
//       id: json['id'],
//       readableId: json['readable_id'],
//       bookingId: json['booking_id'],
//       serviceId: json['service_id'],
//       providerId: json['provider_id'],
//
//       reviewRating: json['review_rating'] != null
//           ? int.tryParse(json['review_rating'].toString())
//           : null,
//
//       reviewComment: json['review_comment'],
//       reviewImages: json['review_images'],
//
//       bookingDate: json['booking_date'] != null
//           ? DateTime.parse(json['booking_date'])
//           : null,
//
//       isActive: json['is_active'],
//
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'])
//           : null,
//
//       updatedAt: json['updated_at'] != null
//           ? DateTime.parse(json['updated_at'])
//           : null,
//
//       customerId: json['customer_id'],
//
//       customer: json['customer'] != null
//           ? Customer.fromJson(json['customer'])
//           : null,
//     );
//   }
// }
//
//
// class Customer {
//   final String? id;
//   final String? firstName;
//   final String? lastName;
//   final dynamic profileImageFullPath;
//   final List<dynamic>? identificationImageFullPath;
//
//   Customer({
//     this.id,
//     this.firstName,
//     this.lastName,
//     this.profileImageFullPath,
//     this.identificationImageFullPath,
//   });
//
//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       id: json['id'],
//       firstName: json['first_name'],
//       lastName: json['last_name'],
//       profileImageFullPath: json['profile_image_full_path'],
//       identificationImageFullPath:
//           json['identification_image_full_path'] != null
//               ? List<dynamic>.from(json['identification_image_full_path'])
//               : null,
//     );
//   }
// }
