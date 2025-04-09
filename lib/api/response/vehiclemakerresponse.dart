// To parse this JSON data, do
//
//     final vehiclemakerresponse = vehiclemakerresponseFromJson(jsonString);

import 'dart:convert';

List<Vehiclemakerresponse> vehiclemakerresponseFromJson(String str) =>
    List<Vehiclemakerresponse>.from(
        json.decode(str).map((x) => Vehiclemakerresponse.fromJson(x)));

String vehiclemakerresponseToJson(List<Vehiclemakerresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Vehiclemakerresponse {
  String? status;
  String? message;
  List<VehiclemakerDatum>? data;

  Vehiclemakerresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Vehiclemakerresponse.fromJson(Map<String, dynamic> json) =>
      Vehiclemakerresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<VehiclemakerDatum>.from(
                json["data"]!.map((x) => VehiclemakerDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class VehiclemakerDatum {
  List<String>? vehicleMakerList;
  Response? response;

  VehiclemakerDatum({
    this.vehicleMakerList,
    this.response,
  });

  factory VehiclemakerDatum.fromJson(Map<String, dynamic> json) =>
      VehiclemakerDatum(
        vehicleMakerList: json["vehicleMakerList"] == null
            ? []
            : List<String>.from(json["vehicleMakerList"]!.map((x) => x)),
        response: json["response"] == null
            ? null
            : Response.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "vehicleMakerList": vehicleMakerList == null
            ? []
            : List<dynamic>.from(vehicleMakerList!.map((x) => x)),
        "response": response?.toJson(),
      };
}

class Response {
  String? msg;
  String? status;
  String? code;
  dynamic errorCode;
  dynamic errorDesc;

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
