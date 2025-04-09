// To parse this JSON data, do
//
//     final paymenturlresponse = paymenturlresponseFromJson(jsonString);

import 'dart:convert';

Paymenturlresponse paymenturlresponseFromJson(String str) =>
    Paymenturlresponse.fromJson(json.decode(str));

String paymenturlresponseToJson(Paymenturlresponse data) =>
    json.encode(data.toJson());

class Paymenturlresponse {
  bool? status;
  String? msg;
  Data? data;

  Paymenturlresponse({
    this.status,
    this.msg,
    this.data,
  });

  factory Paymenturlresponse.fromJson(Map<String, dynamic> json) =>
      Paymenturlresponse(
        status: json["status"],
        msg: json["msg"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "msg": msg,
        "data": data?.toJson(),
      };
}

class Data {
  int? orderId;
  String? paymentUrl;
  String? upiIdHash;
  UpiIntent? upiIntent;

  Data({
    this.orderId,
    this.paymentUrl,
    this.upiIdHash,
    this.upiIntent,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderId: json["order_id"],
        paymentUrl: json["payment_url"],
        upiIdHash: json["upi_id_hash"],
        upiIntent: json["upi_intent"] == null
            ? null
            : UpiIntent.fromJson(json["upi_intent"]),
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "payment_url": paymentUrl,
        "upi_id_hash": upiIdHash,
        "upi_intent": upiIntent?.toJson(),
      };
}

class UpiIntent {
  String? bhimLink;
  String? phonepeLink;
  String? paytmLink;
  String? gpayLink;

  UpiIntent({
    this.bhimLink,
    this.phonepeLink,
    this.paytmLink,
    this.gpayLink,
  });

  factory UpiIntent.fromJson(Map<String, dynamic> json) => UpiIntent(
        bhimLink: json["bhim_link"],
        phonepeLink: json["phonepe_link"],
        paytmLink: json["paytm_link"],
        gpayLink: json["gpay_link"],
      );

  Map<String, dynamic> toJson() => {
        "bhim_link": bhimLink,
        "phonepe_link": phonepeLink,
        "paytm_link": paytmLink,
        "gpay_link": gpayLink,
      };
}
