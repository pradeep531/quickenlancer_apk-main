// To parse this JSON data, do
//
//     final completefasttagrequestresponse = completefasttagrequestresponseFromJson(jsonString);

import 'dart:convert';

List<Completefasttagrequestresponse> completefasttagrequestresponseFromJson(
        String str) =>
    List<Completefasttagrequestresponse>.from(json
        .decode(str)
        .map((x) => Completefasttagrequestresponse.fromJson(x)));

String completefasttagrequestresponseToJson(
        List<Completefasttagrequestresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Completefasttagrequestresponse {
  String? status;
  String? message;
  List<CompletefasttagrequestDatum>? data;

  Completefasttagrequestresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Completefasttagrequestresponse.fromJson(Map<String, dynamic> json) =>
      Completefasttagrequestresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<CompletefasttagrequestDatum>.from(json["data"]!
                .map((x) => CompletefasttagrequestDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CompletefasttagrequestDatum {
  String? id;
  String? agentId;
  String? requestId;
  String? requested;
  dynamic approved;
  String? categoryId;
  String? status;
  String? isDeleted;
  String? createdOn;
  DateTime? updatedOn;
  String? categoryName;
  String? courierId;

  CompletefasttagrequestDatum({
    this.id,
    this.agentId,
    this.requestId,
    this.requested,
    this.approved,
    this.categoryId,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
    this.categoryName,
    this.courierId,
  });

  factory CompletefasttagrequestDatum.fromJson(Map<String, dynamic> json) =>
      CompletefasttagrequestDatum(
        id: json["id"],
        agentId: json["agent_id"],
        requestId: json["request_id"],
        requested: json["requested"],
        approved: json["approved"],
        categoryId: json["category_id"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: json["created_on"],
        updatedOn: json["updated_on"] == null
            ? null
            : DateTime.parse(json["updated_on"]),
        categoryName: json["category_name"],
        courierId: json["courier_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "agent_id": agentId,
        "request_id": requestId,
        "requested": requested,
        "approved": approved,
        "category_id": categoryId,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn,
        "updated_on": updatedOn?.toIso8601String(),
        "category_name": categoryName,
        "courier_id": courierId,
      };
}
