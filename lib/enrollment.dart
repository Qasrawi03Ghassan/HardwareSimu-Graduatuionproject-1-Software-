class Enrollment {
  final int id;
  final int CourseID;
  final int userID;

  Enrollment({required this.id, required this.CourseID, required this.userID});

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] ?? 0,
      CourseID: json['CourseID'] ?? 0,
      userID: json['userID'] ?? 0,
    );
  }
}
