// To parse this JSON data, do
//
//     final tagimagesresponse = tagimagesresponseFromJson(jsonString);

import 'dart:convert';

List<Tagimagesresponse> tagimagesresponseFromJson(String str) =>
    List<Tagimagesresponse>.from(
        json.decode(str).map((x) => Tagimagesresponse.fromJson(x)));

String tagimagesresponseToJson(List<Tagimagesresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Tagimagesresponse {
  String status;
  String message;
  List<TagimagesDatum> data;
  String imgPath;

  Tagimagesresponse({
    required this.status,
    required this.message,
    required this.data,
    required this.imgPath,
  });

  factory Tagimagesresponse.fromJson(Map<String, dynamic> json) =>
      Tagimagesresponse(
        status: json["status"],
        message: json["message"],
        data: List<TagimagesDatum>.from(
            json["data"].map((x) => TagimagesDatum.fromJson(x))),
        imgPath: json["img_path"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "img_path": imgPath,
      };
}

class TagimagesDatum {
  String id;
  String sessionId;
  String imageType;
  String image;
  String imageStatus;
  String status;
  String isDeleted;
  DateTime createdOn;
  DateTime updatedOn;

  TagimagesDatum({
    required this.id,
    required this.sessionId,
    required this.imageType,
    required this.image,
    required this.imageStatus,
    required this.status,
    required this.isDeleted,
    required this.createdOn,
    required this.updatedOn,
  });

  factory TagimagesDatum.fromJson(Map<String, dynamic> json) => TagimagesDatum(
        id: json["id"],
        sessionId: json["session_id"],
        imageType: json["image_type"],
        image: json["image"],
        imageStatus: json["image_status"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: DateTime.parse(json["created_on"]),
        updatedOn: DateTime.parse(json["updated_on"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "session_id": sessionId,
        "image_type": imageType,
        "image": image,
        "image_status": imageStatus,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn.toIso8601String(),
        "updated_on": updatedOn.toIso8601String(),
      };
}
