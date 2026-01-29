class ExtraModel {
  final dynamic id;
  final String? categoryId;
  final String? image;
  final String? name;
  final String? price;
  final int? status;

  ExtraModel({
    this.id,
    this.categoryId,
    this.image,
    this.name,
    this.price,
    this.status,
  });

  factory ExtraModel.fromJson(Map<String, dynamic> json) {
    return ExtraModel(
      id: json['id'],
      categoryId: json['category_id'],
      image: json['image'],
      name: json['name'],
      price: json['price'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "category_id": categoryId,
      "price": price,
    };
  }
}
