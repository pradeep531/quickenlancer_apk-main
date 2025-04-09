// To parse this JSON data, do
//
//     final setvehicledetailsmanuallyresponse = setvehicledetailsmanuallyresponseFromJson(jsonString);

import 'dart:convert';

List<Setvehicledetailsmanuallyresponse>
    setvehicledetailsmanuallyresponseFromJson(String str) =>
        List<Setvehicledetailsmanuallyresponse>.from(json
            .decode(str)
            .map((x) => Setvehicledetailsmanuallyresponse.fromJson(x)));

String setvehicledetailsmanuallyresponseToJson(
        List<Setvehicledetailsmanuallyresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Setvehicledetailsmanuallyresponse {
  String? status;
  String? message;
  List<SetvehicledetailsmanuallyDatum>? data;

  Setvehicledetailsmanuallyresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Setvehicledetailsmanuallyresponse.fromJson(
          Map<String, dynamic> json) =>
      Setvehicledetailsmanuallyresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<SetvehicledetailsmanuallyDatum>.from(json["data"]!
                .map((x) => SetvehicledetailsmanuallyDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class SetvehicledetailsmanuallyDatum {
  String? id;
  String? requestId;
  String? sessionId;
  String? agentId;
  dynamic name;
  dynamic dob;
  dynamic idType;
  dynamic idNumber;
  String? vehicleNumber;
  String? mobileNumber;
  dynamic chassisNo;
  dynamic engineNo;
  String? vehicleManuf;
  String? model;
  String? vehicleColour;
  String? type;
  dynamic rtoStatus;
  String? commercial;
  String? tagVehicleClassId;
  String? npciVehicleClassId;
  String? vehicleType;
  String? rechargeAmount;
  String? securityDeposit;
  String? tagCost;
  String? repTagCost;
  dynamic walletId;
  String? walletStatus;
  String? npcIstatus;
  String? kycStatus;
  dynamic serialNo;
  dynamic tid;
  dynamic rcImageFront;
  dynamic rcImageBack;
  dynamic vehicleImage;
  String? planId;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  SetvehicledetailsmanuallyDatum({
    this.id,
    this.requestId,
    this.sessionId,
    this.agentId,
    this.name,
    this.dob,
    this.idType,
    this.idNumber,
    this.vehicleNumber,
    this.mobileNumber,
    this.chassisNo,
    this.engineNo,
    this.vehicleManuf,
    this.model,
    this.vehicleColour,
    this.type,
    this.rtoStatus,
    this.commercial,
    this.tagVehicleClassId,
    this.npciVehicleClassId,
    this.vehicleType,
    this.rechargeAmount,
    this.securityDeposit,
    this.tagCost,
    this.repTagCost,
    this.walletId,
    this.walletStatus,
    this.npcIstatus,
    this.kycStatus,
    this.serialNo,
    this.tid,
    this.rcImageFront,
    this.rcImageBack,
    this.vehicleImage,
    this.planId,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
  });

  factory SetvehicledetailsmanuallyDatum.fromJson(Map<String, dynamic> json) =>
      SetvehicledetailsmanuallyDatum(
        id: json["id"],
        requestId: json["request_id"],
        sessionId: json["session_id"],
        agentId: json["agent_id"],
        name: json["name"],
        dob: json["dob"],
        idType: json["id_type"],
        idNumber: json["id_number"],
        vehicleNumber: json["vehicle_number"],
        mobileNumber: json["mobile_number"],
        chassisNo: json["chassisNo"],
        engineNo: json["engineNo"],
        vehicleManuf: json["vehicleManuf"],
        model: json["model"],
        vehicleColour: json["vehicleColour"],
        type: json["type"],
        rtoStatus: json["rtoStatus"],
        commercial: json["commercial"],
        tagVehicleClassId: json["tagVehicleClassID"],
        npciVehicleClassId: json["npciVehicleClassID"],
        vehicleType: json["vehicleType"],
        rechargeAmount: json["rechargeAmount"],
        securityDeposit: json["securityDeposit"],
        tagCost: json["tagCost"],
        repTagCost: json["repTagCost"],
        walletId: json["walletId"],
        walletStatus: json["walletStatus"],
        npcIstatus: json["NPCIstatus"],
        kycStatus: json["kycStatus"],
        serialNo: json["serialNo"],
        tid: json["tid"],
        rcImageFront: json["rcImageFront"],
        rcImageBack: json["rcImageBack"],
        vehicleImage: json["vehicleImage"],
        planId: json["plan_id"],
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
        "request_id": requestId,
        "session_id": sessionId,
        "agent_id": agentId,
        "name": name,
        "dob": dob,
        "id_type": idType,
        "id_number": idNumber,
        "vehicle_number": vehicleNumber,
        "mobile_number": mobileNumber,
        "chassisNo": chassisNo,
        "engineNo": engineNo,
        "vehicleManuf": vehicleManuf,
        "model": model,
        "vehicleColour": vehicleColour,
        "type": type,
        "rtoStatus": rtoStatus,
        "commercial": commercial,
        "tagVehicleClassID": tagVehicleClassId,
        "npciVehicleClassID": npciVehicleClassId,
        "vehicleType": vehicleType,
        "rechargeAmount": rechargeAmount,
        "securityDeposit": securityDeposit,
        "tagCost": tagCost,
        "repTagCost": repTagCost,
        "walletId": walletId,
        "walletStatus": walletStatus,
        "NPCIstatus": npcIstatus,
        "kycStatus": kycStatus,
        "serialNo": serialNo,
        "tid": tid,
        "rcImageFront": rcImageFront,
        "rcImageBack": rcImageBack,
        "vehicleImage": vehicleImage,
        "plan_id": planId,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
      };
}
