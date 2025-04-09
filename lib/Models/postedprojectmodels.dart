class Postedprojectmodels {
  final String title;
  final String location;
  final String description;
  final List<String> tags;
  late final String hiredOn;
  final String hiredStatus;
  final List<String> attachments;

  Postedprojectmodels({
    required this.title,
    required this.location,
    required this.description,
    required this.tags,
    required this.hiredOn,
    required this.hiredStatus,
    required this.attachments,
  });

  // Factory method to convert JSON into a Postedprojectmodels instance
  factory Postedprojectmodels.fromJson(Map<String, dynamic> json) {
    return Postedprojectmodels(
      title: json['title'],
      location: json['location'],
      description: json['description'],
      tags: List<String>.from(json['tags']),
      hiredOn: json['hiredOn'],
      hiredStatus: json['hiredStatus'],
      attachments: List<String>.from(json['attachments']),
    );
  }
}
