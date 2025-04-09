// To parse this JSON data, do
//
//     final getpaymentoptionresponse = getpaymentoptionresponseFromJson(jsonString);

import 'dart:convert';

List<Getpaymentoptionresponse> getpaymentoptionresponseFromJson(String str) =>
    List<Getpaymentoptionresponse>.from(
        json.decode(str).map((x) => Getpaymentoptionresponse.fromJson(x)));

String getpaymentoptionresponseToJson(List<Getpaymentoptionresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Getpaymentoptionresponse {
  String? status;
  String? message;
  String? razzorGatewayStatus;
  String? upiGatewayStatus;
  String? upi_gateway_message;
  String? razzor_gateway_message;
  String? ccavenue_gateway_message;
  String? ccavenue_gateway_status;

  List<dynamic>? data;

  Getpaymentoptionresponse(
      {this.status,
      this.message,
      this.razzorGatewayStatus,
      this.upiGatewayStatus,
      this.razzor_gateway_message,
      this.upi_gateway_message,
      this.data,
      this.ccavenue_gateway_message,
      this.ccavenue_gateway_status});

  factory Getpaymentoptionresponse.fromJson(Map<String, dynamic> json) =>
      Getpaymentoptionresponse(
        status: json["status"],
        message: json["message"],
        razzorGatewayStatus: json["razzor_gateway_status"],
        upiGatewayStatus: json["upi_gateway_status"],
        upi_gateway_message: json["upi_gateway_message"],
        razzor_gateway_message: json["razzor_gateway_message"],
        data: json["data"] == null
            ? []
            : List<dynamic>.from(json["data"]!.map((x) => x)),
        ccavenue_gateway_message: json["ccavenue_gateway_message"],
        ccavenue_gateway_status: json["ccavenue_gateway_status"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "razzor_gateway_status": razzorGatewayStatus,
        "upi_gateway_status": upiGatewayStatus,
        "razzor_gateway_message": razzor_gateway_message,
        "upi_gateway_message": upi_gateway_message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x)),
        "ccavenue_gateway_message": ccavenue_gateway_message,
        "ccavenue_gateway_status": ccavenue_gateway_status,
      };
}
