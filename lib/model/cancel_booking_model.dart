import 'dart:convert';

CancelBookingModel cancelBookingModelFromJson(String str) =>
    CancelBookingModel.fromJson(json.decode(str));

String cancelBookingModelToJson(CancelBookingModel data) =>
    json.encode(data.toJson());

class CancelBookingModel {
  final String? responseCode;
  final String? message;
  final Content? content;
  final List<dynamic>? errors;

  CancelBookingModel({
    this.responseCode,
    this.message,
    this.content,
    this.errors,
  });

  factory CancelBookingModel.fromJson(Map<String, dynamic> json) =>
      CancelBookingModel(
        responseCode: json["response_code"],
        message: json["message"],
        content:
            json["content"] == null ? null : Content.fromJson(json["content"]),
        errors: json["errors"] == null
            ? []
            : List<dynamic>.from(json["errors"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "response_code": responseCode,
        "message": message,
        "content": content?.toJson(),
        "errors":
            errors == null ? [] : List<dynamic>.from(errors!.map((x) => x)),
      };
}

class Content {
  final String? id;
  final int? readableId;
  final String? customerId;
  final dynamic providerId;
  final String? zoneId;
  final String? bookingStatus;
  final int? isPaid;
  final String? paymentMethod;
  final String? transactionId;
  final int? totalBookingAmount;
  final double? totalTaxAmount;
  final int? totalDiscountAmount;
  final DateTime? serviceSchedule;
  final String? serviceAddressId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? categoryId;
  final String? subCategoryId;
  final dynamic servicemanId;
  final int? totalCampaignDiscountAmount;
  final int? totalCouponDiscountAmount;
  final dynamic couponCode;
  final int? isChecked;
  final int? servicePreference;
  final int? additionalCharge;
  final int? additionalTaxAmount;
  final int? additionalDiscountAmount;
  final int? additionalCampaignDiscountAmount;
  final String? removedCouponAmount;
  final dynamic reachImage;
  final dynamic preVideos;
  final dynamic postVideos;
  final dynamic preWorkImage;
  final dynamic evidencePhotos;
  final String? bookingOtp;
  final int? isGuest;
  final int? isVerified;
  final int? extraFee;
  final int? totalReferralDiscountAmount;
  final int? isRepeated;
  final dynamic assignedBy;
  final String? message;
  final dynamic cancelReson;
  final List<dynamic>? evidencePhotosFullPath;
  final List<dynamic>? preWorkImageFullPath;
  final Customer? customer;
  final List<BookingPartialPayment>? bookingPartialPayments;
  final dynamic provider;
  final dynamic serviceman;
  final List<dynamic>? repeat;

  Content({
    this.id,
    this.readableId,
    this.customerId,
    this.providerId,
    this.zoneId,
    this.bookingStatus,
    this.isPaid,
    this.paymentMethod,
    this.transactionId,
    this.totalBookingAmount,
    this.totalTaxAmount,
    this.totalDiscountAmount,
    this.serviceSchedule,
    this.serviceAddressId,
    this.createdAt,
    this.updatedAt,
    this.categoryId,
    this.subCategoryId,
    this.servicemanId,
    this.totalCampaignDiscountAmount,
    this.totalCouponDiscountAmount,
    this.couponCode,
    this.isChecked,
    this.servicePreference,
    this.additionalCharge,
    this.additionalTaxAmount,
    this.additionalDiscountAmount,
    this.additionalCampaignDiscountAmount,
    this.removedCouponAmount,
    this.reachImage,
    this.preVideos,
    this.postVideos,
    this.preWorkImage,
    this.evidencePhotos,
    this.bookingOtp,
    this.isGuest,
    this.isVerified,
    this.extraFee,
    this.totalReferralDiscountAmount,
    this.isRepeated,
    this.assignedBy,
    this.message,
    this.cancelReson,
    this.evidencePhotosFullPath,
    this.preWorkImageFullPath,
    this.customer,
    this.bookingPartialPayments,
    this.provider,
    this.serviceman,
    this.repeat,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        id: json["id"],
        readableId: json["readable_id"],
        customerId: json["customer_id"],
        providerId: json["provider_id"],
        zoneId: json["zone_id"],
        bookingStatus: json["booking_status"],
        isPaid: json["is_paid"],
        paymentMethod: json["payment_method"],
        transactionId: json["transaction_id"],
        totalBookingAmount: json["total_booking_amount"],
        totalTaxAmount: json["total_tax_amount"]?.toDouble(),
        totalDiscountAmount: json["total_discount_amount"],
        serviceSchedule: json["service_schedule"] == null
            ? null
            : DateTime.parse(json["service_schedule"]),
        serviceAddressId: json["service_address_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        categoryId: json["category_id"],
        subCategoryId: json["sub_category_id"],
        servicemanId: json["serviceman_id"],
        totalCampaignDiscountAmount: json["total_campaign_discount_amount"],
        totalCouponDiscountAmount: json["total_coupon_discount_amount"],
        couponCode: json["coupon_code"],
        isChecked: json["is_checked"],
        servicePreference: json["service_preference"],
        additionalCharge: json["additional_charge"],
        additionalTaxAmount: json["additional_tax_amount"],
        additionalDiscountAmount: json["additional_discount_amount"],
        additionalCampaignDiscountAmount:
            json["additional_campaign_discount_amount"],
        removedCouponAmount: json["removed_coupon_amount"],
        reachImage: json["reach_image"],
        preVideos: json["pre_videos"],
        postVideos: json["post_videos"],
        preWorkImage: json["pre_work_image"],
        evidencePhotos: json["evidence_photos"],
        bookingOtp: json["booking_otp"],
        isGuest: json["is_guest"],
        isVerified: json["is_verified"],
        extraFee: json["extra_fee"],
        totalReferralDiscountAmount: json["total_referral_discount_amount"],
        isRepeated: json["is_repeated"],
        assignedBy: json["assigned_by"],
        message: json["message"],
        cancelReson: json["cancel_reson"],
        evidencePhotosFullPath: json["evidence_photos_full_path"] == null
            ? []
            : List<dynamic>.from(
                json["evidence_photos_full_path"]!.map((x) => x)),
        preWorkImageFullPath: json["pre_work_image_full_path"] == null
            ? []
            : List<dynamic>.from(
                json["pre_work_image_full_path"]!.map((x) => x)),
        customer: json["customer"] == null
            ? null
            : Customer.fromJson(json["customer"]),
        bookingPartialPayments: json["booking_partial_payments"] == null
            ? []
            : List<BookingPartialPayment>.from(json["booking_partial_payments"]!
                .map((x) => BookingPartialPayment.fromJson(x))),
        provider: json["provider"],
        serviceman: json["serviceman"],
        repeat: json["repeat"] == null
            ? []
            : List<dynamic>.from(json["repeat"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "readable_id": readableId,
        "customer_id": customerId,
        "provider_id": providerId,
        "zone_id": zoneId,
        "booking_status": bookingStatus,
        "is_paid": isPaid,
        "payment_method": paymentMethod,
        "transaction_id": transactionId,
        "total_booking_amount": totalBookingAmount,
        "total_tax_amount": totalTaxAmount,
        "total_discount_amount": totalDiscountAmount,
        "service_schedule": serviceSchedule?.toIso8601String(),
        "service_address_id": serviceAddressId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "category_id": categoryId,
        "sub_category_id": subCategoryId,
        "serviceman_id": servicemanId,
        "total_campaign_discount_amount": totalCampaignDiscountAmount,
        "total_coupon_discount_amount": totalCouponDiscountAmount,
        "coupon_code": couponCode,
        "is_checked": isChecked,
        "service_preference": servicePreference,
        "additional_charge": additionalCharge,
        "additional_tax_amount": additionalTaxAmount,
        "additional_discount_amount": additionalDiscountAmount,
        "additional_campaign_discount_amount": additionalCampaignDiscountAmount,
        "removed_coupon_amount": removedCouponAmount,
        "reach_image": reachImage,
        "pre_videos": preVideos,
        "post_videos": postVideos,
        "pre_work_image": preWorkImage,
        "evidence_photos": evidencePhotos,
        "booking_otp": bookingOtp,
        "is_guest": isGuest,
        "is_verified": isVerified,
        "extra_fee": extraFee,
        "total_referral_discount_amount": totalReferralDiscountAmount,
        "is_repeated": isRepeated,
        "assigned_by": assignedBy,
        "message": message,
        "cancel_reson": cancelReson,
        "evidence_photos_full_path": evidencePhotosFullPath == null
            ? []
            : List<dynamic>.from(evidencePhotosFullPath!.map((x) => x)),
        "pre_work_image_full_path": preWorkImageFullPath == null
            ? []
            : List<dynamic>.from(preWorkImageFullPath!.map((x) => x)),
        "customer": customer?.toJson(),
        "booking_partial_payments": bookingPartialPayments == null
            ? []
            : List<dynamic>.from(
                bookingPartialPayments!.map((x) => x.toJson())),
        "provider": provider,
        "serviceman": serviceman,
        "repeat":
            repeat == null ? [] : List<dynamic>.from(repeat!.map((x) => x)),
      };
}

class BookingPartialPayment {
  final String? id;
  final String? bookingId;
  final String? paidWith;
  final String? paidAmount;
  final String? dueAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingPartialPayment({
    this.id,
    this.bookingId,
    this.paidWith,
    this.paidAmount,
    this.dueAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingPartialPayment.fromJson(Map<String, dynamic> json) =>
      BookingPartialPayment(
        id: json["id"],
        bookingId: json["booking_id"],
        paidWith: json["paid_with"],
        paidAmount: json["paid_amount"],
        dueAmount: json["due_amount"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "booking_id": bookingId,
        "paid_with": paidWith,
        "paid_amount": paidAmount,
        "due_amount": dueAmount,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Customer {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final dynamic identificationNumber;
  final String? identificationType;
  final List<dynamic>? identificationImage;
  final dynamic dateOfBirth;
  final String? gender;
  final String? profileImage;
  final dynamic fcmToken;
  final int? isPhoneVerified;
  final int? isEmailVerified;
  final dynamic phoneVerifiedAt;
  final dynamic emailVerifiedAt;
  final int? isActive;
  final String? userType;
  final dynamic rememberToken;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? walletBalance;
  final int? loyaltyPoint;
  final String? refCode;
  final dynamic referredBy;
  final int? loginHitCount;
  final int? isTempBlocked;
  final dynamic tempBlockTime;
  final String? currentLanguageKey;
  final dynamic profileImageFullPath;
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

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        phone: json["phone"],
        identificationNumber: json["identification_number"],
        identificationType: json["identification_type"],
        identificationImage: json["identification_image"] == null
            ? []
            : List<dynamic>.from(json["identification_image"]!.map((x) => x)),
        dateOfBirth: json["date_of_birth"],
        gender: json["gender"],
        profileImage: json["profile_image"],
        fcmToken: json["fcm_token"],
        isPhoneVerified: json["is_phone_verified"],
        isEmailVerified: json["is_email_verified"],
        phoneVerifiedAt: json["phone_verified_at"],
        emailVerifiedAt: json["email_verified_at"],
        isActive: json["is_active"],
        userType: json["user_type"],
        rememberToken: json["remember_token"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        walletBalance: json["wallet_balance"],
        loyaltyPoint: json["loyalty_point"],
        refCode: json["ref_code"],
        referredBy: json["referred_by"],
        loginHitCount: json["login_hit_count"],
        isTempBlocked: json["is_temp_blocked"],
        tempBlockTime: json["temp_block_time"],
        currentLanguageKey: json["current_language_key"],
        profileImageFullPath: json["profile_image_full_path"],
        identificationImageFullPath:
            json["identification_image_full_path"] == null
                ? []
                : List<dynamic>.from(
                    json["identification_image_full_path"]!.map((x) => x)),
        storage: json["storage"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "identification_number": identificationNumber,
        "identification_type": identificationType,
        "identification_image": identificationImage == null
            ? []
            : List<dynamic>.from(identificationImage!.map((x) => x)),
        "date_of_birth": dateOfBirth,
        "gender": gender,
        "profile_image": profileImage,
        "fcm_token": fcmToken,
        "is_phone_verified": isPhoneVerified,
        "is_email_verified": isEmailVerified,
        "phone_verified_at": phoneVerifiedAt,
        "email_verified_at": emailVerifiedAt,
        "is_active": isActive,
        "user_type": userType,
        "remember_token": rememberToken,
        "deleted_at": deletedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "wallet_balance": walletBalance,
        "loyalty_point": loyaltyPoint,
        "ref_code": refCode,
        "referred_by": referredBy,
        "login_hit_count": loginHitCount,
        "is_temp_blocked": isTempBlocked,
        "temp_block_time": tempBlockTime,
        "current_language_key": currentLanguageKey,
        "profile_image_full_path": profileImageFullPath,
        "identification_image_full_path": identificationImageFullPath == null
            ? []
            : List<dynamic>.from(identificationImageFullPath!.map((x) => x)),
        "storage": storage,
      };
}
