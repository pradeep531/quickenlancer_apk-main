// To parse this JSON data, do
//
//     final categorydetailsresponse = categorydetailsresponseFromJson(jsonString);

import 'dart:convert';

List<Categorydetailsresponse> categorydetailsresponseFromJson(String str) =>
    List<Categorydetailsresponse>.from(
        json.decode(str).map((x) => Categorydetailsresponse.fromJson(x)));

String categorydetailsresponseToJson(List<Categorydetailsresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Categorydetailsresponse {
  String? status;
  String? message;
  List<CategorydetailsDatum>? data;

  Categorydetailsresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Categorydetailsresponse.fromJson(Map<String, dynamic> json) =>
      Categorydetailsresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<CategorydetailsDatum>.from(
                json["data"]!.map((x) => CategorydetailsDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CategorydetailsDatum {
  String? agentId;
  int? requestId;
  String? categoryId;
  String? requested;

  CategorydetailsDatum({
    this.agentId,
    this.requestId,
    this.categoryId,
    this.requested,
  });

  factory CategorydetailsDatum.fromJson(Map<String, dynamic> json) =>
      CategorydetailsDatum(
        agentId: json["agent_id"],
        requestId: json["request_id"],
        categoryId: json["category_id"],
        requested: json["requested"],
      );

  Map<String, dynamic> toJson() => {
        "agent_id": agentId,
        "request_id": requestId,
        "category_id": categoryId,
        "requested": requested,
      };
}
