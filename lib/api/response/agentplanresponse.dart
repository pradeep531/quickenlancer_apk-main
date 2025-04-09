// To parse this JSON data, do
//
//     final agentplanresponse = agentplanresponseFromJson(jsonString);

import 'dart:convert';

List<Agentplanresponse> agentplanresponseFromJson(String str) =>
    List<Agentplanresponse>.from(
        json.decode(str).map((x) => Agentplanresponse.fromJson(x)));

String agentplanresponseToJson(List<Agentplanresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Agentplanresponse {
  String? status;
  String? message;
  List<AgentplanDatum>? data;

  Agentplanresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Agentplanresponse.fromJson(Map<String, dynamic> json) =>
      Agentplanresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<AgentplanDatum>.from(
                json["data"]!.map((x) => AgentplanDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class AgentplanDatum {
  String? id;
  String? planName;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  AgentplanDatum({
    this.id,
    this.planName,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
  });

  factory AgentplanDatum.fromJson(Map<String, dynamic> json) => AgentplanDatum(
        id: json["id"],
        planName: json["plan_name"],
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
        "plan_name": planName,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
      };
}
