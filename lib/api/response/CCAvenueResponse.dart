// To parse this JSON data, do
//
//     final ccavenueapiresponse = ccavenueapiresponseFromJson(jsonString);

import 'dart:convert';

List<Ccavenueapiresponse> ccavenueapiresponseFromJson(String str) =>
    List<Ccavenueapiresponse>.from(
        json.decode(str).map((x) => Ccavenueapiresponse.fromJson(x)));

String ccavenueapiresponseToJson(List<Ccavenueapiresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Ccavenueapiresponse {
  String? status;
  String? message;
  String? initiateUrl;

  Ccavenueapiresponse({
    this.status,
    this.message,
    this.initiateUrl,
  });

  factory Ccavenueapiresponse.fromJson(Map<String, dynamic> json) =>
      Ccavenueapiresponse(
        status: json["status"],
        message: json["message"],
        initiateUrl: json["initiate_url"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "initiate_url": initiateUrl,
      };
}
