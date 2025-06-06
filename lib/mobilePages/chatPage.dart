import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/chatComponents.dart';
import 'package:hardwaresimu_software_graduation_project/courses.dart';
import 'package:hardwaresimu_software_graduation_project/enrollment.dart';
import 'package:hardwaresimu_software_graduation_project/main.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/themeMobile.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final myUser.User? user;
  const ChatScreen({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _ChatScreenState(user: this.user);
}

class _ChatScreenState extends State<ChatScreen> {
  bool isLightTheme = false;
  myUser.User? user;
  _ChatScreenState({required this.user});

  List<Map<String, dynamic>> posts = [];
  List<Course> dbCoursesList = [];
  List<Enrollment> dbEnrollmentList = [];
  List<Course> enrolledCourses = [];
  List<String> enrolledCoursesTitles = [];
  List<String> enrolledCoursesImages = [];

  int courseIndex = 0;

  TextEditingController postController = TextEditingController();
  bool courseChosen = false;
  bool isLoading = true;

  Future<void> _fetchCourses() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/courses'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbCoursesList = json.map((item) => Course.fromJson(item)).toList();
      });
      for (int i = 0; i < dbCoursesList.length; i++) {
        enrolledCoursesTitles.add(dbCoursesList[i].title);
        enrolledCoursesImages.add(dbCoursesList[i].imageURL);
      }
    } else {
      throw Exception('Failed to load courses');
    }
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

  Future<void> fetchDB() async {
    _fetchCourses();

    _fetchEnrollment();

    await Future.delayed(Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    fetchDB();
  }

  @override
  Widget build(BuildContext context) {
    isLightTheme = Provider.of<MobileThemeProvider>(
      context,
    ).isLightTheme(context);
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
        ),
      );
    }
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      drawer:
          courseChosen
              ? Drawer(
                backgroundColor: isLightTheme ? Colors.white : darkBg,

                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

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
                                    fontSize: 15,
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
                                          fontSize: 15,
                                          color:
                                              isLightTheme
                                                  ? Colors.blue.shade600
                                                  : Colors.green.shade600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 40),
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
                                enrolledCourses.length,
                                enrolledCoursesImages,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : null,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "Message other enrollees",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
        ),
      ),
      body: Center(
        //child: Text("Messages appear here", style: TextStyle(fontSize: 24)),
        child:
            courseChosen
                ? chatComps(
                  isLightTheme: isLightTheme,
                  user: user,
                  selectedCourse: dbCoursesList[courseIndex], //todo fix this
                )
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15),
                      if (enrolledCourses.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            textAlign: TextAlign.center,
                            'Choose one of the courses you enrolled in from below to show other enrollees',
                            style: GoogleFonts.comfortaa(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color:
                                  isLightTheme
                                      ? Colors.blue.shade600
                                      : Colors.green.shade600,
                            ),
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
                                  fontSize: 15,
                                  color:
                                      isLightTheme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Image.asset('Images/404.png'),
                          ],
                        ),
                      const SizedBox(height: 20),

                      ScrollConfiguration(
                        behavior: ScrollConfiguration.of(
                          context,
                        ).copyWith(scrollbars: false),
                        child: coursesSubFeedsButtonsImages(
                          isLightTheme,
                          enrolledCourses.length,
                          enrolledCoursesImages,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget coursesSubFeedsButtonsImages(
    bool theme,
    int count,
    List<String> coursesImages,
  ) {
    enrolledCourses = getEnrolledCourses(user!.userID);

    int bi = 0;

    final enrolledCourseWidgets =
        dbCoursesList
            .asMap()
            .entries
            .where(
              (entry) => enrolledCourses.any(
                (enrolled) => enrolled.courseID == entry.value.courseID,
              ),
            )
            .map((entry) {
              final buttonIndex = entry.key;
              bi = buttonIndex;
              final course = entry.value;

              final borderColor =
                  theme ? Colors.blue.shade600 : Colors.green.shade600;

              return InkWell(
                onTap: () {
                  if (courseChosen) Navigator.pop(context);
                  setState(() {
                    bi = buttonIndex;
                    courseChosen = true;
                    courseIndex = buttonIndex;
                  });
                },
                child: SizedBox(
                  height: 230, // ✅ FIX: lock each grid item’s height
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                          color: borderColor,
                        ),
                        padding: const EdgeInsets.all(5),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            //image.network
                            imageUrl: course.imageURL,
                            width: 150,
                            height: 150,
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course.title,
                          style: GoogleFonts.comfortaa(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })
            .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: enrolledCourseWidgets.length,
      itemBuilder: (context, index) => enrolledCourseWidgets[index],
    );
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
                padding: const EdgeInsets.all(8),
              ),
              onPressed: () {
                if (courseChosen) {
                  Navigator.pop(context);
                }
                setState(() {
                  courseChosen = true;
                  courseIndex = buttonIndex;
                });
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (builder) => chatComps(
                          user: user,
                          isLightTheme: isLightTheme,
                          selectedCourse: dbCoursesList[courseIndex],
                        ),
                  ),
                );*/
                /*if (!kIsWeb) {
                  Navigator.pop(context);
                }*/
              },
              child: Text(
                textAlign: TextAlign.center,
                course.title, // No need to use coursesTitles anymore
                style: GoogleFonts.comfortaa(
                  color: theme ? Colors.white : Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } else {
          return const SizedBox(height: 5);
        }
      });
    } else {
      return [];
    }
  }
}
