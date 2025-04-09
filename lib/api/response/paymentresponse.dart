// To parse this JSON data, do
//
//     final rechargeNowResponse = rechargeNowResponseFromJson(jsonString);

import 'dart:convert';

List<RechargeNowResponse> rechargeNowResponseFromJson(String str) =>
    List<RechargeNowResponse>.from(
        json.decode(str).map((x) => RechargeNowResponse.fromJson(x)));

String rechargeNowResponseToJson(List<RechargeNowResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RechargeNowResponse {
  String? status;
  String? message;
  List<dynamic>? data;

  RechargeNowResponse({
    this.status,
    this.message,
    this.data,
  });

  factory RechargeNowResponse.fromJson(Map<String, dynamic> json) =>
      RechargeNowResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<dynamic>.from(json["data"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x)),
      };
}
