// To parse this JSON data, do
//
//     final orderResponse = orderResponseFromJson(jsonString);

import 'dart:convert';

List<OrderResponse> orderResponseFromJson(String str) => List<OrderResponse>.from(json.decode(str).map((x) => OrderResponse.fromJson(x)));

String orderResponseToJson(List<OrderResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderResponse {
    final String? id;
    final String? totalPrice;
    final String? status;
    final DateTime? createdAt;
    final List<Item>? items;

    OrderResponse({
        this.id,
        this.totalPrice,
        this.status,
        this.createdAt,
        this.items,
    });

    factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
        id: json["id"],
        totalPrice: json["totalPrice"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "totalPrice": totalPrice,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    };
}

class Item {
    final int? productId;
    final String? name;
    final int? price;
    final int? quantity;
    final String? image;
    final String? selectedSize;

    Item({
        this.productId,
        this.name,
        this.price,
        this.quantity,
        this.image,
        this.selectedSize,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        productId: json["product_id"],
        name: json["name"],
        price: json["price"],
        quantity: json["quantity"],
        image: json["image"],
        selectedSize: json["selected_size"],
    );

    Map<String, dynamic> toJson() => {
        "product_id": productId,
        "name": name,
        "price": price,
        "quantity": quantity,
        "image": image,
        "selected_size": selectedSize,
    };
}
