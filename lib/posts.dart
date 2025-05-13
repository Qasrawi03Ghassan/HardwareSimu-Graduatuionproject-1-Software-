class Post {
  final int postID;
  final String userEmail;
  final int courseID;
  final String description;
  final String imageUrl;
  int likesCount;
  bool isPostLiked;
  final DateTime createdAt;

  Post({
    required this.postID,
    required this.userEmail,
    required this.courseID,
    required this.description,
    required this.imageUrl,
    required this.likesCount,
    required this.createdAt,
    this.isPostLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postID: json['postID'] ?? 0,
      userEmail: json['userEmail'] ?? 'defAuthorEmail',
      courseID: json['courseID'] ?? 0,
      description: json['description'] ?? 'defDesc',
      imageUrl: json['imageUrl'] ?? 'defImage',
      createdAt:
          json['createdAt'] is DateTime
              ? json['createdAt']
              : DateTime.parse(json['createdAt']),
      likesCount: json['likesCount'] ?? 0,
    );
  }
}
