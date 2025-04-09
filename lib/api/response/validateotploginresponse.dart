// To parse this JSON data, do
//
//     final validateotploginresponse = validateotploginresponseFromJson(jsonString);

import 'dart:convert';

List<Validateotploginresponse> validateotploginresponseFromJson(String str) =>
    List<Validateotploginresponse>.from(
        json.decode(str).map((x) => Validateotploginresponse.fromJson(x)));

String validateotploginresponseToJson(List<Validateotploginresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Validateotploginresponse {
  String? status;
  String? message;
  bool? isNew;
  List<ValidateotploginDatum>? data;

  Validateotploginresponse({
    this.status,
    this.message,
    this.isNew,
    this.data,
  });

  factory Validateotploginresponse.fromJson(Map<String, dynamic> json) =>
      Validateotploginresponse(
        status: json["status"],
        message: json["message"],
        isNew: json["is_new"],
        data: json["data"] == null
            ? []
            : List<ValidateotploginDatum>.from(
                json["data"]!.map((x) => ValidateotploginDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ValidateotploginDatum {
  String? id;
  String? firstName;
  String? lastName;
  String? ownership;
  String? type;
  String? mobileNumber;
  String? otp;
  String? alternameMobileNumber;
  String? email;
  String? orgPassword;
  String? password;
  String? address;
  String? pincode;
  String? city;
  String? state;
  String? country;
  String? tollPlaza;
  String? photo;
  String? pancardNumber;
  String? aadharCard;
  String? pancardFile;
  String? documentType;
  String? documentFile;
  String? bankName;
  String? accountNumber;
  String? ifscCode;
  String? bankFile;
  String? payoutType;
  String? payoutDetails;
  String? fcmToken;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  ValidateotploginDatum({
    this.id,
    this.firstName,
    this.lastName,
    this.ownership,
    this.type,
    this.mobileNumber,
    this.otp,
    this.alternameMobileNumber,
    this.email,
    this.orgPassword,
    this.password,
    this.address,
    this.pincode,
    this.city,
    this.state,
    this.country,
    this.tollPlaza,
    this.photo,
    this.pancardNumber,
    this.aadharCard,
    this.pancardFile,
    this.documentType,
    this.documentFile,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.bankFile,
    this.payoutType,
    this.payoutDetails,
    this.fcmToken,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
  });

  factory ValidateotploginDatum.fromJson(Map<String, dynamic> json) =>
      ValidateotploginDatum(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        ownership: json["ownership"],
        type: json["type"],
        mobileNumber: json["mobile_number"],
        otp: json["otp"],
        alternameMobileNumber: json["altername_mobile_number"],
        email: json["email"],
        orgPassword: json["org_password"],
        password: json["password"],
        address: json["address"],
        pincode: json["pincode"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        tollPlaza: json["toll_plaza"],
        photo: json["photo"],
        pancardNumber: json["pancard_number"],
        aadharCard: json["aadhar_card"],
        pancardFile: json["pancard_file"],
        documentType: json["document_type"],
        documentFile: json["document_file"],
        bankName: json["bank_name"],
        accountNumber: json["account_number"],
        ifscCode: json["ifsc_code"],
        bankFile: json["bank_file"],
        payoutType: json["payout_type"],
        payoutDetails: json["payout_details"],
        fcmToken: json["fcm_token"],
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
        "first_name": firstName,
        "last_name": lastName,
        "ownership": ownership,
        "type": type,
        "mobile_number": mobileNumber,
        "otp": otp,
        "altername_mobile_number": alternameMobileNumber,
        "email": email,
        "org_password": orgPassword,
        "password": password,
        "address": address,
        "pincode": pincode,
        "city": city,
        "state": state,
        "country": country,
        "toll_plaza": tollPlaza,
        "photo": photo,
        "pancard_number": pancardNumber,
        "aadhar_card": aadharCard,
        "pancard_file": pancardFile,
        "document_type": documentType,
        "document_file": documentFile,
        "bank_name": bankName,
        "account_number": accountNumber,
        "ifsc_code": ifscCode,
        "bank_file": bankFile,
        "payout_type": payoutType,
        "payout_details": payoutDetails,
        "fcm_token": fcmToken,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
      };
}
