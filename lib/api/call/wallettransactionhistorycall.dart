// To parse this JSON data, do
//
//     final wallettransactionhistorycall = wallettransactionhistorycallFromJson(jsonString);

import 'dart:convert';

Wallettransactionhistorycall wallettransactionhistorycallFromJson(String str) =>
    Wallettransactionhistorycall.fromJson(json.decode(str));

String wallettransactionhistorycallToJson(Wallettransactionhistorycall data) =>
    json.encode(data.toJson());

class Wallettransactionhistorycall {
  String? agentId;

  Wallettransactionhistorycall({
    this.agentId,
  });

  factory Wallettransactionhistorycall.fromJson(Map<String, dynamic> json) =>
      Wallettransactionhistorycall(
        agentId: json["agent_id"],
      );

  Map<String, dynamic> toJson() => {
        "agent_id": agentId,
      };
}
