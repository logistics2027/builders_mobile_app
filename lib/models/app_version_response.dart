// To parse this JSON data, do
//
//     final appVersionResponse = appVersionResponseFromJson(jsonString);

import 'dart:convert';

AppVersionResponse appVersionResponseFromJson(String str) => AppVersionResponse.fromJson(json.decode(str));

String appVersionResponseToJson(AppVersionResponse data) => json.encode(data.toJson());

class AppVersionResponse {
    bool? success;
    Data? data;

    AppVersionResponse({
        this.success,
        this.data,
    });

    factory AppVersionResponse.fromJson(Map<String, dynamic> json) => AppVersionResponse(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    String? androidCurrent;
    String? androidMinimum;
    String? iosCurrent;
    String? iosMinimum;
    String? releaseNotes;
    bool? forceUpdate;
    DateTime? updatedAt;

    Data({
        this.androidCurrent,
        this.androidMinimum,
        this.iosCurrent,
        this.iosMinimum,
        this.releaseNotes,
        this.forceUpdate,
        this.updatedAt,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        androidCurrent: json["androidCurrent"],
        androidMinimum: json["androidMinimum"],
        iosCurrent: json["iosCurrent"],
        iosMinimum: json["iosMinimum"],
        releaseNotes: json["releaseNotes"],
        forceUpdate: json["forceUpdate"],
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "androidCurrent": androidCurrent,
        "androidMinimum": androidMinimum,
        "iosCurrent": iosCurrent,
        "iosMinimum": iosMinimum,
        "releaseNotes": releaseNotes,
        "forceUpdate": forceUpdate,
        "updatedAt": updatedAt?.toIso8601String(),
    };
}
