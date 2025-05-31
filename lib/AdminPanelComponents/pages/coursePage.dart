import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/courseVideo.dart';
import 'package:hardwaresimu_software_graduation_project/courses.dart';
import 'package:hardwaresimu_software_graduation_project/enrollment.dart';
import 'package:hardwaresimu_software_graduation_project/main.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CoursesPage extends StatefulWidget {
  final bool theme;
  final User user;
  const CoursesPage({super.key, required this.theme, required this.user});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  List<Course> dbCoursesList = [];
  List<User> dbUsersList = [];
  List<Enrollment> dbEnrollmentList = [];
  List<CourseVideo> dbCoursesVideos = [];
  List<CourseFile> dbCoursesFilesList = [];
  List<Review> dbReviewsList = [];

  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  final ScrollController _verticalController2 = ScrollController();
  final ScrollController _horizontalController2 = ScrollController();

  final ScrollController _verticalController3 = ScrollController();
  final ScrollController _horizontalController3 = ScrollController();

  Future<void> _fetchUsers() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/users'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbUsersList = json.map((item) => User.fromJson(item)).toList();
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
    } else {
      throw Exception('Failed to load enrollment');
    }
  }

  Future<void> _fetchCoursesFiles() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/courseFiles'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          dbCoursesFilesList =
              json.map((item) => CourseFile.fromJson(item)).toList();
        });
      }
    } else {
      throw Exception('Failed to load course files');
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
        });
      }
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<void> _fetchCoursesVideos() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/cVideos'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbCoursesVideos =
            json.map((item) => CourseVideo.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load courses\' videos');
    }
  }

  Future<void> _fetchReviews() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/reviews'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          dbReviewsList = json.map((item) => Review.fromJson(item)).toList();
        });
      }
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchCourses();
    _fetchEnrollment();
    _fetchCoursesVideos();
    _fetchCoursesFiles();
    _fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stats = [
      {
        'label': 'Enrollments',
        'count': dbEnrollmentList.length,
        'icon': Icons.app_registration_rounded,
        'color': Colors.green,
      },
      {
        'label': 'Lectures',
        'count': dbCoursesVideos.length,
        'icon': Icons.video_call,
        'color': Colors.orange,
      },
      {
        'label': 'PDF files',
        'count': dbCoursesFilesList.length,
        'icon': Icons.picture_as_pdf,
        'color': Colors.purple,
      },
      {
        'label': 'Reviews',
        'count': dbReviewsList.length,
        'icon': Icons.reviews,
        'color': Colors.blue,
      },
    ];

    final cardColor =
        widget.theme
            ? Colors.blue.shade600
            : const Color.fromARGB(255, 67, 70, 92);
    final textColor = widget.theme ? Colors.white : Colors.green.shade600;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 20,
              runSpacing: 20,
              children:
                  stats.map((stat) {
                    return Container(
                      width: 400,
                      height: 150,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                widget.theme ? Colors.white : Colors.grey[100],
                            child:
                                stat['icon'] is IconData
                                    ? Icon(
                                      stat['icon'],
                                      color: stat['color'],
                                      size: 50,
                                    )
                                    : stat['icon'],
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat['count'].toString(),
                                style: GoogleFonts.comfortaa(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                stat['label'],
                                style: GoogleFonts.comfortaa(
                                  fontSize: 30,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: 40),

          //Courses table
          dbCoursesList.isNotEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Courses\' information',
                        style: GoogleFonts.comfortaa(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                              widget.theme
                                  ? Colors.blue.shade600
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 500,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Scrollbar(
                          controller: _horizontalController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _horizontalController,
                            scrollDirection: Axis.horizontal,
                            primary: false,
                            child: Scrollbar(
                              notificationPredicate:
                                  (notification) =>
                                      notification.metrics.axis ==
                                      Axis.vertical,
                              controller: _verticalController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _verticalController,
                                scrollDirection: Axis.vertical,
                                child: DataTable(
                                  dataRowMinHeight: 50,
                                  dataRowMaxHeight: 150,
                                  columns: [
                                    DataColumn(
                                      label: Center(
                                        child: Text(
                                          style: GoogleFonts.comfortaa(),
                                          'Course ID',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Title',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.comfortaa(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Creator\'s email',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.comfortaa(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Tag',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.comfortaa(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Level',
                                            style: GoogleFonts.comfortaa(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Enrollees count',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.comfortaa(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Description',
                                            style: GoogleFonts.comfortaa(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Creation date',
                                            style: GoogleFonts.comfortaa(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Image URL',
                                            style: GoogleFonts.comfortaa(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    /*DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Delete course',
                                            style: GoogleFonts.comfortaa(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),*/
                                  ],
                                  rows:
                                      (dbCoursesList.toList())
                                          .map(
                                            (c) => DataRow(
                                              cells: [
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      c.courseID.toString(),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 300,
                                                    child: SingleChildScrollView(
                                                      child: Center(
                                                        child: Text(
                                                          c.title,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.comfortaa(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      c.usersEmails,
                                                      style:
                                                          GoogleFonts.comfortaa(),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      c.tag,
                                                      style:
                                                          GoogleFonts.comfortaa(),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      c.level,
                                                      style:
                                                          GoogleFonts.comfortaa(),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      getCourseEnrolls(
                                                        c,
                                                      ).toString(),
                                                      style:
                                                          GoogleFonts.comfortaa(),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: SizedBox(
                                                      width: 300,
                                                      child: SingleChildScrollView(
                                                        child: Center(
                                                          child: Text(
                                                            c.description,
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            softWrap: true,
                                                            style:
                                                                GoogleFonts.comfortaa(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 10,
                                                          ),
                                                      child: SizedBox(
                                                        width: 300,
                                                        child: Text(
                                                          DateFormat(
                                                            'yyyy-MM-dd-hh a',
                                                          ).format(c.createdAt),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.comfortaa(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 10,
                                                          ),
                                                      child: SizedBox(
                                                        width: 300,
                                                        child: GestureDetector(
                                                          onTap:
                                                              c.imageURL !=
                                                                      'N/A'
                                                                  ? () =>
                                                                      _launchURL(
                                                                        c.imageURL,
                                                                      )
                                                                  : null,
                                                          child: SelectableText.rich(
                                                            TextSpan(
                                                              text:
                                                                  c.imageURL !=
                                                                          ''
                                                                      ? c.imageURL
                                                                      : 'N/A',
                                                              style: GoogleFonts.comfortaa(
                                                                color:
                                                                    Colors.blue,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                decorationColor:
                                                                    Colors.blue,
                                                              ),
                                                              recognizer:
                                                                  TapGestureRecognizer()
                                                                    ..onTap = () {
                                                                      if (c.imageURL !=
                                                                          '') {
                                                                        final url =
                                                                            Uri.parse(
                                                                              c.imageURL,
                                                                            );
                                                                        launchUrl(
                                                                          url,
                                                                          mode:
                                                                              LaunchMode.externalApplication,
                                                                        );
                                                                      }
                                                                    },
                                                            ),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // DataCell(
                                                //   Center(
                                                //     child: ElevatedButton(
                                                //       onPressed: () async {
                                                //         bool?
                                                //         confirmed = await showDialog(
                                                //           context: context,
                                                //           builder:
                                                //               (
                                                //                 context,
                                                //               ) => AlertDialog(
                                                //                 title: Text(
                                                //                   'Confirm course deletion',
                                                //                   style: GoogleFonts.comfortaa(
                                                //                     color:
                                                //                         widget.theme
                                                //                             ? Colors.blue.shade600
                                                //                             : Colors.green.shade600,
                                                //                   ),
                                                //                 ),
                                                //                 content: Text(
                                                //                   'Delete course with id ${c.courseID}?',
                                                //                   style: GoogleFonts.comfortaa(
                                                //                     color:
                                                //                         widget.theme
                                                //                             ? Colors.blue.shade600
                                                //                             : Colors.green.shade600,
                                                //                   ),
                                                //                 ),
                                                //                 actions: [
                                                //                   TextButton(
                                                //                     onPressed:
                                                //                         () => Navigator.pop(
                                                //                           context,
                                                //                           false,
                                                //                         ),
                                                //                     child: Text(
                                                //                       'No',
                                                //                       style: GoogleFonts.comfortaa(
                                                //                         color:
                                                //                             widget.theme
                                                //                                 ? Colors.blue.shade600
                                                //                                 : Colors.green.shade600,
                                                //                       ),
                                                //                     ),
                                                //                   ),
                                                //                   TextButton(
                                                //                     onPressed:
                                                //                         () => Navigator.pop(
                                                //                           context,
                                                //                           true,
                                                //                         ),
                                                //                     child: Text(
                                                //                       'Yes, delete',
                                                //                       style: GoogleFonts.comfortaa(
                                                //                         color:
                                                //                             widget.theme
                                                //                                 ? Colors.blue.shade600
                                                //                                 : Colors.green.shade600,
                                                //                       ),
                                                //                     ),
                                                //                   ),
                                                //                 ],
                                                //               ),
                                                //         );
                                                //         if (confirmed!) {
                                                //           // TODO: handle deleting courses
                                                //         }
                                                //       },
                                                //       style: ElevatedButton.styleFrom(
                                                //         backgroundColor:
                                                //             Colors.red,
                                                //         padding:
                                                //             EdgeInsets.symmetric(
                                                //               vertical: 3,
                                                //               horizontal: 10,
                                                //             ),
                                                //       ),
                                                //       child: Text(
                                                //         'Delete',
                                                //         style:
                                                //             GoogleFonts.comfortaa(
                                                //               color:
                                                //                   widget.theme
                                                //                       ? Colors
                                                //                           .white
                                                //                       : darkBg,
                                                //             ),
                                                //       ),
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Center(
                child: Text(
                  'No courses yet',
                  style: GoogleFonts.comfortaa(
                    fontSize: 30,
                    color:
                        widget.theme
                            ? Colors.blue.shade600
                            : Colors.green.shade600,
                  ),
                ),
              ),
          const SizedBox(height: 30),

          //videos table
          dbCoursesList.isNotEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Files\' information',
                        style: GoogleFonts.comfortaa(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                              widget.theme
                                  ? Colors.blue.shade600
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 500,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Scrollbar(
                          controller: _horizontalController2,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _horizontalController2,
                            scrollDirection: Axis.horizontal,
                            primary: false,
                            child: Scrollbar(
                              notificationPredicate:
                                  (notification) =>
                                      notification.metrics.axis ==
                                      Axis.vertical,
                              controller: _verticalController2,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _verticalController2,
                                scrollDirection: Axis.vertical,
                                child: DataTable(
                                  dataRowMinHeight: 50,
                                  dataRowMaxHeight: 150,
                                  columns: [
                                    DataColumn(
                                      label: Center(
                                        child: Text(
                                          style: GoogleFonts.comfortaa(),
                                          'File ID',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Course ID',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.comfortaa(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Name',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.comfortaa(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'URL',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.comfortaa(),
                                          ),
                                        ),
                                      ),
                                    ),

                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Delete file',
                                            style: GoogleFonts.comfortaa(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows:
                                      (dbCoursesFilesList.toList())
                                          .map(
                                            (c) => DataRow(
                                              cells: [
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      c.id.toString(),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 300,
                                                    child: SingleChildScrollView(
                                                      child: Center(
                                                        child: Text(
                                                          c.courseID.toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.comfortaa(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 150,
                                                    child: SingleChildScrollView(
                                                      child: Center(
                                                        child: Text(
                                                          textAlign:
                                                              TextAlign.center,
                                                          c.fileName,
                                                          style:
                                                              GoogleFonts.comfortaa(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 10,
                                                          ),
                                                      child: SizedBox(
                                                        width: 300,
                                                        child: GestureDetector(
                                                          onTap:
                                                              c.URL != ''
                                                                  ? () =>
                                                                      _launchURL(
                                                                        c.URL!,
                                                                      )
                                                                  : null,
                                                          child: SelectableText.rich(
                                                            TextSpan(
                                                              text:
                                                                  c.URL != ''
                                                                      ? c.URL
                                                                      : 'N/A',
                                                              style: GoogleFonts.comfortaa(
                                                                color:
                                                                    Colors.blue,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                decorationColor:
                                                                    Colors.blue,
                                                              ),
                                                              recognizer:
                                                                  TapGestureRecognizer()
                                                                    ..onTap = () {
                                                                      if (c.URL !=
                                                                          '') {
                                                                        final url =
                                                                            Uri.parse(
                                                                              c.URL!,
                                                                            );
                                                                        launchUrl(
                                                                          url,
                                                                          mode:
                                                                              LaunchMode.externalApplication,
                                                                        );
                                                                      }
                                                                    },
                                                            ),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        bool?
                                                        confirmed = await showDialog(
                                                          context: context,
                                                          builder:
                                                              (
                                                                context,
                                                              ) => AlertDialog(
                                                                title: Text(
                                                                  'Confirm file deletion',
                                                                  style: GoogleFonts.comfortaa(
                                                                    color:
                                                                        widget.theme
                                                                            ? Colors.blue.shade600
                                                                            : Colors.green.shade600,
                                                                  ),
                                                                ),
                                                                content: Text(
                                                                  'Delete file with id ${c.id}?',
                                                                  style: GoogleFonts.comfortaa(
                                                                    color:
                                                                        widget.theme
                                                                            ? Colors.blue.shade600
                                                                            : Colors.green.shade600,
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () => Navigator.pop(
                                                                          context,
                                                                          false,
                                                                        ),
                                                                    child: Text(
                                                                      'No',
                                                                      style: GoogleFonts.comfortaa(
                                                                        color:
                                                                            widget.theme
                                                                                ? Colors.blue.shade600
                                                                                : Colors.green.shade600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () => Navigator.pop(
                                                                          context,
                                                                          true,
                                                                        ),
                                                                    child: Text(
                                                                      'Yes, delete',
                                                                      style: GoogleFonts.comfortaa(
                                                                        color:
                                                                            widget.theme
                                                                                ? Colors.blue.shade600
                                                                                : Colors.green.shade600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                        );
                                                        if (confirmed!) {
                                                          // TODO: handle deleting files
                                                          final loaderContext =
                                                              context;
                                                          showDialog(
                                                            context:
                                                                loaderContext,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => Center(
                                                                  child: CircularProgressIndicator(
                                                                    color:
                                                                        widget.theme
                                                                            ? Colors.blue.shade600
                                                                            : Colors.green.shade600,
                                                                  ),
                                                                ),
                                                          );

                                                          await _submitDeleteCourseFile(
                                                            c,
                                                          );
                                                          setState(() {
                                                            _fetchCoursesFiles();
                                                          });
                                                          await Future.delayed(
                                                            Duration(
                                                              seconds: 2,
                                                            ),
                                                          );

                                                          Navigator.of(
                                                            loaderContext,
                                                            rootNavigator: true,
                                                          ).pop();

                                                          showSnackBar(
                                                            widget.theme,
                                                            'File ${c.fileName} deleted successfully',
                                                          );
                                                        }
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 3,
                                                              horizontal: 10,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        'Delete',
                                                        style:
                                                            GoogleFonts.comfortaa(
                                                              color:
                                                                  widget.theme
                                                                      ? Colors
                                                                          .white
                                                                      : darkBg,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Center(
                child: Text(
                  'No videos yet',
                  style: GoogleFonts.comfortaa(
                    fontSize: 30,
                    color:
                        widget.theme
                            ? Colors.blue.shade600
                            : Colors.green.shade600,
                  ),
                ),
              ),
          const SizedBox(height: 50),

          //Files table
          //videos table
          dbCoursesList.isNotEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Videos\' information',
                        style: GoogleFonts.comfortaa(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                              widget.theme
                                  ? Colors.blue.shade600
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 500,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Scrollbar(
                          controller: _horizontalController3,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _horizontalController3,
                            scrollDirection: Axis.horizontal,
                            primary: false,
                            child: Scrollbar(
                              notificationPredicate:
                                  (notification) =>
                                      notification.metrics.axis ==
                                      Axis.vertical,
                              controller: _verticalController3,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _verticalController3,
                                scrollDirection: Axis.vertical,
                                child: DataTable(
                                  dataRowMinHeight: 50,
                                  dataRowMaxHeight: 150,
                                  columns: [
                                    DataColumn(
                                      label: Center(
                                        child: Text(
                                          style: GoogleFonts.comfortaa(),
                                          'Video ID',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Course ID',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.comfortaa(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Title',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.comfortaa(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'URL',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.comfortaa(),
                                          ),
                                        ),
                                      ),
                                    ),

                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Delete video',
                                            style: GoogleFonts.comfortaa(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows:
                                      (dbCoursesVideos.toList())
                                          .map(
                                            (c) => DataRow(
                                              cells: [
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      c.cVidID.toString(),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 300,
                                                    child: SingleChildScrollView(
                                                      child: Center(
                                                        child: Text(
                                                          c.courseID.toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.comfortaa(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 150,
                                                    child: SingleChildScrollView(
                                                      child: Center(
                                                        child: Text(
                                                          textAlign:
                                                              TextAlign.center,
                                                          c.vTitle,
                                                          style:
                                                              GoogleFonts.comfortaa(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 10,
                                                          ),
                                                      child: SizedBox(
                                                        width: 300,
                                                        child: GestureDetector(
                                                          onTap:
                                                              c.vidUrl != ''
                                                                  ? () =>
                                                                      _launchURL(
                                                                        c.vidUrl!,
                                                                      )
                                                                  : null,
                                                          child: SelectableText.rich(
                                                            TextSpan(
                                                              text:
                                                                  c.vidUrl != ''
                                                                      ? c.vidUrl
                                                                      : 'N/A',
                                                              style: GoogleFonts.comfortaa(
                                                                color:
                                                                    Colors.blue,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                decorationColor:
                                                                    Colors.blue,
                                                              ),
                                                              recognizer:
                                                                  TapGestureRecognizer()
                                                                    ..onTap = () {
                                                                      if (c.vidUrl !=
                                                                          '') {
                                                                        final url =
                                                                            Uri.parse(
                                                                              c.vidUrl!,
                                                                            );
                                                                        launchUrl(
                                                                          url,
                                                                          mode:
                                                                              LaunchMode.externalApplication,
                                                                        );
                                                                      }
                                                                    },
                                                            ),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        bool?
                                                        confirmed = await showDialog(
                                                          context: context,
                                                          builder:
                                                              (
                                                                context,
                                                              ) => AlertDialog(
                                                                title: Text(
                                                                  'Confirm video deletion',
                                                                  style: GoogleFonts.comfortaa(
                                                                    color:
                                                                        widget.theme
                                                                            ? Colors.blue.shade600
                                                                            : Colors.green.shade600,
                                                                  ),
                                                                ),
                                                                content: Text(
                                                                  'Delete video with id ${c.cVidID}?',
                                                                  style: GoogleFonts.comfortaa(
                                                                    color:
                                                                        widget.theme
                                                                            ? Colors.blue.shade600
                                                                            : Colors.green.shade600,
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () => Navigator.pop(
                                                                          context,
                                                                          false,
                                                                        ),
                                                                    child: Text(
                                                                      'No',
                                                                      style: GoogleFonts.comfortaa(
                                                                        color:
                                                                            widget.theme
                                                                                ? Colors.blue.shade600
                                                                                : Colors.green.shade600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () => Navigator.pop(
                                                                          context,
                                                                          true,
                                                                        ),
                                                                    child: Text(
                                                                      'Yes, delete',
                                                                      style: GoogleFonts.comfortaa(
                                                                        color:
                                                                            widget.theme
                                                                                ? Colors.blue.shade600
                                                                                : Colors.green.shade600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                        );
                                                        if (confirmed!) {
                                                          // TODO: handle deleting videos
                                                          final loaderContext =
                                                              context;
                                                          showDialog(
                                                            context:
                                                                loaderContext,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => Center(
                                                                  child: CircularProgressIndicator(
                                                                    color:
                                                                        widget.theme
                                                                            ? Colors.blue.shade600
                                                                            : Colors.green.shade600,
                                                                  ),
                                                                ),
                                                          );

                                                          await _submitDeleteVideo(
                                                            c,
                                                          );
                                                          setState(() {
                                                            _fetchCoursesVideos();
                                                          });
                                                          await Future.delayed(
                                                            Duration(
                                                              seconds: 2,
                                                            ),
                                                          );

                                                          Navigator.of(
                                                            loaderContext,
                                                            rootNavigator: true,
                                                          ).pop();

                                                          showSnackBar(
                                                            widget.theme,
                                                            'File ${c.vTitle} deleted successfully',
                                                          );
                                                        }
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 3,
                                                              horizontal: 10,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        'Delete',
                                                        style:
                                                            GoogleFonts.comfortaa(
                                                              color:
                                                                  widget.theme
                                                                      ? Colors
                                                                          .white
                                                                      : darkBg,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Center(
                child: Text(
                  'No files yet',
                  style: GoogleFonts.comfortaa(
                    fontSize: 30,
                    color:
                        widget.theme
                            ? Colors.blue.shade600
                            : Colors.green.shade600,
                  ),
                ),
              ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  int getCourseEnrolls(Course c) {
    return dbEnrollmentList
        .where((e) => e.CourseID == c.courseID)
        .toList()
        .length;
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, webOnlyWindowName: '_blank')) {
      throw Exception('Could not launch $url');
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

  Future<void> _submitDeleteVideo(CourseVideo x) async {
    final Map<String, dynamic> dataToSend = {'cVideoID': x.cVidID};

    final url = Uri.parse('http://$serverUrl:3000/cVideo/delete');

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

  Future<void> _submitDeleteCourseFile(CourseFile x) async {
    final Map<String, dynamic> dataToSend = {'id': x.id};

    final url = Uri.parse('http://$serverUrl:3000/courseFile/delete');

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
