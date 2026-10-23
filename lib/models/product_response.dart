// // To parse this JSON data, do
// //
// //     final productResponse = productResponseFromJson(jsonString);

// import 'dart:convert';


// List<ProductResponse> productResponseFromJson(String str) => List<ProductResponse>.from(json.decode(str).map((x) => ProductResponse.fromJson(x)));

// String productResponseToJson(List<ProductResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class ProductResponse {
//     int? id;
//     String? name;
//     String? category;
//     List<String>? sizes;
//     String? description;
//     String? originalPrice;
//     String? offerPrice;
//     String? branchAdminPrice;
//     int? count;
//     List<String>? images;
//     bool? isFeatured;

//     ProductResponse({
//         this.id,
//         this.name,
//         this.category,
//         this.sizes,
//         this.description,
//         this.originalPrice,
//         this.offerPrice,
//         this.branchAdminPrice,
//         this.count,
//         this.images,
//         this.isFeatured,
//     });

//     factory ProductResponse.fromJson(Map<String, dynamic> json) => ProductResponse(
//         id: json["id"],
//         name: json["name"],
//         category: json["category"],
//         sizes: json["sizes"] == null ? [] : List<String>.from(json["sizes"]!.map((x) => x)),
//         description: json["description"],
//         originalPrice: json["originalPrice"],
//         offerPrice: json["offerPrice"],
//         branchAdminPrice: json["branchAdminPrice"],
//         count: json["count"],
//         images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
//         isFeatured: json["isFeatured"],
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "category": category,
//         "sizes": sizes == null ? [] : List<dynamic>.from(sizes!.map((x) => x)),
//         "description": description,
//         "originalPrice": originalPrice,
//         "offerPrice": offerPrice,
//         "branchAdminPrice": branchAdminPrice,
//         "count": count,
//         "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
//         "isFeatured": isFeatured,
//     };
// }


// To parse this JSON data, do
//
//     final productResponse = productResponseFromJson(jsonString);

import 'dart:convert';
/// Product model used across the UI (Home, Search, Product Detail, Cart).
///
/// NOTE: This file is a best-effort RECONSTRUCTION inferred from how
/// `Product` fields are used in home_screen.dart / cart_screen.dart
/// (prod.title, prod.price, prod.images, prod.rating, prod.isPrime,
/// prod.variants, etc). Your real product.dart may already exist with
/// different field names/types — if so, replace this file with the real
/// one and just keep the `toProduct()` extension in product_response.dart
/// pointed at your actual constructor.
class Product {
  final int id;
  final String title;
  final String category;
  final String description;
  final num price;
  final num originalPrice;
  final int discountPercentage;
  final List<String> images;
  final double rating;
  final int reviewsCount;
  final bool isDealOfTheDay;
  final bool isPrime;
  final bool isFeatured;

  /// e.g. { "Size": ["S", "M", "L"], "Color": ["Red", "Blue"] }
  final Map<String, List<String>> variants;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    this.description = '',
    required this.price,
    num? originalPrice,
    this.discountPercentage = 0,
    this.images = const [],
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.isDealOfTheDay = false,
    this.isPrime = false,
    this.isFeatured = false,
    this.variants = const {},
  }) : originalPrice = originalPrice ?? price;
}
List<ProductResponse> productResponseFromJson(String str) =>
    List<ProductResponse>.from(json.decode(str).map((x) => ProductResponse.fromJson(x)));

String productResponseToJson(List<ProductResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductResponse {
  int? id;
  String? name;
  String? category;
  List<String>? sizes;
  String? description;
  String? originalPrice;
  String? offerPrice;
  String? branchAdminPrice;
  int? count;
  List<String>? images;
  bool? isFeatured;

  ProductResponse({
    this.id,
    this.name,
    this.category,
    this.sizes,
    this.description,
    this.originalPrice,
    this.offerPrice,
    this.branchAdminPrice,
    this.count,
    this.images,
    this.isFeatured,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) => ProductResponse(
        id: json["id"] is int
            ? json["id"]
            : int.tryParse(json["id"]?.toString() ?? ''),
        name: json["name"]?.toString(),
        category: json["category"]?.toString(),
        sizes: json["sizes"] == null
            ? []
            : (json["sizes"] is List
                ? (json["sizes"] as List).map((x) => x.toString()).toList()
                : []),
        description: json["description"]?.toString(),
        originalPrice: json["originalPrice"]?.toString() ?? json["original_price"]?.toString(),
        offerPrice: json["offerPrice"]?.toString() ?? json["offer_price"]?.toString(),
        branchAdminPrice: json["branchAdminPrice"]?.toString() ?? json["branch_admin_price"]?.toString(),
        count: json["count"] is int
            ? json["count"]
            : int.tryParse(json["count"]?.toString() ?? ''),
        images: json["images"] == null
            ? []
            : (json["images"] is List
                ? (json["images"] as List).map((x) => x.toString()).toList()
                : []),
        isFeatured: json["isFeatured"] is bool
            ? json["isFeatured"]
            : (json["isFeatured"]?.toString().toLowerCase() == 'true'),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category,
        "sizes": sizes == null ? [] : List<dynamic>.from(sizes!.map((x) => x)),
        "description": description,
        "originalPrice": originalPrice,
        "offerPrice": offerPrice,
        "branchAdminPrice": branchAdminPrice,
        "count": count,
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "isFeatured": isFeatured,
      };
}

/// Converts a raw API `ProductResponse` into the UI-facing `Product` model.
///
/// ASSUMPTION: the backend doesn't yet return `rating`, `reviewsCount`,
/// `isPrime`, or a distinct "deal of the day" flag — those default to 0 /
/// false below. `isDealOfTheDay` is temporarily derived from `isFeatured`
/// as a placeholder; swap in a real field once your API exposes one.
extension ProductResponseMapper on ProductResponse {
  Product toProduct() {
    final price = num.tryParse(offerPrice ?? '') ?? 0;
    final original = num.tryParse(originalPrice ?? '') ?? price;

    int discount = 0;
    if (original > 0 && original > price) {
      discount = (((original - price) / original) * 100).round();
    }

    final variantMap = <String, List<String>>{};
    if (sizes != null && sizes!.isNotEmpty) {
      variantMap['Size'] = sizes!;
    }

    return Product(
      id: id ?? 0,
      title: name ?? '',
      category: category ?? '',
      description: description ?? '',
      price: price,
      originalPrice: original,
      discountPercentage: discount,
      images: images ?? [],
      rating: 0.0, // ASSUMPTION: no rating field from API yet
      reviewsCount: 0, // ASSUMPTION: no reviews field from API yet
      isDealOfTheDay: isFeatured ?? false, // ASSUMPTION: reusing isFeatured
      isPrime: false, // ASSUMPTION: no prime/shipping-tier field from API yet
      isFeatured: isFeatured ?? false,
      variants: variantMap,
    );
  }
}