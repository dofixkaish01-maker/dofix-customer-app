class ApiResponse {
  final String responseCode;
  final String message;
  final ContentData content;
  final List<dynamic> errors;

  ApiResponse({
    required this.responseCode,
    required this.message,
    required this.content,
    required this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      responseCode: json['response_code'] as String,
      message: json['message'] as String,
      content: ContentData.fromJson(json['content']),
      errors: json['errors'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_code': responseCode,
      'message': message,
      'content': content.toJson(),
      'errors': errors,
    };
  }
}

class PageInfo {
  final String id;
  final String key;
  final String value;
  final String type;
  final int isActive;
  final String createdAt;
  final String updatedAt;
  final List<dynamic> translations;

  PageInfo({
    required this.id,
    required this.key,
    required this.value,
    required this.type,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      id: json['id'] as String,
      key: json['key'] as String,
      value: json['value'] as String,
      type: json['type'] as String,
      isActive: json['is_active'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      translations: json['translations'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'type': type,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'translations': translations,
    };
  }
}

class PolicyImages {
  final String? aboutUs;
  final String? termsAndConditions;
  final String? refundPolicy;
  final String? returnPolicy;
  final String? cancellationPolicy;
  final String? privacyPolicy;

  PolicyImages({
    this.aboutUs,
    this.termsAndConditions,
    this.refundPolicy,
    this.returnPolicy,
    this.cancellationPolicy,
    this.privacyPolicy,
  });

  factory PolicyImages.fromJson(Map<String, dynamic> json) {
    return PolicyImages(
      aboutUs: json['about_us'],
      termsAndConditions: json['terms_and_conditions'],
      refundPolicy: json['refund_policy'],
      returnPolicy: json['return_policy'],
      cancellationPolicy: json['cancellation_policy'],
      privacyPolicy: json['privacy_policy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'about_us': aboutUs,
      'terms_and_conditions': termsAndConditions,
      'refund_policy': refundPolicy,
      'return_policy': returnPolicy,
      'cancellation_policy': cancellationPolicy,
      'privacy_policy': privacyPolicy,
    };
  }
}

class ContentData {
  final PageInfo? aboutUs;
  final PageInfo? termsAndConditions;
  final PageInfo? refundPolicy;
  final PageInfo? returnPolicy;
  final PageInfo? cancellationPolicy;
  final PageInfo? privacyPolicy;
  final PolicyImages images;

  ContentData({
    this.aboutUs,
    this.termsAndConditions,
    this.refundPolicy,
    this.returnPolicy,
    this.cancellationPolicy,
    this.privacyPolicy,
    required this.images,
  });

  factory ContentData.fromJson(Map<String, dynamic> json) {
    return ContentData(
      aboutUs: json['about_us'] != null ? PageInfo.fromJson(json['about_us']) : null,
      termsAndConditions: json['terms_and_conditions'] != null ? PageInfo.fromJson(json['terms_and_conditions']) : null,
      refundPolicy: json['refund_policy'] != null ? PageInfo.fromJson(json['refund_policy']) : null,
      returnPolicy: json['return_policy'] != null ? PageInfo.fromJson(json['return_policy']) : null,
      cancellationPolicy: json['cancellation_policy'] != null ? PageInfo.fromJson(json['cancellation_policy']) : null,
      privacyPolicy: json['privacy_policy'] != null ? PageInfo.fromJson(json['privacy_policy']) : null,
      images: PolicyImages.fromJson(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'about_us': aboutUs?.toJson(),
      'terms_and_conditions': termsAndConditions?.toJson(),
      'refund_policy': refundPolicy?.toJson(),
      'return_policy': returnPolicy?.toJson(),
      'cancellation_policy': cancellationPolicy?.toJson(),
      'privacy_policy': privacyPolicy?.toJson(),
      'images': images.toJson(),
    };
  }
}
