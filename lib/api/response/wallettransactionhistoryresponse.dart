// To parse this JSON data, do
//
//     final wallettransactionhistoryresponse = wallettransactionhistoryresponseFromJson(jsonString);

import 'dart:convert';

List<Wallettransactionhistoryresponse> wallettransactionhistoryresponseFromJson(
        String str) =>
    List<Wallettransactionhistoryresponse>.from(json
        .decode(str)
        .map((x) => Wallettransactionhistoryresponse.fromJson(x)));

String wallettransactionhistoryresponseToJson(
        List<Wallettransactionhistoryresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Wallettransactionhistoryresponse {
  String? status;
  String? message;
  List<WallettransactionhistoryDatum>? data;

  Wallettransactionhistoryresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Wallettransactionhistoryresponse.fromJson(
          Map<String, dynamic> json) =>
      Wallettransactionhistoryresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<WallettransactionhistoryDatum>.from(json["data"]!
                .map((x) => WallettransactionhistoryDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class WallettransactionhistoryDatum {
  String? id;
  String? transactionType;
  String? agentId;
  String? amount;
  dynamic previousBalance;
  dynamic walletBalance;
  String? remark;
  String? transcationId;
  String? paymentMode;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  WallettransactionhistoryDatum({
    this.id,
    this.transactionType,
    this.agentId,
    this.amount,
    this.previousBalance,
    this.walletBalance,
    this.remark,
    this.transcationId,
    this.paymentMode,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
  });

  factory WallettransactionhistoryDatum.fromJson(Map<String, dynamic> json) =>
      WallettransactionhistoryDatum(
        id: json["id"],
        transactionType: json["transaction_type"],
        agentId: json["agent_id"],
        amount: json["amount"],
        previousBalance: json["previous_balance"],
        walletBalance: json["wallet_balance"],
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
        "previous_balance": previousBalance,
        "wallet_balance": walletBalance,
        "remark": remark,
        "transcation_id": transcationId,
        "payment_mode": paymentMode,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
      };
}
