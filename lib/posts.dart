class Post {
  final String userEmail;
  final int courseID;
  final String description;
  final String imageUrl;

  Post({
    required this.userEmail,
    required this.courseID,
    required this.description,
    required this.imageUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userEmail: json['userEmail'],
      courseID: json['courseID'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}
