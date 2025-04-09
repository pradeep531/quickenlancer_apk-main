// To parse this JSON data, do
//
//     final gettagforunallocateresponse = gettagforunallocateresponseFromJson(jsonString);

import 'dart:convert';

List<Gettagforunallocateresponse> gettagforunallocateresponseFromJson(
        String str) =>
    List<Gettagforunallocateresponse>.from(
        json.decode(str).map((x) => Gettagforunallocateresponse.fromJson(x)));

String gettagforunallocateresponseToJson(
        List<Gettagforunallocateresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Gettagforunallocateresponse {
  String? status;
  String? message;
  List<GettagforunallocateDatum>? data;

  Gettagforunallocateresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Gettagforunallocateresponse.fromJson(Map<String, dynamic> json) =>
      Gettagforunallocateresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<GettagforunallocateDatum>.from(
                json["data"]!.map((x) => GettagforunallocateDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class GettagforunallocateDatum {
  String? id;
  String? vehicleColor;
  String? categoryName;
  String? vehicleClassCount;
  String? category_id;

  GettagforunallocateDatum({
    this.id,
    this.vehicleColor,
    this.categoryName,
    this.vehicleClassCount,
    this.category_id,
  });

  factory GettagforunallocateDatum.fromJson(Map<String, dynamic> json) =>
      GettagforunallocateDatum(
        id: json["id"],
        vehicleColor: json["vehicle_color"],
        categoryName: json["category_name"],
        vehicleClassCount: json["vehicle_class_count"],
        category_id: json["category_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vehicle_color": vehicleColor,
        "category_name": categoryName,
        "vehicle_class_count": vehicleClassCount,
        "category_id": category_id
      };
}
