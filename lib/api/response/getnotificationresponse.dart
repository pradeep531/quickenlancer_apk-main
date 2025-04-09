// To parse this JSON data, do
//
//     final getnotificationresponse = getnotificationresponseFromJson(jsonString);

import 'dart:convert';

List<Getnotificationresponse> getnotificationresponseFromJson(String str) =>
    List<Getnotificationresponse>.from(
        json.decode(str).map((x) => Getnotificationresponse.fromJson(x)));

String getnotificationresponseToJson(List<Getnotificationresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Getnotificationresponse {
  String? status;
  String? message;
  List<GetnotificationDatum>? data;

  Getnotificationresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Getnotificationresponse.fromJson(Map<String, dynamic> json) =>
      Getnotificationresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<GetnotificationDatum>.from(
                json["data"]!.map((x) => GetnotificationDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class GetnotificationDatum {
  String? id;
  String? agentId;
  String? title;
  String? description;
  DateTime? date;
  String? pageLink;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  GetnotificationDatum({
    this.id,
    this.agentId,
    this.title,
    this.description,
    this.date,
    this.pageLink,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
  });

  factory GetnotificationDatum.fromJson(Map<String, dynamic> json) =>
      GetnotificationDatum(
        id: json["id"],
        agentId: json["agent_id"],
        title: json["title"],
        description: json["description"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        pageLink: json["page_link"],
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
        "title": title,
        "description": description,
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "page_link": pageLink,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
      };
}
