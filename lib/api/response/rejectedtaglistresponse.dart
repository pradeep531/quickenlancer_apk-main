// To parse this JSON data, do
//
//     final rejectedtagresponse = rejectedtagresponseFromJson(jsonString);

import 'dart:convert';

List<Rejectedtagresponse> rejectedtagresponseFromJson(String str) =>
    List<Rejectedtagresponse>.from(
        json.decode(str).map((x) => Rejectedtagresponse.fromJson(x)));

String rejectedtagresponseToJson(List<Rejectedtagresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Rejectedtagresponse {
  String status;
  String message;
  List<RejectedtagDatum> data;

  Rejectedtagresponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory Rejectedtagresponse.fromJson(Map<String, dynamic> json) =>
      Rejectedtagresponse(
        status: json["status"],
        message: json["message"],
        data: List<RejectedtagDatum>.from(
            json["data"].map((x) => RejectedtagDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class RejectedtagDatum {
  String id;
  String sessionId;
  String imageType;
  String image;
  String imageStatus;
  String status;
  String isDeleted;
  DateTime createdOn;
  DateTime updatedOn;
  String requestId;
  String name;
  String lastName;
  String isChassis;
  String dob;
  String serialNo;
  String agentId;
  String mobileNumber;
  String vehicleNumber;

  RejectedtagDatum({
    required this.id,
    required this.sessionId,
    required this.imageType,
    required this.image,
    required this.imageStatus,
    required this.status,
    required this.isDeleted,
    required this.createdOn,
    required this.updatedOn,
    required this.requestId,
    required this.name,
    required this.lastName,
    required this.isChassis,
    required this.dob,
    required this.serialNo,
    required this.agentId,
    required this.mobileNumber,
    required this.vehicleNumber,
  });

  factory RejectedtagDatum.fromJson(Map<String, dynamic> json) =>
      RejectedtagDatum(
        id: json["id"],
        sessionId: json["session_id"],
        imageType: json["image_type"],
        image: json["image"],
        imageStatus: json["image_status"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: DateTime.parse(json["created_on"]),
        updatedOn: DateTime.parse(json["updated_on"]),
        requestId: json["request_id"],
        name: json["name"],
        lastName: json["lastName"],
        isChassis: json["isChassis"],
        dob: json["dob"],
        serialNo: json["serialNo"],
        agentId: json["agent_id"],
        mobileNumber: json["mobile_number"],
        vehicleNumber: json["vehicle_number"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "session_id": sessionId,
        "image_type": imageType,
        "image": image,
        "image_status": imageStatus,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn.toIso8601String(),
        "updated_on": updatedOn.toIso8601String(),
        "request_id": requestId,
        "name": name,
        "lastName": lastName,
        "isChassis": isChassis,
        "dob": dob,
        "serialNo": serialNo,
        "agent_id": agentId,
        "mobile_number": mobileNumber,
        "vehicle_number": vehicleNumber,
      };
}
