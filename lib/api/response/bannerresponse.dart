// To parse this JSON data, do
//
//     final bannerresponse = bannerresponseFromJson(jsonString);

import 'dart:convert';

List<Bannerresponse> bannerresponseFromJson(String str) =>
    List<Bannerresponse>.from(
        json.decode(str).map((x) => Bannerresponse.fromJson(x)));

String bannerresponseToJson(List<Bannerresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Bannerresponse {
  String? status;
  String? message;
  String? imageUrl;
  List<BannerDatum>? data;

  Bannerresponse({
    this.status,
    this.message,
    this.imageUrl,
    this.data,
  });

  factory Bannerresponse.fromJson(Map<String, dynamic> json) => Bannerresponse(
        status: json["status"],
        message: json["message"],
        imageUrl: json["image_url"],
        data: json["data"] == null
            ? []
            : List<BannerDatum>.from(
                json["data"]!.map((x) => BannerDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "image_url": imageUrl,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class BannerDatum {
  String? id;
  String? bannerLink;
  String? displayOrder;
  String? banner;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  BannerDatum({
    this.id,
    this.bannerLink,
    this.displayOrder,
    this.banner,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
  });

  factory BannerDatum.fromJson(Map<String, dynamic> json) => BannerDatum(
        id: json["id"],
        bannerLink: json["banner_link"],
        displayOrder: json["display_order"],
        banner: json["banner"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        updatedOn: json["updated_on"] == null
            ? null
            : DateTime.parse(json["updated_on"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "banner_link": bannerLink,
        "display_order": displayOrder,
        "banner": banner,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
      };
}
