import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/comments.dart';
import 'package:hardwaresimu_software_graduation_project/courseVideo.dart';
import 'package:hardwaresimu_software_graduation_project/courses.dart';
import 'package:hardwaresimu_software_graduation_project/edit_profile.dart';
import 'package:hardwaresimu_software_graduation_project/main.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/posts.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PostsPage extends StatefulWidget {
  final bool theme;
  final User user;
  const PostsPage({super.key, required this.theme, required this.user});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  List<Comment> dbCommentsList = [];
  List<Post> dbPostsList = [];
  List<Course> dbCoursesList = [];
  List<PostFile> dbPostFilesList = [];

  Timer? _refreshTimer;

  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _fetchCourses();
    _fetchPosts();
    _fetchPostFiles();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, webOnlyWindowName: '_blank')) {
      throw Exception('Could not launch $url');
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
      throw Exception('Failed to load certificates');
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
    } else {
      throw Exception('Failed to load post files');
    }
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
      throw Exception('Failed to load users');
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        _fetchComments();
        _fetchPosts();
      }
    });
  }

  String getCourseTitle(Post post) {
    return dbCoursesList
        .firstWhere((course) => course.courseID == post.courseID)
        .title;
  }

  int getImagePostsNum() {
    return dbPostsList
        .where((post) => post.imageUrl.isNotEmpty)
        .toList()
        .length;
  }

  PostFile? getPostFile(int postID) {
    return dbPostFilesList.cast<PostFile?>().firstWhere(
      (file) => file?.postID == postID,
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stats = [
      {
        'label': 'Image posts',
        'count': getImagePostsNum(),
        'icon': Icons.image,
        'color': Colors.blue,
      },
      {
        'label': 'File posts',
        'count': dbPostFilesList.length,
        'icon': FontAwesomeIcons.file,
        'color': Colors.green,
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
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children:
                  stats.map((stat) {
                    return Container(
                      width: 420,
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

          //Posts table
          dbPostsList.isNotEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Posts information',
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
                  Container(
                    height: 500,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Scrollbar(
                        controller: _horizontalController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          primary: false,
                          controller: _horizontalController,
                          scrollDirection: Axis.horizontal,
                          child: Scrollbar(
                            controller: _verticalController,
                            thumbVisibility: true,
                            notificationPredicate:
                                (notification) =>
                                    notification.metrics.axis == Axis.vertical,
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
                                        'ID',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Center(
                                        child: Text(
                                          'Course title',
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
                                          'Author\'s email',
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
                                          'Image URL',
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
                                          'File URL',
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
                                          'Delete post',
                                          style: GoogleFonts.comfortaa(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                rows:
                                    (dbPostsList.toList()..sort(
                                          (a, b) =>
                                              a.postID.compareTo(b.postID),
                                        ))
                                        .map(
                                          (post) => DataRow(
                                            cells: [
                                              DataCell(
                                                Center(
                                                  child: Text(
                                                    post.postID.toString(),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: SizedBox(
                                                    width: 300,
                                                    child: Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          GoogleFonts.comfortaa(),
                                                      getCourseTitle(post),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: Text(
                                                    style:
                                                        GoogleFonts.comfortaa(),
                                                    post.userEmail,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: SizedBox(
                                                    width: 300,
                                                    child: Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          GoogleFonts.comfortaa(),
                                                      post.description,
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
                                                            () => _launchURL(
                                                              post.imageUrl,
                                                            ),
                                                        child: SelectableText.rich(
                                                          textAlign:
                                                              TextAlign.center,
                                                          TextSpan(
                                                            text:
                                                                post.imageUrl !=
                                                                        ''
                                                                    ? post
                                                                        .imageUrl
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
                                                                    if (post.imageUrl !=
                                                                        '') {
                                                                      final url =
                                                                          Uri.parse(
                                                                            post.imageUrl,
                                                                          );
                                                                      launchUrl(
                                                                        url,
                                                                        mode:
                                                                            LaunchMode.externalApplication,
                                                                      );
                                                                    }
                                                                  },
                                                          ),
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
                                                      child: GestureDetector(
                                                        onTap:
                                                            () => _launchURL(
                                                              (getPostFile(
                                                                            post.postID,
                                                                          ) !=
                                                                          null &&
                                                                      getPostFile(
                                                                            post.postID,
                                                                          ) !=
                                                                          '')
                                                                  ? getPostFile(
                                                                    post.postID,
                                                                  )!.fileUrl!
                                                                  : 'N/A',
                                                            ),
                                                        child: SelectableText.rich(
                                                          textAlign:
                                                              TextAlign.center,
                                                          TextSpan(
                                                            text:
                                                                (getPostFile(
                                                                              post.postID,
                                                                            ) !=
                                                                            null &&
                                                                        getPostFile(
                                                                              post.postID,
                                                                            ) !=
                                                                            '')
                                                                    ? getPostFile(
                                                                      post.postID,
                                                                    )!.fileUrl!
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
                                                                    if (getPostFile(
                                                                          post.postID,
                                                                        )!.fileUrl !=
                                                                        '') {
                                                                      final url = Uri.parse(
                                                                        (getPostFile(
                                                                                      post.postID,
                                                                                    ) !=
                                                                                    null &&
                                                                                getPostFile(
                                                                                      post.postID,
                                                                                    ) !=
                                                                                    '')
                                                                            ? getPostFile(
                                                                              post.postID,
                                                                            )!.fileUrl!
                                                                            : 'N/A',
                                                                      );
                                                                      launchUrl(
                                                                        url,
                                                                        mode:
                                                                            LaunchMode.externalApplication,
                                                                      );
                                                                    }
                                                                  },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () async {
                                                      bool?
                                                      confirmed = await showDialog(
                                                        context: context,
                                                        builder:
                                                            (
                                                              context,
                                                            ) => AlertDialog(
                                                              title: Text(
                                                                'Confirm post deletion',
                                                                style: GoogleFonts.comfortaa(
                                                                  color:
                                                                      widget.theme
                                                                          ? Colors
                                                                              .blue
                                                                              .shade600
                                                                          : Colors
                                                                              .green
                                                                              .shade600,
                                                                ),
                                                              ),
                                                              content: Text(
                                                                'Delete post with id ${post.postID}?',
                                                                style: GoogleFonts.comfortaa(
                                                                  color:
                                                                      widget.theme
                                                                          ? Colors
                                                                              .blue
                                                                              .shade600
                                                                          : Colors
                                                                              .green
                                                                              .shade600,
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
                                                                    'Yes',
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
                                                        //todo copy video deletion logic from comm page
                                                        await _submitDeletePost(
                                                          post,
                                                        );

                                                        final postFiles =
                                                            getPostFiles(post);

                                                        await Future.wait(
                                                          postFiles.map(
                                                            (file) =>
                                                                deletePostFile(
                                                                  file.fileName,
                                                                ),
                                                          ),
                                                        );

                                                        showSnackBar(
                                                          widget.theme,
                                                          'Post deleted successfully',
                                                        );
                                                      }
                                                    },
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                    label: Icon(
                                                      FontAwesomeIcons.trash,
                                                      color:
                                                          widget.theme
                                                              ? Colors.white
                                                              : darkBg,
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
                ],
              )
              : Center(
                child: Text(
                  'No posts to show',
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

          //comments table
          dbPostsList.isNotEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Comments information',
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
                  Container(
                    height: 500,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          dataRowMinHeight: 50,
                          dataRowMaxHeight: 150,
                          columns: [
                            DataColumn(
                              label: Center(
                                child: Text(
                                  style: GoogleFonts.comfortaa(),
                                  'ID',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Center(
                                  child: Text(
                                    'Post ID',
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
                                    'Author\'s email',
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
                                    'Sharing date',
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
                                    'Delete comment',
                                    style: GoogleFonts.comfortaa(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          rows:
                              (dbCommentsList.toList()..sort(
                                    (a, b) =>
                                        a.commentID.compareTo(b.commentID),
                                  ))
                                  .map(
                                    (post) => DataRow(
                                      cells: [
                                        DataCell(
                                          Center(
                                            child: Text(
                                              post.commentID.toString(),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: SizedBox(
                                              width: 300,
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.comfortaa(),
                                                post.postID.toString(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              style: GoogleFonts.comfortaa(),
                                              post.userEmail,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: SizedBox(
                                              width: 300,
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.comfortaa(),
                                                post.description,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                              child: SizedBox(
                                                width: 300,
                                                child: Text(
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      GoogleFonts.comfortaa(),
                                                  DateFormat(
                                                    'yyyy-MM-dd-hh a',
                                                  ).format(post.createdAt),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                bool?
                                                confirmed = await showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                        title: Text(
                                                          'Confirm comment deletion',
                                                          style: GoogleFonts.comfortaa(
                                                            color:
                                                                widget.theme
                                                                    ? Colors
                                                                        .blue
                                                                        .shade600
                                                                    : Colors
                                                                        .green
                                                                        .shade600,
                                                          ),
                                                        ),
                                                        content: Text(
                                                          'Delete comment with id ${post.commentID}?',
                                                          style: GoogleFonts.comfortaa(
                                                            color:
                                                                widget.theme
                                                                    ? Colors
                                                                        .blue
                                                                        .shade600
                                                                    : Colors
                                                                        .green
                                                                        .shade600,
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      false,
                                                                    ),
                                                            child: Text(
                                                              'No',
                                                              style: GoogleFonts.comfortaa(
                                                                color:
                                                                    widget.theme
                                                                        ? Colors
                                                                            .blue
                                                                            .shade600
                                                                        : Colors
                                                                            .green
                                                                            .shade600,
                                                              ),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      true,
                                                                    ),
                                                            child: Text(
                                                              'Yes',
                                                              style: GoogleFonts.comfortaa(
                                                                color:
                                                                    widget.theme
                                                                        ? Colors
                                                                            .blue
                                                                            .shade600
                                                                        : Colors
                                                                            .green
                                                                            .shade600,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );
                                                if (confirmed!) {
                                                  await _submitDeleteComment(
                                                    post,
                                                  );

                                                  showSnackBar(
                                                    widget.theme,
                                                    'Comment deleted successfully',
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              label: Icon(
                                                FontAwesomeIcons.trash,
                                                color:
                                                    widget.theme
                                                        ? Colors.white
                                                        : darkBg,
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
                  const SizedBox(height: 30),
                ],
              )
              : Center(
                child: Text(
                  'No comments to show',
                  style: GoogleFonts.comfortaa(
                    fontSize: 30,
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

  List<PostFile> getPostFiles(Post x) {
    return dbPostFilesList.where((file) => file.postID == x.postID).toList();
  }

  Future<void> submitDeleteUser(User x) async {
    final Map<String, dynamic> dataToSend = {'id': x.userID};

    final url = Uri.parse('http://$serverUrl:3000/user/delete');

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

  Future<void> submitVerifyUser(User x) async {
    final Map<String, dynamic> dataToSend = {'userID': x.userID};

    final url = Uri.parse('http://$serverUrl:3000/user/setVer');

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

  Future<void> deleteRequest(Request x) async {
    final Map<String, dynamic> dataToSend = {'id': x.id};

    final url = Uri.parse('http://$serverUrl:3000/reqs/delete');

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
