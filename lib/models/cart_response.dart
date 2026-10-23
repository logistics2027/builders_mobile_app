import 'dart:convert';

List<CartResponse> cartResponseFromJson(String str) => List<CartResponse>.from(
  json.decode(str).map((x) => CartResponse.fromJson(x)),
);

String cartResponseToJson(List<CartResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CartResponse {
  int? id;
  int? userId;
  int? productId;
  String? name;
  String? category;
  String? price;
  String? image;
  int? quantity;
  DateTime? createdAt;
  String? selectedSize;

  CartResponse({
    this.id,
    this.userId,
    this.productId,
    this.name,
    this.category,
    this.price,
    this.image,
    this.quantity,
    this.createdAt,
    this.selectedSize,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) => CartResponse(
    id: json["id"],
    userId: json["user_id"],
    productId: json["product_id"],
    name: json["name"],
    category: json["category"],
    price: json["price"],
    image: json["image"],
    quantity: json["quantity"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    selectedSize: json["selected_size"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "product_id": productId,
    "name": name,
    "category": category,
    "price": price,
    "image": image,
    "quantity": quantity,
    "created_at": createdAt?.toIso8601String(),
    "selected_size": selectedSize,
  };
}
