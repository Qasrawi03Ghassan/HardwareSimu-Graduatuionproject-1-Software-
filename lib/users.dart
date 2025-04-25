class User {
  final String fullName;
  final String userName;
  final String email;
  final String phoneNum;
  final String password;
  final String profileImgUrl;
  final bool isSignedIn;

  User({
    required this.fullName,
    required this.userName,
    required this.email,
    required this.phoneNum,
    required this.password,
    required this.profileImgUrl,
    required this.isSignedIn,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['name'],
      userName: json['username'],
      email: json['email'],
      isSignedIn: json['isSignedIn'],
      password: json['password'],
      phoneNum: json['phone'],
      profileImgUrl: json['imageUrl'],
    );
  }
}
