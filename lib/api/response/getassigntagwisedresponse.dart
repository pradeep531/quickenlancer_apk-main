// To parse this JSON data, do
//
//     final getassignedtagdatewiseresponse = getassignedtagdatewiseresponseFromJson(jsonString);

import 'dart:convert';

List<Getassignedtagdatewiseresponse> getassignedtagdatewiseresponseFromJson(
        String str) =>
    List<Getassignedtagdatewiseresponse>.from(json
        .decode(str)
        .map((x) => Getassignedtagdatewiseresponse.fromJson(x)));

String getassignedtagdatewiseresponseToJson(
        List<Getassignedtagdatewiseresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Getassignedtagdatewiseresponse {
  String? status;
  String? message;
  List<GetassignedtagdatewisDatum>? data;

  Getassignedtagdatewiseresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Getassignedtagdatewiseresponse.fromJson(Map<String, dynamic> json) =>
      Getassignedtagdatewiseresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<GetassignedtagdatewisDatum>.from(json["data"]!
                .map((x) => GetassignedtagdatewisDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class GetassignedtagdatewisDatum {
  String? name;
  String? serialNo;
  DateTime? createdOn;
  String? vehicleNumber;

  GetassignedtagdatewisDatum({
    this.name,
    this.serialNo,
    this.createdOn,
    this.vehicleNumber,
  });

  factory GetassignedtagdatewisDatum.fromJson(Map<String, dynamic> json) =>
      GetassignedtagdatewisDatum(
        name: json["name"],
        serialNo: json["serialNo"],
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        vehicleNumber: json["vehicle_number"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "serialNo": serialNo,
        "created_on": createdOn?.toIso8601String(),
        "vehicle_number": vehicleNumber,
      };
}
