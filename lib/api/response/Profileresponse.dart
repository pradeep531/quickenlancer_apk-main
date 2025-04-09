// To parse this JSON data, do
//
//     final profileresponse = profileresponseFromJson(jsonString);

import 'dart:convert';

List<Profileresponse> profileresponseFromJson(String str) =>
    List<Profileresponse>.from(
        json.decode(str).map((x) => Profileresponse.fromJson(x)));

String profileresponseToJson(List<Profileresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Profileresponse {
  String? status;
  String? message;
  ProfileData? data;

  Profileresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Profileresponse.fromJson(Map<String, dynamic> json) =>
      Profileresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : ProfileData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class ProfileData {
  String? firstName;
  String? lastName;
  String? ownership;
  String? type;
  String? mobileNumber;
  String? alternameMobileNumber;
  String? email;
  String? password;
  String? address;
  String? pincode;
  String? city;
  String? state;
  String? country;
  String? photo;
  String? ifscCode;
  String? cityName;
  String? stateName;
  String? countryName;
  String? imagePathPhoto;
  String? re_search_charge;

  ProfileData({
    this.firstName,
    this.lastName,
    this.ownership,
    this.type,
    this.mobileNumber,
    this.alternameMobileNumber,
    this.email,
    this.password,
    this.address,
    this.pincode,
    this.city,
    this.state,
    this.country,
    this.photo,
    this.ifscCode,
    this.cityName,
    this.stateName,
    this.countryName,
    this.imagePathPhoto,
    this.re_search_charge,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
        firstName: json["first_name"],
        lastName: json["last_name"],
        ownership: json["ownership"],
        type: json["type"],
        mobileNumber: json["mobile_number"],
        alternameMobileNumber: json["altername_mobile_number"],
        email: json["email"],
        password: json["password"],
        address: json["address"],
        pincode: json["pincode"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        photo: json["photo"],
        ifscCode: json["ifsc_code"],
        cityName: json["city_name"],
        stateName: json["state_name"],
        countryName: json["country_name"],
        imagePathPhoto: json["image_path_photo"],
        re_search_charge: json["re_search_charge"],
      );

  Map<String, dynamic> toJson() => {
        "first_name": firstName,
        "last_name": lastName,
        "ownership": ownership,
        "type": type,
        "mobile_number": mobileNumber,
        "altername_mobile_number": alternameMobileNumber,
        "email": email,
        "password": password,
        "address": address,
        "pincode": pincode,
        "city": city,
        "state": state,
        "country": country,
        "photo": photo,
        "ifsc_code": ifscCode,
        "city_name": cityName,
        "state_name": stateName,
        "country_name": countryName,
        "image_path_photo": imagePathPhoto,
        "re_search_charge": re_search_charge,
      };
}
