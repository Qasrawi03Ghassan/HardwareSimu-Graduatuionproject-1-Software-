class User {
  final int userID;
  final String name;
  final String userName;
  final String email;
  final String? phoneNum;
  final String password;
  final String? profileImgUrl;
  final bool isSignedIn;

  User({
    required this.userID,
    required this.name,
    required this.userName,
    required this.email,
    this.phoneNum,
    required this.password,
    this.profileImgUrl,
    required this.isSignedIn,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['userID'] ?? 0,
      name: json['name'] ?? 'defName',
      userName: json['username'] ?? 'defUserName',
      email: json['email'] ?? 'defEmail',
      isSignedIn: json['isSignedIn'] ?? false,
      password: json['password'] ?? 'defPass',
      phoneNum: json['phone'] ?? '0000000000',
      profileImgUrl: json['imageUrl'] ?? '',
    );
  }
}
