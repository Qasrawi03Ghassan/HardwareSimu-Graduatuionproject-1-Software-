class Post {
  final int postID;
  final String userEmail;
  final int courseID;
  final String description;
  final String imageUrl;
  int likesCount;
  bool isPostLiked;

  Post({
    required this.postID,
    required this.userEmail,
    required this.courseID,
    required this.description,
    required this.imageUrl,
    required this.likesCount,
    this.isPostLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postID: json['postID'] ?? 0,
      userEmail: json['userEmail'] ?? 'defAuthorEmail',
      courseID: json['courseID'] ?? 0,
      description: json['description'] ?? 'defDesc',
      imageUrl: json['imageUrl'] ?? 'defImage',
      likesCount: json['likesCount'] ?? 0,
    );
  }
}
