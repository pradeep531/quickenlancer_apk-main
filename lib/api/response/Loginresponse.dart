// To parse this JSON data, do
//
//     final loginresponse = loginresponseFromJson(jsonString);

import 'dart:convert';

List<Loginresponse> loginresponseFromJson(String str) => List<Loginresponse>.from(json.decode(str).map((x) => Loginresponse.fromJson(x)));

String loginresponseToJson(List<Loginresponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Loginresponse {
    String? status;
    String? message;
    String? otp;
    List<LoginData>? data;

    Loginresponse({
        this.status,
        this.message,
        this.otp,
        this.data,
    });

    factory Loginresponse.fromJson(Map<String, dynamic> json) => Loginresponse(
        status: json["status"],
        message: json["message"],
        otp: json["otp"],
        data: json["data"] == null ? [] : List<LoginData>.from(json["data"]!.map((x) => LoginData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "otp": otp,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class LoginData {
    String? id;
    String? firstName;
    String? lastName;
    String? ownership;
    String? type;
    String? mobileNumber;
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
    dynamic fcmToken;
    String? status;
    String? isDeleted;
    DateTime? createdOn;
    DateTime? updatedOn;

    LoginData({
        this.id,
        this.firstName,
        this.lastName,
        this.ownership,
        this.type,
        this.mobileNumber,
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
        this.fcmToken,
        this.status,
        this.isDeleted,
        this.createdOn,
        this.updatedOn,
    });

    factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        ownership: json["ownership"],
        type: json["type"],
        mobileNumber: json["mobile_number"],
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
        fcmToken: json["fcm_token"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: json["created_on"] == null ? null : DateTime.parse(json["created_on"]),
        updatedOn: json["updated_on"] == null ? null : DateTime.parse(json["updated_on"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "ownership": ownership,
        "type": type,
        "mobile_number": mobileNumber,
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
        "fcm_token": fcmToken,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
    };
}
