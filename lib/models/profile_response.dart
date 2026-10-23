// To parse this JSON data, do
//
//     final profileResponse = profileResponseFromJson(jsonString);

import 'dart:convert';

ProfileResponse profileResponseFromJson(String str) => ProfileResponse.fromJson(json.decode(str));

String profileResponseToJson(ProfileResponse data) => json.encode(data.toJson());

class ProfileResponse {
    User? user;
    List<Address>? addresses;

    ProfileResponse({
        this.user,
        this.addresses,
    });

    factory ProfileResponse.fromJson(Map<String, dynamic> json) => ProfileResponse(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        addresses: json["addresses"] == null ? [] : List<Address>.from(json["addresses"]!.map((x) => Address.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "addresses": addresses == null ? [] : List<dynamic>.from(addresses!.map((x) => x.toJson())),
    };
}

class Address {
    int? id;
    int? userId;
    String? tag;
    String? phone;
    String? streetName;
    String? landmark;
    String? city;
    String? state;
    String? district;
    String? pincode;
    DateTime? createdAt;

    Address({
        this.id,
        this.userId,
        this.tag,
        this.phone,
        this.streetName,
        this.landmark,
        this.city,
        this.state,
        this.district,
        this.pincode,
        this.createdAt,
    });

    factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json["id"],
        userId: json["user_id"],
        tag: json["tag"],
        phone: json["phone"],
        streetName: json["street_name"],
        landmark: json["landmark"],
        city: json["city"],
        state: json["state"],
        district: json["district"],
        pincode: json["pincode"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "tag": tag,
        "phone": phone,
        "street_name": streetName,
        "landmark": landmark,
        "city": city,
        "state": state,
        "district": district,
        "pincode": pincode,
        "created_at": createdAt?.toIso8601String(),
    };
}

class User {
    int? id;
    String? name;
    String? email;
    String? role;

    User({
        this.id,
        this.name,
        this.email,
        this.role,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        role: json["role"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "role": role,
    };
}
