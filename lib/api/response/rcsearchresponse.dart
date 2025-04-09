// To parse this JSON data, do
//
//     final rcsearchresponse = rcsearchresponseFromJson(jsonString);

import 'dart:convert';

List<Rcsearchresponse> rcsearchresponseFromJson(String str) =>
    List<Rcsearchresponse>.from(
        json.decode(str).map((x) => Rcsearchresponse.fromJson(x)));

String rcsearchresponseToJson(List<Rcsearchresponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Rcsearchresponse {
  dynamic? status;
  dynamic? message;
  RcsearchData? data;

  Rcsearchresponse({
    this.status,
    this.message,
    this.data,
  });

  factory Rcsearchresponse.fromJson(Map<String, dynamic> json) =>
      Rcsearchresponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : RcsearchData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class RcsearchData {
  String? status;
  String? message;
  String? responseType;
  Result? result;

  RcsearchData({
    this.status,
    this.message,
    this.responseType,
    this.result,
  });

  factory RcsearchData.fromJson(Map<String, dynamic> json) => RcsearchData(
        status: json["status"],
        message: json["message"],
        responseType: json["response_type"],
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "response_type": responseType,
        "result": result?.toJson(),
      };
}

class Result {
  dynamic? stateCode;
  dynamic? state;
  dynamic? officeCode;
  dynamic? officeName;
  dynamic? regNo;
  dynamic? regDate;
  dynamic? purchaseDate;
  dynamic? ownerCount;
  dynamic? ownerName;
  dynamic? ownerFatherName;
  dynamic? currentAddressLine1;
  dynamic? currentAddressLine2;
  dynamic? currentAddressLine3;
  dynamic? currentDistrictName;
  dynamic? currentState;
  dynamic? currentStateName;
  dynamic? currentPincode;
  dynamic? currentFullAddress;
  dynamic? permanentAddressLine1;
  dynamic? permanentAddressLine2;
  dynamic? permanentAddressLine3;
  dynamic? permanentDistrictName;
  dynamic? permanentState;
  dynamic? permanentStateName;
  dynamic? permanentPincode;
  dynamic? permanentFullAddress;
  dynamic? ownerCodeDescr;
  dynamic? regTypeDescr;
  dynamic? vehicleClassDesc;
  dynamic? chassisNo;
  dynamic? engineNo;
  dynamic? vehicleManufacturerName;
  dynamic? modelCode;
  dynamic? model;
  dynamic? bodyType;
  dynamic? cylindersNo;
  dynamic vehicleHp;
  dynamic? vehicleSeatCapacity;
  dynamic vehicleStandingCapacity;
  dynamic vehicleSleeperCapacity;
  dynamic? unladenWeight;
  dynamic? vehicleGrossWeight;
  dynamic? vehicleGrossCombWeight;
  dynamic? fuelDescr;
  dynamic? color;
  dynamic? manufacturingMon;
  dynamic? manufacturingYr;
  dynamic? normsDescr;
  dynamic wheelbase;
  dynamic? cubicCap;
  dynamic floorArea;
  dynamic? acFitted;
  dynamic? audioFitted;
  dynamic? videoFitted;
  dynamic? vehicleCatg;
  dynamic? saleAmount;
  dynamic length;
  dynamic width;
  dynamic height;
  dynamic? regUpto;
  dynamic? fitUpto;
  dynamic? importedVehicle;
  dynamic? status;
  dynamic? vehicleType;
  dynamic? taxMode;
  VehicleInsuranceDetails? vehicleInsuranceDetails;
  VehiclePuccDetails? vehiclePuccDetails;
  dynamic permitDetails;
  LatestTaxDetails? latestTaxDetails;
  FinancerDetails? financerDetails;

  Result({
    this.stateCode,
    this.state,
    this.officeCode,
    this.officeName,
    this.regNo,
    this.regDate,
    this.purchaseDate,
    this.ownerCount,
    this.ownerName,
    this.ownerFatherName,
    this.currentAddressLine1,
    this.currentAddressLine2,
    this.currentAddressLine3,
    this.currentDistrictName,
    this.currentState,
    this.currentStateName,
    this.currentPincode,
    this.currentFullAddress,
    this.permanentAddressLine1,
    this.permanentAddressLine2,
    this.permanentAddressLine3,
    this.permanentDistrictName,
    this.permanentState,
    this.permanentStateName,
    this.permanentPincode,
    this.permanentFullAddress,
    this.ownerCodeDescr,
    this.regTypeDescr,
    this.vehicleClassDesc,
    this.chassisNo,
    this.engineNo,
    this.vehicleManufacturerName,
    this.modelCode,
    this.model,
    this.bodyType,
    this.cylindersNo,
    this.vehicleHp,
    this.vehicleSeatCapacity,
    this.vehicleStandingCapacity,
    this.vehicleSleeperCapacity,
    this.unladenWeight,
    this.vehicleGrossWeight,
    this.vehicleGrossCombWeight,
    this.fuelDescr,
    this.color,
    this.manufacturingMon,
    this.manufacturingYr,
    this.normsDescr,
    this.wheelbase,
    this.cubicCap,
    this.floorArea,
    this.acFitted,
    this.audioFitted,
    this.videoFitted,
    this.vehicleCatg,
    this.saleAmount,
    this.length,
    this.width,
    this.height,
    this.regUpto,
    this.fitUpto,
    this.importedVehicle,
    this.status,
    this.vehicleType,
    this.taxMode,
    this.vehicleInsuranceDetails,
    this.vehiclePuccDetails,
    this.permitDetails,
    this.latestTaxDetails,
    this.financerDetails,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        stateCode: json["state_code"],
        state: json["state"],
        officeCode: json["office_code"],
        officeName: json["office_name"],
        regNo: json["reg_no"],
        regDate: json["reg_date"],
        purchaseDate: json["purchase_date"],
        ownerCount: json["owner_count"],
        ownerName: json["owner_name"],
        ownerFatherName: json["owner_father_name"],
        currentAddressLine1: json["current_address_line1"],
        currentAddressLine2: json["current_address_line2"],
        currentAddressLine3: json["current_address_line3"],
        currentDistrictName: json["current_district_name"],
        currentState: json["current_state"],
        currentStateName: json["current_state_name"],
        currentPincode: json["current_pincode"],
        currentFullAddress: json["current_full_address"],
        permanentAddressLine1: json["permanent_address_line1"],
        permanentAddressLine2: json["permanent_address_line2"],
        permanentAddressLine3: json["permanent_address_line3"],
        permanentDistrictName: json["permanent_district_name"],
        permanentState: json["permanent_state"],
        permanentStateName: json["permanent_state_name"],
        permanentPincode: json["permanent_pincode"],
        permanentFullAddress: json["permanent_full_address"],
        ownerCodeDescr: json["owner_code_descr"],
        regTypeDescr: json["reg_type_descr"],
        vehicleClassDesc: json["vehicle_class_desc"],
        chassisNo: json["chassis_no"],
        engineNo: json["engine_no"],
        vehicleManufacturerName: json["vehicle_manufacturer_name"],
        modelCode: json["model_code"],
        model: json["model"],
        bodyType: json["body_type"],
        cylindersNo: json["cylinders_no"],
        vehicleHp: json["vehicle_hp"],
        vehicleSeatCapacity: json["vehicle_seat_capacity"],
        vehicleStandingCapacity: json["vehicle_standing_capacity"],
        vehicleSleeperCapacity: json["vehicle_sleeper_capacity"],
        unladenWeight: json["unladen_weight"],
        vehicleGrossWeight: json["vehicle_gross_weight"],
        vehicleGrossCombWeight: json["vehicle_gross_comb_weight"],
        fuelDescr: json["fuel_descr"],
        color: json["color"],
        manufacturingMon: json["manufacturing_mon"],
        manufacturingYr: json["manufacturing_yr"],
        normsDescr: json["norms_descr"],
        wheelbase: json["wheelbase"],
        cubicCap: json["cubic_cap"],
        floorArea: json["floor_area"],
        acFitted: json["ac_fitted"],
        audioFitted: json["audio_fitted"],
        videoFitted: json["video_fitted"],
        vehicleCatg: json["vehicle_catg"],
        saleAmount: json["sale_amount"],
        length: json["length"],
        width: json["width"],
        height: json["height"],
        regUpto: json["reg_upto"],
        fitUpto: json["fit_upto"],
        importedVehicle: json["imported_vehicle"],
        status: json["status"],
        vehicleType: json["vehicle_type"],
        taxMode: json["tax_mode"],
        vehicleInsuranceDetails: json["vehicle_insurance_details"] == null
            ? null
            : VehicleInsuranceDetails.fromJson(
                json["vehicle_insurance_details"]),
        vehiclePuccDetails: json["vehicle_pucc_details"] == null
            ? null
            : VehiclePuccDetails.fromJson(json["vehicle_pucc_details"]),
        permitDetails: json["permit_details"],
        latestTaxDetails: json["latest_tax_details"] == null
            ? null
            : LatestTaxDetails.fromJson(json["latest_tax_details"]),
        financerDetails: json["financer_details"] == null
            ? null
            : FinancerDetails.fromJson(json["financer_details"]),
      );

  Map<String, dynamic> toJson() => {
        "state_code": stateCode,
        "state": state,
        "office_code": officeCode,
        "office_name": officeName,
        "reg_no": regNo,
        "reg_date":
            "${regDate!.year.toString().padLeft(4, '0')}-${regDate!.month.toString().padLeft(2, '0')}-${regDate!.day.toString().padLeft(2, '0')}",
        "purchase_date":
            "${purchaseDate!.year.toString().padLeft(4, '0')}-${purchaseDate!.month.toString().padLeft(2, '0')}-${purchaseDate!.day.toString().padLeft(2, '0')}",
        "owner_count": ownerCount,
        "owner_name": ownerName,
        "owner_father_name": ownerFatherName,
        "current_address_line1": currentAddressLine1,
        "current_address_line2": currentAddressLine2,
        "current_address_line3": currentAddressLine3,
        "current_district_name": currentDistrictName,
        "current_state": currentState,
        "current_state_name": currentStateName,
        "current_pincode": currentPincode,
        "current_full_address": currentFullAddress,
        "permanent_address_line1": permanentAddressLine1,
        "permanent_address_line2": permanentAddressLine2,
        "permanent_address_line3": permanentAddressLine3,
        "permanent_district_name": permanentDistrictName,
        "permanent_state": permanentState,
        "permanent_state_name": permanentStateName,
        "permanent_pincode": permanentPincode,
        "permanent_full_address": permanentFullAddress,
        "owner_code_descr": ownerCodeDescr,
        "reg_type_descr": regTypeDescr,
        "vehicle_class_desc": vehicleClassDesc,
        "chassis_no": chassisNo,
        "engine_no": engineNo,
        "vehicle_manufacturer_name": vehicleManufacturerName,
        "model_code": modelCode,
        "model": model,
        "body_type": bodyType,
        "cylinders_no": cylindersNo,
        "vehicle_hp": vehicleHp,
        "vehicle_seat_capacity": vehicleSeatCapacity,
        "vehicle_standing_capacity": vehicleStandingCapacity,
        "vehicle_sleeper_capacity": vehicleSleeperCapacity,
        "unladen_weight": unladenWeight,
        "vehicle_gross_weight": vehicleGrossWeight,
        "vehicle_gross_comb_weight": vehicleGrossCombWeight,
        "fuel_descr": fuelDescr,
        "color": color,
        "manufacturing_mon": manufacturingMon,
        "manufacturing_yr": manufacturingYr,
        "norms_descr": normsDescr,
        "wheelbase": wheelbase,
        "cubic_cap": cubicCap,
        "floor_area": floorArea,
        "ac_fitted": acFitted,
        "audio_fitted": audioFitted,
        "video_fitted": videoFitted,
        "vehicle_catg": vehicleCatg,
        "sale_amount": saleAmount,
        "length": length,
        "width": width,
        "height": height,
        "reg_upto":
            "${regUpto!.year.toString().padLeft(4, '0')}-${regUpto!.month.toString().padLeft(2, '0')}-${regUpto!.day.toString().padLeft(2, '0')}",
        "fit_upto":
            "${fitUpto!.year.toString().padLeft(4, '0')}-${fitUpto!.month.toString().padLeft(2, '0')}-${fitUpto!.day.toString().padLeft(2, '0')}",
        "imported_vehicle": importedVehicle,
        "status": status,
        "vehicle_type": vehicleType,
        "tax_mode": taxMode,
        "vehicle_insurance_details": vehicleInsuranceDetails?.toJson(),
        "vehicle_pucc_details": vehiclePuccDetails?.toJson(),
        "permit_details": permitDetails,
        "latest_tax_details": latestTaxDetails?.toJson(),
        "financer_details": financerDetails?.toJson(),
      };
}

class LatestTaxDetails {
  dynamic? regNo;
  dynamic? taxMode;
  dynamic? paymentMode;
  dynamic? taxAmt;
  dynamic? taxFine;
  dynamic? rcptDt;
  dynamic? taxFrom;
  dynamic taxUpto;
  dynamic? collectedBy;
  dynamic? rcptNo;

  LatestTaxDetails({
    this.regNo,
    this.taxMode,
    this.paymentMode,
    this.taxAmt,
    this.taxFine,
    this.rcptDt,
    this.taxFrom,
    this.taxUpto,
    this.collectedBy,
    this.rcptNo,
  });

  factory LatestTaxDetails.fromJson(Map<String, dynamic> json) =>
      LatestTaxDetails(
        regNo: json["reg_no"],
        taxMode: json["tax_mode"],
        paymentMode: json["payment_mode"],
        taxAmt: json["tax_amt"],
        taxFine: json["tax_fine"],
        rcptDt: json["rcpt_dt"],
        taxFrom: json["tax_from"],
        taxUpto: json["tax_upto"],
        collectedBy: json["collected_by"],
        rcptNo: json["rcpt_no"],
      );

  Map<String, dynamic> toJson() => {
        "reg_no": regNo,
        "tax_mode": taxMode,
        "payment_mode": paymentMode,
        "tax_amt": taxAmt,
        "tax_fine": taxFine,
        "rcpt_dt": rcptDt,
        "tax_from":
            "${taxFrom!.year.toString().padLeft(4, '0')}-${taxFrom!.month.toString().padLeft(2, '0')}-${taxFrom!.day.toString().padLeft(2, '0')}",
        "tax_upto": taxUpto,
        "collected_by": collectedBy,
        "rcpt_no": rcptNo,
      };
}

class VehicleInsuranceDetails {
  dynamic? insuranceFrom;
  dynamic? insuranceUpto;
  int? insuranceCompanyCode;
  String? insuranceCompanyName;
  dynamic? opdt;
  String? policyNo;
  String? regNo;

  VehicleInsuranceDetails({
    this.insuranceFrom,
    this.insuranceUpto,
    this.insuranceCompanyCode,
    this.insuranceCompanyName,
    this.opdt,
    this.policyNo,
    this.regNo,
  });

  factory VehicleInsuranceDetails.fromJson(Map<String, dynamic> json) =>
      VehicleInsuranceDetails(
        insuranceFrom: json["insurance_from"],
        insuranceUpto: json["insurance_upto"],
        insuranceCompanyCode: json["insurance_company_code"],
        insuranceCompanyName: json["insurance_company_name"],
        opdt: json["opdt"] == null,
        policyNo: json["policy_no"],
        regNo: json["reg_no"],
      );

  Map<String, dynamic> toJson() => {
        "insurance_from":
            "${insuranceFrom!.year.toString().padLeft(4, '0')}-${insuranceFrom!.month.toString().padLeft(2, '0')}-${insuranceFrom!.day.toString().padLeft(2, '0')}",
        "insurance_upto":
            "${insuranceUpto!.year.toString().padLeft(4, '0')}-${insuranceUpto!.month.toString().padLeft(2, '0')}-${insuranceUpto!.day.toString().padLeft(2, '0')}",
        "insurance_company_code": insuranceCompanyCode,
        "insurance_company_name": insuranceCompanyName,
        "opdt": opdt?.toIso8601String(),
        "policy_no": policyNo,
        "reg_no": regNo,
      };
}

class VehiclePuccDetails {
  dynamic? puccFrom;
  dynamic? puccUpto;
  dynamic? puccCentreno;
  dynamic? puccNo;
  dynamic? opDt;

  VehiclePuccDetails({
    this.puccFrom,
    this.puccUpto,
    this.puccCentreno,
    this.puccNo,
    this.opDt,
  });

  factory VehiclePuccDetails.fromJson(Map<String, dynamic> json) =>
      VehiclePuccDetails(
        puccFrom: json["pucc_from"],
        puccUpto: json["pucc_upto"],
        puccCentreno: json["pucc_centreno"],
        puccNo: json["pucc_no"],
        opDt: json["op_dt"],
      );

  Map<String, dynamic> toJson() => {
        "pucc_from": puccFrom,
        "pucc_upto": puccUpto,
        "pucc_centreno": puccCentreno,
        "pucc_no": puccNo,
        "op_dt": opDt,
      };
}

class FinancerDetails {
  dynamic? hpType;
  dynamic? financerName;
  dynamic? financerAddressLine1;
  dynamic? financerAddressLine2;
  dynamic? financerAddressLine3;
  dynamic? financerDistrict;
  dynamic? financerPincode;
  dynamic? financerState;
  dynamic? financerFullAddress;
  dynamic? hypothecationDt;
  dynamic? opDt;

  FinancerDetails({
    this.hpType,
    this.financerName,
    this.financerAddressLine1,
    this.financerAddressLine2,
    this.financerAddressLine3,
    this.financerDistrict,
    this.financerPincode,
    this.financerState,
    this.financerFullAddress,
    this.hypothecationDt,
    this.opDt,
  });

  factory FinancerDetails.fromJson(Map<String, dynamic> json) =>
      FinancerDetails(
        hpType: json["hp_type"],
        financerName: json["financer_name"],
        financerAddressLine1: json["financer_address_line1"],
        financerAddressLine2: json["financer_address_line2"],
        financerAddressLine3: json["financer_address_line3"],
        financerDistrict: json["financer_district"],
        financerPincode: json["financer_pincode"],
        financerState: json["financer_state"],
        financerFullAddress: json["financer_full_address"],
        hypothecationDt: json["hypothecation_dt"],
        opDt: json["op_dt"],
      );

  Map<String, dynamic> toJson() => {
        "hp_type": hpType,
        "financer_name": financerName,
        "financer_address_line1": financerAddressLine1,
        "financer_address_line2": financerAddressLine2,
        "financer_address_line3": financerAddressLine3,
        "financer_district": financerDistrict,
        "financer_pincode": financerPincode,
        "financer_state": financerState,
        "financer_full_address": financerFullAddress,
        "hypothecation_dt":
            "${hypothecationDt!.year.toString().padLeft(4, '0')}-${hypothecationDt!.month.toString().padLeft(2, '0')}-${hypothecationDt!.day.toString().padLeft(2, '0')}",
        "op_dt":
            "${opDt!.year.toString().padLeft(4, '0')}-${opDt!.month.toString().padLeft(2, '0')}-${opDt!.day.toString().padLeft(2, '0')}",
      };
}
