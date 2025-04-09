// To parse this JSON data, do
//
//     final issusancereportcounterboxresponse = issusancereportcounterboxresponseFromJson(jsonString);

import 'dart:convert';

List<Issusancereportcounterboxresponse>
    issusancereportcounterboxresponseFromJson(String str) =>
        List<Issusancereportcounterboxresponse>.from(json
            .decode(str)
            .map((x) => Issusancereportcounterboxresponse.fromJson(x)));

String issusancereportcounterboxresponseToJson(
        List<Issusancereportcounterboxresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Issusancereportcounterboxresponse {
  String? status;
  String? message;
  IssuanceCount? data;

  Issusancereportcounterboxresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Issusancereportcounterboxresponse.fromJson(
          Map<String, dynamic> json) =>
      Issusancereportcounterboxresponse(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null ? null : IssuanceCount.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class IssuanceCount {
  int? assignFastag;
  int? approvedFastag;
  String? requestedFastag;
  int? recharge;

  IssuanceCount({
    this.assignFastag,
    this.approvedFastag,
    this.requestedFastag,
    this.recharge,
  });

  factory IssuanceCount.fromJson(Map<String, dynamic> json) => IssuanceCount(
        assignFastag: json["assign_fastag"],
        approvedFastag: json["approved_fastag"],
        requestedFastag: json["requested_fastag"],
        recharge: json["recharge"],
      );

  Map<String, dynamic> toJson() => {
        "assign_fastag": assignFastag,
        "approved_fastag": approvedFastag,
        "requested_fastag": requestedFastag,
        "recharge": recharge,
      };
}
