import 'package:flutter/widgets.dart';

class Course {
  final int id;
  final String title;
  final String author;
  final String imageURL;

  Course({
    required this.id,
    required this.title,
    required this.author,
    required this.imageURL,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      imageURL: json['image'],
    );
  }
}
