class AddressResponse {
  final List<AddressData> data;

  AddressResponse({
    required this.data,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(

      data: (json['data'] as List<dynamic>)
          .map((e) => AddressData.fromJson(e))
          .toList(),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),

    };
  }
}

class AddressData {
  final int id;
  final String userId;
  final double lat;
  final double lon;
  final String city;
  final String street;
  final String zipCode;
  final String country;
  final String address;
  final String createdAt;
  final String updatedAt;
  final String addressType;
  final String contactPersonName;
  final String contactPersonNumber;
  final String addressLabel;
  final String zoneId;
  final bool isGuest;
  final String house;
  final String floor;

  AddressData({
    required this.id,
    required this.userId,
    required this.lat,
    required this.lon,
    required this.city,
    required this.street,
    required this.zipCode,
    required this.country,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.addressType,
    required this.contactPersonName,
    required this.contactPersonNumber,
    required this.addressLabel,
    required this.zoneId,
    required this.isGuest,
    required this.house,
    required this.floor,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      id: json['id'] ?? "",
      userId: json['user_id'] ?? "",
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lon: double.tryParse(json['lon'].toString()) ?? 0.0,
      city: json['city'] ?? "",
      street: json['street'] ?? "",
      zipCode: json['zip_code'] ?? "",
      country: json['country'] ?? "",
      address: json['address'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
      addressType: json['address_type'] ?? "",
      contactPersonName: json['contact_person_name'] ?? "",
      contactPersonNumber: json['contact_person_number'] ?? "",
      addressLabel: json['address_label'] ?? "",
      zoneId: json['zone_id'] ?? "",
      isGuest: (json['is_guest'] ?? "1").toString() == '1' || (json['is_guest'] ?? true) == true,
      house: json['house'] ?? "",
      floor: json['floor'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lat': lat.toString(),
      'lon': lon.toString(),
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
      'is_guest': isGuest ? 1 : 0,
      'house': house,
      'floor': floor,
    };
  }
}

