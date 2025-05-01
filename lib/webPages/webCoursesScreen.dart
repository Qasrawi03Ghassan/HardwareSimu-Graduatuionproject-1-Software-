import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/courses.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
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
  bool isSignedIn;
  User? user;
  _WebCoursesScreenState({required this.isSignedIn, this.user});

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
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _fetchCourses();
  }

  Widget getCoursesList(bool isLightTheme) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: dbCoursesList.length,
      itemBuilder: (BuildContext context, int index) {
        return Wrap(
          children: [
            ListTile(
              leading: SizedBox(
                width: 120,
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(300),
                  child: Image.network(
                    dbCoursesList[index].imageURL,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              title: Text(
                dbCoursesList[index].title,
                style: GoogleFonts.comfortaa(fontSize: 24),
              ),
              subtitle: Text(
                (dbCoursesList[index].author +
                    '\n' +
                    dbCoursesList[index].courseID.toString() +
                    '\n' +
                    dbCoursesList[index].usersEmails.toLowerCase() +
                    '\n' +
                    dbCoursesList[index].level +
                    '\n'),
                style: GoogleFonts.comfortaa(fontSize: 24),
              ),
              textColor: isLightTheme ? Colors.black : Colors.white,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = context.watch<SysThemes>().isLightTheme;
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      body: Center(
        //child: getCoursesList(isLightTheme),
        /*child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = (constraints.maxWidth ~/ 200).clamp(2, 6);
              return GridView.builder(
                itemCount: dbCoursesList.length + 1, // +1 for the Add button
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (context, index) {
                  if (index < dbCoursesList.length) {
                    final course = dbCoursesList[index];
                    return _buildCourseCard(course);
                  } else {
                    return const SizedBox(); //_buildAddButton();
                  }
                },
              );
            },
          ),
        ),*/
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          course.imageURL != ''
              ? Image.asset(
                course.imageURL,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              )
              : Placeholder(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              course.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('by ${course.author}'),
          ),
          Spacer(),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text('${course.enrolled} enrolled'),
          // ),
        ],
      ),
    );

    // @override
    // Widget build(BuildContext context) {
    //   bool isLightTheme = context.watch<SysThemes>().isLightTheme;

    //   return Scaffold(
    //     backgroundColor: isLightTheme ? Colors.white : darkBg,
    //     body: Center(child: getCoursesList(isLightTheme)),
    //   );
    // }
  }

  /*class CourseGridPage extends StatefulWidget {
  @override
  _CourseGridPageState createState() => _CourseGridPageState();
}

class _CourseGridPageState extends State<CourseGridPage> {


  void _addCourse() {
    setState(() {
      courses.add(
        Course(
          title: 'New Course',
          author: 'New Author',
          imageUrl: 'https://via.placeholder.com/150',
          enrolled: 0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = (constraints.maxWidth ~/ 200).clamp(2, 6);
            return GridView.builder(
              itemCount: courses.length + 1, // +1 for the Add button
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 / 4,
              ),
              itemBuilder: (context, index) {
                if (index < courses.length) {
                  final course = courses[index];
                  return _buildCourseCard(course);
                } else {
                  return _buildAddButton();
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            course.imageUrl,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              course.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('by ${course.author}'),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${course.enrolled} enrolled'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _addCourse,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(😎,
          border: Border.all(color: Colors.black26),
        ),
        child: Center(
          child: Icon(Icons.add, size: 40),
        ),
      ),
    );
  }*/
}
