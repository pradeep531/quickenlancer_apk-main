// To parse this JSON data, do
//
//     final ticketraiseresponse = ticketraiseresponseFromJson(jsonString);

import 'dart:convert';

List<Ticketraiseresponse> ticketraiseresponseFromJson(String str) => List<Ticketraiseresponse>.from(json.decode(str).map((x) => Ticketraiseresponse.fromJson(x)));

String ticketraiseresponseToJson(List<Ticketraiseresponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Ticketraiseresponse {
    String? status;
    String? message;
    TicketRaiseData? data;

    Ticketraiseresponse({
        this.status,
        this.message,
        this.data,
    });

    factory Ticketraiseresponse.fromJson(Map<String, dynamic> json) => Ticketraiseresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : TicketRaiseData.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
    };
}

class TicketRaiseData {
    String? id;
    String? agentId;
    String? ticketNumber;
    String? ticketCreateDate;
    String? ticketStatus;
    String? description;
    String? attachment;
    String? helpTypeId;
    String? status;
    String? isDeleted;
    String? createdOn;
    DateTime? updatedOn;

    TicketRaiseData({
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

    factory TicketRaiseData.fromJson(Map<String, dynamic> json) => TicketRaiseData(
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
