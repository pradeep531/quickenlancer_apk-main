// To parse this JSON data, do
//
//     final editfasttagrequestresponse = editfasttagrequestresponseFromJson(jsonString);

import 'dart:convert';

List<Editfasttagrequestresponse> editfasttagrequestresponseFromJson(
        String str) =>
    List<Editfasttagrequestresponse>.from(
        json.decode(str).map((x) => Editfasttagrequestresponse.fromJson(x)));

String editfasttagrequestresponseToJson(
        List<Editfasttagrequestresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Editfasttagrequestresponse {
  String? status;
  String? message;
  List<EditfasttagrequestDatum>? data;

  Editfasttagrequestresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Editfasttagrequestresponse.fromJson(Map<String, dynamic> json) =>
      Editfasttagrequestresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<EditfasttagrequestDatum>.from(
                json["data"]!.map((x) => EditfasttagrequestDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class EditfasttagrequestDatum {
  String? agentId;
  String? requestId;
  String? categoryId;
  String? requested;

  EditfasttagrequestDatum({
    this.agentId,
    this.requestId,
    this.categoryId,
    this.requested,
  });

  factory EditfasttagrequestDatum.fromJson(Map<String, dynamic> json) =>
      EditfasttagrequestDatum(
        agentId: json["agent_id"],
        requestId: json["request_id"],
        categoryId: json["category_id"],
        requested: json["requested"],
      );

  Map<String, dynamic> toJson() => {
        "agent_id": agentId,
        "request_id": requestId,
        "category_id": categoryId,
        "requested": requested,
      };
}
