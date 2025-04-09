// To parse this JSON data, do
//
//     final replacevehicleotpresponse = replacevehicleotpresponseFromJson(jsonString);

import 'dart:convert';

List<Replacevehicleotpresponse> replacevehicleotpresponseFromJson(String str) =>
    List<Replacevehicleotpresponse>.from(
        json.decode(str).map((x) => Replacevehicleotpresponse.fromJson(x)));

String replacevehicleotpresponseToJson(List<Replacevehicleotpresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Replacevehicleotpresponse {
  String? status;
  String? message;
  List<Datum>? data;

  Replacevehicleotpresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Replacevehicleotpresponse.fromJson(Map<String, dynamic> json) =>
      Replacevehicleotpresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  Response? response;
  dynamic tagRepalceResp;

  Datum({
    this.response,
    this.tagRepalceResp,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        response: json["response"] == null
            ? null
            : Response.fromJson(json["response"]),
        tagRepalceResp: json["tagRepalceResp"],
      );

  Map<String, dynamic> toJson() => {
        "response": response?.toJson(),
        "tagRepalceResp": tagRepalceResp,
      };
}

class Response {
  String? msg;
  String? status;
  String? code;
  String? errorCode;
  String? errorDesc;

  Response({
    this.msg,
    this.status,
    this.code,
    this.errorCode,
    this.errorDesc,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        msg: json["msg"],
        status: json["status"],
        code: json["code"],
        errorCode: json["errorCode"],
        errorDesc: json["errorDesc"],
      );

  Map<String, dynamic> toJson() => {
        "msg": msg,
        "status": status,
        "code": code,
        "errorCode": errorCode,
        "errorDesc": errorDesc,
      };
}
