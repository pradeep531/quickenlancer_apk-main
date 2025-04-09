// To parse this JSON data, do
//
//     final stockcategoryresponse = stockcategoryresponseFromJson(jsonString);

import 'dart:convert';

List<Stockcategoryresponse> stockcategoryresponseFromJson(String str) =>
    List<Stockcategoryresponse>.from(
        json.decode(str).map((x) => Stockcategoryresponse.fromJson(x)));

String stockcategoryresponseToJson(List<Stockcategoryresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Stockcategoryresponse {
  String? status;
  String? message;
  List<StockcategoryDatum>? data;

  Stockcategoryresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Stockcategoryresponse.fromJson(Map<String, dynamic> json) =>
      Stockcategoryresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<StockcategoryDatum>.from(
                json["data"]!.map((x) => StockcategoryDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class StockcategoryDatum {
  String? id;
  String? tagOrifinalId;
  String? barcode;
  String? tagId;
  String? mapperVehicleClass;
  String? agentName;
  dynamic agentRequestId;
  dynamic agentRequestNumber;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;
  String? categoryName;
  String? vehicleColor;

  StockcategoryDatum({
    this.id,
    this.tagOrifinalId,
    this.barcode,
    this.tagId,
    this.mapperVehicleClass,
    this.agentName,
    this.agentRequestId,
    this.agentRequestNumber,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
    this.categoryName,
    this.vehicleColor,
  });

  factory StockcategoryDatum.fromJson(Map<String, dynamic> json) =>
      StockcategoryDatum(
        id: json["id"],
        tagOrifinalId: json["tag_orifinal_id"],
        barcode: json["barcode"],
        tagId: json["tag_id"],
        mapperVehicleClass: json["mapper_vehicle_class"],
        agentName: json["agent_name"],
        agentRequestId: json["agent_request_id"],
        agentRequestNumber: json["agent_request_number"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        updatedOn: json["updated_on"] == null
            ? null
            : DateTime.parse(json["updated_on"]),
        categoryName: json["category_name"],
        vehicleColor: json["vehicle_color"],
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
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
        "category_name": categoryName,
        "vehicle_color": vehicleColor,
      };
}
