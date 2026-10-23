// To parse this JSON data, do
//
//     final bannerResponse = bannerResponseFromJson(jsonString);

import 'dart:convert';

BannerResponse bannerResponseFromJson(String str) => BannerResponse.fromJson(json.decode(str));

String bannerResponseToJson(BannerResponse data) => json.encode(data.toJson());

class BannerResponse {
    bool? success;
    List<Banners>? banners;

    BannerResponse({
        this.success,
        this.banners,
    });

    factory BannerResponse.fromJson(Map<String, dynamic> json) {
      final list = json["banners"] ?? json["data"];
      return BannerResponse(
        success: json["success"] is bool ? json["success"] : true,
        banners: list == null || list is! List
            ? []
            : list.map((x) => Banners.fromJson(x as Map<String, dynamic>)).toList(),
      );
    }

    Map<String, dynamic> toJson() => {
        "success": success,
        "banners": banners == null ? [] : List<dynamic>.from(banners!.map((x) => x.toJson())),
    };
}

class Banners {
    int? id;
    String? title;
    String? imageUrl;
    int? productId;
    DateTime? createdAt;
    String? productName;

    Banners({
        this.id,
        this.title,
        this.imageUrl,
        this.productId,
        this.createdAt,
        this.productName,
    });

    factory Banners.fromJson(Map<String, dynamic> json) {
      int? parseId(dynamic val) {
        if (val == null) return null;
        if (val is int) return val;
        return int.tryParse(val.toString());
      }

      DateTime? parseDate(dynamic val) {
        if (val == null) return null;
        if (val is DateTime) return val;
        return DateTime.tryParse(val.toString());
      }

      return Banners(
        id: parseId(json["id"]),
        title: json["title"]?.toString(),
        imageUrl: (json["image_url"] ?? json["imageUrl"])?.toString(),
        productId: parseId(json["product_id"] ?? json["productId"]),
        createdAt: parseDate(json["created_at"] ?? json["createdAt"]),
        productName: (json["product_name"] ?? json["productName"])?.toString(),
      );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image_url": imageUrl,
        "product_id": productId,
        "created_at": createdAt?.toIso8601String(),
        "product_name": productName,
    };
}
