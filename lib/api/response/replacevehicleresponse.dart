// To parse this JSON data, do
//
//     final replacevehicleresponse = replacevehicleresponseFromJson(jsonString);

import 'dart:convert';

List<Replacevehicleresponse> replacevehicleresponseFromJson(String str) =>
    List<Replacevehicleresponse>.from(
        json.decode(str).map((x) => Replacevehicleresponse.fromJson(x)));

String replacevehicleresponseToJson(List<Replacevehicleresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Replacevehicleresponse {
  String? status;
  String? message;
  List<ReplacevehicleDatum>? data;

  Replacevehicleresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Replacevehicleresponse.fromJson(Map<String, dynamic> json) =>
      Replacevehicleresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<ReplacevehicleDatum>.from(
                json["data"]!.map((x) => ReplacevehicleDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ReplacevehicleDatum {
  String? requestId;
  String? sessionId;
  String? agentId;
  String? vehicleNumber;
  String? mobileNumber;

  ReplacevehicleDatum({
    this.requestId,
    this.sessionId,
    this.agentId,
    this.vehicleNumber,
    this.mobileNumber,
  });

  factory ReplacevehicleDatum.fromJson(Map<String, dynamic> json) =>
      ReplacevehicleDatum(
        requestId: json["requestId"],
        sessionId: json["sessionId"],
        agentId: json["agent_id"],
        vehicleNumber: json["vehicle_number"],
        mobileNumber: json["mobile_number"],
      );

  Map<String, dynamic> toJson() => {
        "requestId": requestId,
        "sessionId": sessionId,
        "agent_id": agentId,
        "vehicle_number": vehicleNumber,
        "mobile_number": mobileNumber,
      };
}
