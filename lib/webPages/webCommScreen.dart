import 'dart:convert';
import 'dart:io';
import 'package:hardwaresimu_software_graduation_project/chatComponents.dart';
import 'package:hardwaresimu_software_graduation_project/comments.dart';
import 'package:hardwaresimu_software_graduation_project/enrollment.dart';
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
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';
import 'package:collection/collection.dart';

class WebCommScreen extends StatefulWidget {
  final bool isSignedIn;
  final User? user;
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
  User? user;
  _WebCommScreenState({required this.isSignedIn, this.user});
  List<User> _users = [];

  String initFeed =
      kIsWeb
          ? 'Choose a course subfeed from the list on the left'
          : 'Choose a course subfeed from the list above first';
  String newPostText = '';
  String newCommentText = '';

  Widget postsList = const SizedBox();
  List<Post> dbPostsList = [];
  List<Post> filteredPosts = [];

  List<String> coursesTitles = [];
  List<Course> dbCoursesList = [];

  List<Comment> dbCommentsList = [];
  List<Comment> postComments = [];

  List<Enrollment> dbEnrollmentList = [];

  List<Course> enrolledCourses = [];

  int newCommentID = 0;

  int courseIndex = 0;
  int newPostID = 0;

  Future<void> _fetchAllDB() async {
    _fetchUsers();
    _fetchPosts();
    _fetchCourses();
    _fetchComments();
    _fetchEnrollment();
  }

  Future<void> _fetchComments() async {
    final response = await http.get(
      Uri.parse(
        kIsWeb
            ? 'http://localhost:3000/api/comments'
            : 'http://10.0.2.2:3000/api/comments',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbCommentsList = json.map((item) => Comment.fromJson(item)).toList();
      });
      newCommentID = dbCommentsList.length + 1;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> _fetchPosts() async {
    final response = await http.get(
      Uri.parse(
        kIsWeb
            ? 'http://localhost:3000/api/posts'
            : 'http://10.0.2.2:3000/api/posts',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbPostsList = json.map((item) => Post.fromJson(item)).toList();
      });
      newPostID = dbPostsList.length + 1;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> _fetchCourses() async {
    final response = await http.get(
      Uri.parse(
        kIsWeb
            ? 'http://localhost:3000/api/courses'
            : 'http://10.0.2.2:3000/api/courses',
      ),
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
      Uri.parse(
        kIsWeb
            ? 'http://localhost:3000/api/users'
            : 'http://10.0.2.2:3000/api/users',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        _users = json.map((item) => User.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> _fetchEnrollment() async {
    final response = await http.get(
      Uri.parse(
        kIsWeb
            ? 'http://localhost:3000/api/enrollment'
            : 'http://10.0.2.2:3000/api/enrollment',
      ),
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
            : MediaQuery.of(context).platformBrightness == Brightness.light;

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
                              showCreatePost(isLightTheme, context);
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

                        // Message or list of courses
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

                        // Course subfeed buttons
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
                              builder: (context) => WebApp(isSignedIn: false),
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
                                    user: User(
                                      userID: 0,
                                      name: '',
                                      userName: '',
                                      email: '',
                                      phoneNum: '',
                                      password: '',
                                      profileImgUrl: '',
                                      isSignedIn: false,
                                      isAdmin: false,
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
                                                : 587,
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
                              height: kIsWeb ? 80 : 50,
                              alignment: Alignment.center,
                              padding: !kIsWeb ? EdgeInsets.all(10) : null,
                              child: Text(
                                textAlign:
                                    !kIsWeb
                                        ? TextAlign.center
                                        : TextAlign.start,
                                initFeed,
                                style: GoogleFonts.comfortaa(
                                  fontSize: kIsWeb ? 28 : 20,
                                  color:
                                      isLightTheme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                              ),
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
                    if (kIsWeb)
                      Expanded(
                        flex: 4,
                        child: chatComps(
                          user: user,
                          isLightTheme: isLightTheme,
                        ),
                        /*child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.topCenter,
                              margin: EdgeInsets.symmetric(vertical: 15),
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Chat with others',
                                style: GoogleFonts.comfortaa(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                  color:
                                      isLightTheme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            //chatSection(isLightTheme, user!),
                            chatComps(user: user, isLightTheme: isLightTheme),
                          ],
                        ),
                      ),*/
                      ),
                  ],
                ),
      ),
    );
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
                              child: Image.network(
                                author.profileImgUrl!,
                                width: kIsWeb ? 80 : 60,
                                height: kIsWeb ? 80 : 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    (!isGoneAuthor)
                        ? '${author!.userName}\n${author.name}'
                        : 'Previous enrollee',
                    style: GoogleFonts.comfortaa(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                    ),
                  ),
                  Expanded(child: SizedBox(width: 10)),
                  if (author!.email == user!.email && !isGoneAuthor)
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
                              size: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
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
                        fontSize: 20,
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
                          IconButton(
                            onPressed: () {
                              if (kIsWeb) {
                                _pickImageWeb((bytes) async {
                                  setState(() {
                                    localImageBytes = bytes;
                                  });
                                  _imageBytes = bytes;
                                  await _uploadImage();
                                });
                              }
                              setState(() {
                                isImagePost = true;
                              });
                            },
                            icon: Icon(
                              FontAwesomeIcons.image,
                              color:
                                  theme
                                      ? Colors.blue.shade600
                                      : Colors.green.shade600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Add a new post',
                            style: TextStyle(
                              fontSize: 22,
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
                                      Post? newPost;
                                      setState(() {
                                        newPost = Post(
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
                                        Navigator.pop(context);
                                        setState(() {
                                          setImagePost(false);
                                        });
                                      });
                                      await _submitCreatePost(newPost!);
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
                      if (localImageBytes != null)
                        Center(
                          child: Container(
                            child:
                                (kIsWeb && localImageBytes != null)
                                    ? Image.memory(localImageBytes!, width: 500)
                                    : Text('ERROR'),
                          ),
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

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageWeb(Function(Uint8List) onImagePicked) async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      Uint8List bytes = await picked.readAsBytes();
      onImagePicked(bytes);
    }
  }

  void setImagePost(bool x) {
    setState(() {
      isImagePost = x;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    final mimeType =
        kIsWeb
            ? lookupMimeType('', headerBytes: _imageBytes)
            : lookupMimeType(_image!.path);
    final mediaType = mimeType?.split('/');
    final fileExtension = mediaType != null ? mediaType.last : 'png';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/ds565huxe/upload');
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
          _imgUrl = jsonMap['url'];
        });
        //print(_imgUrl);
      }
    }
  }

  User? getPostAuthor(Post post) {
    return _users.firstWhereOrNull((user) => user.email == post.userEmail);
  }

  User? getCommentAuthor(Comment comment) {
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
                          child: Image.network(
                            author.profileImgUrl!,
                            width: kIsWeb ? 80 : 60,
                            height: kIsWeb ? 80 : 60,
                            fit: BoxFit.cover,
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
              Expanded(child: SizedBox(width: 10)),
              if (author!.email == user!.email && !isGoneAuthor)
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
                              title: Text('Confirm post deletion'),
                              content: Text(
                                'Are you sure you want to delete post? (ALL RELATED COMMENTS WILL BE DELETED)',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: Text('No'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Yes'),
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
          Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              post.description,
              style: GoogleFonts.comfortaa(
                color: theme ? Colors.white : Colors.black,
                fontSize: kIsWeb ? 25 : 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Visibility(
            visible:
                (post.imageUrl != '' &&
                    dbPostsList.any(
                      (element) => element.postID == post.postID,
                    )),
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
                  child: Image.network(post.imageUrl),
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
                  child: Image.network(post.imageUrl),
                ),
              ),
            ),
          ),
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
          const SizedBox(height: 20),
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

  bool isCourseEnrolled(User? u, Course c) {
    final enrolledCourses = getEnrolledCourses(u!.userID);
    return enrolledCourses.any((course) => course.courseID == c.courseID);
  }

  Future<void> _submitCreatePost(Post x) async {
    //await _uploadImage(); - made above so it will render to the post immediately

    final Map<String, dynamic> dataToSend = {
      'postID': x.postID,
      'userEmail': x.userEmail,
      'courseID': x.courseID,
      'description': x.description,
      'imageUrl': x.imageUrl,
      'likesCount': x.likesCount,
    };

    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/post/create')
            : Uri.parse('http://10.0.2.2:3000/post/create');

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
    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/post/delete')
            : Uri.parse('http://10.0.2.2:3000/post/delete');

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
    };

    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/comment/create')
            : Uri.parse('http://10.0.2.2:3000/comment/create');

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
    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/comment/delete')
            : Uri.parse('http://10.0.2.2:3000/comment/delete');

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
}
