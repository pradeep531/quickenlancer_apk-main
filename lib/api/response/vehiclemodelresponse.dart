// To parse this JSON data, do
//
//     final vehiclemodelresponse = vehiclemodelresponseFromJson(jsonString);

import 'dart:convert';

List<Vehiclemodelresponse> vehiclemodelresponseFromJson(String str) =>
    List<Vehiclemodelresponse>.from(
        json.decode(str).map((x) => Vehiclemodelresponse.fromJson(x)));

String vehiclemodelresponseToJson(List<Vehiclemodelresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Vehiclemodelresponse {
  String? status;
  String? message;
  List<VehiclemodelDatum>? data;

  Vehiclemodelresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Vehiclemodelresponse.fromJson(Map<String, dynamic> json) =>
      Vehiclemodelresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<VehiclemodelDatum>.from(
                json["data"]!.map((x) => VehiclemodelDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class VehiclemodelDatum {
  List<String>? vehicleModelList;
  Response? response;

  VehiclemodelDatum({
    this.vehicleModelList,
    this.response,
  });

  factory VehiclemodelDatum.fromJson(Map<String, dynamic> json) =>
      VehiclemodelDatum(
        vehicleModelList: json["vehicleModelList"] == null
            ? []
            : List<String>.from(json["vehicleModelList"]!.map((x) => x)),
        response: json["response"] == null
            ? null
            : Response.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "vehicleModelList": vehicleModelList == null
            ? []
            : List<dynamic>.from(vehicleModelList!.map((x) => x)),
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
