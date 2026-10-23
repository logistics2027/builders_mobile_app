// To parse this JSON data, do
//
//     final productDetailResponse = productDetailResponseFromJson(jsonString);

import 'dart:convert';
import 'product_response.dart';

ProductDetailResponse productDetailResponseFromJson(String str) =>
    ProductDetailResponse.fromJson(json.decode(str));

String productDetailResponseToJson(ProductDetailResponse data) =>
    json.encode(data.toJson());

class ProductDetailResponse {
  bool? success;
  ProductResponse? product;

  ProductDetailResponse({
    this.success,
    this.product,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    ProductResponse? parsedProduct;
    final dynamic prodData = json["product"] ?? json["data"];
    if (prodData != null && prodData is Map<String, dynamic>) {
      parsedProduct = ProductResponse.fromJson(prodData);
    } else if (json.containsKey("id") || json.containsKey("name")) {
      parsedProduct = ProductResponse.fromJson(json);
    }
    return ProductDetailResponse(
      success: json["success"] is bool ? json["success"] as bool : (parsedProduct != null),
      product: parsedProduct,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "product": product?.toJson(),
      };
}