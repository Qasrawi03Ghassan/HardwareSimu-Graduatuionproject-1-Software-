import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/authService.dart';
import 'package:hardwaresimu_software_graduation_project/comments.dart';
import 'package:hardwaresimu_software_graduation_project/courses.dart';
import 'package:hardwaresimu_software_graduation_project/edit_profile.dart';
import 'package:hardwaresimu_software_graduation_project/enrollment.dart';
import 'package:hardwaresimu_software_graduation_project/main.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/notificationsServices/firebaseNots.dart';
import 'package:hardwaresimu_software_graduation_project/posts.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:http/http.dart' as http;
import 'package:hardwaresimu_software_graduation_project/themeMobile.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final myUser.User? user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState(user: this.user);
}

class _ProfileScreenState extends State<ProfileScreen> {
  myUser.User? user;

  _ProfileScreenState({this.user});

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _fetchCourses();
    _fetchEnrollment();
    _fetchComments();
    _fetchPosts();
  }

  int getPostCreatedNum(String courseCreatorEmail) {
    return dbPostsList
        .where((post) => post.userEmail == courseCreatorEmail)
        .length;
  }

  int getCommentsCreatedNum(String courseCreatorEmail) {
    return dbCommentsList
        .where((comment) => comment.userEmail == courseCreatorEmail)
        .length;
  }

  int getCourseCreatedNum(String courseCreatorEmail) {
    return dbCoursesList
        .where((course) => course.usersEmails == courseCreatorEmail)
        .length;
  }

  Future<void> _fetchComments() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/comments'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbCommentsList = json.map((item) => Comment.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> _fetchPosts() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/posts'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbPostsList = json.map((item) => Post.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> _fetchEnrollment() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/enrollment'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbEnrollmentList =
            json.map((item) => Enrollment.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load enrollment');
    }
  }

  Future<void> _fetchCourses() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/courses'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          dbCoursesList = json.map((item) => Course.fromJson(item)).toList();
          //filteredCourses = List.from(dbCoursesList);
        });
      }
    } else {
      throw Exception('Failed to load courses');
    }
  }

  List<Course> dbCoursesList = [];
  List<Enrollment> dbEnrollmentList = [];
  List<Post> dbPostsList = [];
  List<Comment> dbCommentsList = [];

  int getEnrolledCoursesNum(int userId) {
    final enrolledCourseIds =
        dbEnrollmentList
            .where((enrollment) => enrollment.userID == userId)
            .map((enrollment) => enrollment.CourseID)
            .toSet();

    return dbCoursesList
        .where((course) => enrolledCourseIds.contains(course.courseID))
        .toList()
        .length;
  }

  bool isLightTheme = true;
  @override
  Widget build(BuildContext context) {
    isLightTheme = Provider.of<MobileThemeProvider>(
      context,
    ).isLightTheme(context);
    AuthService _gAuth = AuthService();
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      appBar: AppBar(
        title: Text(
          user!.userName,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w100),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              //implement sign out here
              await signOutUser(user!.email);
              try {
                await FirebaseAuth.instance.signOut();
                print("Firebase signout successful");
              } catch (e) {
                print('Firebase sign out error: $e');
              }

              await FirebaseMessaging.instance.deleteToken();
              await _gAuth.signOutIfGoogle();

              await messageSub?.cancel();
              messageSub = null;

              await messageSubBack?.cancel();
              messageSubBack = null;

              if (!mounted) return;

              try {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                  (route) => false,
                );
              } catch (e, stack) {
                print("Navigator error: $e");
                print(stack);
              }

              showSnackBar(isLightTheme, 'Signed out successfully');
            },
            icon: Icon(
              FontAwesomeIcons.arrowRightFromBracket,
              color: isLightTheme ? Colors.white : Colors.green.shade600,
            ),
          ),
        ],
      ),
      body: profileSettings(),
    );
  }

  Widget profileSettings() {
    //return Center(
    /*child:*/
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3),
              margin: EdgeInsets.only(left: 20, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color:
                    isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child:
                    widget.user!.profileImgUrl! != ''
                        ? Image.network(
                          widget.user!.profileImgUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                        : Image.asset(
                          'Images/defProfile.jpg',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
              ),
            ),
            Text(
              widget.user!.name,
              style: GoogleFonts.comfortaa(
                color: isLightTheme ? Colors.black : Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 5),
            if (widget.user!.isVerified)
              Tooltip(
                message: 'Your account is verified',
                child: Container(
                  decoration: BoxDecoration(
                    color: isLightTheme ? Colors.white : darkBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Image.asset(
                    isLightTheme ? 'Images/ver.png' : 'Images/verDark.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
        Center(
          child: Text(
            'User ID: ${user!.userID}',
            style: GoogleFonts.comfortaa(
              color: isLightTheme ? Colors.black : Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              margin: EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color:
                    isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Created courses: ${getCourseCreatedNum(user!.email)}',
                style: GoogleFonts.comfortaa(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isLightTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
            Expanded(child: const SizedBox(width: 5)),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              margin: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color:
                    isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Enrolled courses: ${getEnrolledCoursesNum(user!.userID)}',
                style: GoogleFonts.comfortaa(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isLightTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              margin: EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color:
                    isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Shared posts: ${getPostCreatedNum(user!.email)}',
                style: GoogleFonts.comfortaa(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isLightTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
            Expanded(child: const SizedBox(width: 5)),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              margin: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color:
                    isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Shared comments: ${getCommentsCreatedNum(user!.email)}',
                style: GoogleFonts.comfortaa(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isLightTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: 350,
          decoration: BoxDecoration(
            color: isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //const SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Email: ',
                          style: GoogleFonts.comfortaa(
                            fontSize: 18,
                            color: isLightTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          widget.user!.email,
                          style: GoogleFonts.comfortaa(
                            fontSize:
                                (user!.email.length > 25)
                                    ? MediaQuery.of(context).size.width / 30
                                    : 18,
                            fontWeight: FontWeight.bold,
                            color: isLightTheme ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Phone number: ',
                          style: GoogleFonts.comfortaa(
                            fontSize: 20,
                            color: isLightTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(width: 10),
                        (widget.user!.phoneNum != null ||
                                widget.user!.phoneNum != '')
                            ? Text(
                              widget.user!.phoneNum!,
                              style: GoogleFonts.comfortaa(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isLightTheme ? Colors.white : Colors.black,
                              ),
                            )
                            : Text(
                              'Not available',
                              style: GoogleFonts.comfortaa(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isLightTheme ? Colors.white : Colors.black,
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
              //const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              EditProfile(theme: isLightTheme, user: user!),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isLightTheme ? Colors.white : darkBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.penToSquare,
                        size: 30,
                        color:
                            isLightTheme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Edit Profile data',
                        style: GoogleFonts.comfortaa(
                          fontSize: 20,
                          color:
                              isLightTheme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              InkWell(
                onTap: () {
                  showAndApplyThemeChoiceDialog(context);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isLightTheme ? Colors.white : darkBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        isLightTheme
                            ? FontAwesomeIcons.moon
                            : FontAwesomeIcons.sun,
                        size: 30,
                        color:
                            isLightTheme ? Colors.blue.shade600 : Colors.yellow,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Change theme',
                        style: GoogleFonts.comfortaa(
                          fontSize: 20,
                          color:
                              isLightTheme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      //),
    );
  }

  Future<void> showAndApplyThemeChoiceDialog(BuildContext context) async {
    final mobileThemeProvider = Provider.of<MobileThemeProvider>(
      context,
      listen: false,
    );
    AppThemeMode selectedMode = mobileThemeProvider.selectedMode;

    AppThemeMode? result = await showDialog<AppThemeMode>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    AppThemeMode.values.map((mode) {
                      String label;
                      switch (mode) {
                        case AppThemeMode.light:
                          label = 'Light Theme';
                          break;
                        case AppThemeMode.dark:
                          label = 'Dark Theme';
                          break;
                        case AppThemeMode.system:
                          label = 'Same as System';
                          break;
                      }
                      return RadioListTile<AppThemeMode>(
                        title: Text(label),
                        value: mode,
                        groupValue: selectedMode,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedMode = value;
                            });
                          }
                        },
                      );
                    }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed:
                  () =>
                      Navigator.pop(context, selectedMode), // OK with selection
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      mobileThemeProvider.setTheme(result);
    }
  }

  String _getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System Default';
    }
  }

  void showSnackBar(bool barTheme, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 20,
        showCloseIcon: true,
        closeIconColor: barTheme ? Colors.white : Colors.green.shade600,
        backgroundColor: barTheme ? Colors.blue.shade600 : Colors.black,
        content: Center(
          child: Text(
            text,
            style: GoogleFonts.comfortaa(
              fontSize: kIsWeb ? 30 : 20,
              color: barTheme ? Colors.white : Colors.green.shade600,
            ),
          ),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> signOutUser(String email) async {
    final Map<String, dynamic> dataToSend = {
      'email': email,
      'isSignedIn': false,
    };
    final url = Uri.parse('http://$serverUrl:3000/user/signout');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}
