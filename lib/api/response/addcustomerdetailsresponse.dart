// To parse this JSON data, do
//
//     final addcustomerdetailsresponse = addcustomerdetailsresponseFromJson(jsonString);

import 'dart:convert';

List<Addcustomerdetailsresponse> addcustomerdetailsresponseFromJson(
        String str) =>
    List<Addcustomerdetailsresponse>.from(
        json.decode(str).map((x) => Addcustomerdetailsresponse.fromJson(x)));

String addcustomerdetailsresponseToJson(
        List<Addcustomerdetailsresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Addcustomerdetailsresponse {
  String? wallet_status;
  String? status;
  String? message;
  List<AddcustomerdetailsDatum>? data;

  Addcustomerdetailsresponse({
    this.wallet_status,
    this.status,
    this.message,
    this.data,
  });

  factory Addcustomerdetailsresponse.fromJson(Map<String, dynamic> json) =>
      Addcustomerdetailsresponse(
        wallet_status: json["wallet_status"],
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<AddcustomerdetailsDatum>.from(
                json["data"]!.map((x) => AddcustomerdetailsDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "wallet_status": wallet_status,
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class AddcustomerdetailsDatum {
  String? id;
  String? requestId;
  String? sessionId;
  String? agentId;
  String? name;
  String? dob;
  String? docType;
  String? docNo;
  String? expiryDate;
  String? vehicleNumber;
  String? mobileNumber;
  dynamic chassisNo;
  dynamic engineNo;
  String? vehicleManuf;
  String? model;
  String? vehicleColour;
  String? type;
  dynamic rtoStatus;
  String? isCommercial;
  String? tagVehicleClassId;
  String? npciVehicleClassId;
  String? vehicleType;
  dynamic vehicleCategory;
  String? rechargeAmount;
  String? securityDeposit;
  String? tagCost;
  String? repTagCost;
  String? walletId;
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
  String? stateOfRegistration;
  dynamic wallet_response;
  AddcustomerdetailsDatum({
    this.id,
    this.requestId,
    this.sessionId,
    this.agentId,
    this.name,
    this.dob,
    this.docType,
    this.docNo,
    this.expiryDate,
    this.vehicleNumber,
    this.mobileNumber,
    this.chassisNo,
    this.engineNo,
    this.vehicleManuf,
    this.model,
    this.vehicleColour,
    this.type,
    this.rtoStatus,
    this.isCommercial,
    this.tagVehicleClassId,
    this.npciVehicleClassId,
    this.vehicleType,
    this.vehicleCategory,
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
    this.stateOfRegistration,
    this.wallet_response,
  });

  factory AddcustomerdetailsDatum.fromJson(Map<String, dynamic> json) =>
      AddcustomerdetailsDatum(
        id: json["id"],
        requestId: json["request_id"],
        sessionId: json["session_id"],
        agentId: json["agent_id"],
        name: json["name"],
        dob: json["dob"],
        docType: json["docType"],
        docNo: json["docNo"],
        expiryDate: json["expiryDate"],
        vehicleNumber: json["vehicle_number"],
        mobileNumber: json["mobile_number"],
        chassisNo: json["chassisNo"],
        engineNo: json["engineNo"],
        vehicleManuf: json["vehicleManuf"],
        model: json["model"],
        vehicleColour: json["vehicleColour"],
        type: json["type"],
        rtoStatus: json["rtoStatus"],
        isCommercial: json["isCommercial"],
        tagVehicleClassId: json["tagVehicleClassID"],
        npciVehicleClassId: json["npciVehicleClassID"],
        vehicleType: json["vehicleType"],
        vehicleCategory: json["vehicleCategory"],
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
        stateOfRegistration: json["stateOfRegistration"],
        wallet_response: json["wallet_response"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "request_id": requestId,
        "session_id": sessionId,
        "agent_id": agentId,
        "name": name,
        "dob": dob,
        "docType": docType,
        "docNo": docNo,
        "expiryDate": expiryDate,
        "vehicle_number": vehicleNumber,
        "mobile_number": mobileNumber,
        "chassisNo": chassisNo,
        "engineNo": engineNo,
        "vehicleManuf": vehicleManuf,
        "model": model,
        "vehicleColour": vehicleColour,
        "type": type,
        "rtoStatus": rtoStatus,
        "isCommercial": isCommercial,
        "tagVehicleClassID": tagVehicleClassId,
        "npciVehicleClassID": npciVehicleClassId,
        "vehicleType": vehicleType,
        "vehicleCategory": vehicleCategory,
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
        "stateOfRegistration": stateOfRegistration,
        "wallet_response": wallet_response,
      };
}
