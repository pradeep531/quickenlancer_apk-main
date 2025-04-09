class History {
  final String allocatedOn;
  final String purchasedOn;
  final String tokenNo;
  final String allocatedProject;
  final String projectDescription;

  History({
    required this.allocatedOn,
    required this.purchasedOn,
    required this.tokenNo,
    required this.allocatedProject,
    required this.projectDescription,
  });

  // From JSON
  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      allocatedOn: json['allocatedOn'],
      purchasedOn: json['purchasedOn'],
      tokenNo: json['tokenNo'],
      allocatedProject: json['allocatedProject'],
      projectDescription: json['projectDescription'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'allocatedOn': allocatedOn,
      'purchasedOn': purchasedOn,
      'tokenNo': tokenNo,
      'allocatedProject': allocatedProject,
      'projectDescription': projectDescription,
    };
  }
}
