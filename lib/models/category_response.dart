// To parse this JSON data, do
//
//     final categoryiesResponse = categoryiesResponseFromJson(jsonString);

import 'dart:convert';

List<CategoryiesResponse> categoryiesResponseFromJson(String str) => List<CategoryiesResponse>.from(json.decode(str).map((x) => CategoryiesResponse.fromJson(x)));

String categoryiesResponseToJson(List<CategoryiesResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryiesResponse {
    int? id;
    String? name;
    String? imageUrl;
    DateTime? createdAt;
    List<String>? attributes;

    CategoryiesResponse({
        this.id,
        this.name,
        this.imageUrl,
        this.createdAt,
        this.attributes,
    });

    factory CategoryiesResponse.fromJson(Map<String, dynamic> json) => CategoryiesResponse(
        id: json["id"],
        name: json["name"],
        imageUrl: json["image_url"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        attributes: json["attributes"] == null ? [] : List<String>.from(json["attributes"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image_url": imageUrl,
        "created_at": createdAt?.toIso8601String(),
        "attributes": attributes == null ? [] : List<dynamic>.from(attributes!.map((x) => x)),
    };
}
