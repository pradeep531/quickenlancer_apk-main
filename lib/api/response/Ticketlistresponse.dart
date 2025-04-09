// To parse this JSON data, do
//
//     final ticketlistresponse = ticketlistresponseFromJson(jsonString);

import 'dart:convert';

List<Ticketlistresponse> ticketlistresponseFromJson(String str) => List<Ticketlistresponse>.from(json.decode(str).map((x) => Ticketlistresponse.fromJson(x)));

String ticketlistresponseToJson(List<Ticketlistresponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Ticketlistresponse {
    String? status;
    String? message;
    List<TicketListData>? data;

    Ticketlistresponse({
        this.status,
        this.message,
        this.data,
    });

    factory Ticketlistresponse.fromJson(Map<String, dynamic> json) => Ticketlistresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<TicketListData>.from(json["data"]!.map((x) => TicketListData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class TicketListData {
    String? id;
    String? agentId;
    String? ticketNumber;
    String? ticketCreateDate;
    String? ticketStatus;
    String? description;
    String? attachment;
    dynamic helpTypeId;
    String? status;
    String? isDeleted;
    String? createdOn;
    DateTime? updatedOn;

    TicketListData({
        this.id,
        this.agentId,
        this.ticketNumber,
        this.ticketCreateDate,
        this.ticketStatus,
        this.description,
        this.attachment,
        this.helpTypeId,
        this.status,
        this.isDeleted,
        this.createdOn,
        this.updatedOn,
    });

    factory TicketListData.fromJson(Map<String, dynamic> json) => TicketListData(
        id: json["id"],
        agentId: json["agent_id"],
        ticketNumber: json["ticket_number"],
        ticketCreateDate: json["ticket_create_date"],
        ticketStatus: json["ticket_status"],
        description: json["description"],
        attachment: json["attachment"],
        helpTypeId: json["help_type_id"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: json["created_on"],
        updatedOn: json["updated_on"] == null ? null : DateTime.parse(json["updated_on"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "agent_id": agentId,
        "ticket_number": ticketNumber,
        "ticket_create_date": ticketCreateDate,
        "ticket_status": ticketStatus,
        "description": description,
        "attachment": attachment,
        "help_type_id": helpTypeId,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn,
        "updated_on": updatedOn?.toIso8601String(),
    };
}
