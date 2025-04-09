// To parse this JSON data, do
//
//     final assignvehicleresponse = assignvehicleresponseFromJson(jsonString);

import 'dart:convert';

List<Assignvehicleresponse> assignvehicleresponseFromJson(String str) =>
    List<Assignvehicleresponse>.from(
        json.decode(str).map((x) => Assignvehicleresponse.fromJson(x)));

String assignvehicleresponseToJson(List<Assignvehicleresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Assignvehicleresponse {
  String? status;
  String? message;
  List<AssignvehicleDatum>? data;

  Assignvehicleresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Assignvehicleresponse.fromJson(Map<String, dynamic> json) =>
      Assignvehicleresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<AssignvehicleDatum>.from(
                json["data"]!.map((x) => AssignvehicleDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class AssignvehicleDatum {
  String? requestId;
  String? sessionId;
  String? agentId;
  String? vehicleNumber;
  String? mobileNumber;
  String? appApiStatus;
  bool appInstallStatus;

  AssignvehicleDatum({
    this.requestId,
    this.sessionId,
    this.agentId,
    this.vehicleNumber,
    this.mobileNumber,
    this.appApiStatus,
    required this.appInstallStatus,
  });

  factory AssignvehicleDatum.fromJson(Map<String, dynamic> json) =>
      AssignvehicleDatum(
        requestId: json["requestId"],
        sessionId: json["sessionId"],
        agentId: json["agent_id"],
        vehicleNumber: json["vehicle_number"],
        mobileNumber: json["mobile_number"],
        appApiStatus: json["app_api_status"],
        appInstallStatus: json["app_install_status"],
      );

  Map<String, dynamic> toJson() => {
        "requestId": requestId,
        "sessionId": sessionId,
        "agent_id": agentId,
        "vehicle_number": vehicleNumber,
        "mobile_number": mobileNumber,
        "app_api_status": appApiStatus,
        "app_install_status": appInstallStatus,
      };
}
