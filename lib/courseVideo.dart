import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class CourseVideo {
  final String vTitle;
  final int cVidID;
  final int courseID;
  final String? vidUrl;

  CourseVideo({
    required this.vTitle,
    required this.cVidID,
    required this.courseID,
    required this.vidUrl,
  });

  factory CourseVideo.fromJson(Map<String, dynamic> json) {
    return CourseVideo(
      vTitle: json['vTitle'] ?? '',
      cVidID: json['cVideoID'] ?? 0,
      courseID: json['courseID'] ?? 0,
      vidUrl: json['videoUrl'] ?? '',
    );
  }
}

extension XFileHelper on XFile {
  static XFile fromBytes(Uint8List data, {required String name}) {
    return XFile.fromData(data, name: name);
  }
}

class PickedCourseVideo {
  final XFile xFile;
  final Uint8List bytes;
  final String title;

  PickedCourseVideo({
    required this.xFile,
    required this.bytes,
    required this.title,
  });
}

class CourseFile {
  final int id;
  final int courseID;
  final String fileName;
  final String? URL;

  CourseFile({
    required this.id,
    required this.courseID,
    required this.URL,
    required this.fileName,
  });

  factory CourseFile.fromJson(Map<String, dynamic> json) {
    return CourseFile(
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      courseID: json['courseID'] ?? 0,
      URL: json['fileUrl'] ?? '',
    );
  }
}

class PostFile {
  final int id;
  final int postID;
  final int userID;
  final String fileName;
  final String? fileUrl;

  PostFile({
    required this.id,
    required this.postID,
    required this.userID,
    required this.fileUrl,
    required this.fileName,
  });

  factory PostFile.fromJson(Map<String, dynamic> json) {
    return PostFile(
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      postID: json['postID'] ?? 0,
      userID: json['userID'] ?? 0,
      fileUrl: json['fileUrl'] ?? '',
    );
  }
}

class Certificate {
  final int id;
  final int userID;
  final String? URL;

  Certificate({required this.id, required this.userID, required this.URL});

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] ?? '',
      userID: json['userID'] ?? 0,
      URL: json['fileUrl'] ?? 0,
    );
  }
}

class Request {
  final int id;
  final int userID;
  final int cerID;

  Request({required this.id, required this.userID, required this.cerID});

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'] ?? '',
      userID: json['userID'] ?? 0,
      cerID: json['cerID'] ?? 0,
    );
  }
}

class Review {
  final int id;
  final int userID;
  final int courseID;
  final String description;
  final int starsCount;

  Review({
    required this.id,
    required this.userID,
    required this.courseID,
    required this.description,
    required this.starsCount,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      userID: json['userID'] ?? 0,
      courseID: json['courseID'] ?? 0,
      description: json['description'] ?? '',
      starsCount: json['starsCount'] ?? 0,
    );
  }
}

class Example {
  final int id;
  final int courseID;
  final String description;
  final String questionImageURL;
  final String txtFileURL;
  final String txtFileName;

  Example({
    required this.id,
    required this.courseID,
    required this.description,
    required this.questionImageURL,
    required this.txtFileURL,
    required this.txtFileName,
  });

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      id: json['id'] ?? 0,
      courseID: json['courseID'] ?? 0,
      description: json['description'] ?? '',
      questionImageURL: json['imageUrl'] ?? '',
      txtFileURL: json['fileUrl'] ?? '',
      txtFileName: json['fileName'] ?? '',
    );
  }
}
