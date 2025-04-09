// To parse this JSON data, do
//
//     final customervehicledetailsrespone = customervehicledetailsresponeFromJson(jsonString);

import 'dart:convert';

List<Customervehicledetailsrespone> customervehicledetailsresponeFromJson(
        String str) =>
    List<Customervehicledetailsrespone>.from(
        json.decode(str).map((x) => Customervehicledetailsrespone.fromJson(x)));

String customervehicledetailsresponeToJson(
        List<Customervehicledetailsrespone> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Customervehicledetailsrespone {
  String? status;
  String? message;
  List<CustomervehicledetailsDatum>? data;

  Customervehicledetailsrespone({
    this.status,
    this.message,
    this.data,
  });

  factory Customervehicledetailsrespone.fromJson(Map<String, dynamic> json) =>
      Customervehicledetailsrespone(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<CustomervehicledetailsDatum>.from(json["data"]!
                .map((x) => CustomervehicledetailsDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CustomervehicledetailsDatum {
  String? id;
  String? requestId;
  String? sessionId;
  String? agentId;
  String? name;
  String? lastName;
  String? isChassis;
  String? vehicleDescriptor;
  String? reqType;
  String? dob;
  String? docType;
  String? docNo;
  String? expiryDate;
  String? vehicleNumber;
  String? mobileNumber;
  String? chassisNo;
  String? engineNo;
  String? vehicleManuf;
  String? model;
  String? vehicleColour;
  String? type;
  String? rtoStatus;
  String? isCommercial;
  String? tagVehicleClassId;
  String? npciVehicleClassId;
  String? vehicleType;
  String? vehicleCategory;
  String? rechargeAmount;
  String? securityDeposit;
  String? tagCost;
  String? repTagCost;
  String? walletId;
  String? walletStatus;
  String? npcIstatus;
  String? kycStatus;
  String? serialNo;
  dynamic tid;
  String? rcImageFront;
  String? rcImageBack;
  String? vehicleImage;
  String? stateOfRegistration;
  String? isNationalPermit;
  String? permitExpiryDate;
  String? planId;
  String? requestType;
  String? tagIssue;
  String? finalAmount;
  String? status;
  String? isDeleted;
  DateTime? createdOn;
  DateTime? updatedOn;

  CustomervehicledetailsDatum({
    this.id,
    this.requestId,
    this.sessionId,
    this.agentId,
    this.name,
    this.lastName,
    this.isChassis,
    this.vehicleDescriptor,
    this.reqType,
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
    this.stateOfRegistration,
    this.isNationalPermit,
    this.permitExpiryDate,
    this.planId,
    this.requestType,
    this.tagIssue,
    this.finalAmount,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
  });

  factory CustomervehicledetailsDatum.fromJson(Map<String, dynamic> json) =>
      CustomervehicledetailsDatum(
        id: json["id"],
        requestId: json["request_id"],
        sessionId: json["session_id"],
        agentId: json["agent_id"],
        name: json["name"],
        lastName: json["lastName"],
        isChassis: json["isChassis"],
        vehicleDescriptor: json["vehicleDescriptor"],
        reqType: json["req_type"],
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
        stateOfRegistration: json["stateOfRegistration"],
        isNationalPermit: json["isNationalPermit"],
        permitExpiryDate: json["permitExpiryDate"],
        planId: json["plan_id"],
        requestType: json["request_type"],
        tagIssue: json["tag_issue"],
        finalAmount: json["final_amount"],
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
        "lastName": lastName,
        "isChassis": isChassis,
        "vehicleDescriptor": vehicleDescriptor,
        "req_type": reqType,
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
        "stateOfRegistration": stateOfRegistration,
        "isNationalPermit": isNationalPermit,
        "permitExpiryDate": permitExpiryDate,
        "plan_id": planId,
        "request_type": requestType,
        "tag_issue": tagIssue,
        "final_amount": finalAmount,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn?.toIso8601String(),
        "updated_on": updatedOn?.toIso8601String(),
      };
}
