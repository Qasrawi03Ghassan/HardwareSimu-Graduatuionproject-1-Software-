class Course {
  final int courseID;
  final String title;
  final String imageURL;
  final String level;
  final String author;
  final String usersEmails;

  Course({
    required this.courseID,
    required this.title,
    required this.author,
    required this.imageURL,
    required this.level,
    required this.usersEmails,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseID: json['courseID'],
      title: json['title'],
      author: json['author'],
      imageURL: json['image'],
      usersEmails: json['usersEmails'],
      level: json['level'],
    );
  }
}
