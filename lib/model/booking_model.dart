class Booking {
  dynamic id;
  dynamic readableId;
  dynamic customerId;
  dynamic providerId;
  dynamic zoneId;
  dynamic bookingStatus;
  dynamic isPaid;
  dynamic paymentMethod;
  dynamic transactionId;
  dynamic totalBookingAmount;
  dynamic totalTaxAmount;
  dynamic totalDiscountAmount;
  dynamic serviceSchedule;
  dynamic serviceAddressId;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic categoryId;
  dynamic subCategoryId;
  dynamic servicemanId;
  dynamic customer;
  dynamic subCategory;
  dynamic category;
  dynamic serviceAddress;
  dynamic message;

  Booking({
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
    this.customer,
    this.subCategory,
    this.category,
    this.serviceAddress,
    this.message,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
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
      totalDiscountAmount: json['total_discount_amount'],
      serviceSchedule: json['service_schedule'],
      serviceAddressId: json['service_address_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      servicemanId: json['serviceman_id'],
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      subCategory: json['sub_category'] != null
          ? SubCategory.fromJson(json['sub_category'])
          : null,
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      serviceAddress: json['service_address'] != null
          ? AddressModel.fromJson(json['service_address'])
          : null,
      message: json['message'],
    );
  }
}

class Category {
  dynamic id;
  dynamic parentId;
  dynamic name;
  dynamic image;
  dynamic position;
  dynamic description;
  dynamic isActive;
  dynamic isFeatured;
  dynamic topRated;
  dynamic quickRepair;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic deletedAt;
  dynamic imageFullPath;

  Category({
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
    this.deletedAt,
    this.imageFullPath,
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
      topRated: json['top_rated'],
      quickRepair: json['quick_repair'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      imageFullPath: json['image_full_path'],
    );
  }
}

class Customer {
  dynamic id;
  dynamic firstName;
  dynamic lastName;
  dynamic email;
  dynamic phone;

  Customer({this.id, this.firstName, this.lastName, this.email, this.phone});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

class SubCategory {
  dynamic id;
  dynamic name;
  dynamic thumbnailFullPath;

  SubCategory({this.id, this.name, this.thumbnailFullPath});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
      thumbnailFullPath: json['image_full_path'],
    );
  }
}

class AddressModel {
  final int id;
  final int? userId;
  final String? lat;
  final String? lon;
  final String? city;
  final String? street;
  final String? zipCode;
  final String? country;
  final String? address;
  final String? createdAt;
  final String? updatedAt;
  final String? addressType;
  final String? contactPersonName;
  final String? contactPersonNumber;
  final String? addressLabel;
  final int? zoneId;
  final int? isGuest;
  final String? house;
  final String? floor;

  AddressModel({
    required this.id,
    this.userId,
    this.lat,
    this.lon,
    this.city,
    this.street,
    this.zipCode,
    this.country,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.addressType,
    this.contactPersonName,
    this.contactPersonNumber,
    this.addressLabel,
    this.zoneId,
    this.isGuest,
    this.house,
    this.floor,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      userId: json['user_id'],
      lat: json['lat'],
      lon: json['lon'],
      city: json['city'],
      street: json['street'],
      zipCode: json['zip_code'],
      country: json['country'],
      address: json['address'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      addressType: json['address_type'],
      contactPersonName: json['contact_person_name'],
      contactPersonNumber: json['contact_person_number'],
      addressLabel: json['address_label'],
      zoneId: json['zone_id'],
      isGuest: json['is_guest'],
      house: json['house'],
      floor: json['floor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lat': lat,
      'lon': lon,
      'city': city,
      'street': street,
      'zip_code': zipCode,
      'country': country,
      'address': address,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'address_type': addressType,
      'contact_person_name': contactPersonName,
      'contact_person_number': contactPersonNumber,
      'address_label': addressLabel,
      'zone_id': zoneId,
      'is_guest': isGuest,
      'house': house,
      'floor': floor,
    };
  }
}

class BookingModel {
  List<Booking>? data;

  BookingModel({this.data});

  factory BookingModel.fromJson(dynamic json) {
    return BookingModel(
      data: (json['data'] as List?)?.map((e) => Booking.fromJson(e)).toList(),
    );
  }
}
