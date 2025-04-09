// To parse this JSON data, do
//
//     final pendingissuanceresponse = pendingissuanceresponseFromJson(jsonString);

import 'dart:convert';

List<Pendingissuanceresponse> pendingissuanceresponseFromJson(String str) =>
    List<Pendingissuanceresponse>.from(
        json.decode(str).map((x) => Pendingissuanceresponse.fromJson(x)));

String pendingissuanceresponseToJson(List<Pendingissuanceresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Pendingissuanceresponse {
  String? status;
  String? message;
  List<PendingissuanceDatum>? data;

  Pendingissuanceresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Pendingissuanceresponse.fromJson(Map<String, dynamic> json) =>
      Pendingissuanceresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<PendingissuanceDatum>.from(
                json["data"]!.map((x) => PendingissuanceDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class PendingissuanceDatum {
  DateTime? appliedDate;
  String? id;
  String? name;
  String? vehicleNumber;
  String? mobileNumber;
  String? engineNo;
  String? isChassis;
  String? chassisNo;

  PendingissuanceDatum({
    this.appliedDate,
    this.id,
    this.name,
    this.vehicleNumber,
    this.mobileNumber,
    this.engineNo,
    this.isChassis,
    this.chassisNo,
  });

  factory PendingissuanceDatum.fromJson(Map<String, dynamic> json) =>
      PendingissuanceDatum(
        appliedDate: json["applied_date"] == null
            ? null
            : DateTime.parse(json["applied_date"]),
        id: json["id"],
        name: json["name"],
        vehicleNumber: json["vehicle_number"],
        mobileNumber: json["mobile_number"],
        engineNo: json["engineNo"],
        isChassis: json["isChassis"],
        chassisNo: json["chassisNo"]!,
      );

  Map<String, dynamic> toJson() => {
        "applied_date": appliedDate?.toIso8601String(),
        "id": id,
        "name": name,
        "vehicle_number": vehicleNumber,
        "mobile_number": mobileNumber,
        "engineNo": engineNo,
        "isChassis": isChassis,
        "chassisNo": chassisNo,
      };
}
