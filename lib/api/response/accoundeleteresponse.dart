// To parse this JSON data, do
//
//     final accountdeleteresponse = accountdeleteresponseFromJson(jsonString);

import 'dart:convert';

List<Accountdeleteresponse> accountdeleteresponseFromJson(String str) =>
    List<Accountdeleteresponse>.from(
        json.decode(str).map((x) => Accountdeleteresponse.fromJson(x)));

String accountdeleteresponseToJson(List<Accountdeleteresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Accountdeleteresponse {
  String? status;
  String? message;
  List<dynamic>? data;

  Accountdeleteresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Accountdeleteresponse.fromJson(Map<String, dynamic> json) =>
      Accountdeleteresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<dynamic>.from(json["data"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x)),
      };
}
