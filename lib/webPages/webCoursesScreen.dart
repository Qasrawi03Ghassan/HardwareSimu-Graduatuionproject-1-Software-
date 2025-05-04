import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/courses.dart';
import 'package:hardwaresimu_software_graduation_project/enrollment.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'dart:convert';

class WebCoursesScreen extends StatefulWidget {
  final bool isSignedIn;
  final User? user;
  const WebCoursesScreen({super.key, required this.isSignedIn, this.user});

  @override
  State<WebCoursesScreen> createState() =>
      _WebCoursesScreenState(isSignedIn: this.isSignedIn, user: this.user);
}

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

  int newEnrollmentID = 0;

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
                  const SizedBox(height: 5),
                  if (user != null && user!.userID != 0 && isCourseEnrolled(c))
                    Text(
                      'You are already taking this course',
                      style: GoogleFonts.comfortaa(
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 50),
                  if (selectedCourse != null && selectedCourse!.imageURL != '')
                    Container(
                      width: 800,
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

                  //todo: Course enrollment management section
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
                              _submitNewEnroll(newEnrollment);
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
                            //todo handle leaving course
                            //_submitDeleteEnroll();
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
                  Text(
                    'Create a new course',
                    style: GoogleFonts.comfortaa(
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                      fontSize: 40,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '#${course.tag}',
                        style: TextStyle(
                          color: theme ? Colors.white : Colors.black,
                        ),
                      ),
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
      'courseID': x.CourseID,
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
    final Map<String, dynamic> dataToSend = {
      'id': x.id,
      'courseID': x.CourseID,
      'userID': x.userID,
    };

    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/enrollemnt/delete')
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
