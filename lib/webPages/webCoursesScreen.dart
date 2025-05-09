import 'dart:io' as io;

import 'package:hardwaresimu_software_graduation_project/courseVideo.dart';
import 'package:hardwaresimu_software_graduation_project/fullScreenVideo.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/feedPage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/courses.dart';
import 'package:hardwaresimu_software_graduation_project/enrollment.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class WebCoursesScreen extends StatefulWidget {
  final bool isSignedIn;
  final User? user;
  const WebCoursesScreen({super.key, required this.isSignedIn, this.user});

  @override
  State<WebCoursesScreen> createState() =>
      _WebCoursesScreenState(isSignedIn: this.isSignedIn, user: this.user);
}

enum CourseLevel { Beginner, Intermediate, HighIntermediate, Advanced }

class _WebCoursesScreenState extends State<WebCoursesScreen> {
  List<Course> dbCoursesList = [];
  List<CourseVideo> dbCoursesVideos = [];
  List<Course> filteredCourses = [];
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollControllerH = ScrollController();
  final GlobalKey _detailsKey = GlobalKey();
  final GlobalKey _addKey = GlobalKey();
  final GlobalKey _editKey = GlobalKey();
  Course? selectedCourse;

  List<Course> createdCourses = [];

  bool isSignedIn;
  User? user;

  List<User> dbUsersList = [];
  List<Enrollment> dbEnrollmentList = [];

  bool isEnrollClicked = false;
  bool showAddSection = false;
  bool showEditSection = false;

  bool isLoading = false;

  int newEnrollmentID = 0;
  int newCourseID = 0;

  TextEditingController newCourseTitle = TextEditingController();
  TextEditingController newCourseCategory = TextEditingController();
  TextEditingController newCourseDescription = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController editCourseTitle = TextEditingController();
  TextEditingController editCourseCategory = TextEditingController();
  TextEditingController editCourseDescription = TextEditingController();

  String _imgUrl = '';
  File? _image;
  Uint8List? _imageBytes;

  String _vidUrl = '';
  File? _video;
  Uint8List? _videoBytes;
  String newCVTitle = '';
  int newCVID = 0;

  bool isNoVideos = false;

  late VideoPlayerController _vController;

  _WebCoursesScreenState({required this.isSignedIn, this.user});

  void setShowEditSection(bool x) {
    setState(() {
      showEditSection = x;
    });
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _fetchCourses();
    _fetchUsers();
    _fetchEnrollment();
    _fetchCoursesVideos();
    searchController.addListener(_onSearchChanged);
    editCourseCategory.text = '';
    editCourseTitle.text = '';
    editCourseDescription.text = '';
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollControllerH.dispose();
    _scrollController.dispose();

    newCourseCategory.dispose();
    newCourseDescription.dispose();
    newCourseTitle.dispose();

    editCourseCategory.dispose();
    editCourseTitle.dispose();
    editCourseDescription.dispose();
    super.dispose();
  }

  void setLoading() {
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
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
      newEnrollmentID = dbEnrollmentList.length + 1;
    } else {
      throw Exception('Failed to load enrollment');
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
        dbUsersList = json.map((item) => User.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load courses');
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
        filteredCourses = List.from(dbCoursesList);
      });
      newCourseID = dbCoursesList.length + 1;
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<void> _fetchCoursesVideos() async {
    final response = await http.get(
      Uri.parse(
        kIsWeb
            ? 'http://localhost:3000/api/cVideos'
            : 'http://10.0.2.2:3000/api/cVideos',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbCoursesVideos =
            json.map((item) => CourseVideo.fromJson(item)).toList();
      });
      newCVID = dbCoursesVideos.length + 1;
    } else {
      throw Exception('Failed to load courses\' videos');
    }
  }

  User getCourseCreator(String courseCreatorEmail) {
    return dbUsersList.firstWhere((user) => user.email == courseCreatorEmail);
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCourses =
          dbCoursesList.where((course) {
            return course.title.toLowerCase().contains(query) ||
                course.tag.toLowerCase().contains(query);
          }).toList();
    });
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

  bool isCourseEnrolled(Course c) {
    final enrolledCourses = getEnrolledCourses(user!.userID);
    return enrolledCourses.any((course) => course.courseID == c.courseID);
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme =
        kIsWeb
            ? context.watch<SysThemes>().isLightTheme
            : MediaQuery.of(context).platformBrightness == Brightness.light;

    int crossAxisCount = 3;

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    crossAxisCount = (constraints.maxWidth ~/ 300).clamp(1, 4);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Container(
                          width: 800,
                          alignment: Alignment.center,
                          child: TextField(
                            style: GoogleFonts.comfortaa(
                              color:
                                  isLightTheme
                                      ? Colors.blue.shade600
                                      : Colors.green.shade600,
                            ),
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by title or tag...',
                              hintStyle: GoogleFonts.comfortaa(
                                color:
                                    isLightTheme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                              ),
                              prefixIcon: Icon(
                                FontAwesomeIcons.magnifyingGlass,
                                color:
                                    isLightTheme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      isLightTheme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: filteredCourses.length + 1,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 4 / 3,
                              ),
                          itemBuilder: (context, index) {
                            if (index < filteredCourses.length) {
                              final course = filteredCourses[index];
                              return _buildCourseCard(isLightTheme, course);
                            } else if (isSignedIn) {
                              return _buildAddButton(isLightTheme);
                            } else {
                              return SizedBox();
                            }
                          },
                        ),

                        // Grid view with fixed height
                        /*SizedBox(
                          height: 700,
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: filteredCourses.length + 1,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 4 / 3,
                                ),
                            itemBuilder: (context, index) {
                              if (index < filteredCourses.length) {
                                final course = filteredCourses[index];
                                return _buildCourseCard(isLightTheme, course);
                              } else if (isSignedIn) {
                                return _buildAddButton(isLightTheme);
                              } else {
                                return SizedBox();
                              }
                            },
                          ),
                        ),*/
                        const SizedBox(height: 20),

                        (selectedCourse != null && !showEditSection)
                            ? Container(
                              key: _detailsKey,
                              child: courseDetailsSection(
                                isLightTheme,
                                selectedCourse!,
                              ),
                            )
                            : (selectedCourse != null && showEditSection)
                            ? Container(
                              key: _editKey,
                              child: editCourseSection(
                                isLightTheme,
                                selectedCourse!,
                              ),
                            )
                            : (showAddSection && selectedCourse == null)
                            ? Container(
                              key: _addKey,
                              child: addCourseSection(isLightTheme),
                            )
                            : const SizedBox(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget courseDetailsSection(bool theme, Course c) {
    return StatefulBuilder(
      builder: (context, setState) {
        //_vController = VideoPlayerController.networkUrl(url);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              thickness: 3,
              color: theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Wrap(
                    children: [
                      Text(
                        textAlign: !kIsWeb ? TextAlign.center : TextAlign.start,
                        c.title,
                        style: GoogleFonts.comfortaa(
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  (user!.userID != 0 && c.usersEmails == user!.email)
                      ? Text(
                        'By: ${getCourseCreator(c.usersEmails).name} (You)',
                        style: GoogleFonts.comfortaa(
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                          fontSize: 20,
                        ),
                      )
                      : Text(
                        'By: ${getCourseCreator(c.usersEmails).name}',
                        style: GoogleFonts.comfortaa(
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                          fontSize: 20,
                        ),
                      ),

                  const SizedBox(height: 50),
                  if (selectedCourse != null && selectedCourse!.imageURL != '')
                    Container(
                      width: kIsWeb ? 1000 : 300, //800 for web default
                      //height: kIsWeb ? 1000 : 300,
                      decoration: BoxDecoration(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.all(13),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          selectedCourse!.imageURL,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Text(
              textAlign: !kIsWeb ? TextAlign.center : TextAlign.start,
              'Description of the course:',
              style: GoogleFonts.comfortaa(
                decoration: TextDecoration.underline,
                decorationColor:
                    theme ? Colors.blue.shade600 : Colors.green.shade600,
                decorationThickness: 2,
                fontSize: 30,
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              textAlign: !kIsWeb ? TextAlign.center : TextAlign.start,
              c.description,
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 50),
            RichText(
              text: TextSpan(
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                  decoration: TextDecoration.underline,
                  decorationColor:
                      theme ? Colors.blue.shade600 : Colors.green.shade600,
                  decorationThickness: 2,
                ),
                children: [
                  TextSpan(text: 'Course level:'),
                  TextSpan(
                    text: ' ${c.level}',
                    style: TextStyle(
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                      fontSize: 20,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                  decoration: TextDecoration.underline,
                  decorationColor:
                      theme ? Colors.blue.shade600 : Colors.green.shade600,
                  decorationThickness: 2,
                ),
                children: [
                  TextSpan(text: 'Course category:'),
                  TextSpan(
                    text: ' #${c.tag}',
                    style: TextStyle(
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                      fontSize: 20,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  (isEnrollClicked && user != null && isCourseEnrolled(c))
                      ? Text(
                        'You are already enrolled in this course',
                        style: GoogleFonts.comfortaa(
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                      : (isEnrollClicked && user!.userID == 0)
                      ? Text(
                        'You must login first',
                        style: GoogleFonts.comfortaa(
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                      : SizedBox(),
                  //const SizedBox(height: 15),
                  if (user != null && user!.userID != 0 && isCourseEnrolled(c))
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            textAlign:
                                !kIsWeb ? TextAlign.center : TextAlign.start,
                            'Course content',
                            style: GoogleFonts.comfortaa(
                              fontSize: 40,
                              color:
                                  theme
                                      ? Colors.blue.shade600
                                      : Colors.green.shade600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Uploaded lectures',
                              style: GoogleFonts.comfortaa(
                                color:
                                    theme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(child: contentSection(theme)),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Examples',
                              style: GoogleFonts.comfortaa(
                                fontSize: 20,
                                color:
                                    theme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),

                  const SizedBox(height: 5),
                  (!isCourseEnrolled(c))
                      ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          backgroundColor:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                        onPressed: () async {
                          if (user == null ||
                              user!.userID == 0 ||
                              isCourseEnrolled(c)) {
                            setIsEnrolledClicked(true);
                            await Future.delayed(Duration(seconds: 2));
                            setIsEnrolledClicked(false);
                          } else if (user != null &&
                              user!.userID != 0 &&
                              !isCourseEnrolled(c)) {
                            bool? confirmed = await showDialog(
                              barrierDismissible: false,
                              context: super.context,
                              builder:
                                  (context) => AlertDialog(
                                    backgroundColor:
                                        theme ? Colors.white : darkBg,
                                    title: Text(
                                      'Enroll in course?',
                                      style: GoogleFonts.comfortaa(
                                        color:
                                            theme
                                                ? Colors.blue.shade600
                                                : Colors.green.shade600,
                                      ),
                                    ),
                                    content: Text(
                                      'Ready to start learning in this course?',
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
                                          'Maybe later',
                                          style: GoogleFonts.comfortaa(
                                            color:
                                                theme
                                                    ? Colors.blue.shade600
                                                    : Colors.green.shade600,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
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
                              //todo: handle enrolling
                              final newEnrollment = Enrollment(
                                id: newEnrollmentID++,
                                CourseID: c.courseID,
                                userID: user!.userID,
                              );
                              try {
                                _submitNewEnroll(newEnrollment);

                                setState(() {
                                  _fetchEnrollment();
                                });

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

                                await Future.delayed(Duration(seconds: 2));

                                Navigator.of(
                                  loaderContext,
                                  rootNavigator: true,
                                ).pop();

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => WebCoursesScreen(
                                          isSignedIn: true,
                                          user: user,
                                        ),
                                  ),
                                  (route) => false,
                                );
                                showSnackBar(
                                  theme,
                                  'Enrolled in course ${c.title} successfully',
                                );
                              } catch (e) {
                                print(e);
                                showSnackBar(
                                  theme,
                                  'Error enrolling in course',
                                );
                              }
                            }
                          }
                        },
                        child: Text(
                          'Enroll now',
                          style: GoogleFonts.comfortaa(
                            fontSize: 30,
                            color: theme ? Colors.white : Colors.black,
                          ),
                        ),
                      )
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          backgroundColor: const Color.fromARGB(
                            255,
                            216,
                            90,
                            81,
                          ),
                        ),
                        onPressed: () async {
                          bool? confirmed = await showDialog(
                            barrierDismissible: false,
                            context: super.context,
                            builder:
                                (context) => AlertDialog(
                                  backgroundColor:
                                      theme ? Colors.white : darkBg,
                                  title: Text(
                                    'Leave course?',
                                    style: GoogleFonts.comfortaa(
                                      color:
                                          theme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to leave this course?',
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
                                        'No, i want to stay',
                                        style: GoogleFonts.comfortaa(
                                          color:
                                              theme
                                                  ? Colors.blue.shade600
                                                  : Colors.green.shade600,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: Text(
                                        'Yes, i want to leave',
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
                            try {
                              final toDelete =
                                  dbEnrollmentList
                                      .where(
                                        (enroll) =>
                                            enroll.CourseID == c.courseID &&
                                            enroll.userID == user!.userID,
                                      )
                                      .toList();

                              for (var enroll in toDelete) {
                                _submitDeleteEnroll(enroll);
                              }
                              setState(() {
                                _fetchEnrollment();
                              });

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

                              await Future.delayed(Duration(seconds: 2));

                              Navigator.of(
                                loaderContext,
                                rootNavigator: true,
                              ).pop();

                              if (kIsWeb) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => WebCoursesScreen(
                                          isSignedIn: true,
                                          user: user,
                                        ),
                                  ),
                                  (route) => false,
                                );
                              } else {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FeedPage(user: user),
                                  ),
                                  (route) => false,
                                );
                              }

                              showSnackBar(
                                theme,
                                'You left  ${c.title} course successfully',
                              );
                            } catch (e) {
                              print(e);
                              showSnackBar(theme, 'Error leaving course');
                            }
                          }
                        },
                        child: Text(
                          'Leave course',
                          style: GoogleFonts.comfortaa(
                            fontSize: 30,
                            color:
                                theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        );
      },
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

  Widget editCourseSection(bool theme, Course c) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                thickness: 3,
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    kIsWeb
                        ? Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            textAlign: TextAlign.center,
                            'Edit ${c.title}',
                            style: GoogleFonts.comfortaa(
                              color: theme ? Colors.white : darkBg,
                              fontSize: 40,
                            ),
                          ),
                        )
                        : Text(
                          textAlign: TextAlign.center,
                          'Edit ${c.title}',
                          style: GoogleFonts.comfortaa(
                            color:
                                theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                            fontSize: 25,
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              RichText(
                textAlign: !kIsWeb ? TextAlign.center : TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Basic overview:\n\n',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decorationThickness: 2,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' Change the course\'s basic information here',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child:
                    (kIsWeb)
                        ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 20),
                            _buildEditTextField(
                              theme,
                              'Title: ',
                              editCourseTitle,
                            ),
                            const SizedBox(width: 60),
                            _buildEditTextField(
                              theme,
                              'Category: ',
                              editCourseCategory,
                            ),
                          ],
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            _buildEditTextField(
                              theme,
                              'Title: ',
                              editCourseTitle,
                            ),
                            const SizedBox(height: 20),
                            _buildEditTextField(
                              theme,
                              'Cat.:  ',
                              editCourseCategory,
                            ),
                          ],
                        ),
              ),
              const SizedBox(height: 50),
              Center(
                child: Text(
                  'Course Level',
                  style: GoogleFonts.comfortaa(
                    fontWeight: FontWeight.bold,
                    color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: kIsWeb ? 500 : 300,
                  child:
                      kIsWeb
                          ? _buildLevelSelectionWebEditCourse(theme)
                          : _buildLevelSelectionEditCourse(theme),
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: !kIsWeb ? TextAlign.center : TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Description\n\n',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decorationThickness: 2,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' Change the course\'s description in the next text area',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 800,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field cannot be empty';
                      }
                      return null;
                    },
                    controller: editCourseDescription,
                    maxLines: 8,
                    style: TextStyle(
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          theme
                              ? const Color.fromARGB(255, 223, 220, 220)
                              : const Color.fromARGB(255, 62, 65, 85),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: !kIsWeb ? TextAlign.center : TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Change course\'s image: ',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decorationThickness: 2,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (kIsWeb)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _pickImageWeb((bytes) async {
                        setState(() {
                          _imageBytes = bytes;
                        });
                        await _uploadImage();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(20),
                      backgroundColor:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                    ),
                    child: Text(
                      'Change image',
                      style: GoogleFonts.comfortaa(
                        fontSize: 17,
                        color: theme ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              //todo mobile choose image
              const SizedBox(height: 30),
              if (_imageBytes == null && kIsWeb)
                Center(
                  child: Container(
                    width: 800,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child:
                          (c.imageURL != '')
                              ? Image.network(c.imageURL, fit: BoxFit.contain)
                              : Text(
                                textAlign: TextAlign.center,
                                'Error showing image',
                                style: GoogleFonts.comfortaa(color: Colors.red),
                              ),
                    ),
                  ),
                ),
              if (_imageBytes != null && kIsWeb)
                Center(
                  child: Container(
                    width: 800,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child:
                          (_imageBytes != null)
                              ? Image.memory(_imageBytes!, fit: BoxFit.contain)
                              : Text(
                                textAlign: TextAlign.center,
                                'Error showing image',
                                style: GoogleFonts.comfortaa(color: Colors.red),
                              ),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              RichText(
                textAlign: !kIsWeb ? TextAlign.center : TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Course content: ',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decorationThickness: 2,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' upload video content to your course',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: contentSection(theme),
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(12),
                        backgroundColor:
                            theme
                                ? const Color.fromARGB(255, 160, 158, 158)
                                : const Color.fromARGB(255, 86, 90, 117),
                      ),
                      onPressed: () async {
                        bool? confirmed = await showDialog(
                          barrierDismissible: false,
                          context: super.context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: theme ? Colors.white : darkBg,
                                title: Text(
                                  'Confirm exit',
                                  style: GoogleFonts.comfortaa(
                                    color:
                                        theme
                                            ? Colors.blue.shade600
                                            : Colors.green.shade600,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure?',
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
                                    onPressed:
                                        () => Navigator.pop(context, true),
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
                          _formKey.currentState?.reset();
                          editCourseCategory.clear();
                          editCourseTitle.clear();
                          editCourseDescription.clear();
                          setState(() {
                            _selectedLevelEditCourse = null;
                          });

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      kIsWeb
                                          ? WebCoursesScreen(
                                            isSignedIn: true,
                                            user: user,
                                          )
                                          : FeedPage(user: user),
                            ),
                            (route) => false,
                          );
                          showSnackBar(theme, 'Course changing canceled');
                        }
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.comfortaa(
                          fontSize: kIsWeb ? 20 : 15,
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(12),
                        backgroundColor:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                      ),
                      onPressed: () async {
                        if (_selectedLevelEditCourse == null) {
                          showSnackBar(
                            theme,
                            'Please choose a level for the course first',
                          );
                        }
                        if (_formKey.currentState!.validate() &&
                            _selectedLevelEditCourse != null) {
                          bool? confirmed = await showDialog(
                            barrierDismissible: false,
                            context: super.context,
                            builder:
                                (context) => AlertDialog(
                                  backgroundColor:
                                      theme ? Colors.white : darkBg,
                                  title: Text(
                                    'Edit course confirmation',
                                    style: GoogleFonts.comfortaa(
                                      color:
                                          theme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                  content: Text(
                                    'Confirm changing this course\'s information?',
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
                                        'Cancel',
                                        style: GoogleFonts.comfortaa(
                                          color:
                                              theme
                                                  ? Colors.blue.shade600
                                                  : Colors.green.shade600,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: Text(
                                        'Submit changes',
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
                            await _submitEditCourse(c);

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

                            if (kIsWeb && _videoBytes != null) {
                              await _uploadVideo();
                              final addedVideo = CourseVideo(
                                vTitle: newCVTitle,
                                cVidID: newCVID++,
                                courseID: c.courseID,
                                vidUrl: _vidUrl,
                              );
                              await _submitNewVideo(addedVideo);
                            }

                            await Future.delayed(Duration(seconds: 2));

                            Navigator.of(
                              loaderContext,
                              rootNavigator: true,
                            ).pop();

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        kIsWeb
                                            ? WebCoursesScreen(
                                              isSignedIn: true,
                                              user: user,
                                            )
                                            : FeedPage(user: user),
                              ),
                              (route) => false,
                            );
                            showSnackBar(
                              theme,
                              'Course ${c.title} information changed successfully',
                            );
                          }
                        } else {}
                      },
                      child: Text(
                        'Submit changes',
                        style: GoogleFonts.comfortaa(
                          fontSize: kIsWeb ? 20 : 15,
                          color: theme ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget addCourseSection(bool theme) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                thickness: 3,
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    kIsWeb
                        ? Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            textAlign: TextAlign.center,
                            'Create a new course',
                            style: GoogleFonts.comfortaa(
                              color: theme ? Colors.white : darkBg,
                              fontSize: 40,
                            ),
                          ),
                        )
                        : Text(
                          textAlign: TextAlign.center,
                          'Create a new course',
                          style: GoogleFonts.comfortaa(
                            color:
                                theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                            fontSize: 25,
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              RichText(
                textAlign: !kIsWeb ? TextAlign.center : TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Basic overview:\n\n',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decorationThickness: 2,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' add the course\'s basic information here',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child:
                    (kIsWeb)
                        ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 20),
                            _buildTextField(theme, 'Title: ', newCourseTitle),
                            const SizedBox(width: 60),
                            _buildTextField(
                              theme,
                              'Category: ',
                              newCourseCategory,
                            ),
                          ],
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            _buildTextField(theme, 'Title: ', newCourseTitle),
                            const SizedBox(height: 20),
                            _buildTextField(
                              theme,
                              'Cat.:  ',
                              newCourseCategory,
                            ),
                          ],
                        ),
              ),
              const SizedBox(height: 50),
              Center(
                child: Text(
                  'Course Level',
                  style: GoogleFonts.comfortaa(
                    fontWeight: FontWeight.bold,
                    color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: kIsWeb ? 500 : 300,
                  child:
                      kIsWeb
                          ? _buildLevelSelectionWeb(theme)
                          : _buildLevelSelection(theme),
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: !kIsWeb ? TextAlign.center : TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Description\n\n',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decorationThickness: 2,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' add the course\'s description in the next text area',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 800,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field cannot be empty';
                      }
                      return null;
                    },
                    controller: newCourseDescription,
                    maxLines: 8,
                    style: TextStyle(
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          theme
                              ? const Color.fromARGB(255, 223, 220, 220)
                              : const Color.fromARGB(255, 62, 65, 85),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: !kIsWeb ? TextAlign.center : TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Add an image: ',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decorationThickness: 2,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' add an image to outstand from other courses.',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (kIsWeb)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _pickImageWeb((bytes) async {
                        setState(() {
                          _imageBytes = bytes;
                        });
                        await _uploadImage();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(20),
                      backgroundColor:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                    ),
                    child: Text(
                      'Choose image',
                      style: GoogleFonts.comfortaa(
                        fontSize: 17,
                        color: theme ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              //todo mobile choose image
              const SizedBox(height: 30),
              if (_imageBytes != null && kIsWeb)
                Center(
                  child: Container(
                    width: 800,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child:
                          (_imageBytes != null)
                              ? Image.memory(_imageBytes!, fit: BoxFit.contain)
                              : Text(
                                textAlign: TextAlign.center,
                                'Error showing image',
                                style: GoogleFonts.comfortaa(color: Colors.red),
                              ),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              RichText(
                textAlign: !kIsWeb ? TextAlign.center : TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Course content: ',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        decorationThickness: 2,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' upload video content to your course',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: contentSection(theme),
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(12),
                        backgroundColor:
                            theme
                                ? const Color.fromARGB(255, 160, 158, 158)
                                : const Color.fromARGB(255, 86, 90, 117),
                      ),
                      onPressed: () async {
                        bool? confirmed = await showDialog(
                          barrierDismissible: false,
                          context: super.context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: theme ? Colors.white : darkBg,
                                title: Text(
                                  'Confirm exit',
                                  style: GoogleFonts.comfortaa(
                                    color:
                                        theme
                                            ? Colors.blue.shade600
                                            : Colors.green.shade600,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure?',
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
                                    onPressed:
                                        () => Navigator.pop(context, true),
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
                          _formKey.currentState?.reset();
                          newCourseTitle.clear();
                          newCourseCategory.clear();
                          newCourseDescription.clear();
                          setState(() {
                            _selectedLevel = null;
                          });

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      kIsWeb
                                          ? WebCoursesScreen(
                                            isSignedIn: true,
                                            user: user,
                                          )
                                          : FeedPage(user: user),
                            ),
                            (route) => false,
                          );
                          showSnackBar(theme, 'Course creation canceled');
                        }
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.comfortaa(
                          fontSize: kIsWeb ? 20 : 15,
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(12),
                        backgroundColor:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                      ),
                      onPressed: () async {
                        if (_selectedLevel == null) {
                          showSnackBar(
                            theme,
                            'Please choose a level for the course first',
                          );
                        }
                        if (_formKey.currentState!.validate() &&
                            _selectedLevel != null) {
                          bool? confirmed = await showDialog(
                            barrierDismissible: false,
                            context: super.context,
                            builder:
                                (context) => AlertDialog(
                                  backgroundColor:
                                      theme ? Colors.white : darkBg,
                                  title: Text(
                                    'New course creation confirmation',
                                    style: GoogleFonts.comfortaa(
                                      color:
                                          theme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                  content: Text(
                                    'Confirm adding this new course?',
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
                                        'Cancel',
                                        style: GoogleFonts.comfortaa(
                                          color:
                                              theme
                                                  ? Colors.blue.shade600
                                                  : Colors.green.shade600,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: Text(
                                        'Add course',
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
                            final newCourse = Course(
                              courseID: newCourseID++,
                              title: newCourseTitle.text,
                              tag: newCourseCategory.text,
                              description: newCourseDescription.text,
                              imageURL: _imgUrl,
                              level:
                                  (_selectedLevel == CourseLevel.Beginner)
                                      ? 'Beginner'
                                      : (_selectedLevel ==
                                          CourseLevel.Intermediate)
                                      ? 'Intermediate'
                                      : (_selectedLevel ==
                                          CourseLevel.HighIntermediate)
                                      ? 'High-Intermediate'
                                      : 'Advanced',
                              usersEmails: newCourseTitle.text,
                            );
                            await _submitNewCourse(newCourse);

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

                            if (kIsWeb && _videoBytes != null) {
                              await _uploadVideo();
                              final addedVideo = CourseVideo(
                                vTitle: newCVTitle,
                                cVidID: newCVID++,
                                courseID: newCourseID,
                                vidUrl: _vidUrl,
                              );
                              await _submitNewVideo(addedVideo);
                            }

                            await Future.delayed(Duration(seconds: 2));

                            Navigator.of(
                              loaderContext,
                              rootNavigator: true,
                            ).pop();

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        kIsWeb
                                            ? WebCoursesScreen(
                                              isSignedIn: true,
                                              user: user,
                                            )
                                            : FeedPage(user: user),
                              ),
                              (route) => false,
                            );
                            showSnackBar(
                              theme,
                              'Course ${newCourse.title} created and added successfully',
                            );
                          }
                        } else {}
                      },
                      child: Text(
                        'Submit new course',
                        style: GoogleFonts.comfortaa(
                          fontSize: kIsWeb ? 20 : 15,
                          color: theme ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /*Widget contentSection(bool theme) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme ? Colors.white : darkBg,
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      height: 300,
    );
  }*/
  List<XFile> _courseVids = [];
  Widget contentSection(bool theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme ? Colors.white : darkBg,
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      height: 300,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollControllerH,
        child: SingleChildScrollView(
          controller: _scrollControllerH,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showEditSection || showAddSection) _buildUploadCard(theme),
              const SizedBox(width: 20),
              if (selectedCourse != null) ...[
                if (dbCoursesVideos
                    .where(
                      (video) => video.courseID == selectedCourse!.courseID,
                    )
                    .isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No videos uploaded yet',
                        style: GoogleFonts.comfortaa(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                      ),
                    ),
                  ),

                ...dbCoursesVideos
                    .where(
                      (video) => video.courseID == selectedCourse!.courseID,
                    )
                    .map(
                      (video) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _buildDBVideoCard(theme, video),
                      ),
                    ),
              ],
              const SizedBox(width: 10),
              ..._courseVids.map(
                (vid) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildVideoCard(vid, theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final ImagePicker _pickerVideo = ImagePicker();

  Future<void> _pickVideo() async {
    final XFile? video = await _pickerVideo.pickVideo(
      source: ImageSource.gallery,
    );

    if (video != null) {
      final File file = File(video.path);
      final Uint8List bytes = await video.readAsBytes();

      setState(() {
        _video = file;
        _videoBytes = bytes;
        _vidUrl = '';
        newCVTitle = video.name;
        _courseVids.add(video); // if you still want to keep a list
      });
      print(newCVTitle);
    }
  }

  Widget _buildUploadCard(bool theme) {
    return Container(
      width: 300,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme ? Colors.blue.shade50 : Colors.green.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme ? Colors.blue : Colors.green,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: _pickVideo,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.video_call,
                size: 40,
                color: theme ? Colors.blue : Colors.greenAccent,
              ),
              const SizedBox(height: 4),
              Text(
                "Upload",
                style: GoogleFonts.comfortaa(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: theme ? Colors.blue : Colors.greenAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVideoDialog(bool theme, BuildContext context, CourseVideo video) {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(video.vidUrl!),
    );

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: controller.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return StatefulBuilder(
                builder: (context, setState) {
                  controller.addListener(() => setState(() {}));

                  Duration position = controller.value.position;
                  Duration total = controller.value.duration;

                  String formatTime(Duration d) {
                    String twoDigits(int n) => n.toString().padLeft(2, '0');
                    final minutes = twoDigits(d.inMinutes.remainder(60));
                    final seconds = twoDigits(d.inSeconds.remainder(60));
                    return '${d.inHours > 0 ? '${twoDigits(d.inHours)}:' : ''}$minutes:$seconds';
                  }

                  return AlertDialog(
                    title: Text('${selectedCourse!.title} - ${video.vTitle}'),
                    content: SizedBox(
                      width: 1300,
                      height: kIsWeb ? 900 : 400,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 1100,
                            child: AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: VideoPlayer(controller),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color:
                                      theme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                                onPressed: () {
                                  controller.value.isPlaying
                                      ? controller.pause()
                                      : controller.play();
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  controller.value.volume == 0
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  color:
                                      theme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                                onPressed: () {
                                  controller.setVolume(
                                    controller.value.volume == 0 ? 1.0 : 0.0,
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.fullscreen,
                                  color:
                                      theme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                                onPressed: () {
                                  controller.pause();
                                  //Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => FullScreenVideoPage(
                                            videoUrl: video.vidUrl!,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Slider(
                            min: 0,
                            max: total.inMilliseconds.toDouble(),
                            value:
                                position.inMilliseconds
                                    .clamp(0, total.inMilliseconds)
                                    .toDouble(),
                            onChanged: (value) {
                              controller.seekTo(
                                Duration(milliseconds: value.toInt()),
                              );
                            },
                          ),
                          Text(
                            '${formatTime(position)} / ${formatTime(total)}',
                            style: GoogleFonts.comfortaa(
                              color:
                                  theme
                                      ? Colors.blue.shade600
                                      : Colors.green.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          controller.dispose();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Close',
                          style: GoogleFonts.comfortaa(
                            color:
                                theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else {
              return AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildDBVideoCard(bool theme, CourseVideo video) {
    return InkWell(
      onTap: () {
        if (!showAddSection || !showEditSection) {
          _showVideoDialog(theme, context, video);
        }
      },
      child: Container(
        width: 300,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme ? Colors.blue.shade50 : Colors.green.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: Stack(
          children: [
            // Delete icon at top-left
            if (selectedCourse!.usersEmails == user!.email)
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: theme ? Colors.red.shade700 : Colors.red.shade200,
                    size: 20,
                  ),
                  onPressed: () async {
                    bool? confirmed = await showDialog(
                      barrierDismissible: false,
                      context: super.context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor: theme ? Colors.white : darkBg,
                            title: Text(
                              'Confirm video deletion',
                              style: GoogleFonts.comfortaa(
                                color:
                                    theme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                              ),
                            ),
                            content: Text(
                              'Are you sure?',
                              style: GoogleFonts.comfortaa(
                                color:
                                    theme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
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
                      await _submitDeleteVideo(video);
                      setState(() {
                        _fetchCoursesVideos();
                      });
                      showSnackBar(theme, 'Video deleted successfully');
                    }
                  },
                ),
              ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 35,
                    color: theme ? Colors.blue.shade800 : Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      video.vTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: theme ? Colors.blue.shade900 : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(XFile video, bool theme) {
    return Container(
      width: 300,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme ? Colors.blue.shade50 : Colors.green.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 35,
            color: theme ? Colors.blue.shade800 : Colors.white,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              video.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: theme ? Colors.blue.shade900 : Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageWeb(Function(Uint8List) onImagePicked) async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      Uint8List bytes = await picked.readAsBytes();
      onImagePicked(bytes);
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

  /*Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }*/

  Future<void> _uploadVideo() async {
    final mimeType =
        kIsWeb
            ? lookupMimeType('', headerBytes: _videoBytes)
            : lookupMimeType(_video!.path);
    final mediaType = mimeType?.split('/');
    final fileExtension = mediaType != null ? mediaType.last : 'mp4';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/ds565huxe/video/upload',
    );
    final http.MultipartRequest? request;

    if (!kIsWeb && _video != null) {
      request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = 'uploadPreset'
            ..fields['folder'] = 'postsVideosFolder'
            ..files.add(
              await http.MultipartFile.fromPath(
                'file',
                _video!.path,
                filename: 'postVideoUpload.$fileExtension',
                contentType:
                    mediaType != null
                        ? MediaType(mediaType.first, mediaType.last)
                        : MediaType('video', 'mp4'),
              ),
            );
    } else if (_videoBytes != null) {
      request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = 'uploadPreset'
            ..fields['folder'] = 'postsVideosFolder'
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                _videoBytes!,
                filename: 'postVideoUpload.$fileExtension',
                contentType:
                    mediaType != null
                        ? MediaType(mediaType.first, mediaType.last)
                        : MediaType('video', 'mp4'),
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

        setState(() {
          _vidUrl = jsonMap['url'];
        });

        // print(_videoUrl);
      } else {
        print("Video upload failed with status: ${response.statusCode}");
      }
    }
  }

  CourseLevel? _selectedLevel;
  CourseLevel? _selectedLevelEditCourse;

  Widget _buildLevelSelectionWebEditCourse(bool theme) {
    final Color selectedColor =
        theme ? Colors.blue.shade600 : Colors.green.shade600;

    return RadioTheme(
      data: RadioThemeData(fillColor: WidgetStateProperty.all(selectedColor)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildRadioOptionEditCourse(
            CourseLevel.Beginner,
            'Beginner',
            selectedColor,
          ),
          SizedBox(width: 20),
          _buildRadioOptionEditCourse(
            CourseLevel.Intermediate,
            'Intermediate',
            selectedColor,
          ),
          SizedBox(width: 20),
          _buildRadioOptionEditCourse(
            CourseLevel.HighIntermediate,
            'High-Intermediate',
            selectedColor,
          ),
          SizedBox(width: 20),
          _buildRadioOptionEditCourse(
            CourseLevel.Advanced,
            'Advanced',
            selectedColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOptionEditCourse(
    CourseLevel level,
    String label,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<CourseLevel>(
          value: level,
          groupValue: _selectedLevelEditCourse,
          onChanged: (CourseLevel? value) {
            setState(() {
              _selectedLevelEditCourse = value;
            });
          },
        ),
        Text(label, style: GoogleFonts.comfortaa(color: color)),
      ],
    );
  }

  Widget _buildLevelSelectionEditCourse(bool theme) {
    return RadioTheme(
      data: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          final color = theme ? Colors.blue.shade600 : Colors.green.shade600;
          return color;
        }),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RadioListTile<CourseLevel>(
            title: Text(
              'Beginner',
              style: GoogleFonts.comfortaa(
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            activeColor: theme ? Colors.blue.shade600 : Colors.green.shade600,
            value: CourseLevel.Beginner,
            groupValue: _selectedLevelEditCourse,
            onChanged: (CourseLevel? value) {
              setState(() {
                _selectedLevelEditCourse = value;
              });
            },
          ),
          const SizedBox(width: 20),
          RadioListTile<CourseLevel>(
            title: Text(
              'Intermediate',
              style: GoogleFonts.comfortaa(
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            value: CourseLevel.Intermediate,
            activeColor: theme ? Colors.blue.shade600 : Colors.green.shade600,
            groupValue: _selectedLevelEditCourse,
            onChanged: (CourseLevel? value) {
              setState(() {
                _selectedLevelEditCourse = value;
              });
            },
          ),
          const SizedBox(width: 20),
          RadioListTile<CourseLevel>(
            title: Text(
              'High-Intermediate',
              style: GoogleFonts.comfortaa(
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            value: CourseLevel.HighIntermediate,
            activeColor: theme ? Colors.blue.shade600 : Colors.green.shade600,
            groupValue: _selectedLevelEditCourse,
            onChanged: (CourseLevel? value) {
              setState(() {
                _selectedLevelEditCourse = value;
              });
            },
          ),
          const SizedBox(width: 20),
          RadioListTile<CourseLevel>(
            title: Text(
              'Advanced',
              style: GoogleFonts.comfortaa(
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            value: CourseLevel.Advanced,
            activeColor: theme ? Colors.blue.shade600 : Colors.green.shade600,
            groupValue: _selectedLevelEditCourse,
            onChanged: (CourseLevel? value) {
              setState(() {
                _selectedLevelEditCourse = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelectionWeb(bool theme) {
    final Color selectedColor =
        theme ? Colors.blue.shade600 : Colors.green.shade600;

    return RadioTheme(
      data: RadioThemeData(fillColor: WidgetStateProperty.all(selectedColor)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildRadioOption(CourseLevel.Beginner, 'Beginner', selectedColor),
          SizedBox(width: 20),
          _buildRadioOption(
            CourseLevel.Intermediate,
            'Intermediate',
            selectedColor,
          ),
          SizedBox(width: 20),
          _buildRadioOption(
            CourseLevel.HighIntermediate,
            'High-Intermediate',
            selectedColor,
          ),
          SizedBox(width: 20),
          _buildRadioOption(CourseLevel.Advanced, 'Advanced', selectedColor),
        ],
      ),
    );
  }

  Widget _buildRadioOption(CourseLevel level, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<CourseLevel>(
          value: level,
          groupValue: _selectedLevel,
          onChanged: (CourseLevel? value) {
            setState(() {
              _selectedLevel = value;
            });
          },
        ),
        Text(label, style: GoogleFonts.comfortaa(color: color)),
      ],
    );
  }

  Widget _buildLevelSelection(bool theme) {
    return RadioTheme(
      data: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          final color = theme ? Colors.blue.shade600 : Colors.green.shade600;
          return color;
        }),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RadioListTile<CourseLevel>(
            title: Text(
              'Beginner',
              style: GoogleFonts.comfortaa(
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            activeColor: theme ? Colors.blue.shade600 : Colors.green.shade600,
            value: CourseLevel.Beginner,
            groupValue: _selectedLevel,
            onChanged: (CourseLevel? value) {
              setState(() {
                _selectedLevel = value;
              });
            },
          ),
          const SizedBox(width: 20),
          RadioListTile<CourseLevel>(
            title: Text(
              'Intermediate',
              style: GoogleFonts.comfortaa(
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            value: CourseLevel.Intermediate,
            activeColor: theme ? Colors.blue.shade600 : Colors.green.shade600,
            groupValue: _selectedLevel,
            onChanged: (CourseLevel? value) {
              setState(() {
                _selectedLevel = value;
              });
            },
          ),
          const SizedBox(width: 20),
          RadioListTile<CourseLevel>(
            title: Text(
              'High-Intermediate',
              style: GoogleFonts.comfortaa(
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            value: CourseLevel.HighIntermediate,
            activeColor: theme ? Colors.blue.shade600 : Colors.green.shade600,
            groupValue: _selectedLevel,
            onChanged: (CourseLevel? value) {
              setState(() {
                _selectedLevel = value;
              });
            },
          ),
          const SizedBox(width: 20),
          RadioListTile<CourseLevel>(
            title: Text(
              'Advanced',
              style: GoogleFonts.comfortaa(
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            value: CourseLevel.Advanced,
            activeColor: theme ? Colors.blue.shade600 : Colors.green.shade600,
            groupValue: _selectedLevel,
            onChanged: (CourseLevel? value) {
              setState(() {
                _selectedLevel = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(bool theme, String text, TextEditingController cont) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.comfortaa(
            color: theme ? Colors.blue.shade600 : Colors.green.shade600,
            fontSize: 20,
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: kIsWeb ? 300 : 190,
          child: TextFormField(
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field cannot be empty';
              }
              return null;
            },
            controller: cont,
            style: GoogleFonts.comfortaa(
              color: theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  theme
                      ? const Color.fromARGB(255, 223, 220, 220)
                      : const Color.fromARGB(255, 62, 65, 85),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditTextField(
    bool theme,
    String text,
    TextEditingController cont,
  ) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.comfortaa(
            color: theme ? Colors.blue.shade600 : Colors.green.shade600,
            fontSize: 20,
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: kIsWeb ? 300 : 190,
          child: TextFormField(
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field cannot be empty';
              }
              return null;
            },
            controller: cont,
            style: GoogleFonts.comfortaa(
              color: theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  theme
                      ? const Color.fromARGB(255, 223, 220, 220)
                      : const Color.fromARGB(255, 62, 65, 85),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void setIsEnrolledClicked(bool b) {
    setState(() {
      isEnrollClicked = b;
    });
  }

  Widget _buildCourseCard(bool theme, Course course) {
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: InkWell(
            onTap: () {
              setShowEditSection(false);
              setIsEnrolledClicked(false);
              setAddClicked(false);

              setSelectedCourse(course);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_detailsKey.currentContext != null) {
                  Scrollable.ensureVisible(
                    _detailsKey.currentContext!,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(isHovered ? 1.03 : 1.0),
              child: Card(
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*Expanded(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            course.imageURL,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder:
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
                    ),*/
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color:
                                  theme
                                      ? Colors.blue.shade600
                                      : Colors.green.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                course.imageURL,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder:
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
                          if (user != null &&
                              user!.userID != 0 &&
                              getCourseCreator(course.usersEmails).userID ==
                                  user!.userID)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () {
                                  // TODO: Edit logic
                                  setAddClicked(false);
                                  setSelectedCourse(course);
                                  editCourseDescription.text =
                                      course.description;
                                  editCourseCategory.text = course.tag;
                                  editCourseTitle.text = course.title;
                                  if (course.level == 'Beginner') {
                                    _selectedLevelEditCourse =
                                        CourseLevel.Beginner;
                                  } else if (course.level == 'Advanced') {
                                    _selectedLevelEditCourse =
                                        CourseLevel.Advanced;
                                  } else if (course.level == 'Intermediate') {
                                    _selectedLevelEditCourse =
                                        CourseLevel.Intermediate;
                                  } else if (course.level ==
                                      'High-Intermediate') {
                                    _selectedLevelEditCourse =
                                        CourseLevel.HighIntermediate;
                                  } else {
                                    _selectedLevelEditCourse = null;
                                  }

                                  setShowEditSection(true);

                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (_editKey.currentContext != null) {
                                      Scrollable.ensureVisible(
                                        _editKey.currentContext!,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme ? Colors.white : Colors.black,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color:
                                        theme
                                            ? Colors.blue.shade600
                                            : Colors.green.shade600,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        course.title,
                        style: GoogleFonts.comfortaa(
                          fontWeight: FontWeight.bold,
                          color: theme ? Colors.white : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '#${course.tag}',
                            style: TextStyle(
                              color: theme ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox(width: 3)),
                        if (user != null &&
                            user!.userID != 0 &&
                            isCourseEnrolled(course))
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.circleExclamation,
                                  color: theme ? Colors.white : Colors.black,
                                  size: !kIsWeb ? 12 : 18,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Currently enrolled',
                                  style: GoogleFonts.comfortaa(
                                    color: theme ? Colors.white : Colors.black,
                                    fontSize: !kIsWeb ? 12 : 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitNewEnroll(Enrollment x) async {
    final Map<String, dynamic> dataToSend = {
      'id': x.id,
      'CourseID': x.CourseID,
      'userID': x.userID,
    };

    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/enrollment/create')
            : Uri.parse('http://10.0.2.2:3000/enrollment/create');

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

  Future<void> _submitDeleteEnroll(Enrollment x) async {
    final Map<String, dynamic> dataToSend = {'id': x.id};

    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/enrollment/delete')
            : Uri.parse('http://10.0.2.2:3000/enrollment/delete');

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

  void setAddClicked(bool x) {
    setState(() {
      showAddSection = x;
    });
  }

  void setSelectedCourse(Course? c) {
    setState(() {
      selectedCourse = c;
    });
  }

  Widget _buildAddButton(bool theme) {
    return InkWell(
      onTap: () {
        setState(() {
          setShowEditSection(false);
          setSelectedCourse(null);
          setAddClicked(true);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_addKey.currentContext != null) {
            Scrollable.ensureVisible(
              _addKey.currentContext!,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: theme ? Colors.blue.shade600 : Colors.green.shade600,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 40, color: theme ? Colors.white : darkBg),
              SizedBox(height: 8),
              Text(
                'Add Course',
                style: TextStyle(
                  fontSize: 16,
                  color: theme ? Colors.white : darkBg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitEditCourse(Course x) async {
    final Map<String, dynamic> dataToSend = {
      'courseID': x.courseID,
      'title': editCourseTitle.text,
      'image': (_imgUrl == '') ? x.imageURL : _imgUrl,
      'usersEmails': user!.email,
      'level':
          (_selectedLevelEditCourse == CourseLevel.Beginner)
              ? 'Beginner'
              : (_selectedLevelEditCourse == CourseLevel.Intermediate)
              ? 'Intermediate'
              : (_selectedLevelEditCourse == CourseLevel.HighIntermediate)
              ? 'High-Intermediate'
              : 'Advanced',
      'tag': editCourseCategory.text,
      'description': editCourseDescription.text,
    };

    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/course/edit')
            : Uri.parse('http://10.0.2.2:3000/course/edit');

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

  Future<void> _submitDeleteVideo(CourseVideo x) async {
    final Map<String, dynamic> dataToSend = {'cVideoID': x.cVidID};

    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/cVideo/delete')
            : Uri.parse('http://10.0.2.2:3000/cVideo/delete');

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

  Future<void> _submitNewVideo(CourseVideo x) async {
    final Map<String, dynamic> dataToSend = {
      'cVideoID': x.cVidID,
      'courseID': x.courseID,
      'videoUrl': x.vidUrl,
      'vTitle': x.vTitle,
    };

    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/cVideo/add')
            : Uri.parse('http://10.0.2.2:3000/cVideo/add');

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

  Future<void> _submitNewCourse(Course x) async {
    final Map<String, dynamic> dataToSend = {
      'courseID': x.courseID,
      'title': x.title,
      'image': x.imageURL,
      'usersEmails': user!.email,
      'level': x.level,
      'tag': x.tag,
      'description': x.description,
    };

    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/course/create')
            : Uri.parse('http://10.0.2.2:3000/course/create');

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
}
