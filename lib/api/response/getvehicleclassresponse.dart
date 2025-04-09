// To parse this JSON data, do
//
//     final getvehicleclassresponse = getvehicleclassresponseFromJson(jsonString);

import 'dart:convert';

List<Getvehicleclassresponse> getvehicleclassresponseFromJson(String str) =>
    List<Getvehicleclassresponse>.from(
        json.decode(str).map((x) => Getvehicleclassresponse.fromJson(x)));

String getvehicleclassresponseToJson(List<Getvehicleclassresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Getvehicleclassresponse {
  String? status;
  String? message;
  List<GetvehicleclassDatum>? data;

  Getvehicleclassresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Getvehicleclassresponse.fromJson(Map<String, dynamic> json) =>
      Getvehicleclassresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<GetvehicleclassDatum>.from(
                json["data"]!.map((x) => GetvehicleclassDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class GetvehicleclassDatum {
  String? id;
  String? categoryName;
  String? vehicleColor;
  String? lowOrderQty;
  String? highOrderQty;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  GetvehicleclassDatum({
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

  factory GetvehicleclassDatum.fromJson(Map<String, dynamic> json) =>
      GetvehicleclassDatum(
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
