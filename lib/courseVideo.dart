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
      URL: json['fileUrl'] ?? 0,
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
