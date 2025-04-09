// To parse this JSON data, do
//
//     final fasttagrequestlistresponse = fasttagrequestlistresponseFromJson(jsonString);

import 'dart:convert';

List<Fasttagrequestlistresponse> fasttagrequestlistresponseFromJson(
        String str) =>
    List<Fasttagrequestlistresponse>.from(
        json.decode(str).map((x) => Fasttagrequestlistresponse.fromJson(x)));

String fasttagrequestlistresponseToJson(
        List<Fasttagrequestlistresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Fasttagrequestlistresponse {
  String? status;
  String? message;
  List<FasttagrequestlistDatum>? data;

  Fasttagrequestlistresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Fasttagrequestlistresponse.fromJson(Map<String, dynamic> json) =>
      Fasttagrequestlistresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<FasttagrequestlistDatum>.from(
                json["data"]!.map((x) => FasttagrequestlistDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class FasttagrequestlistDatum {
  Request? request;
  List<Detail>? details;

  FasttagrequestlistDatum({
    this.request,
    this.details,
  });

  factory FasttagrequestlistDatum.fromJson(Map<String, dynamic> json) =>
      FasttagrequestlistDatum(
        request:
            json["request"] == null ? null : Request.fromJson(json["request"]),
        details: json["details"] == null
            ? []
            : List<Detail>.from(
                json["details"]!.map((x) => Detail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "request": request?.toJson(),
        "details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class Detail {
  String? id;
  String? requestId;
  String? agentId;
  String? requested;
  String? categoryId;
  String? vehicleColor;
  String? category_name;
  String? category_id;

  Detail({
    this.id,
    this.requestId,
    this.agentId,
    this.requested,
    this.categoryId,
    this.vehicleColor,
    this.category_name,
    this.category_id,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["id"],
        requestId: json["request_id"],
        agentId: json["agent_id"],
        requested: json["requested"],
        categoryId: json["category_id"],
        vehicleColor: json["vehicle_color"],
        category_name: json["category_name"],
        category_id: json["category_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "request_id": requestId,
        "agent_id": agentId,
        "requested": requested,
        "category_id": categoryId,
        "vehicle_color": vehicleColor,
        "category_name": category_name,
        "category_id": category_id,
      };
}

class Request {
  String? id;
  String? agentId;
  String? requestNumber;
  String? courierId;
  String? requestStatus;

  Request({
    this.id,
    this.agentId,
    this.requestNumber,
    this.courierId,
    this.requestStatus,
  });

  factory Request.fromJson(Map<String, dynamic> json) => Request(
        id: json["id"],
        agentId: json["agent_id"],
        requestNumber: json["request_number"],
        courierId: json["courier_id"],
        requestStatus: json["request_status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "agent_id": agentId,
        "request_number": requestNumber,
        "courier_id": courierId,
        "request_status": requestStatus,
      };
}
