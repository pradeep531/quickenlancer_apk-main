// To parse this JSON data, do
//
//     final setwithdrawresponse = setwithdrawresponseFromJson(jsonString);

import 'dart:convert';

List<Setwithdrawresponse> setwithdrawresponseFromJson(String str) =>
    List<Setwithdrawresponse>.from(
        json.decode(str).map((x) => Setwithdrawresponse.fromJson(x)));

String setwithdrawresponseToJson(List<Setwithdrawresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Setwithdrawresponse {
  String? status;
  String? message;
  List<SetwithdrawDatum>? data;

  Setwithdrawresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Setwithdrawresponse.fromJson(Map<String, dynamic> json) =>
      Setwithdrawresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<SetwithdrawDatum>.from(
                json["data"]!.map((x) => SetwithdrawDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class SetwithdrawDatum {
  String? id;
  String? agentId;
  String? requestNumber;
  String? withdraAmount;
  String? approvedAmount;
  String? approveStatus;
  String? remark;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  SetwithdrawDatum({
    this.id,
    this.agentId,
    this.requestNumber,
    this.withdraAmount,
    this.approvedAmount,
    this.approveStatus,
    this.remark,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
  });

  factory SetwithdrawDatum.fromJson(Map<String, dynamic> json) =>
      SetwithdrawDatum(
        id: json["id"],
        agentId: json["agent_id"],
        requestNumber: json["request_number"],
        withdraAmount: json["withdra_amount"],
        approvedAmount: json["approved_amount"],
        approveStatus: json["approve_status"],
        remark: json["remark"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        updatedOn: json["updated_on"] == null
            ? null
            : DateTime.parse(json["updated_on"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "agent_id": agentId,
        "request_number": requestNumber,
        "withdra_amount": withdraAmount,
        "approved_amount": approvedAmount,
        "approve_status": approveStatus,
        "remark": remark,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
      };
}
