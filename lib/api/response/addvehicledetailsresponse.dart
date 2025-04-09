// To parse this JSON data, do
//
//     final addvehicledetailsresponse = addvehicledetailsresponseFromJson(jsonString);

import 'dart:convert';

List<Addvehicledetailsresponse> addvehicledetailsresponseFromJson(String str) =>
    List<Addvehicledetailsresponse>.from(
        json.decode(str).map((x) => Addvehicledetailsresponse.fromJson(x)));

String addvehicledetailsresponseToJson(List<Addvehicledetailsresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Addvehicledetailsresponse {
  String? status;
  String? message;

  Addvehicledetailsresponse({
    this.status,
    this.message,
  });

  factory Addvehicledetailsresponse.fromJson(Map<String, dynamic> json) =>
      Addvehicledetailsresponse(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
