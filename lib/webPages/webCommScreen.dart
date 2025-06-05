import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudinary_url_gen/transformation/source/source.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hardwaresimu_software_graduation_project/chatComponents.dart';
import 'package:hardwaresimu_software_graduation_project/comments.dart';
import 'package:hardwaresimu_software_graduation_project/courseVideo.dart';
import 'package:hardwaresimu_software_graduation_project/edit_profile.dart';
import 'package:hardwaresimu_software_graduation_project/enrollment.dart';
import 'package:hardwaresimu_software_graduation_project/main.dart';
import 'package:hardwaresimu_software_graduation_project/themeMobile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mime/mime.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/courses.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/signIn.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/signUp.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/posts.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:web/web.dart' as web;
import 'package:web_smooth_scroll/web_smooth_scroll.dart';
import 'package:collection/collection.dart';
import 'package:hardwaresimu_software_graduation_project/downloadServices/downloadPicker.dart';

class WebCommScreen extends StatefulWidget {
  final bool isSignedIn;
  final myUser.User? user;
  const WebCommScreen({super.key, required this.isSignedIn, this.user});

  @override
  State<WebCommScreen> createState() =>
      _WebCommScreenState(isSignedIn: this.isSignedIn, user: this.user);
}

class _WebCommScreenState extends State<WebCommScreen> {
  String _imgUrl = '';
  File? _image;
  Uint8List? _imageBytes;

  bool isImagePost = false;
  bool isCourseFeed = false;
  bool isCourseSubFeedClicked = false;

  final _formKey = GlobalKey<FormState>();
  final ScrollController _controller = ScrollController();

  bool isSignedIn;
  myUser.User? user;
  _WebCommScreenState({required this.isSignedIn, this.user});
  List<myUser.User> _users = [];

  String initFeed =
      kIsWeb
          ? 'Choose a course subfeed from the list on the left'
          : 'Choose a course subfeed from the list above first';
  String newPostText = '';
  String newCommentText = '';

  Widget postsList = const SizedBox();
  List<Post> dbPostsList = [];
  List<Post> filteredPosts = [];
  List<PostFile> dbPostFilesList = [];

  List<String> coursesTitles = [];
  List<Course> dbCoursesList = [];

  List<Comment> dbCommentsList = [];
  List<Comment> postComments = [];

  List<Enrollment> dbEnrollmentList = [];

  List<Course> enrolledCourses = [];

  int newCommentID = 0;

  int courseIndex = 0;
  int newPostID = 0;
  int newPostFileID = 0;

  List<PlatformFile> pickedFiles = [];
  bool isFilePicked = false;
  List<String> pickedFileNames = [];

  bool isLoading = true;

  Future<void> _fetchAllDB() async {
    _fetchUsers();
    _fetchPosts();
    _fetchCourses();
    _fetchComments();
    _fetchEnrollment();
    _fetchPostFiles();

    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      isLoading = false;
    });
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
      if (dbCommentsList.isNotEmpty) {
        final maxID = dbCommentsList
            .map((c) => c.commentID)
            .reduce((a, b) => a > b ? a : b);
        newCommentID = maxID + 1;
      } else {
        newCommentID = 1;
      }
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
      if (dbPostsList.isNotEmpty) {
        final maxID = dbPostsList
            .map((c) => c.postID)
            .reduce((a, b) => a > b ? a : b);
        newPostID = maxID + 1;
      } else {
        newPostID = 1; // start from 1 if list is empty
      }
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> _fetchPostFiles() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/postFiles'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbPostFilesList = json.map((item) => PostFile.fromJson(item)).toList();
      });
      if (dbPostFilesList.isNotEmpty) {
        final maxID = dbPostFilesList
            .map((c) => c.id)
            .reduce((a, b) => a > b ? a : b);
        newPostFileID = maxID + 1;
      } else {
        newPostFileID = 1; // start from 1 if list is empty
      }
    } else {
      throw Exception('Failed to load post files');
    }
  }

  myUser.User getCourseCreator(String courseCreatorEmail) {
    return _users.firstWhere((user) => user.email == courseCreatorEmail);
  }

  int getCourseEnrolls(Course c) {
    return dbEnrollmentList
        .where((e) => e.CourseID == c.courseID)
        .toList()
        .length;
  }

  Future<void> _fetchCourses() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/courses'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbCoursesList = json.map((item) => Course.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load courses');
    }
    for (int i = 0; i < dbCoursesList.length; i++) {
      coursesTitles.add(dbCoursesList[i].title);
    }
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/users'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        _users = json.map((item) => myUser.User.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load users');
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
      enrolledCourses = getEnrolledCourses(user!.userID);
    } else {
      throw Exception('Failed to load enrollment list');
    }
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _fetchAllDB();
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme =
        kIsWeb
            ? context.watch<SysThemes>().isLightTheme
            : Provider.of<MobileThemeProvider>(context).isLightTheme(context);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
        ),
      );
    }

    return Scaffold(
      drawer:
          !kIsWeb
              ? Drawer(
                backgroundColor: isLightTheme ? Colors.white : darkBg,

                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        Visibility(
                          visible: isCourseSubFeedClicked,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                isImagePost = false;
                              });
                              newPostText = '';
                              if (kIsWeb) {
                                showCreatePost(isLightTheme, context);
                              } else {
                                Navigator.pop(context);
                                showCreatePost(isLightTheme, context);
                              }
                            },
                            icon: Icon(
                              Icons.add,
                              color: isLightTheme ? Colors.white : Colors.black,
                            ),
                            label: Text(
                              "Create post",
                              style: GoogleFonts.comfortaa(
                                color:
                                    isLightTheme ? Colors.white : Colors.black,
                                fontSize: kIsWeb ? 25 : 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isLightTheme
                                      ? Colors.blue.shade600
                                      : Colors.green.shade600,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(12),
                          child: Wrap(
                            children: [
                              if (enrolledCourses.isNotEmpty)
                                Text(
                                  textAlign: TextAlign.center,
                                  'Choose a course subfeed from below',
                                  style: GoogleFonts.comfortaa(
                                    fontWeight: FontWeight.w900,
                                    fontSize: kIsWeb ? 20 : 15,
                                    color:
                                        isLightTheme
                                            ? Colors.blue.shade600
                                            : Colors.green.shade600,
                                  ),
                                ),
                              if (enrolledCourses.isEmpty)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        'You haven\'t enrolled in any course yet, join one first!',
                                        style: GoogleFonts.comfortaa(
                                          fontWeight: FontWeight.w900,
                                          fontSize: kIsWeb ? 20 : 15,
                                          color:
                                              isLightTheme
                                                  ? Colors.blue.shade600
                                                  : Colors.green.shade600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: kIsWeb ? 80 : 40),
                                    Image.asset('Images/404.png'),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        ScrollConfiguration(
                          behavior: ScrollConfiguration.of(
                            context,
                          ).copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            child: Column(
                              children: coursesSubFeedsButtons(
                                isLightTheme,
                                coursesTitles.length,
                                coursesTitles,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : const SizedBox(),
      appBar:
          !kIsWeb
              ? AppBar(
                iconTheme: IconThemeData(
                  color: isLightTheme ? Colors.white : Colors.green.shade600,
                  size: 30,
                ),
                title: Text(
                  'My feed',
                  style: GoogleFonts.comfortaa(fontSize: 25),
                ),
              )
              : null,
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      body: Center(
        child:
            !isSignedIn
                ? Container(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 600,
                        height: 600,
                        child: Image.asset(
                          isLightTheme
                              ? 'Images/connect2.png'
                              : 'Images/connectdark.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      Text(
                        'Connect, share and  learn with others',
                        style: GoogleFonts.comfortaa(
                          fontSize: 40,
                          color: isLightTheme ? Colors.black : Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => WebApp(
                                    isSignedIn: false,
                                    user: globalSignedUser,
                                  ),
                            ),
                          );
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => SignupPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(25),
                          backgroundColor:
                              isLightTheme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                        child: Text(
                          'Register now',
                          style: GoogleFonts.comfortaa(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'or',
                        style: GoogleFonts.comfortaa(
                          fontSize: 20,
                          color:
                              isLightTheme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => WebApp(
                                    isSignedIn: false,
                                    user: myUser.User(
                                      userID: 0,
                                      name: '',
                                      userName: '',
                                      email: '',
                                      phoneNum: '',
                                      password: '',
                                      profileImgUrl: '',
                                      isSignedIn: false,
                                      isAdmin: false,
                                      isVerified: false,
                                    ),
                                  ),
                            ),
                          );
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => SigninPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Login here',
                          style: GoogleFonts.comfortaa(
                            color:
                                isLightTheme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                isLightTheme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //-----------------------------Create post and courses subfeeds section---------------------------
                    if (kIsWeb)
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Visibility(
                              visible: isCourseSubFeedClicked,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    isImagePost = false;
                                  });
                                  newPostText = '';
                                  showCreatePost(isLightTheme, context);
                                },
                                icon: Icon(
                                  Icons.add,
                                  color:
                                      isLightTheme
                                          ? Colors.white
                                          : Colors.black,
                                ),
                                label: Text(
                                  "Create post",
                                  style: GoogleFonts.comfortaa(
                                    color:
                                        isLightTheme
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 25,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isLightTheme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(12),
                              child: Wrap(
                                children: [
                                  if (enrolledCourses.isNotEmpty)
                                    Text(
                                      'Choose a course subfeed from below',
                                      style: GoogleFonts.comfortaa(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
                                        color:
                                            isLightTheme
                                                ? Colors.blue.shade600
                                                : Colors.green.shade600,
                                      ),
                                    ),
                                  if (enrolledCourses.isEmpty)
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            'You haven\'t enrolled in any course yet, join one first!',
                                            style: GoogleFonts.comfortaa(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 20,
                                              color:
                                                  isLightTheme
                                                      ? Colors.blue.shade600
                                                      : Colors.green.shade600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 80),
                                        Image.asset('Images/404.png'),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            ScrollConfiguration(
                              behavior: ScrollConfiguration.of(
                                context,
                              ).copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: coursesSubFeedsButtons(
                                    isLightTheme,
                                    coursesTitles.length,
                                    coursesTitles,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (kIsWeb)
                      VerticalDivider(
                        thickness: 3,
                        color:
                            isLightTheme ? Colors.blue.shade600 : Colors.black,
                      ),
                    //-------------------------------------------------------------------------------------
                    Expanded(
                      flex: 6,

                      child: Container(
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: kIsWeb ? 80 : 40,
                              ),
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(
                                  context,
                                ).copyWith(scrollbars: false),
                                child: WebSmoothScroll(
                                  scrollSpeed: 3.2,
                                  controller: _controller,
                                  child: SingleChildScrollView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    controller: _controller,
                                    child: Visibility(
                                      visible: isCourseFeed,
                                      child: SizedBox(
                                        height:
                                            kIsWeb
                                                ? MediaQuery.of(
                                                  context,
                                                ).size.height
                                                : 580,
                                        width: 700,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ListView.separated(
                                                itemCount: filteredPosts.length,
                                                separatorBuilder:
                                                    (_, __) => const SizedBox(
                                                      height: 10,
                                                    ),
                                                itemBuilder:
                                                    (
                                                      context,
                                                      index,
                                                    ) => buildPost(
                                                      isLightTheme,
                                                      filteredPosts[index],
                                                      index,
                                                      () async {
                                                        final postToDelete =
                                                            filteredPosts[index];

                                                        setState(() {
                                                          filteredPosts
                                                              .removeAt(index);
                                                          dbPostsList
                                                              .removeWhere(
                                                                (p) =>
                                                                    p.postID ==
                                                                    postToDelete
                                                                        .postID,
                                                              );
                                                        });

                                                        await _submitDeletePost(
                                                          postToDelete,
                                                        );

                                                        final postFiles =
                                                            getPostFiles(
                                                              postToDelete,
                                                            );

                                                        await Future.wait(
                                                          postFiles.map(
                                                            (file) =>
                                                                deletePostFile(
                                                                  file.fileName,
                                                                ),
                                                          ),
                                                        );

                                                        //await deletePostFile(
                                                        //  getPostFiles(
                                                        //    postToDelete,
                                                        //  ),
                                                        //);

                                                        await _fetchAllDB();
                                                      },
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: !kIsWeb ? 10 : 0,
                              ),
                              height:
                                  kIsWeb
                                      ? 80
                                      : initFeed ==
                                          'Choose a course subfeed from the list above first'
                                      ? 100
                                      : 30,
                              alignment: Alignment.center,
                              //child: Expanded(
                              child: Text(
                                textAlign:
                                    !kIsWeb
                                        ? TextAlign.center
                                        : TextAlign.start,
                                initFeed,
                                style: GoogleFonts.comfortaa(
                                  fontSize: kIsWeb ? 28 : 22,
                                  color:
                                      isLightTheme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                              ),
                              //),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //------------------------------------------------------------------------------------
                    if (kIsWeb) SizedBox(width: 20),
                    if (kIsWeb)
                      VerticalDivider(
                        thickness: 3,
                        color:
                            isLightTheme ? Colors.blue.shade600 : Colors.black,
                      ),
                    kIsWeb && isCourseSubFeedClicked
                        ? Expanded(
                          flex: 4,
                          child: chatComps(
                            user: user,
                            isLightTheme: isLightTheme,
                            selectedCourse: dbCoursesList[courseIndex],
                          ),
                        )
                        : kIsWeb
                        ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              initFeed,
                              style: GoogleFonts.comfortaa(
                                fontSize: kIsWeb ? 20 : 22,
                                color:
                                    isLightTheme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                              ),
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),
                  ],
                ),
      ),
    );
  }

  List<PostFile> getPostFiles(Post x) {
    return dbPostFilesList.where((file) => file.postID == x.postID).toList();
  }

  List<Course> getEnrolledCourses(int userId) {
    final enrolledCourseIds =
        dbEnrollmentList
            .where((enrollment) => enrollment.userID == userId)
            .map((enrollment) => enrollment.CourseID)
            .toSet();

    return dbCoursesList
        .where((course) => enrolledCourseIds.contains(course.courseID))
        .toList();
  }

  List<Widget> coursesSubFeedsButtons(
    bool theme,
    int count,
    List<String> coursesTitles,
  ) {
    // Get only the courses the user is enrolled in
    enrolledCourses = getEnrolledCourses(user!.userID);

    if (dbCoursesList.isNotEmpty) {
      return List.generate(dbCoursesList.length * 2 - 1, (index) {
        if (index.isEven) {
          final buttonIndex = index ~/ 2;
          final course = dbCoursesList[buttonIndex];

          final isEnrolled = enrolledCourses.any(
            (enrolled) => enrolled.courseID == course.courseID,
          );

          if (!isEnrolled) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            width: 350,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    theme ? Colors.blue.shade600 : Colors.green.shade600,
                padding: const EdgeInsets.all(kIsWeb ? 20 : 8),
              ),
              onPressed: () {
                setState(() {
                  isCourseSubFeedClicked = true;
                  courseIndex = buttonIndex;
                  filteredPosts =
                      dbPostsList
                          .where((post) => post.courseID == course.courseID)
                          .toList();
                  if (filteredPosts.isNotEmpty) {
                    isCourseFeed = true;
                    initFeed = 'Scroll through your feed here';
                  } else {
                    isCourseFeed = false;
                    initFeed = 'This subfeed is empty';
                  }
                });
                if (!kIsWeb) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                textAlign: TextAlign.center,
                course.title, // No need to use coursesTitles anymore
                style: GoogleFonts.comfortaa(
                  color: theme ? Colors.white : Colors.black,
                  fontSize: kIsWeb ? 20 : 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } else {
          return const SizedBox(height: kIsWeb ? 10 : 5);
        }
      });
    } else {
      return [];
    }
  }

  //void showCourseFeed(int courseID, int postCourseID) {}

  Future<bool?> showAddComment(bool theme, BuildContext context, Post post) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: theme ? Colors.white : Colors.black,
              content: Container(
                width: 600,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a new comment to this post',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            style: GoogleFonts.comfortaa(
                              color: theme ? Colors.black : Colors.white,
                            ),
                            decoration: InputDecoration(
                              labelText: "Write your comment here",
                              labelStyle: GoogleFonts.comfortaa(
                                color:
                                    theme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                              ),
                            ),
                            maxLines: 5,
                            onChanged: (value) => newCommentText = value,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(12),
                              backgroundColor:
                                  theme
                                      ? Colors.blue.shade600
                                      : Colors.green.shade600,
                            ),
                            onPressed: () async {
                              final newComment = Comment(
                                createdAt: DateTime.now(),
                                commentID: newCommentID++,
                                postID: post.postID,
                                userEmail: user!.email,
                                description: newCommentText,
                              );

                              dbCommentsList.insert(0, newComment);

                              await _submitCreateComment(newComment);
                              await _fetchAllDB();

                              Navigator.pop(context, true);
                            },
                            child: Text(
                              "Add comment",
                              style: GoogleFonts.comfortaa(
                                color: theme ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Comment> getCommentsForPost(Post post) {
    return dbCommentsList
        .where((comment) => comment.postID == post.postID)
        .toList();
  }

  Widget buildComment(
    bool theme,
    Comment comment,
    Post post,
    int index,
    VoidCallback onDelete,
  ) {
    final author = getCommentAuthor(comment);
    final isGoneAuthor = !isCourseEnrolled(author, dbCoursesList[courseIndex]);
    if (post.postID == comment.postID) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: theme ? Colors.white : darkBg,
          ),
          alignment: Alignment.centerLeft,
          width: 600,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child:
                        (author == null ||
                                author.profileImgUrl == null ||
                                author.profileImgUrl!.isEmpty ||
                                author.profileImgUrl == '' ||
                                author.profileImgUrl == 'defU' ||
                                isGoneAuthor)
                            ? Tooltip(
                              message:
                                  (isGoneAuthor)
                                      ? 'Previous enrollee'
                                      : author!.userName,
                              textStyle: GoogleFonts.comfortaa(
                                color: theme ? Colors.white : darkBg,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                              ),
                              child: Image.asset(
                                'Images/defProfile.jpg',
                                width: kIsWeb ? 80 : 60,
                                height: kIsWeb ? 80 : 60,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Tooltip(
                              message:
                                  (isGoneAuthor)
                                      ? 'Previous enrollee'
                                      : author!.userName,
                              textStyle: GoogleFonts.comfortaa(
                                color: theme ? Colors.white : darkBg,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                              ),
                              child: CachedNetworkImage(
                                //image.network
                                imageUrl: author.profileImgUrl!,
                                width: kIsWeb ? 80 : 40,
                                height: kIsWeb ? 80 : 40,
                                fit: BoxFit.cover,
                                errorWidget:
                                    (context, error, stackTrace) => Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color:
                                          theme
                                              ? Colors.grey.shade200
                                              : Colors.grey.shade600,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 55,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    (!isGoneAuthor)
                        ? '${author!.userName}\n${author.name}'
                        : 'Previous enrollee',
                    style: GoogleFonts.comfortaa(
                      fontSize: kIsWeb ? 20 : 15,
                      fontWeight: FontWeight.bold,
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (author != null && author.isVerified)
                    Tooltip(
                      message:
                          'This mark proves that ${author.name} is a verified lecturer and provided the required material for it and got approved by the admins',
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme ? Colors.white : darkBg,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Image.asset(
                          theme ? 'Images/ver.png' : 'Images/verDark.png',
                          width: kIsWeb ? 30 : 20,
                          height: kIsWeb ? 30 : 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  const SizedBox(width: 3),
                  if (author!.userID ==
                      getCourseCreator(
                        dbCoursesList[courseIndex].usersEmails,
                      ).userID)
                    Tooltip(
                      message: '${author.name} is this course creator',
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: theme ? darkBg : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          Icons.create_rounded,
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                          size: kIsWeb ? 25 : 10,
                        ),
                      ),
                    ),

                  Expanded(child: SizedBox(width: 10)),
                  if (author!.email == user!.email && !isGoneAuthor && kIsWeb)
                    Tooltip(
                      message: 'Delete comment',
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          bool? confirmed = await showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text('Confirm'),
                                  content: Text(
                                    'Are you sure you want to delete comment?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirmed!) {
                            onDelete();
                          }
                        },
                        label: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors:
                                  theme
                                      ? [
                                        Colors.blue.shade600,
                                        Colors.green.shade600,
                                      ]
                                      : [
                                        Colors.green.shade600,
                                        Colors.blue.shade600,
                                      ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              FontAwesomeIcons.trash,
                              size: kIsWeb ? 20 : 15,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (author!.email == user!.email && !isGoneAuthor && !kIsWeb)
                    Tooltip(
                      message: 'Delete comment',
                      child: InkWell(
                        onTap: () async {
                          bool? confirmed = await showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text('Confirm'),
                                  content: Text(
                                    'Are you sure you want to delete comment?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirmed!) {
                            onDelete();
                          }
                        },
                        child: Icon(Icons.delete, color: Colors.red, size: 20),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: kIsWeb ? 15 : 10),
              Wrap(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      comment.description,
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        fontSize: kIsWeb ? 20 : 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  void showCreatePost(bool theme, BuildContext context) {
    _imgUrl = '';
    Uint8List? localImageBytes;
    File? localImage;

    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: theme ? Colors.white : Colors.black,
              content: Container(
                width: 600,
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Tooltip(
                            message: 'Upload an image',
                            child: IconButton(
                              onPressed: () async {
                                if (kIsWeb) {
                                  _pickImageWeb((bytes) async {
                                    setState(() {
                                      localImageBytes = bytes;
                                      isImagePost = true;
                                    });
                                    _imageBytes = bytes;
                                    await _uploadImage();
                                  });
                                } else {
                                  File? pickedImg = await _showImagePicker(
                                    theme,
                                  );
                                  if (pickedImg != null) {
                                    setState(() {
                                      localImage = pickedImg;
                                      _image = localImage;
                                      isImagePost = true;
                                    });
                                    await _uploadImage();
                                  }
                                }
                              },
                              icon: Icon(
                                FontAwesomeIcons.image,
                                color:
                                    theme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                              ),
                            ),
                          ),
                          SizedBox(width: kIsWeb ? 8 : 1),
                          Tooltip(
                            message: 'Upload a txt file',
                            child: IconButton(
                              onPressed: () async {
                                _pickFile(theme, setState);
                              },
                              icon: Icon(
                                FontAwesomeIcons.fileArrowUp,
                                color:
                                    theme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(width: kIsWeb ? 8 : 5),
                          Text(
                            'Add a new post',
                            style: TextStyle(
                              fontSize: kIsWeb ? 22 : 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme
                                      ? Colors.blue.shade600
                                      : Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              style: GoogleFonts.comfortaa(
                                color: theme ? Colors.black : Colors.white,
                              ),
                              decoration: InputDecoration(
                                labelText: "What's on your mind?",
                                labelStyle: GoogleFonts.comfortaa(
                                  color:
                                      theme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                              ),
                              maxLines: 5,
                              onChanged: (value) => newPostText = value,
                            ),

                            const SizedBox(height: 20),
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.all(12),
                                    backgroundColor:
                                        theme
                                            ? Colors.blue.shade600
                                            : Colors.green.shade600,
                                  ),
                                  onPressed: () async {
                                    if (newPostText.isNotEmpty) {
                                      final loaderContext = context;
                                      showDialog(
                                        context: loaderContext,
                                        barrierDismissible: false,
                                        builder:
                                            (context) => Center(
                                              child: CircularProgressIndicator(
                                                color:
                                                    theme
                                                        ? Colors.blue.shade600
                                                        : Colors.green.shade600,
                                              ),
                                            ),
                                      );
                                      if (pickedFiles.isNotEmpty &&
                                          isFilePicked) {
                                        await uploadAllPickedFiles();
                                      }
                                      Post? newPost;
                                      setState(() {
                                        newPost = Post(
                                          createdAt: DateTime.now(),
                                          postID: newPostID++,
                                          userEmail: user!.email,
                                          courseID:
                                              dbCoursesList[courseIndex]
                                                  .courseID,
                                          description: newPostText,
                                          imageUrl: _imgUrl,
                                          likesCount: 0,
                                        );
                                        dbPostsList.insert(0, newPost!);

                                        filteredPosts =
                                            dbPostsList
                                                .where(
                                                  (post) =>
                                                      post.courseID ==
                                                      dbCoursesList[courseIndex]
                                                          .courseID,
                                                )
                                                .toList();

                                        if (filteredPosts.isNotEmpty) {
                                          isCourseFeed = true;
                                          initFeed =
                                              'Scroll through your feed here';
                                        } else {
                                          isCourseFeed = false;
                                          initFeed = 'This subfeed is empty';
                                        }
                                      });

                                      await _submitCreatePost(newPost!);

                                      if (isFilePicked &&
                                          (webFileName != null ||
                                              mobileFileName != null)) {
                                        // await _submitCreatePost(newPost!);
                                        kIsWeb
                                            ? await _submitAddPostFile(
                                              PostFile(
                                                id: newPostFileID++,
                                                postID: newPostID - 1,
                                                userID: user!.userID,
                                                fileUrl: fileUrl,
                                                fileName: webFileName ?? '',
                                              ),
                                            )
                                            : await _submitAddPostFile(
                                              PostFile(
                                                id: newPostFileID++,
                                                postID: newPostID - 1,
                                                userID: user!.userID,
                                                fileUrl: fileUrl,
                                                fileName: mobileFileName ?? '',
                                              ),
                                            );
                                      }

                                      await Future.delayed(
                                        Duration(seconds: 2),
                                      );

                                      Navigator.of(
                                        loaderContext,
                                        rootNavigator: true,
                                      ).pop();

                                      Navigator.pop(context);
                                      setState(() {
                                        setImagePost(false);
                                      });

                                      if (mounted) {
                                        setState(() {
                                          isFilePicked = false;
                                          pickedFiles.clear();
                                          pickedFileNames.clear();
                                        });
                                      }

                                      showSnackBar(
                                        theme,
                                        'Post added successfully',
                                      );

                                      await _fetchAllDB();
                                    } else {
                                      setState(() {
                                        showSnackBar(
                                          theme,
                                          'Please enter some text first',
                                        );
                                      });
                                    }
                                  },
                                  child: Text(
                                    "Submit post",
                                    style: GoogleFonts.comfortaa(
                                      color:
                                          theme ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 25),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.all(12),
                                    backgroundColor:
                                        theme
                                            ? Colors.blue.shade600
                                            : Colors.green.shade600,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      setImagePost(false);
                                    });
                                    //todo : if uploading doesnt work anymore just remove the if statement although it might break the mobile app.
                                    if (mounted) {
                                      setState(() {
                                        isFilePicked = false;
                                      });
                                    }
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.comfortaa(
                                      color:
                                          theme ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isFilePicked && pickedFiles.isNotEmpty)
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: pickedFiles.length,
                            itemBuilder: (context, index) {
                              final file = pickedFiles[index];
                              return Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.fileLines,
                                      color: theme ? Colors.white : darkBg,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 80,
                                      ),
                                      child: Text(
                                        file.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.comfortaa(
                                          color: theme ? Colors.white : darkBg,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          pickedFiles.removeAt(index);
                                          isFilePicked = pickedFiles.isNotEmpty;
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: theme ? Colors.white : darkBg,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      if (localImageBytes != null && kIsWeb)
                        Center(
                          child: Container(
                            child: Image.memory(localImageBytes!, width: 500),
                          ),
                        ),
                      if (localImage != null && !kIsWeb)
                        Center(
                          child: Container(child: Image.file(localImage!)),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> uploadAllPickedFiles() async {
    if (pickedFiles.isEmpty) {
      print('⚠️ No files to upload.');
      return;
    }

    final storageRef = supabase.storage.from('circuit-academy-files');

    for (PlatformFile f in pickedFiles) {
      try {
        String originalName = f.name;
        String baseName =
            originalName.contains('.')
                ? originalName.substring(0, originalName.lastIndexOf('.'))
                : originalName;
        String extension =
            originalName.contains('.')
                ? originalName.substring(originalName.lastIndexOf('.'))
                : '';
        String fileName = originalName;
        String storagePath = 'PostsFiles/$fileName';

        // 🔍 Check for existing files and increment suffix
        int count = 1;
        List<FileObject> existingFiles = await storageRef.list(
          path: 'PostsFiles',
        );
        List<String> existingNames = existingFiles.map((f) => f.name).toList();

        while (existingNames.contains(fileName)) {
          fileName = '$baseName($count)$extension';
          storagePath = 'PostsFiles/$fileName';
          count++;
        }

        // 💻 Upload logic
        if (kIsWeb) {
          if (f.bytes == null) {
            print('❌ No bytes found for $originalName');
            continue;
          }

          await storageRef.uploadBinary(storagePath, f.bytes!);
          final url = storageRef.getPublicUrl(storagePath);
          fileUrl = url;
          webFileName = fileName;
          print('✅ Uploaded (Web): $fileName\nURL: $url');
        } else {
          if (f.path == null) {
            print('❌ No path for $originalName');
            continue;
          }

          final localFile = File(f.path!);
          await storageRef.upload(storagePath, localFile);
          final url = storageRef.getPublicUrl(storagePath);
          fileUrl = url;
          mobileFileName = fileName;
          print('✅ Uploaded (Mobile): $fileName\nURL: $url');
        }
      } catch (e) {
        print('❌ Upload failed for ${f.name}: $e');
      }
    }
  }

  /*Future<void> uploadAllPickedFiles() async {
    if (pickedFiles.isEmpty) {
      print('⚠️ No files to upload.');
      return;
    }

    for (PlatformFile f in pickedFiles) {
      try {
        final fileName = f.name;
        final storageRef = supabase.storage.from('circuit-academy-files');

        if (kIsWeb) {
          if (f.bytes == null) {
            print('❌ No bytes found for $fileName');
            continue;
          }

          await storageRef.uploadBinary('PostsFiles/$fileName', f.bytes!);

          final url = storageRef.getPublicUrl('PostsFiles/$fileName');
          fileUrl = url;
          webFileName = fileName;
          print('✅ Uploaded (Web): $fileName\nURL: $url');
        } else {
          if (f.path == null) {
            print('❌ No path for $fileName');
            continue;
          }

          final localFile = File(f.path!);
          await storageRef.upload('PostsFiles/$fileName', localFile);

          final url = storageRef.getPublicUrl('PostsFiles/$fileName');
          fileUrl = url;
          mobileFileName = fileName;
          print('✅ Uploaded (Mobile): $fileName\nURL: $url');
        }
      } catch (e) {
        print('❌ Upload failed for ${f.name}: $e');
      }
    }
  }*/

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageWeb(Function(Uint8List) onImagePicked) async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      Uint8List bytes = await picked.readAsBytes();
      onImagePicked(bytes);
    }
  }

  // Future<void> downloadFileViaBlob(String url, String fileName) async {
  //   try {
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final bytes = response.bodyBytes;

  //       final blob = html.Blob([bytes]);
  //       final blobUrl = html.Url.createObjectUrlFromBlob(blob);

  //       final anchor =
  //           html.AnchorElement(href: blobUrl)
  //             ..download = fileName
  //             ..style.display = 'none';

  //       html.document.body!.append(anchor);
  //       anchor.click();
  //       anchor.remove();

  //       html.Url.revokeObjectUrl(blobUrl);
  //     } else {
  //       print('Failed to download file: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Download error: $e');
  //   }
  // }

  Future<File?> _showImagePicker(bool theme) async {
    final pickedImage = await showModalBottomSheet<File>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: theme ? Colors.blueAccent : Colors.white,
                ),
                title: const Text("Take Photo"),
                onTap: () async {
                  final img = await _pickImage(ImageSource.camera);
                  Navigator.pop(context, img);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: theme ? Colors.blueAccent : Colors.white,
                ),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  final img = await _pickImage(ImageSource.gallery);
                  Navigator.pop(context, img);
                },
              ),
            ],
          ),
        );
      },
    );

    return pickedImage;
  }

  void setImagePost(bool x) {
    setState(() {
      isImagePost = x;
    });
  }

  Future<File?> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  String optimizeCloudinaryUrl(String url) {
    final uploadPattern = RegExp(r'(\/upload\/)(?!.*f_auto)');

    if (uploadPattern.hasMatch(url)) {
      return url.replaceFirst(uploadPattern, '/upload/f_auto/q_auto/');
    }

    return url;
  }

  Future<void> _uploadImage() async {
    final mimeType =
        kIsWeb
            ? lookupMimeType('', headerBytes: _imageBytes)
            : lookupMimeType(_image!.path);
    final mediaType = mimeType?.split('/');
    final fileExtension = mediaType != null ? mediaType.last : 'png';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dfjtstpjc/upload',
    ); //old:ds565huxe
    final http.MultipartRequest? request;
    if (!kIsWeb && _image != null) {
      request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = 'uploadPreset'
            ..fields['folder'] = 'postsImagesFolder'
            ..files.add(
              await http.MultipartFile.fromPath(
                'file',
                _image!.path,
                filename: 'postImageUpload.$fileExtension',
                contentType:
                    mediaType != null
                        ? MediaType(mediaType.first, mediaType.last)
                        : MediaType('image', 'png'),
              ),
            );
    } else if (_imageBytes != null) {
      request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = 'uploadPreset'
            ..fields['folder'] = 'postsImagesFolder'
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                _imageBytes!,
                filename: 'postImageUpload.$fileExtension',
                contentType:
                    mediaType != null
                        ? MediaType(mediaType.first, mediaType.last)
                        : MediaType('image', 'png'),
              ),
            );
    } else {
      request = null;
    }
    if (request != null) {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();

        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        //If the image doesn't go to server remove these comment
        //if (!mounted) return;
        setState(() {
          _imgUrl = optimizeCloudinaryUrl(jsonMap['url']);
        });
        //print(_imgUrl);
      }
    }
  }

  myUser.User? getPostAuthor(Post post) {
    return _users.firstWhereOrNull((user) => user.email == post.userEmail);
  }

  myUser.User? getCommentAuthor(Comment comment) {
    return _users.firstWhereOrNull((user) => user.email == comment.userEmail);
  }

  Container buildPost(bool theme, Post post, int index, VoidCallback onDelete) {
    final author = getPostAuthor(post);
    final bool isGoneAuthor =
        !isCourseEnrolled(author, dbCoursesList[courseIndex]);
    final commentsForPost = getCommentsForPost(post);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        //color: theme ? Colors.blue.shade600 : Colors.green.shade600,
        gradient: LinearGradient(
          colors:
              theme
                  ? [Colors.blue.shade600, Colors.green.shade600]
                  : [Colors.green.shade600, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      width: 700,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child:
                    (author == null ||
                            author.profileImgUrl == null ||
                            author.profileImgUrl!.isEmpty ||
                            author.profileImgUrl == '' ||
                            author.profileImgUrl == 'defU' ||
                            isGoneAuthor)
                        ? Tooltip(
                          textStyle: GoogleFonts.comfortaa(
                            color:
                                theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                          ),
                          decoration: BoxDecoration(
                            color: theme ? Colors.white : darkBg,
                          ),
                          message:
                              (isGoneAuthor)
                                  ? 'A previous enrollee'
                                  : author!.userName,
                          child: Image.asset(
                            'Images/defProfile.jpg',
                            width: kIsWeb ? 80 : 60,
                            height: kIsWeb ? 80 : 60,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Tooltip(
                          message:
                              (isGoneAuthor)
                                  ? 'A previous enrollee'
                                  : author!.userName,
                          textStyle: GoogleFonts.comfortaa(
                            color:
                                theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                          ),
                          decoration: BoxDecoration(
                            color: theme ? Colors.white : darkBg,
                          ),
                          child: CachedNetworkImage(
                            //image.network
                            imageUrl: author.profileImgUrl!,
                            width: kIsWeb ? 80 : 60,
                            height: kIsWeb ? 80 : 60,
                            fit: BoxFit.cover,
                            errorWidget:
                                (context, error, stackTrace) => Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color:
                                      theme
                                          ? Colors.grey.shade200
                                          : Colors.grey.shade600,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 55,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                          ),
                        ),
              ),
              const SizedBox(width: 10),
              Text(
                (author != null && !isGoneAuthor)
                    ? '${author.userName}\n${author.name}'
                    : 'Previous enrollee',
                style: GoogleFonts.comfortaa(
                  fontSize: kIsWeb ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: theme ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 5),

              if (author != null && author.isVerified)
                Tooltip(
                  message:
                      'This mark proves that ${author.name} is a verified lecturer and provided the required material for it and got approved by the admins',
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme ? Colors.white : darkBg,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Image.asset(
                      theme ? 'Images/ver.png' : 'Images/verDark.png',
                      width: kIsWeb ? 30 : 20,
                      height: kIsWeb ? 30 : 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              const SizedBox(width: 10),
              if (author!.userID ==
                  getCourseCreator(
                    dbCoursesList[courseIndex].usersEmails,
                  ).userID)
                Tooltip(
                  message: '${author.name} is this course creator',
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: theme ? Colors.white : darkBg,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(
                      Icons.create_rounded,
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                      size: kIsWeb ? 25 : 10,
                    ),
                  ),
                ),

              Expanded(child: SizedBox(width: 10)),
              if (author!.email == user!.email && !isGoneAuthor && kIsWeb)
                Tooltip(
                  message: 'Delete post',
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme ? Colors.white : darkBg,
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      bool? confirmed = await showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(
                                'Confirm post deletion',
                                style: GoogleFonts.comfortaa(
                                  color:
                                      theme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to delete post? (ALL RELATED COMMENTS WILL BE DELETED)',
                                style: GoogleFonts.comfortaa(
                                  color:
                                      theme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: Text(
                                    'No',
                                    style: GoogleFonts.comfortaa(
                                      color:
                                          theme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    'Yes',
                                    style: GoogleFonts.comfortaa(
                                      color:
                                          theme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      );
                      if (confirmed!) {
                        onDelete();
                      }
                    },
                    label: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: kIsWeb ? 20 : 0,
                        vertical: kIsWeb ? 12 : 0,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        FontAwesomeIcons.trash,
                        size: kIsWeb ? 20 : 15,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (author!.email == user!.email && !isGoneAuthor && !kIsWeb)
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                alignment: Alignment.centerRight,
                child: Tooltip(
                  message: 'Delete post',
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme ? Colors.white : darkBg,
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () async {
                      bool? confirmed = await showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(
                                'Confirm post deletion',
                                style: GoogleFonts.comfortaa(
                                  color:
                                      theme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to delete post? (ALL RELATED COMMENTS WILL BE DELETED)',
                                style: GoogleFonts.comfortaa(
                                  color:
                                      theme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: Text(
                                    'No',
                                    style: GoogleFonts.comfortaa(
                                      color:
                                          theme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    'Yes',
                                    style: GoogleFonts.comfortaa(
                                      color:
                                          theme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      );
                      if (confirmed!) {
                        onDelete();
                      }
                    },
                    label: Icon(
                      FontAwesomeIcons.trash,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              post.description,
              style: GoogleFonts.comfortaa(
                color: theme ? Colors.white : Colors.black,
                fontSize: kIsWeb ? 25 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Builder(
            builder: (context) {
              final currentPostFiles =
                  dbPostFilesList
                      .where((file) => file.postID == post.postID)
                      .toList();

              if (currentPostFiles.isEmpty) return const SizedBox.shrink();

              return SizedBox(
                width: 200,
                height: 70,
                child: ListView.builder(
                  itemCount: currentPostFiles.length,
                  itemBuilder: (context, index) {
                    final postFile = currentPostFiles[index];

                    return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme ? Colors.white : darkBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.fileLines,
                            color:
                                theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              postFile.fileName,
                              style: GoogleFonts.comfortaa(
                                color:
                                    theme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              FontAwesomeIcons.download,
                              size: 16,
                              color:
                                  theme
                                      ? Colors.blue.shade600
                                      : Colors.green.shade600,
                            ),
                            onPressed: () async {
                              //todo implement file downloading instead of opening in new tab
                              /*_launchFileUrl(
                                '${postFile.fileUrl!}?download=true',
                              );*/

                              await downloadFileFromUrl(
                                postFile.fileUrl!,
                                postFile.fileName,
                              );

                              showSnackBar(
                                theme,
                                'File downloaded to downloads file successfully.',
                              );

                              /*downloadFileViaBlob(
                                postFile.fileUrl!,
                                postFile.fileName,
                              );*/
                            },
                            tooltip: 'Download',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 5),
          Visibility(
            visible:
                (post.imageUrl != '' &&
                    dbPostsList.any(
                      (element) => element.postID == post.postID,
                    )),
            child: Container(
              padding: EdgeInsets.all(kIsWeb ? 15 : 0),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: theme ? Colors.white : darkBg,
                ),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl,
                    errorWidget:
                        (context, error, stackTrace) => Text(
                          'Could not get image',
                          style: GoogleFonts.comfortaa(color: Colors.red),
                        ),
                  ), //image.network
                ),
              ),
            ),
          ),
          Visibility(
            visible: isImagePost,
            child: Container(
              padding: EdgeInsets.all(15),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: theme ? Colors.white : darkBg,
                ),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl,
                    errorWidget:
                        (context, error, stackTrace) => Text(
                          'Could not get image',
                          style: GoogleFonts.comfortaa(color: Colors.red),
                        ),
                  ), //image.network
                ),
              ),
            ),
          ),
          !kIsWeb ? const SizedBox(height: 5) : SizedBox(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: kIsWeb ? 120 : 60,
                    vertical: kIsWeb ? 15 : 10,
                  ),
                  backgroundColor: theme ? Colors.white : darkBg,
                ),
                onPressed: () {
                  setState(() {
                    if (!post.isPostLiked) {
                      post.likesCount++;
                      post.isPostLiked = true;
                    } else if (post.likesCount > 0) {
                      post.likesCount--;
                      post.isPostLiked = false;
                    }
                  });
                },
                label: Row(
                  children: [
                    Icon(
                      post.isPostLiked
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      size: kIsWeb ? 30 : 20,
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                    ),
                    /*const SizedBox(width: 5),
                    Text(
                      post.likesCount.toString(),
                      style: TextStyle(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                      ),
                    ),*/
                  ],
                ),
              ),
              SizedBox(width: kIsWeb ? 15 : 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: kIsWeb ? 120 : 60,
                    vertical: kIsWeb ? 15 : 10,
                  ),
                  backgroundColor: theme ? Colors.white : darkBg,
                ),
                onPressed: () async {
                  final shouldRefresh = await showAddComment(
                    theme,
                    context,
                    post,
                  );
                  if (shouldRefresh == true) {
                    setState(() {});
                  }
                },
                label: Icon(
                  FontAwesomeIcons.comment,
                  size: kIsWeb ? 30 : 20,
                  color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: kIsWeb ? 10 : 5),
          commentsSection(post, theme),
        ],
      ),
    );
  }

  Widget commentsSection(Post post, bool theme) {
    final postComments =
        dbCommentsList
            .where((comment) => comment.postID == post.postID)
            .toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: postComments.length,
      itemBuilder: (context, index) {
        final comment = postComments[index];

        return buildComment(theme, comment, post, index, () async {
          final success = await _submitDeleteComment(comment);
          if (success) {
            setState(() {
              dbCommentsList.removeWhere(
                (c) => c.commentID == comment.commentID,
              );
            });
            await _fetchAllDB();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete comment.')),
            );
          }
        });
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
    );
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

  bool isCourseEnrolled(myUser.User? u, Course c) {
    final enrolledCourses = getEnrolledCourses(u!.userID);
    return enrolledCourses.any((course) => course.courseID == c.courseID);
  }

  Future<void> _submitCreatePost(Post x) async {
    /*if (!kIsWeb) {
      print(_image);
      await _uploadImage();
    }*/
    //await _uploadImage(); - made above so it will render to the post immediately

    final Map<String, dynamic> dataToSend = {
      'postID': x.postID,
      'userEmail': x.userEmail,
      'courseID': x.courseID,
      'description': x.description,
      'imageUrl': x.imageUrl,
      'likesCount': x.likesCount,
      'createdAt': x.createdAt.toIso8601String(),
    };

    final url = Uri.parse('http://$serverUrl:3000/post/create');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else if (response.statusCode == 404) {
        print('User not found: ${response.body}');
      } else if (response.statusCode == 401) {
        print('Wrong data: ${response.body}');
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _launchFileUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print('❌ Could not launch $url');
    }
  }

  Future<void> _submitAddPostFile(PostFile x) async {
    final Map<String, dynamic> dataToSend = {
      'id': x.id,
      'postID': x.postID,
      'userID': x.userID,
      'fileUrl': x.fileUrl,
      'fileName': x.fileName,
    };

    final url = Uri.parse('http://$serverUrl:3000/postFile/create');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else if (response.statusCode == 404) {
        print('User not found: ${response.body}');
      } else if (response.statusCode == 401) {
        print('Wrong data: ${response.body}');
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _submitDeletePost(Post x) async {
    final Map<String, dynamic> dataToSend = {'postID': x.postID};
    final url = Uri.parse('http://$serverUrl:3000/post/delete');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else if (response.statusCode == 404) {
        print('User not found: ${response.body}');
      } else if (response.statusCode == 401) {
        print('Wrong data: ${response.body}');
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _submitCreateComment(Comment x) async {
    //await _uploadImage(); - made above so it will render to the post immediately

    final Map<String, dynamic> dataToSend = {
      'commentID': x.commentID,
      'PostID': x.postID,
      'userEmail': x.userEmail,
      'description': x.description,
      'createdAt': x.createdAt.toIso8601String(),
    };

    final url = Uri.parse('http://$serverUrl:3000/comment/create');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else if (response.statusCode == 404) {
        print('User not found: ${response.body}');
      } else if (response.statusCode == 401) {
        print('Wrong data: ${response.body}');
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<bool> _submitDeleteComment(Comment x) async {
    final Map<String, dynamic> dataToSend = {'commentID': x.commentID};
    final url = Uri.parse('http://$serverUrl:3000/comment/delete');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
        return true;
      } else if (response.statusCode == 404) {
        print('User not found: ${response.body}');
        return false;
      } else if (response.statusCode == 401) {
        print('Wrong data: ${response.body}');
        return false;
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  Future<void> deletePostFile(String fileName) async {
    final storageRef = supabase.storage.from('circuit-academy-files');

    try {
      await storageRef.remove(['PostsFiles/$fileName']);
      print('File deleted successfully!');
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  String? webFileName;
  String? mobileFileName;
  String? fileUrl;

  void _pickFile(bool theme, void Function(void Function()) setState) async {
    final allowedExtensions = ['txt'];

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
      withData: kIsWeb,
    );

    if (result != null) {
      List<PlatformFile> validFiles =
          result.files.where((file) {
            final ext = file.extension?.toLowerCase();
            return ext != null && allowedExtensions.contains(ext);
          }).toList();

      if (validFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Please select at least one valid .txt file.',
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  color: theme ? Colors.white : Colors.black,
                ),
              ),
            ),
            backgroundColor:
                theme ? Colors.blue.shade600 : Colors.green.shade600,
          ),
        );
        return;
      }

      setState(() {
        pickedFiles.addAll(validFiles);
        isFilePicked = pickedFiles.isNotEmpty;
      });
    }
  }

  /*void _pickFile(bool theme) async {
    final allowedExtensions = ['txt'];

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
      withData: kIsWeb, // Needed to get bytes on web
    );

    if (result != null) {
      List<PlatformFile> validFiles =
          result.files.where((file) {
            String? ext = file.extension?.toLowerCase();
            return ext != null && allowedExtensions.contains(ext);
          }).toList();

      if (validFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Please select at least one valid txt file.',
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  color: theme ? Colors.white : Colors.black,
                ),
              ),
            ),
            backgroundColor:
                theme ? Colors.blue.shade600 : Colors.green.shade600,
          ),
        );
        return;
      }

      setState(() {
        pickedFiles.addAll(validFiles);
        isFilePicked = pickedFiles.isNotEmpty;
      });

      print('Files picked: ${validFiles.map((f) => f.name).join(', ')}');
    } else {
      print('User canceled file picker');
    }
  }*/
}
