// To parse this JSON data, do
//
//     final ticketdetailsresponse = ticketdetailsresponseFromJson(jsonString);

import 'dart:convert';

List<Ticketdetailsresponse> ticketdetailsresponseFromJson(String str) => List<Ticketdetailsresponse>.from(json.decode(str).map((x) => Ticketdetailsresponse.fromJson(x)));

String ticketdetailsresponseToJson(List<Ticketdetailsresponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Ticketdetailsresponse {
    String? status;
    String? message;
    AddDetailsData? data;

    Ticketdetailsresponse({
        this.status,
        this.message,
        this.data,
    });

    factory Ticketdetailsresponse.fromJson(Map<String, dynamic> json) => Ticketdetailsresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : AddDetailsData.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
    };
}

class AddDetailsData {
    String? id;
    String? description;
    String? ticketId;
    String? replyBy;
    DateTime? replyDate;
    String? status;
    String? isDeleted;
    String? createdOn;
    DateTime? updatedOn;

    AddDetailsData({
        this.id,
        this.description,
        this.ticketId,
        this.replyBy,
        this.replyDate,
        this.status,
        this.isDeleted,
        this.createdOn,
        this.updatedOn,
    });

    factory AddDetailsData.fromJson(Map<String, dynamic> json) => AddDetailsData(
        id: json["id"],
        description: json["description"],
        ticketId: json["ticket_id"],
        replyBy: json["reply_by"],
        replyDate: json["reply_date"] == null ? null : DateTime.parse(json["reply_date"]),
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: json["created_on"],
        updatedOn: json["updated_on"] == null ? null : DateTime.parse(json["updated_on"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "ticket_id": ticketId,
        "reply_by": replyBy,
        "reply_date": "${replyDate!.year.toString().padLeft(4, '0')}-${replyDate!.month.toString().padLeft(2, '0')}-${replyDate!.day.toString().padLeft(2, '0')}",
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn,
        "updated_on": updatedOn?.toIso8601String(),
    };
}
