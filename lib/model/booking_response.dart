class BookingResponse {
  final dynamic responseCode;
  final dynamic message;
  final dynamic content;

  BookingResponse({
    required this.responseCode,
    required this.message,
    required this.content,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      responseCode: json['response_code'],
      message: json['message'],
      content: json['content'] != null
          ? BookingContent.fromJson(json['content'])
          : null,
    );
  }
}

class BookingContent {
  final dynamic id;
  final dynamic readableId;
  final dynamic customerId;
  final dynamic providerId;
  final dynamic zoneId;
  final dynamic bookingStatus;
  final dynamic isPaid;
  final dynamic paymentMethod;
  final dynamic transactionId;
  final dynamic totalBookingAmount;
  final dynamic totalTaxAmount;
  final dynamic serviceSchedule;
  final dynamic serviceAddressId;
  final dynamic createdAt;
  final List<ServiceDetail> detail;
  final List<ScheduleHistory> scheduleHistories;
  final Address? serviceAddress;
  final Customer? customer;
  final String? message;

  BookingContent({
    required this.id,
    required this.readableId,
    required this.customerId,
    required this.providerId,
    required this.zoneId,
    required this.bookingStatus,
    required this.isPaid,
    required this.paymentMethod,
    required this.transactionId,
    required this.totalBookingAmount,
    required this.totalTaxAmount,
    required this.serviceSchedule,
    required this.serviceAddressId,
    required this.createdAt,
    required this.detail,
    required this.scheduleHistories,
    this.serviceAddress,
    this.customer,
    this.message,
  });

  factory BookingContent.fromJson(Map<String, dynamic> json) {
    return BookingContent(
      id: json['id'],
      message:
          json["message"] != null ? json['message'] : "No description provided",
      readableId: json['readable_id'],
      customerId: json['customer_id'],
      providerId: json['provider_id'],
      zoneId: json['zone_id'],
      bookingStatus: json['booking_status'],
      isPaid: json['is_paid'],
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      totalBookingAmount: json['total_booking_amount'],
      totalTaxAmount: json['total_tax_amount'],
      serviceSchedule: json['service_schedule'],
      serviceAddressId: json['service_address_id'],
      createdAt: json['created_at'],
      detail: (json['detail'] as List?)
              ?.map((e) => ServiceDetail.fromJson(e))
              .toList() ??
          [],
      scheduleHistories: (json['schedule_histories'] as List?)
              ?.map((e) => ScheduleHistory.fromJson(e))
              .toList() ??
          [],
      serviceAddress: json['service_address'] != null
          ? Address.fromJson(json['service_address'])
          : null,
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
    );
  }
}

class ServiceDetail {
  final int? id;
  final String? bookingId;
  final String? serviceId;
  final String? serviceName;
  final String? variantKey;
  final int? serviceCost;
  final int? quantity;
  final int? discountAmount;
  final double? taxAmount;
  final double? totalCost;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? campaignDiscountAmount;
  final int? overallCouponDiscountAmount;
  final Service? service;
  final int? isAddOn;

  ServiceDetail({
    this.id,
    this.bookingId,
    this.serviceId,
    this.serviceName,
    this.variantKey,
    this.serviceCost,
    this.quantity,
    this.discountAmount,
    this.taxAmount,
    this.totalCost,
    this.createdAt,
    this.updatedAt,
    this.campaignDiscountAmount,
    this.overallCouponDiscountAmount,
    this.service,
    this.isAddOn,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      id: json["id"],
      bookingId: json["booking_id"],
      serviceId: json["service_id"],
      serviceName: json["service_name"],
      variantKey: json["variant_key"],
      serviceCost: json["service_cost"],
      quantity: json["quantity"],
      isAddOn: json["is_addon"],
      discountAmount: json["discount_amount"],
      taxAmount: json["tax_amount"]?.toDouble(),
      totalCost: json["total_cost"]?.toDouble(),
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.parse(json["updated_at"]),
      campaignDiscountAmount: json["campaign_discount_amount"],
      overallCouponDiscountAmount: json["overall_coupon_discount_amount"],
      service:
          json["service"] == null ? null : Service.fromJson(json["service"]),
    );
  }
}

// class ServiceDetail {
//   final dynamic id;
//   final dynamic serviceId;
//   final dynamic serviceName;
//   final dynamic variantKey;
//   final dynamic serviceCost;
//   final dynamic quantity;
//   final dynamic taxAmount;
//   final dynamic totalCost;
//   final Service? service;

//   ServiceDetail({
//     required this.id,
//     required this.serviceId,
//     required this.serviceName,
//     required this.variantKey,
//     required this.serviceCost,
//     required this.quantity,
//     required this.taxAmount,
//     required this.totalCost,
//     this.service,
//   });

//   factory ServiceDetail.fromJson(Map<String, dynamic> json) {
//     return ServiceDetail(
//       id: json['id'],
//       serviceId: json['service_id'],
//       serviceName: json['service_name'],
//       variantKey: json['variant_key'],
//       serviceCost: json['service_cost'],
//       quantity: json['quantity'],
//       taxAmount: json['tax_amount'],
//       totalCost: json['total_cost'],
//       service:
//           json['service'] != null ? Service.fromJson(json['service']) : null,
//     );
//   }
// }

class Service {
  final dynamic id;
  final dynamic name;
  final dynamic shortDescription;
  final dynamic description;
  final dynamic coverImageFullPath;
  final dynamic thumbnailFullPath;

  Service({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.coverImageFullPath,
    required this.thumbnailFullPath,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      shortDescription: json['short_description'],
      description: json['description'],
      coverImageFullPath: json['cover_image_full_path'],
      thumbnailFullPath: json['thumbnail_full_path'],
    );
  }
}

class ScheduleHistory {
  final dynamic id;
  final dynamic bookingId;
  final dynamic schedule;
  final User? user;

  ScheduleHistory({
    required this.id,
    required this.bookingId,
    required this.schedule,
    this.user,
  });

  factory ScheduleHistory.fromJson(Map<String, dynamic> json) {
    return ScheduleHistory(
      id: json['id'],
      bookingId: json['booking_id'],
      schedule: json['schedule'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  final dynamic id;
  final dynamic firstName;
  final dynamic lastName;
  final dynamic phone;
  final dynamic email;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}

typedef Customer = User;

class Address {
  final dynamic id;
  final dynamic city;
  final dynamic street;
  final dynamic country;
  final dynamic address;
  final dynamic contactPersonName;
  final dynamic contactPersonNumber;

  Address({
    required this.id,
    required this.city,
    required this.street,
    required this.country,
    required this.address,
    required this.contactPersonName,
    required this.contactPersonNumber,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      city: json['city'],
      street: json['street'],
      country: json['country'],
      address: json['address'],
      contactPersonName: json['contact_person_name'],
      contactPersonNumber: json['contact_person_number'],
    );
  }
}
