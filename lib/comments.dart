class Comment {
  final int commentID;
  final int postID;
  final String userEmail;
  String description;

  Comment({
    required this.commentID,
    required this.postID,
    required this.userEmail,
    required this.description,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentID: json['commentID'] ?? 0,
      postID: json['PostID'] ?? 0,
      userEmail: json['userEmail'] ?? 'defE',
      description: json['description'] ?? 'defD',
    );
  }
}
