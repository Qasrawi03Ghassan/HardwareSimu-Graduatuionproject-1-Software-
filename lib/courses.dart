class Course {
  final int id;
  final String title;
  final String imageURL;
  final String level;
  final String author;
  final String usersEmails;

  Course({
    required this.id,
    required this.title,
    required this.author,
    required this.imageURL,
    required this.level,
    required this.usersEmails,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      imageURL: json['image'],
      usersEmails: json['usersEmails'],
      level: json['level'],
    );
  }
}
