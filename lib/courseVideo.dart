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
