import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class WebCommScreen extends StatefulWidget {
  final bool isSignedIn;
  final User? user;
  const WebCommScreen({super.key, required this.isSignedIn, this.user});

  @override
  State<WebCommScreen> createState() =>
      _WebCommScreenState(isSignedIn: this.isSignedIn, user: this.user);
}

class _WebCommScreenState extends State<WebCommScreen> {
  bool isImagePost = false;
  bool isCourseFeed = false;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _controller = ScrollController();
  bool isSignedIn;
  User? user;
  _WebCommScreenState({required this.isSignedIn, this.user});

  String initFeed = 'Choose a course subfeed from the list on the left';
  String newPostText = '';

  List<Widget> postsList = [];
  List<Post> dbPostsList = [];

  List<String> coursesTitles = [];
  List<Course> dbCoursesList = [];

  Future<void> _fetchPosts() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/posts'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbPostsList = json.map((item) => Post.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> _fetchCourses() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/courses'),
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

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _fetchCourses();
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = context.watch<SysThemes>().isLightTheme;

    return Scaffold(
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
                              builder: (context) => WebApp(isSignedIn: false),
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
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Visibility(
                            visible: isCourseFeed,
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
                                    isLightTheme ? Colors.white : Colors.black,
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
                            child: Text(
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
                    VerticalDivider(
                      thickness: 3,
                      color: isLightTheme ? Colors.blue.shade600 : Colors.black,
                    ),
                    //-------------------------------------------------------------------------------------
                    Expanded(
                      flex: 6,

                      child: Container(
                        //color: Colors.amber,
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 80),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: postsList,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 80,
                              alignment: Alignment.center,
                              child: Text(
                                initFeed,
                                style: GoogleFonts.comfortaa(
                                  fontSize: 35,
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
                    SizedBox(width: 20),
                    VerticalDivider(
                      thickness: 3,
                      color: isLightTheme ? Colors.blue.shade600 : Colors.black,
                    ),
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.topCenter,
                              margin: EdgeInsets.symmetric(vertical: 15),
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Friends',
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
                            // const SizedBox(height: 20),
                            // buildFriend(isLightTheme),
                            // const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  void showCourseFeed(int courseID, int postCourseID) {}

  //This function returns the left list of buttons for courses subfeeds
  List<Widget> coursesSubFeedsButtons(
    bool theme,
    int count,
    List<String> coursesTitles,
  ) {
    if (coursesTitles.isNotEmpty) {
      return List.generate(count * 2 - 1, (index) {
        if (index.isEven) {
          final buttonIndex = index ~/ 2;
          return SizedBox(
            width: 350,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    theme ? Colors.blue.shade600 : Colors.green.shade600,
                padding: EdgeInsets.all(20),
              ),
              onPressed: () {
                setState(() {
                  postsList.clear();
                  isCourseFeed = true;
                  initFeed = 'This subfeed is empty';
                  for (int i = 0; i < dbPostsList.length; i++) {
                    if (dbPostsList[i].courseID ==
                        dbCoursesList[buttonIndex].id) {
                      initFeed = 'Scroll through your feed here';
                      postsList.add(buildPost(dbPostsList[i].description));
                      postsList.add(const SizedBox(height: 10));
                    }
                  }
                });
              },
              child: Text(
                coursesTitles[buttonIndex],
                style: GoogleFonts.comfortaa(
                  color: theme ? Colors.white : Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          );
        } else {
          return const SizedBox(height: 10);
        }
      });
    } else {
      return [];
    }
  }

  void showCreatePost(bool theme, BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme ? Colors.white : Colors.black,
          content: Container(
            width: 600,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        //Must put await here
                        setState(() {
                          isImagePost = true;
                        });
                        uploadImage();
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
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(12),
                          backgroundColor:
                              theme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                        onPressed: () {
                          if (newPostText.isNotEmpty || isImagePost == true) {
                            setState(() {
                              postsList.add(buildPost(newPostText));
                              postsList.add(const SizedBox(height: 10));
                              Navigator.pop(context);
                              isImagePost = false;
                              initFeed = 'Scroll through your feed here';
                            });
                          } else {
                            setState(() {
                              showSnackBar(
                                theme,
                                'Please enter text or add an image for the post.',
                              );
                            });
                          }
                        },
                        child: Text(
                          "Submit post",
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
  }

  void uploadImage() {}

  //Use this function to build the post design when signed in
  Container buildPost(String text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.green.shade600],
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
                child: Image.asset(
                  'Images/defProfile.jpg',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '\$Username\n\$Fullname',
                style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white),
              ),
              Expanded(child: SizedBox(width: 10)),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              text,
              style: GoogleFonts.comfortaa(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
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
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset('Images/courseExample.webp'),
                ),
              ),
            ),
          ),
        ],
      ),
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

  // Container buildPost(bool isLightTheme) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 20),
  //     padding: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(30),
  //       color: isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
  //     ),
  //     width: 700,
  //     height: 700,
  //     child: Stack(
  //       children: [
  //         // Post content
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const SizedBox(height: 40), // space under icons
  //             // Post Text/Image
  //             Expanded(
  //               child: Center(
  //                 child: Text(
  //                   'This is a sample post. You can also add an image here.',
  //                   style: TextStyle(color: Colors.white, fontSize: 20),
  //                 ),
  //               ),
  //             ),

  //             // Bottom action buttons
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 IconButton(
  //                   icon: Icon(Icons.favorite_border, color: Colors.white),
  //                   onPressed: () {
  //                     // handle like
  //                   },
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.share, color: Colors.white),
  //                   onPressed: () {
  //                     // handle share
  //                   },
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.comment, color: Colors.white),
  //                   onPressed: () {
  //                     showDialog(
  //                       context: context,
  //                       builder:
  //                           (context) => Dialog(
  //                             child: Container(
  //                               width: 600,
  //                               height: 600,
  //                               padding: EdgeInsets.all(20),
  //                               child: Column(
  //                                 children: [
  //                                   Text(
  //                                     "Post Content Here",
  //                                     style: TextStyle(
  //                                       fontSize: 24,
  //                                       fontWeight: FontWeight.bold,
  //                                     ),
  //                                   ),
  //                                   Divider(),
  //                                   Expanded(
  //                                     child: ListView.builder(
  //                                       itemCount: 5,
  //                                       itemBuilder:
  //                                           (context, index) => ListTile(
  //                                             title: Text("Comment #$index"),
  //                                           ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                     );
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),

  //         // Top right buttons (edit/delete)
  //         Positioned(
  //           top: 0,
  //           right: 0,
  //           child: Row(
  //             children: [
  //               IconButton(
  //                 icon: Icon(Icons.edit, color: Colors.white),
  //                 onPressed: () {
  //                   showDialog(
  //                     context: context,
  //                     builder:
  //                         (context) => Dialog(
  //                           child: Container(
  //                             width: 600,
  //                             padding: EdgeInsets.all(20),
  //                             child: Column(
  //                               mainAxisSize: MainAxisSize.min,
  //                               children: [
  //                                 Text(
  //                                   "Edit Post",
  //                                   style: TextStyle(
  //                                     fontSize: 22,
  //                                     fontWeight: FontWeight.bold,
  //                                   ),
  //                                 ),
  //                                 TextField(
  //                                   decoration: InputDecoration(
  //                                     labelText: "Edit your post",
  //                                   ),
  //                                 ),
  //                                 const SizedBox(height: 20),
  //                                 ElevatedButton(
  //                                   onPressed: () {
  //                                     // save edit
  //                                     Navigator.pop(context);
  //                                   },
  //                                   child: Text("Save Changes"),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                   );
  //                 },
  //               ),
  //               IconButton(
  //                 icon: Icon(Icons.delete, color: Colors.white),
  //                 onPressed: () {
  //                   // handle delete
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Container buildFriend(bool isLightTheme) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 20),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       color: isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
  //     ),
  //     height: 80,
  //   );
  // }
}
