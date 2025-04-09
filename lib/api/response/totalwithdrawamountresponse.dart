// To parse this JSON data, do
//
//     final totalwithdrawamountresponse = totalwithdrawamountresponseFromJson(jsonString);

import 'dart:convert';

List<Totalwithdrawamountresponse> totalwithdrawamountresponseFromJson(
        String str) =>
    List<Totalwithdrawamountresponse>.from(
        json.decode(str).map((x) => Totalwithdrawamountresponse.fromJson(x)));

String totalwithdrawamountresponseToJson(
        List<Totalwithdrawamountresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Totalwithdrawamountresponse {
  String? status;
  String? message;
  Data? data;

  Totalwithdrawamountresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Totalwithdrawamountresponse.fromJson(Map<String, dynamic> json) =>
      Totalwithdrawamountresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  String? totalRequestedAmount;
  String? totalApprovedAmount;

  Data({
    this.totalRequestedAmount,
    this.totalApprovedAmount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalRequestedAmount: json["total_requested_amount"].toString(),
        totalApprovedAmount: json["total_approved_amount"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "total_requested_amount": totalRequestedAmount,
        "total_approved_amount": totalApprovedAmount,
      };
}
