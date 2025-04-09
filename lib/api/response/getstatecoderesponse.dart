// To parse this JSON data, do
//
//     final getstatecoderesponse = getstatecoderesponseFromJson(jsonString);

import 'dart:convert';

List<Getstatecoderesponse> getstatecoderesponseFromJson(String str) =>
    List<Getstatecoderesponse>.from(
        json.decode(str).map((x) => Getstatecoderesponse.fromJson(x)));

String getstatecoderesponseToJson(List<Getstatecoderesponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Getstatecoderesponse {
  String? status;
  String? message;
  List<GetstatecodeDatum>? data;

  Getstatecoderesponse({
    this.status,
    this.message,
    this.data,
  });

  factory Getstatecoderesponse.fromJson(Map<String, dynamic> json) =>
      Getstatecoderesponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<GetstatecodeDatum>.from(
                json["data"]!.map((x) => GetstatecodeDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class GetstatecodeDatum {
  String? stateOfRegistration;

  GetstatecodeDatum({
    this.stateOfRegistration,
  });

  factory GetstatecodeDatum.fromJson(Map<String, dynamic> json) =>
      GetstatecodeDatum(
        stateOfRegistration: json["state_of_registration"],
      );

  Map<String, dynamic> toJson() => {
        "state_of_registration": stateOfRegistration,
      };
}
