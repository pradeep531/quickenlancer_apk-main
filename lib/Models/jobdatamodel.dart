class Job {
  final String title;
  final String location;
  final String description;
  final String price;
  final String jobType;
  final List<String> tags;

  Job({
    required this.title,
    required this.location,
    required this.description,
    required this.price,
    required this.jobType,
    required this.tags,
  });

  // Factory method to convert JSON into a Job instance
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      title: json['title'],
      location: json['location'],
      description: json['description'],
      price: json['price'],
      jobType: json['jobType'],
      tags: List<String>.from(json['tags']),
    );
  }
}
