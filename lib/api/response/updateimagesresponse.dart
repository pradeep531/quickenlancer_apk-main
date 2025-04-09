// To parse this JSON data, do
//
//     final updateimagesresponse = updateimagesresponseFromJson(jsonString);

import 'dart:convert';

List<Updateimagesresponse> updateimagesresponseFromJson(String str) =>
    List<Updateimagesresponse>.from(
        json.decode(str).map((x) => Updateimagesresponse.fromJson(x)));

String updateimagesresponseToJson(List<Updateimagesresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Updateimagesresponse {
  String status;
  String message;

  Updateimagesresponse({
    required this.status,
    required this.message,
  });

  factory Updateimagesresponse.fromJson(Map<String, dynamic> json) =>
      Updateimagesresponse(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
