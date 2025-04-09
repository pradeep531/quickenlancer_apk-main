// To parse this JSON data, do
//
//     final uploadimagesresponse = uploadimagesresponseFromJson(jsonString);

import 'dart:convert';

List<Uploadimagesresponse> uploadimagesresponseFromJson(String str) =>
    List<Uploadimagesresponse>.from(
        json.decode(str).map((x) => Uploadimagesresponse.fromJson(x)));

String uploadimagesresponseToJson(List<Uploadimagesresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Uploadimagesresponse {
  String? status;
  String? message;
  List<Datum>? data;

  Uploadimagesresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Uploadimagesresponse.fromJson(Map<String, dynamic> json) =>
      Uploadimagesresponse(
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
  DocumentDetails? documentDetails;

  Datum({
    this.response,
    this.documentDetails,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        response: json["response"] == null
            ? null
            : Response.fromJson(json["response"]),
        documentDetails: json["documentDetails"] == null
            ? null
            : DocumentDetails.fromJson(json["documentDetails"]),
      );

  Map<String, dynamic> toJson() => {
        "response": response?.toJson(),
        "documentDetails": documentDetails?.toJson(),
      };
}

class DocumentDetails {
  String? imageType;
  String? sessionId;

  DocumentDetails({
    this.imageType,
    this.sessionId,
  });

  factory DocumentDetails.fromJson(Map<String, dynamic> json) =>
      DocumentDetails(
        imageType: json["imageType"],
        sessionId: json["sessionId"],
      );

  Map<String, dynamic> toJson() => {
        "imageType": imageType,
        "sessionId": sessionId,
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
