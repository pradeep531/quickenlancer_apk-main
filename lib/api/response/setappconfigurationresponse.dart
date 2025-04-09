// To parse this JSON data, do
//
//     final setappconfigurationresponse = setappconfigurationresponseFromJson(jsonString);

import 'dart:convert';

List<Setappconfigurationresponse> setappconfigurationresponseFromJson(
        String str) =>
    List<Setappconfigurationresponse>.from(
        json.decode(str).map((x) => Setappconfigurationresponse.fromJson(x)));

String setappconfigurationresponseToJson(
        List<Setappconfigurationresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Setappconfigurationresponse {
  String status;
  String message;
  Data data;

  Setappconfigurationresponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory Setappconfigurationresponse.fromJson(Map<String, dynamic> json) =>
      Setappconfigurationresponse(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  Data();

  factory Data.fromJson(Map<String, dynamic> json) => Data();

  Map<String, dynamic> toJson() => {};
}
