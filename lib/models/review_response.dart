// To parse this JSON data, do
//
//     final reviewResponse = reviewResponseFromJson(jsonString);

import 'dart:convert';

ReviewResponse reviewResponseFromJson(String str) => ReviewResponse.fromJson(json.decode(str));

String reviewResponseToJson(ReviewResponse data) => json.encode(data.toJson());

class ReviewResponse {
    final bool? success;
    final List<Review>? reviews;

    ReviewResponse({
        this.success,
        this.reviews,
    });

    factory ReviewResponse.fromJson(Map<String, dynamic> json) => ReviewResponse(
        success: json["success"],
        reviews: json["reviews"] == null ? [] : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "reviews": reviews == null ? [] : List<dynamic>.from(reviews!.map((x) => x.toJson())),
    };
}

class Review {
    final int? id;
    final int? productId;
    final int? userId;
    final String? userName;
    final int? rating;
    final String? comment;
    final List<String>? images;
    final DateTime? createdAt;

    Review({
        this.id,
        this.productId,
        this.userId,
        this.userName,
        this.rating,
        this.comment,
        this.images,
        this.createdAt,
    });

    factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        productId: json["product_id"],
        userId: json["user_id"],
        userName: json["user_name"],
        rating: json["rating"],
        comment: json["comment"],
        images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "user_id": userId,
        "user_name": userName,
        "rating": rating,
        "comment": comment,
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "created_at": createdAt?.toIso8601String(),
    };
}
