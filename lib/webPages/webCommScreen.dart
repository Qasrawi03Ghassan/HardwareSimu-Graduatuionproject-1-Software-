import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/signIn.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/signUp.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';
import 'package:provider/provider.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';

class WebCommScreen extends StatefulWidget {
  final bool isSignedIn;
  WebCommScreen({super.key, required this.isSignedIn});

  @override
  State<WebCommScreen> createState() =>
      _WebCommScreenState(isSignedIn: this.isSignedIn);
}

class _WebCommScreenState extends State<WebCommScreen> {
  final ScrollController _controller = ScrollController();
  bool isSignedIn;
  _WebCommScreenState({required this.isSignedIn});

  String initFeed = 'Your feed is empty';
  String newPostText = '';
  List<Widget> postsList = [];
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
                    //Expanded(flex: 2, child: SizedBox()),
                    //-----------------------------Create post---------------------------
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            onPressed: () {
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
                        ],
                      ),
                    ),
                    //-------------------------------------------------------------------------------------
                    Expanded(
                      flex: 5,
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
                    SizedBox(width: 20),
                    VerticalDivider(
                      thickness: 3,
                      color:
                          isLightTheme
                              ? Colors.blue.shade600
                              : Colors.green.shade600,
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
                            const SizedBox(height: 20),
                            buildFriend(isLightTheme),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  void showCreatePost(bool theme, BuildContext context) {
    showDialog(
      barrierColor: theme ? Colors.white : darkBg,
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
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
                        "Create a New Post",
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
                  TextField(
                    decoration: InputDecoration(
                      labelText: "What's on your mind?",
                    ),
                    maxLines: 5,
                    onChanged: (value) => newPostText = value,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // handle post creation
                      setState(() {
                        postsList.add(buildPost(newPostText, theme));
                        postsList.add(const SizedBox(height: 10));
                        initFeed = 'Scroll through your feed here';
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Post"),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void uploadImage() {}

  //Use this function to build the post design when signed in
  Container buildPost(String text, bool isLightTheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),

        color: isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
      ),
      width: 700,
      height: 700,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
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
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  color: isLightTheme ? Colors.white : Colors.black,
                ),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
          Container(padding: EdgeInsets.all(15), child: Placeholder()),
        ],
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

  Container buildFriend(bool isLightTheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
      ),
      height: 80,
    );
  }
}
