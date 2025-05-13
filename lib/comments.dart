class Comment {
  final int commentID;
  final int postID;
  final String userEmail;
  String description;
  final DateTime createdAt;

  Comment({
    required this.commentID,
    required this.postID,
    required this.userEmail,
    required this.description,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentID: json['commentID'] ?? 0,
      postID: json['PostID'] ?? 0,
      userEmail: json['userEmail'] ?? 'defE',
      description: json['description'] ?? 'defD',
      createdAt:
          json['createdAt'] is DateTime
              ? json['createdAt']
              : DateTime.parse(json['createdAt']),
    );
  }
}
