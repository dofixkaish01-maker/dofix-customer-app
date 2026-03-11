class AllCategoryModel {
  String? responseCode;
  String? message;
  Content? content;
  List<dynamic>? errors;

  AllCategoryModel({this.responseCode, this.message, this.content, this.errors});

  AllCategoryModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content =
    json['content'] != null ? Content.fromJson(json['content']) : null;
    errors = json['errors'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (content != null) {
      data['content'] = content!.toJson();
    }
    data['errors'] = errors;
    return data;
  }
}

class Content {
  int? currentPage;
  List<Data>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  Content(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.links,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total});

  Content.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];

    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }

    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];

    if (json['links'] != null) {
      links = [];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }

    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['current_page'] = currentPage;

    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }

    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;

    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }

    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;

    return data;
  }
}

class Data {
  String? id;
  String? parentId;
  String? name;
  int? minimumBalance;
  String? image;
  int? position;
  String? description;
  int? isActive;
  int? isFeatured;
  int? topRated;
  int? quickRepair;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? imageFullPath;
  List<Zones>? zones;
  List<dynamic>? translations;
  dynamic storage;

  Data(
      {this.id,
        this.parentId,
        this.name,
        this.minimumBalance,
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
        this.zones,
        this.translations,
        this.storage});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    name = json['name'];
    minimumBalance = json['minimum_balance'];
    image = json['image'];
    position = json['position'];
    description = json['description'];
    isActive = json['is_active'];
    isFeatured = json['is_featured'];
    topRated = json['top_rated'];
    quickRepair = json['quick_repair'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    imageFullPath = json['image_full_path'];

    if (json['zones'] != null) {
      zones = [];
      json['zones'].forEach((v) {
        zones!.add(Zones.fromJson(v));
      });
    }

    translations = json['translations'];
    storage = json['storage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['parent_id'] = parentId;
    data['name'] = name;
    data['minimum_balance'] = minimumBalance;
    data['image'] = image;
    data['position'] = position;
    data['description'] = description;
    data['is_active'] = isActive;
    data['is_featured'] = isFeatured;
    data['top_rated'] = topRated;
    data['quick_repair'] = quickRepair;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['image_full_path'] = imageFullPath;

    if (zones != null) {
      data['zones'] = zones!.map((v) => v.toJson()).toList();
    }

    data['translations'] = translations;
    data['storage'] = storage;

    return data;
  }
}

class Zones {
  String? id;
  String? name;
  Coordinates? coordinates;
  int? isActive;
  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  Zones(
      {this.id,
        this.name,
        this.coordinates,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.pivot});

  Zones.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    coordinates = json['coordinates'] != null
        ? Coordinates.fromJson(json['coordinates'])
        : null;
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['name'] = name;

    if (coordinates != null) {
      data['coordinates'] = coordinates!.toJson();
    }

    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;

    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }

    return data;
  }
}

class Coordinates {
  String? type;
  List<dynamic>? coordinates;

  Coordinates({this.type, this.coordinates});

  Coordinates.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

class Pivot {
  String? categoryId;
  String? zoneId;

  Pivot({this.categoryId, this.zoneId});

  Pivot.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    zoneId = json['zone_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['category_id'] = categoryId;
    data['zone_id'] = zoneId;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
    return data;
  }
}