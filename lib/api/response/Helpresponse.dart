// To parse this JSON data, do
//
//     final helpresponse = helpresponseFromJson(jsonString);

import 'dart:convert';

List<Helpresponse> helpresponseFromJson(String str) => List<Helpresponse>.from(json.decode(str).map((x) => Helpresponse.fromJson(x)));

String helpresponseToJson(List<Helpresponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Helpresponse {
    String? status;
    String? message;
    List<HelpData>? data;

    Helpresponse({
        this.status,
        this.message,
        this.data,
    });

    factory Helpresponse.fromJson(Map<String, dynamic> json) => Helpresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<HelpData>.from(json["data"]!.map((x) => HelpData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class HelpData {
    String? id;
    String? helpType;
    String? status;
    String? isDeleted;
    DateTime? createdOn;
    DateTime? updatedOn;

    HelpData({
        this.id,
        this.helpType,
        this.status,
        this.isDeleted,
        this.createdOn,
        this.updatedOn,
    });

    factory HelpData.fromJson(Map<String, dynamic> json) => HelpData(
        id: json["id"],
        helpType: json["help_type"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: json["created_on"] == null ? null : DateTime.parse(json["created_on"]),
        updatedOn: json["updated_on"] == null ? null : DateTime.parse(json["updated_on"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "help_type": helpType,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
    };
}
