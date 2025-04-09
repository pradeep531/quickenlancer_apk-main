// To parse this JSON data, do
//
//     final getvehicledescriptorreresponse = getvehicledescriptorreresponseFromJson(jsonString);

import 'dart:convert';

List<Getvehicledescriptorreresponse> getvehicledescriptorreresponseFromJson(
        String str) =>
    List<Getvehicledescriptorreresponse>.from(json
        .decode(str)
        .map((x) => Getvehicledescriptorreresponse.fromJson(x)));

String getvehicledescriptorreresponseToJson(
        List<Getvehicledescriptorreresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Getvehicledescriptorreresponse {
  String? status;
  String? message;
  List<GetvehicledescriptorDatum>? data;

  Getvehicledescriptorreresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Getvehicledescriptorreresponse.fromJson(Map<String, dynamic> json) =>
      Getvehicledescriptorreresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<GetvehicledescriptorDatum>.from(json["data"]!
                .map((x) => GetvehicledescriptorDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class GetvehicledescriptorDatum {
  String? vehicleDescriptor;

  GetvehicledescriptorDatum({
    this.vehicleDescriptor,
  });

  factory GetvehicledescriptorDatum.fromJson(Map<String, dynamic> json) =>
      GetvehicledescriptorDatum(
        vehicleDescriptor: json["vehicleDescriptor"],
      );

  Map<String, dynamic> toJson() => {
        "vehicleDescriptor": vehicleDescriptor,
      };
}
