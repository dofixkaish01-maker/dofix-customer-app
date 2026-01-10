import 'dart:convert';

class Variation {
  final int id;
  final String variant;
  final String variantKey;
  final String serviceId;
  final String zoneId;
  final double price;
  final double mrpPrice;
  final double discount;
  final double convenienceFee;
  final int convenienceGst;
  final double aggregatorFee;
  final int aggregatorGst;
  final dynamic varDescription;
  // final dynamic varDuration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Zone zone;
  final String? durationHour;
  final String? durationMinute;

  Variation({
    required this.id,
    required this.variant,
    required this.variantKey,
    required this.serviceId,
    required this.zoneId,
    required this.price,
    required this.mrpPrice,
    required this.discount,
    required this.convenienceFee,
    required this.convenienceGst,
    required this.aggregatorFee,
    required this.aggregatorGst,
    required this.varDescription,
    // required this.varDuration,
    required this.createdAt,
    required this.updatedAt,
    required this.zone,
    this.durationHour,
    this.durationMinute,
  });

  // Factory constructor to handle dynamic JSON parsing
  factory Variation.fromJson(Map<String, dynamic> json) {
    return Variation(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      variant: json['variant'] ?? '',
      variantKey: json['variant_key'] ?? '',
      serviceId: json['service_id'] ?? '',
      zoneId: json['zone_id'] ?? '',
      price: (json['price'] is int || json['price'] is double)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0,
      mrpPrice: (json['mrp_price'] is int || json['mrp_price'] is double)
          ? (json['mrp_price'] as num).toDouble()
          : double.tryParse(json['mrp_price'].toString()) ?? 0.0,
      discount: (json['discount'] is int || json['discount'] is double)
          ? (json['discount'] as num).toDouble()
          : double.tryParse(json['discount'].toString()) ?? 0.0,
      convenienceFee:
          (json['convenience_fee'] is int || json['convenience_fee'] is double)
              ? (json['convenience_fee'] as num).toDouble()
              : double.tryParse(json['convenience_fee'].toString()) ?? 0.0,
      convenienceGst: json['convenience_gst'] is int
          ? json['convenience_gst']
          : int.tryParse(json['convenience_gst'].toString()) ?? 0,
      aggregatorFee:
          (json['aggregator_fee'] is int || json['aggregator_fee'] is double)
              ? (json['aggregator_fee'] as num).toDouble()
              : double.tryParse(json['aggregator_fee'].toString()) ?? 0.0,
      aggregatorGst: json['aggregator_gst'] is int
          ? json['aggregator_gst']
          : int.tryParse(json['aggregator_gst'].toString()) ?? 0,
      varDescription:
          json['var_description'] != null ? json['var_description'] : '0',
      // varDuration: json['var_duration'],
      durationHour: json['duration_hour'],
      durationMinute: json['duration_minute'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      zone: Zone.fromJson(json['zone'] ?? {}),
    );
  }

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variant': variant,
      'variant_key': variantKey,
      'service_id': serviceId,
      'zone_id': zoneId,
      'price': price,
      'mrp_price': mrpPrice,
      'discount': discount,
      'convenience_fee': convenienceFee,
      'convenience_gst': convenienceGst,
      'aggregator_fee': aggregatorFee,
      'aggregator_gst': aggregatorGst,
      'var_description': varDescription,
      'duration_minute': durationMinute,
      'duration_hour': durationHour,
      // 'var_duration': varDuration,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'zone': zone.toJson(),
    };
  }
}

class Zone {
  final String id;
  final String name;
  final List<dynamic> translations;

  Zone({
    required this.id,
    required this.name,
    required this.translations,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      translations: json['translations'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'translations': translations,
    };
  }
}
