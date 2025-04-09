// To parse this JSON data, do
//
//     final getfastagunallocaterequestlistresponse = getfastagunallocaterequestlistresponseFromJson(jsonString);

import 'dart:convert';

List<Getfastagunallocaterequestlistresponse>
    getfastagunallocaterequestlistresponseFromJson(String str) =>
        List<Getfastagunallocaterequestlistresponse>.from(json
            .decode(str)
            .map((x) => Getfastagunallocaterequestlistresponse.fromJson(x)));

String getfastagunallocaterequestlistresponseToJson(
        List<Getfastagunallocaterequestlistresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Getfastagunallocaterequestlistresponse {
  String? status;
  String? message;
  List<GetfastagunallocaterequestDatum>? data;

  Getfastagunallocaterequestlistresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Getfastagunallocaterequestlistresponse.fromJson(
          Map<String, dynamic> json) =>
      Getfastagunallocaterequestlistresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<GetfastagunallocaterequestDatum>.from(json["data"]!
                .map((x) => GetfastagunallocaterequestDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class GetfastagunallocaterequestDatum {
  GetfastagunallocaterequestRequest? request;
  List<GetfastagunallocaterequestDetail>? details;

  GetfastagunallocaterequestDatum({
    this.request,
    this.details,
  });

  factory GetfastagunallocaterequestDatum.fromJson(Map<String, dynamic> json) =>
      GetfastagunallocaterequestDatum(
        request: json["request"] == null
            ? null
            : GetfastagunallocaterequestRequest.fromJson(json["request"]),
        details: json["details"] == null
            ? []
            : List<GetfastagunallocaterequestDetail>.from(json["details"]!
                .map((x) => GetfastagunallocaterequestDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "request": request?.toJson(),
        "details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class GetfastagunallocaterequestDetail {
  String? id;
  String? requestId;
  String? agentId;
  String? requested;
  String? vehicleColor;
  String? categoryName;
  String? categoryId;

  GetfastagunallocaterequestDetail({
    this.id,
    this.requestId,
    this.agentId,
    this.requested,
    this.vehicleColor,
    this.categoryName,
    this.categoryId,
  });

  factory GetfastagunallocaterequestDetail.fromJson(
          Map<String, dynamic> json) =>
      GetfastagunallocaterequestDetail(
        id: json["id"],
        requestId: json["request_id"],
        agentId: json["agent_id"],
        requested: json["requested"],
        vehicleColor: json["vehicle_color"],
        categoryName: json["category_name"],
        categoryId: json["category_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "request_id": requestId,
        "agent_id": agentId,
        "requested": requested,
        "vehicle_color": vehicleColor,
        "category_name": categoryName,
        "category_id": categoryId,
      };
}

class GetfastagunallocaterequestRequest {
  String? id;
  String? agentId;
  String? requestNumber;
  String? requestStatus;

  GetfastagunallocaterequestRequest({
    this.id,
    this.agentId,
    this.requestNumber,
    this.requestStatus,
  });

  factory GetfastagunallocaterequestRequest.fromJson(
          Map<String, dynamic> json) =>
      GetfastagunallocaterequestRequest(
        id: json["id"],
        agentId: json["agent_id"],
        requestNumber: json["request_number"],
        requestStatus: json["request_status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "agent_id": agentId,
        "request_number": requestNumber,
        "request_status": requestStatus,
      };
}
