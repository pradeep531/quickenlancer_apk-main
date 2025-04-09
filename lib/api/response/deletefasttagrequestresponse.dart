// To parse this JSON data, do
//
//     final deletefastagrequestresponse = deletefastagrequestresponseFromJson(jsonString);

import 'dart:convert';

List<Deletefastagrequestresponse> deletefastagrequestresponseFromJson(
        String str) =>
    List<Deletefastagrequestresponse>.from(
        json.decode(str).map((x) => Deletefastagrequestresponse.fromJson(x)));

String deletefastagrequestresponseToJson(
        List<Deletefastagrequestresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Deletefastagrequestresponse {
  String? status;
  String? message;
  List<dynamic>? data;

  Deletefastagrequestresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Deletefastagrequestresponse.fromJson(Map<String, dynamic> json) =>
      Deletefastagrequestresponse(
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
