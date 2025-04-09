// To parse this JSON data, do
//
//     final vehicledetailsresponse = vehicledetailsresponseFromJson(jsonString);

import 'dart:convert';

List<Vehicledetailsresponse> vehicledetailsresponseFromJson(String str) =>
    List<Vehicledetailsresponse>.from(
        json.decode(str).map((x) => Vehicledetailsresponse.fromJson(x)));

String vehicledetailsresponseToJson(List<Vehicledetailsresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Vehicledetailsresponse {
  String status;
  String message;
  List<VehicledetailsDatum> data;

  Vehicledetailsresponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory Vehicledetailsresponse.fromJson(Map<String, dynamic> json) =>
      Vehicledetailsresponse(
        status: json["status"],
        message: json["message"],
        data: List<VehicledetailsDatum>.from(
            json["data"].map((x) => VehicledetailsDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class VehicledetailsDatum {
  dynamic id;
  dynamic requestId;
  dynamic sessionId;
  dynamic agentId;
  dynamic name;
  dynamic lastName;
  dynamic isChassis;
  dynamic vehicleDescriptor;
  dynamic reqType;
  dynamic dob;
  dynamic docType;
  dynamic docNo;
  dynamic expiryDate;
  dynamic vehicleNumber;
  dynamic mobileNumber;
  dynamic chassisNo;
  dynamic engineNo;
  dynamic vehicleManuf;
  dynamic model;
  dynamic vehicleColour;
  dynamic type;
  dynamic rtoStatus;
  dynamic isCommercial;
  dynamic tagVehicleClassId;
  dynamic npciVehicleClassId;
  dynamic vehicleType;
  dynamic vehicleCategory;
  dynamic rechargeAmount;
  dynamic securityDeposit;
  dynamic tagCost;
  dynamic repTagCost;
  dynamic walletId;
  dynamic walletStatus;
  dynamic npcIstatus;
  dynamic kycStatus;
  dynamic serialNo;
  dynamic tid;
  dynamic rcImageFront;
  dynamic rcImageBack;
  dynamic vehicleImage;
  String stateOfRegistration;
  dynamic isNationalPermit;
  dynamic permitExpiryDate;
  dynamic planId;
  dynamic requestType;
  dynamic tagIssue;
  dynamic finalAmount;
  DateTime updatedOn;

  VehicledetailsDatum({
    required this.id,
    required this.requestId,
    required this.sessionId,
    required this.agentId,
    required this.name,
    required this.lastName,
    required this.isChassis,
    required this.vehicleDescriptor,
    required this.reqType,
    required this.dob,
    required this.docType,
    required this.docNo,
    required this.expiryDate,
    required this.vehicleNumber,
    required this.mobileNumber,
    required this.chassisNo,
    required this.engineNo,
    required this.vehicleManuf,
    required this.model,
    required this.vehicleColour,
    required this.type,
    required this.rtoStatus,
    required this.isCommercial,
    required this.tagVehicleClassId,
    required this.npciVehicleClassId,
    required this.vehicleType,
    required this.vehicleCategory,
    required this.rechargeAmount,
    required this.securityDeposit,
    required this.tagCost,
    required this.repTagCost,
    required this.walletId,
    required this.walletStatus,
    required this.npcIstatus,
    required this.kycStatus,
    required this.serialNo,
    required this.tid,
    required this.rcImageFront,
    required this.rcImageBack,
    required this.vehicleImage,
    required this.stateOfRegistration,
    required this.isNationalPermit,
    required this.permitExpiryDate,
    required this.planId,
    required this.requestType,
    required this.tagIssue,
    required this.finalAmount,
    required this.updatedOn,
  });

  factory VehicledetailsDatum.fromJson(Map<String, dynamic> json) =>
      VehicledetailsDatum(
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
        updatedOn: DateTime.parse(json["updated_on"]),
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
        "updated_on": updatedOn.toIso8601String(),
      };
}
