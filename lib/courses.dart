class Course {
  final int courseID;
  final String title;
  final String tag;
  final String imageURL;
  final String level;
  final String description;
  final String usersEmails;

  Course({
    required this.courseID,
    required this.title,
    required this.tag,
    required this.description,
    required this.imageURL,
    required this.level,
    required this.usersEmails,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseID: json['courseID'],
      title: json['title'],
      tag: json['tag'],
      description: json['description'],
      imageURL: json['image'],
      usersEmails: json['usersEmails'],
      level: json['level'],
    );
  }
}
