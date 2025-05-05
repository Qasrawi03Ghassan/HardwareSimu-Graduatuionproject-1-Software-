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
  List<Course> filteredCourses = [];
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsKey = GlobalKey();
  final GlobalKey _addKey = GlobalKey();
  Course? selectedCourse;

  bool isSignedIn;
  User? user;

  List<User> dbUsersList = [];
  List<Enrollment> dbEnrollmentList = [];

  bool isEnrollClicked = false;
  bool showAddSection = false;

  bool isLoading = false;

  int newEnrollmentID = 0;

  TextEditingController newCourseTitle = TextEditingController();
  TextEditingController newCourseCategory = TextEditingController();
  TextEditingController newCourseDescription = TextEditingController();

  String _imgUrl = '';
  File? _image;
  Uint8List? _imageBytes;

  _WebCoursesScreenState({required this.isSignedIn, this.user});

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _fetchCourses();
    _fetchUsers();
    _fetchEnrollment();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
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
      throw Exception('Failed to load users');
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
    } else {
      throw Exception('Failed to load users');
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

                        selectedCourse != null
                            ? Container(
                              key: _detailsKey,
                              child: courseDetailsSection(
                                isLightTheme,
                                selectedCourse!,
                              ),
                            )
                            : showAddSection
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

  /*@override
  Widget build(BuildContext context) {
    bool isLightTheme = context.watch<SysThemes>().isLightTheme;
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              //Courses section
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = (constraints.maxWidth ~/ 300).clamp(
                      1,
                      4,
                    );
                    return GridView.builder(
                      itemCount: filteredCourses.length + 1,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                    );
                  },
                ),
              ),
              //Selected course details section
              if (selectedCourse != null)
                courseDetailsSection(isLightTheme, selectedCourse!),
            ],
          ),
        ),
      ),
    );
  }*/

  Widget courseDetailsSection(bool theme, Course c) {
    return StatefulBuilder(
      builder: (context, setState) {
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
                      width: kIsWeb ? 800 : 300,
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
            const SizedBox(height: 20),
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
                  //todo: Course's content section
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
                          //const SizedBox(height: 3),
                          Divider(
                            thickness: 2,
                            color:
                                theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                          ),
                          const SizedBox(height: 500),
                          //todo add videos list and video player here
                          Divider(
                            thickness: 2,
                            color:
                                theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                          ),
                        ],
                      ),
                    ),

                  //todo: Course enrollment management section (done)
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

  Widget addCourseSection(bool theme) {
    return StatefulBuilder(
      builder: (context, setState) {
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
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                      decorationThickness: 2,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' add the course\'s basic information here',
                    style: GoogleFonts.comfortaa(
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
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
                          _buildTextField(theme, 'Title: '),
                          const SizedBox(width: 60),
                          _buildTextField(theme, 'Category: '),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _buildTextField(theme, 'Title: '),
                          const SizedBox(height: 20),
                          _buildTextField(theme, 'Cat.:  '),
                        ],
                      ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Choose course Level',
                style: GoogleFonts.comfortaa(
                  fontWeight: FontWeight.bold,
                  color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(width: 300, child: _buildLevelSelection(theme)),
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
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
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
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
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
                child: TextField(
                  controller: newCourseDescription,
                  maxLines: 8, // Makes it a large text area
                  style: TextStyle(
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
                    text: 'Add an image if you like:',
                    style: GoogleFonts.comfortaa(
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                      decorationThickness: 2,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' add an image to outstand from other courses.',
                    style: GoogleFonts.comfortaa(
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
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
                    color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child:
                        (_imageBytes != null)
                            ? Image.memory(_imageBytes!, fit: BoxFit.contain)
                            : Text(
                              'Error showing message',
                              style: GoogleFonts.comfortaa(color: Colors.red),
                            ),
                  ),
                ),
              ),
            const SizedBox(height: 30),
            //todo submit and clear buttons(reached here)
          ],
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

  CourseLevel? _selectedLevel;
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

  Widget _buildTextField(bool theme, String text) {
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
          child: TextField(
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
                    Expanded(
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
}
