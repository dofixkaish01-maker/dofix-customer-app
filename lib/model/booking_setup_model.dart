import 'dart:convert';

BookingSetupModel bookingSetupModelFromJson(String str) =>
    BookingSetupModel.fromJson(json.decode(str));

String bookingSetupModelToJson(BookingSetupModel data) =>
    json.encode(data.toJson());

class BookingSetupModel {
  final String? responseCode;
  final String? message;
  final List<Content>? content;
  final List<dynamic>? errors;

  BookingSetupModel({
    this.responseCode,
    this.message,
    this.content,
    this.errors,
  });

  factory BookingSetupModel.fromJson(Map<String, dynamic> json) =>
      BookingSetupModel(
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
  final String? id;
  final String? keyName;
  final dynamic liveValues;
  final dynamic testValues;
  final SettingsType? settingsType;
  final Mode? mode;
  final int? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Content({
    this.id,
    this.keyName,
    this.liveValues,
    this.testValues,
    this.settingsType,
    this.mode,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        id: json["id"],
        keyName: json["key_name"],
        liveValues: json["live_values"],
        testValues: json["test_values"],
        settingsType: settingsTypeValues.map[json["settings_type"]]!,
        mode: modeValues.map[json["mode"]]!,
        isActive: json["is_active"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key_name": keyName,
        "live_values": liveValues,
        "test_values": testValues,
        "settings_type": settingsTypeValues.reverse[settingsType],
        "mode": modeValues.reverse[mode],
        "is_active": isActive,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

enum Mode { LIVE }

final modeValues = EnumValues({"live": Mode.LIVE});

enum SettingsType { BOOKING_SETUP }

final settingsTypeValues =
    EnumValues({"booking_setup": SettingsType.BOOKING_SETUP});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
