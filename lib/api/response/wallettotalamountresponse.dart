// To parse this JSON data, do
//
//     final wallettotalamountresponse = wallettotalamountresponseFromJson(jsonString);

import 'dart:convert';

List<Wallettotalamountresponse> wallettotalamountresponseFromJson(String str) =>
    List<Wallettotalamountresponse>.from(
        json.decode(str).map((x) => Wallettotalamountresponse.fromJson(x)));

String wallettotalamountresponseToJson(List<Wallettotalamountresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Wallettotalamountresponse {
  String? status;
  String? message;
  List<WallettotalamountDatum>? data;

  Wallettotalamountresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Wallettotalamountresponse.fromJson(Map<String, dynamic> json) =>
      Wallettotalamountresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<WallettotalamountDatum>.from(
                json["data"]!.map((x) => WallettotalamountDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class WallettotalamountDatum {
  String? id;
  String? transactionType;
  String? agentId;
  String? amount;
  String? remark;
  String? transcationId;
  String? paymentMode;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  WallettotalamountDatum({
    this.id,
    this.transactionType,
    this.agentId,
    this.amount,
    this.remark,
    this.transcationId,
    this.paymentMode,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
  });

  factory WallettotalamountDatum.fromJson(Map<String, dynamic> json) =>
      WallettotalamountDatum(
        id: json["id"],
        transactionType: json["transaction_type"],
        agentId: json["agent_id"],
        amount: json["amount"],
        remark: json["remark"],
        transcationId: json["transcation_id"],
        paymentMode: json["payment_mode"],
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
        "transaction_type": transactionType,
        "agent_id": agentId,
        "amount": amount,
        "remark": remark,
        "transcation_id": transcationId,
        "payment_mode": paymentMode,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
      };
}
