class Category {
  String? id;
  String? parentId;
  String? name;
  String? image;
  int? position;
  String? description;
  int? isActive;
  int? isFeatured;
  String? createdAt;
  String? updatedAt;
  String? imageFullPath;
  List<Zone>? zones;
  dynamic storage;

  Category({
    this.id,
    this.parentId,
    this.name,
    this.image,
    this.position,
    this.description,
    this.isActive,
    this.isFeatured,
    this.createdAt,
    this.updatedAt,
    this.imageFullPath,
    this.zones,
    this.storage,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      parentId: json['parent_id'],
      name: json['name'],
      image: json['image'],
      position: json['position'] is int ? json['position'] : int.tryParse(json['position'].toString()),
      description: json['description'],
      isActive: json['is_active'] is int ? json['is_active'] : int.tryParse(json['is_active'].toString()),
      isFeatured: json['is_featured'] is int ? json['is_featured'] : int.tryParse(json['is_featured'].toString()),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      imageFullPath: json['image_full_path'],
      zones: json['zones'] != null ? (json['zones'] as List).map((e) => Zone.fromJson(e)).toList() : [],
      storage: json['storage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'image': image,
      'position': position,
      'description': description,
      'is_active': isActive,
      'is_featured': isFeatured,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'image_full_path': imageFullPath,
      'zones': zones?.map((e) => e.toJson()).toList(),
      'storage': storage,
    };
  }
}

class Zone {
  String? id;
  String? name;
  Coordinates? coordinates;
  int? isActive;
  String? createdAt;
  String? updatedAt;

  Zone({
    this.id,
    this.name,
    this.coordinates,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      name: json['name'],
      coordinates: json['coordinates'] != null ? Coordinates.fromJson(json['coordinates']) : null,
      isActive: json['is_active'] is int ? json['is_active'] : int.tryParse(json['is_active'].toString()),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coordinates': coordinates?.toJson(),
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Coordinates {
  String? type;
  List<dynamic>? coordinates;

  Coordinates({this.type, this.coordinates});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      type: json['type'],
      coordinates: json['coordinates'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
class CategoryModel {
  List<Category>? data;

  CategoryModel({this.data});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      data: json['data'] != null ? (json['data'] as List).map((e) => Category.fromJson(e)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}
