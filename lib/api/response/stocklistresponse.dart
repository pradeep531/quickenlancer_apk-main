// To parse this JSON data, do
//
//     final stocklistresponse = stocklistresponseFromJson(jsonString);

import 'dart:convert';

List<Stocklistresponse> stocklistresponseFromJson(String str) =>
    List<Stocklistresponse>.from(
        json.decode(str).map((x) => Stocklistresponse.fromJson(x)));

String stocklistresponseToJson(List<Stocklistresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Stocklistresponse {
  String? status;
  String? message;
  List<StocklistDatum>? data;

  Stocklistresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Stocklistresponse.fromJson(Map<String, dynamic> json) =>
      Stocklistresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<StocklistDatum>.from(
                json["data"]!.map((x) => StocklistDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class StocklistDatum {
  String? id;
  String? categoryName;
  String? vehicleColor;
  int? count;

  StocklistDatum({
    this.id,
    this.categoryName,
    this.vehicleColor,
    this.count,
  });

  factory StocklistDatum.fromJson(Map<String, dynamic> json) => StocklistDatum(
        id: json["id"],
        categoryName: json["category_name"],
        vehicleColor: json["vehicle_color"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category_name": categoryName,
        "vehicle_color": vehicleColor,
        "count": count,
      };
}
