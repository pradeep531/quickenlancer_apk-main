// To parse this JSON data, do
//
//     final getallbarcoderesponse = getallbarcoderesponseFromJson(jsonString);

import 'dart:convert';

List<Getallbarcoderesponse> getallbarcoderesponseFromJson(String str) =>
    List<Getallbarcoderesponse>.from(
        json.decode(str).map((x) => Getallbarcoderesponse.fromJson(x)));

String getallbarcoderesponseToJson(List<Getallbarcoderesponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Getallbarcoderesponse {
  String? status;
  String? message;
  List<GetallbarcodeDatum>? data;

  Getallbarcoderesponse({
    this.status,
    this.message,
    this.data,
  });

  factory Getallbarcoderesponse.fromJson(Map<String, dynamic> json) =>
      Getallbarcoderesponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<GetallbarcodeDatum>.from(
                json["data"]!.map((x) => GetallbarcodeDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class GetallbarcodeDatum {
  String? id;
  String? tagOrifinalId;
  String? barcode;
  String? tagId;
  String? mapperVehicleClass;
  String? agentName;
  dynamic agentRequestId;
  dynamic agentRequestNumber;
  String? isUsed;
  String? custId;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  GetallbarcodeDatum({
    this.id,
    this.tagOrifinalId,
    this.barcode,
    this.tagId,
    this.mapperVehicleClass,
    this.agentName,
    this.agentRequestId,
    this.agentRequestNumber,
    this.isUsed,
    this.custId,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
  });

  factory GetallbarcodeDatum.fromJson(Map<String, dynamic> json) =>
      GetallbarcodeDatum(
        id: json["id"],
        tagOrifinalId: json["tag_orifinal_id"],
        barcode: json["barcode"],
        tagId: json["tag_id"],
        mapperVehicleClass: json["mapper_vehicle_class"],
        agentName: json["agent_name"],
        agentRequestId: json["agent_request_id"],
        agentRequestNumber: json["agent_request_number"],
        isUsed: json["is_used"],
        custId: json["cust_id"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        updatedOn: json["updated_on"] == null
            ? null
            : DateTime.parse(json["updated_on"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tag_orifinal_id": tagOrifinalId,
        "barcode": barcode,
        "tag_id": tagId,
        "mapper_vehicle_class": mapperVehicleClass,
        "agent_name": agentName,
        "agent_request_id": agentRequestId,
        "agent_request_number": agentRequestNumber,
        "is_used": isUsed,
        "cust_id": custId,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
      };
}
