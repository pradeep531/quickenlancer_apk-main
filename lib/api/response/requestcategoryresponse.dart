// To parse this JSON data, do
//
//     final requestcategoryresponse = requestcategoryresponseFromJson(jsonString);

import 'dart:convert';

List<Requestcategoryresponse> requestcategoryresponseFromJson(String str) =>
    List<Requestcategoryresponse>.from(
        json.decode(str).map((x) => Requestcategoryresponse.fromJson(x)));

String requestcategoryresponseToJson(List<Requestcategoryresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Requestcategoryresponse {
  String? status;
  String? message;
  List<RequestcategoryDatum>? data;

  Requestcategoryresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Requestcategoryresponse.fromJson(Map<String, dynamic> json) =>
      Requestcategoryresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<RequestcategoryDatum>.from(
                json["data"]!.map((x) => RequestcategoryDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class RequestcategoryDatum {
  String? id;
  String? categoryName;
  String? vehicleColor;
  dynamic lowOrderQty;
  dynamic highOrderQty;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  RequestcategoryDatum({
    this.id,
    this.categoryName,
    this.vehicleColor,
    this.lowOrderQty,
    this.highOrderQty,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
  });

  factory RequestcategoryDatum.fromJson(Map<String, dynamic> json) =>
      RequestcategoryDatum(
        id: json["id"],
        categoryName: json["category_name"],
        vehicleColor: json["vehicle_color"],
        lowOrderQty: json["low_order_qty"],
        highOrderQty: json["high_order_qty"],
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
        "category_name": categoryName,
        "vehicle_color": vehicleColor,
        "low_order_qty": lowOrderQty,
        "high_order_qty": highOrderQty,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
      };
}
