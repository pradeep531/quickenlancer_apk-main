// To parse this JSON data, do
//
//     final videoResponse = videoResponseFromJson(jsonString);

import 'dart:convert';

VideoResponse videoResponseFromJson(String str) =>
    VideoResponse.fromJson(json.decode(str));

String videoResponseToJson(VideoResponse data) => json.encode(data.toJson());

class VideoResponse {
  String? status;
  String? message;
  String? imageUrl;
  List<VideoDatum>? data;

  VideoResponse({
    this.status,
    this.message,
    this.imageUrl,
    this.data,
  });

  factory VideoResponse.fromJson(Map<String, dynamic> json) => VideoResponse(
        status: json["status"],
        message: json["message"],
        imageUrl: json["image_url"],
        data: json["data"] == null
            ? []
            : List<VideoDatum>.from(
                json["data"].map((x) => VideoDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "image_url": imageUrl,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class VideoDatum {
  String? id;
  String? videoName;
  String? videoLink;
  String? videoImage;
  String? createdOn;
  String? videoTag;
  String? videoDescription;
  String? videoTypeName;

  VideoDatum({
    this.id,
    this.videoName,
    this.videoLink,
    this.videoImage,
    this.createdOn,
    this.videoTag,
    this.videoDescription,
    this.videoTypeName,
  });

  factory VideoDatum.fromJson(Map<String, dynamic> json) => VideoDatum(
        id: json["id"],
        videoName: json["video_name"],
        videoLink: json["video_link"],
        videoImage: json["video_image"],
        createdOn: json["created_on"],
        videoTag: json["video_tag"],
        videoDescription: json["video_description"],
        videoTypeName: json["video_type_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "video_name": videoName,
        "video_link": videoLink,
        "video_image": videoImage,
        "created_on": createdOn,
        "video_tag": videoTag,
        "video_description": videoDescription,
        "video_type_name": videoTypeName,
      };
}
