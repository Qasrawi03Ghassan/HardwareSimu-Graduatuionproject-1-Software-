import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/courses.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'dart:convert';

class WebCoursesScreen extends StatefulWidget {
  const WebCoursesScreen({super.key});

  @override
  State<WebCoursesScreen> createState() => _WebCoursesScreenState();
}

class _WebCoursesScreenState extends State<WebCoursesScreen> {
  List<Course> _courses = [];

  // Future<void> _fetchCourses() async {
  //   final response = await http.get(
  //     Uri.parse('http://localhost:3000/api/courses'),
  //   );
  //   if (response.statusCode == 200) {
  //     final List<dynamic> json = jsonDecode(response.body);
  //     setState(() {
  //       _courses = json.map((item) => Course.fromJson(item)).toList();
  //     });
  //   } else {
  //     throw Exception('Failed to load courses');
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchCourses();
  // }

  Widget getCoursesList(bool isLightTheme) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _courses.length,
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
                    _courses[index].imageURL,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              title: Text(
                _courses[index].title,
                style: GoogleFonts.comfortaa(fontSize: 24),
              ),
              subtitle: Text(
                (_courses[index].author +
                    '\n' +
                    _courses[index].id.toString() +
                    '\n' +
                    _courses[index].usersEmails.toLowerCase() +
                    '\n' +
                    _courses[index].level +
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
        child: Text(
          "Courses page",
          style: GoogleFonts.comfortaa(
            color: isLightTheme ? Colors.black : Colors.white,
            fontSize: 80,
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   bool isLightTheme = context.watch<SysThemes>().isLightTheme;

  //   return Scaffold(
  //     backgroundColor: isLightTheme ? Colors.white : darkBg,
  //     body: Center(child: getCoursesList(isLightTheme)),
  //   );
  // }
}
