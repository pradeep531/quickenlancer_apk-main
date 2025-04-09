// To parse this JSON data, do
//
//     final getunallocaterequestcompletedresponse = getunallocaterequestcompletedresponseFromJson(jsonString);

import 'dart:convert';

List<Getunallocaterequestcompletedresponse>
    getunallocaterequestcompletedresponseFromJson(String str) =>
        List<Getunallocaterequestcompletedresponse>.from(json
            .decode(str)
            .map((x) => Getunallocaterequestcompletedresponse.fromJson(x)));

String getunallocaterequestcompletedresponseToJson(
        List<Getunallocaterequestcompletedresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Getunallocaterequestcompletedresponse {
  String? status;
  String? message;
  List<GetunallocaterequestcompletedDatum>? data;

  Getunallocaterequestcompletedresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Getunallocaterequestcompletedresponse.fromJson(
          Map<String, dynamic> json) =>
      Getunallocaterequestcompletedresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<GetunallocaterequestcompletedDatum>.from(json["data"]!
                .map((x) => GetunallocaterequestcompletedDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class GetunallocaterequestcompletedDatum {
  String? id;
  String? agentId;
  String? requestId;
  String? requested;
  String? approved;
  String? categoryId;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;
  String? categoryName;

  GetunallocaterequestcompletedDatum({
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
  });

  factory GetunallocaterequestcompletedDatum.fromJson(
          Map<String, dynamic> json) =>
      GetunallocaterequestcompletedDatum(
        id: json["id"],
        agentId: json["agent_id"],
        requestId: json["request_id"],
        requested: json["requested"],
        approved: json["approved"],
        categoryId: json["category_id"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        updatedOn: json["updated_on"] == null
            ? null
            : DateTime.parse(json["updated_on"]),
        categoryName: json["category_name"],
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
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
        "category_name": categoryName,
      };
}
