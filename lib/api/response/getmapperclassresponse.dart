// To parse this JSON data, do
//
//     final getmapperclassresponse = getmapperclassresponseFromJson(jsonString);

import 'dart:convert';

List<Getmapperclassresponse> getmapperclassresponseFromJson(String str) =>
    List<Getmapperclassresponse>.from(
        json.decode(str).map((x) => Getmapperclassresponse.fromJson(x)));

String getmapperclassresponseToJson(List<Getmapperclassresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Getmapperclassresponse {
  String? status;
  String? message;
  List<Datum>? data;

  Getmapperclassresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Getmapperclassresponse.fromJson(Map<String, dynamic> json) =>
      Getmapperclassresponse(
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
  String? id;
  String? categoryId;
  String? subCategoryName;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  Datum({
    this.id,
    this.categoryId,
    this.subCategoryName,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        categoryId: json["category_id"],
        subCategoryName: json["sub_category_name"],
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
        "category_id": categoryId,
        "sub_category_name": subCategoryName,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
      };
}
