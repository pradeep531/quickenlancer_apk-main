// To parse this JSON data, do
//
//     final getrazorpaydetailsapiresponse = getrazorpaydetailsapiresponseFromJson(jsonString);

import 'dart:convert';

List<Getrazorpaydetailsapiresponse> getrazorpaydetailsapiresponseFromJson(
        String str) =>
    List<Getrazorpaydetailsapiresponse>.from(
        json.decode(str).map((x) => Getrazorpaydetailsapiresponse.fromJson(x)));

String getrazorpaydetailsapiresponseToJson(
        List<Getrazorpaydetailsapiresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Getrazorpaydetailsapiresponse {
  String? status;
  String? message;
  GetrazorpaydetailsapiresponseData? data;

  Getrazorpaydetailsapiresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Getrazorpaydetailsapiresponse.fromJson(Map<String, dynamic> json) =>
      Getrazorpaydetailsapiresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : GetrazorpaydetailsapiresponseData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class GetrazorpaydetailsapiresponseData {
  String? razorPayKey;
  String? razorPaySecret;
  String? upiKey;
  String? ccMerchantId;
  String? ccAccessCode;
  String? ccWorkingKey;

  GetrazorpaydetailsapiresponseData({
    this.razorPayKey,
    this.razorPaySecret,
    this.upiKey,
    this.ccMerchantId,
    this.ccAccessCode,
    this.ccWorkingKey,
  });

  factory GetrazorpaydetailsapiresponseData.fromJson(
          Map<String, dynamic> json) =>
      GetrazorpaydetailsapiresponseData(
        razorPayKey: json["razor_pay_key"],
        razorPaySecret: json["razor_pay_secret"],
        upiKey: json["upi_key"],
        ccMerchantId: json["cc_merchant_id"],
        ccAccessCode: json["cc_access_code"],
        ccWorkingKey: json["cc_working_key"],
      );

  Map<String, dynamic> toJson() => {
        "razor_pay_key": razorPayKey,
        "razor_pay_secret": razorPaySecret,
        "upi_key": upiKey,
        "cc_merchant_id": ccMerchantId,
        "cc_access_code": ccAccessCode,
        "cc_working_key": ccWorkingKey,
      };
}
