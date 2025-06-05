import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/adminPanel.dart';
import 'package:hardwaresimu_software_graduation_project/authService.dart';
import 'package:hardwaresimu_software_graduation_project/edit_profile.dart';
import 'package:hardwaresimu_software_graduation_project/main.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/signIn.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/signUp.dart';
import 'package:hardwaresimu_software_graduation_project/notificationsServices/firebaseNots.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webCommScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webSimScreen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:hardwaresimu_software_graduation_project/webPages/webAboutScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webCoursesScreen.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webContactScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webHomeScreen.dart';

class WebApp extends StatefulWidget {
  final bool isSignedIn;
  final User? user;
  final Widget? child;

  const WebApp({super.key, required this.isSignedIn, this.user, this.child});

  @override
  _WebApp createState() =>
      _WebApp(isSignedIn: this.isSignedIn, user: this.user);
}

class _WebApp extends State<WebApp> {
  final _isHover = [false, false, false, false, false, false];
  int currentIndex = 0;
  final GlobalKey<NavigatorState> webNavigatorKey = GlobalKey<NavigatorState>();
  bool isSignedIn;
  User? user;

  _WebApp({required this.isSignedIn, this.user});

  @override
  void initState() {
    super.initState();
    user = widget.user;
    initNotifsWeb();
  }

  void initNotifsWeb() async {
    if (isSignedIn) {
      final token = await FirebaseMessaging.instance.getToken(
        vapidKey:
            "BHjYyLt2_KvhyROh8oWMjrLbH9JT2_qJ5lrjb6uk07FpY58a1WstanrSfFWFkKrac0VyGD8NGT6j7UrdqpbS5oo",
      );
      print("FCM Token: $token");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isLightTheme = context.watch<SysThemes>().isLightTheme;

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      appBar:
          (screenSize.width > 800)
              ? PreferredSize(
                preferredSize: Size.fromHeight(65),
                child: Material(
                  elevation: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isLightTheme ? Colors.blue.shade600 : Colors.black,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20),
                        Text(
                          "CircuitAcademy",
                          style: GoogleFonts.comfortaa(
                            fontSize: 30,
                            color:
                                isLightTheme
                                    ? Colors.white
                                    : Colors.green.shade600,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Flexible(
                          child: Row(
                            children: [
                              const SizedBox(width: 35),
                              Expanded(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 150),
                                  padding: EdgeInsets.only(
                                    top: _isHover[0] ? 8 : 0,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      webNavigatorKey.currentState?.pushNamed(
                                        '/home',
                                      );
                                      /*GoRouter.of(context).push(
                                        '/home',
                                      );*/ // or .go() for just going
                                    },
                                    onHover: (value) {
                                      setState(() {
                                        _isHover[0] = value;
                                      });
                                    },
                                    child: Text(
                                      "Home",
                                      style: GoogleFonts.comfortaa(
                                        color:
                                            isLightTheme
                                                ? Colors.white
                                                : Colors.green.shade600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  padding: EdgeInsets.only(
                                    top: _isHover[5] ? 8 : 0,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      webNavigatorKey.currentState?.pushNamed(
                                        '/community',
                                      );
                                      /*GoRouter.of(context).push(
                                        '/community',
                                      );*/ // or .go() for just going
                                    },
                                    onHover: (value) {
                                      setState(() {
                                        _isHover[5] = value;
                                      });
                                    },
                                    child: Text(
                                      "Community",
                                      style: GoogleFonts.comfortaa(
                                        color:
                                            isLightTheme
                                                ? Colors.white
                                                : Colors.green.shade600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  padding: EdgeInsets.only(
                                    top: _isHover[1] ? 8 : 0,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      webNavigatorKey.currentState?.pushNamed(
                                        '/courses',
                                      );
                                      /*GoRouter.of(context).push(
                                        '/courses',
                                      );*/ // or .go() for just going
                                    },
                                    onHover: (value) {
                                      setState(() {
                                        _isHover[1] = value;
                                      });
                                    },
                                    child: Text(
                                      "Courses",
                                      style: GoogleFonts.comfortaa(
                                        color:
                                            isLightTheme
                                                ? Colors.white
                                                : Colors.green.shade600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  padding: EdgeInsets.only(
                                    top: _isHover[2] ? 8 : 0,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      webNavigatorKey.currentState?.pushNamed(
                                        '/simulator',
                                      );
                                      /*GoRouter.of(context).push(
                                        '/simulator',
                                      );*/ // or .go() for just going
                                    },
                                    onHover: (value) {
                                      setState(() {
                                        _isHover[2] = value;
                                      });
                                    },
                                    child: Text(
                                      "Simulator",
                                      style: GoogleFonts.comfortaa(
                                        color:
                                            isLightTheme
                                                ? Colors.white
                                                : Colors.green.shade600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  padding: EdgeInsets.only(
                                    top: _isHover[3] ? 8 : 0,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      webNavigatorKey.currentState?.pushNamed(
                                        '/about',
                                      );
                                      /*GoRouter.of(context).push(
                                        '/about',
                                      );*/ // or .go() for just going
                                    },
                                    onHover: (value) {
                                      setState(() {
                                        _isHover[3] = value;
                                      });
                                    },
                                    child: Text(
                                      "About us",
                                      style: GoogleFonts.comfortaa(
                                        color:
                                            isLightTheme
                                                ? Colors.white
                                                : Colors.green.shade600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  padding: EdgeInsets.only(
                                    top: _isHover[4] ? 8 : 0,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      webNavigatorKey.currentState?.pushNamed(
                                        '/contact',
                                      );
                                      /*GoRouter.of(context).push(
                                        '/contact',
                                      );*/ // or .go() for just going
                                    },
                                    onHover: (value) {
                                      setState(() {
                                        _isHover[4] = value;
                                      });
                                    },
                                    child: Text(
                                      "Contact us",
                                      style: GoogleFonts.comfortaa(
                                        color:
                                            isLightTheme
                                                ? Colors.white
                                                : Colors.green.shade600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 35),
                        InkWell(
                          onTap: () {
                            //Change theme here
                            context.read<SysThemes>().toggleTheme();
                          },
                          child: Icon(
                            isLightTheme
                                ? FontAwesomeIcons.moon
                                : FontAwesomeIcons.sun,
                            size: 30,
                            color:
                                isLightTheme
                                    ? Colors.white
                                    : Colors.yellow.shade600,
                          ),
                        ),
                        const SizedBox(width: 30),

                        Visibility(
                          visible: !isSignedIn,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SigninPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 20,
                              backgroundColor:
                                  isLightTheme
                                      ? Colors.white
                                      : Colors.green.shade600,
                              alignment: Alignment.centerRight,
                            ),
                            child: Text(
                              "Sign in",
                              style: TextStyle(
                                color:
                                    isLightTheme
                                        ? Colors.blue.shade600
                                        : Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Visibility(
                          visible: !isSignedIn,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 20,
                              backgroundColor:
                                  isLightTheme
                                      ? Colors.white
                                      : Colors.green.shade600,
                              alignment: Alignment.centerRight,
                            ),
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                color:
                                    isLightTheme
                                        ? Colors.blue.shade600
                                        : Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isSignedIn,
                          child: InkWell(
                            onTapDown: (details) {
                              final adjustedPos = Offset(
                                details.globalPosition.dx,
                                details.globalPosition.dy + 30,
                              );
                              showProfileList(
                                isLightTheme,
                                context,
                                adjustedPos,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color:
                                    isLightTheme
                                        ? Colors.white
                                        : Colors.yellow.shade600,
                                borderRadius: BorderRadius.circular(50),
                              ),

                              //child: CircleAvatar(
                              //radius: 25,
                              //backgroundColor: Colors.transparent,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child:
                                    (user == null ||
                                            user!.userID == 0 ||
                                            user!.profileImgUrl == null ||
                                            user!.profileImgUrl!.isEmpty ||
                                            user!.profileImgUrl == '' ||
                                            user!.profileImgUrl == 'defU')
                                        ? Tooltip(
                                          message: user!.userName,
                                          textStyle: GoogleFonts.comfortaa(
                                            color:
                                                isLightTheme
                                                    ? Colors.blue.shade600
                                                    : Colors.green.shade600,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isLightTheme
                                                    ? Colors.white
                                                    : darkBg,
                                          ),
                                          child: Image.asset(
                                            'Images/defProfile.jpg',
                                          ),
                                        )
                                        : Tooltip(
                                          message: user!.userName,
                                          textStyle: GoogleFonts.comfortaa(
                                            color:
                                                isLightTheme
                                                    ? Colors.blue.shade600
                                                    : Colors.green.shade600,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isLightTheme
                                                    ? Colors.white
                                                    : darkBg,
                                          ),
                                          child: CachedNetworkImage(
                                            //image.network
                                            imageUrl: user!.profileImgUrl ?? '',
                                            width: 55,
                                            height: 55,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                              ),
                              //),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : AppBar(
                elevation: 10,
                centerTitle: true,
                backgroundColor:
                    isLightTheme ? Colors.blue.shade600 : Colors.black,
                title: Text(
                  "CircuitAcademy",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                    fontSize: 30,
                    color: isLightTheme ? Colors.white : Colors.green.shade600,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
      body: //widget.child ?? WebHomeScreen(isSignedIn: isSignedIn)
          Navigator(
        key: webNavigatorKey,
        initialRoute: '/home',
        onGenerateRoute: (RouteSettings settings) {
          late Widget screen;
          switch (settings.name) {
            case '/home':
              screen = WebHomeScreen(isSignedIn: isSignedIn, user: user);
              break;
            case '/community':
              screen = WebCommScreen(isSignedIn: isSignedIn, user: user);
              break;
            case '/contact':
              screen = WebContactScreen();
              break;
            case '/courses':
              screen = WebCoursesScreen(isSignedIn: isSignedIn, user: user);
              break;
            case '/about':
              screen = WebAboutScreen();
              break;
            case '/simulator':
              screen = WebSimScreen(isSignedIn: isSignedIn);
              break;
            default:
              screen = WebHomeScreen(isSignedIn: isSignedIn);
              break;
          }
          return MaterialPageRoute(builder: (_) => screen);
        },
      ),
    );
  }

  void showProfileList(
    bool isLightTheme,
    BuildContext context,
    Offset position,
  ) async {
    final selected = await showMenu<String>(
      context: context,
      color: isLightTheme ? Colors.blue.shade600 : Colors.black,
      position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        if (user!.isAdmin)
          PopupMenuItem<String>(
            value: 'AdminPage',
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, size: 18),
                SizedBox(width: 8),
                Text(
                  'Go to admin panel',
                  style: GoogleFonts.comfortaa(
                    color: isLightTheme ? Colors.white : Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, size: 18),
              SizedBox(width: 8),
              Text(
                'Edit profile',
                style: GoogleFonts.comfortaa(
                  color: isLightTheme ? Colors.white : Colors.green.shade600,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'signout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18),
              SizedBox(width: 8),
              Text(
                'Sign Out',
                style: GoogleFonts.comfortaa(
                  color: isLightTheme ? Colors.white : Colors.green.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    //use this to go to profile settings page
    if (selected == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditProfile(theme: isLightTheme, user: user!),
        ),
      );
    }
    if (selected == 'signout') {
      signOutUser(user!.email);

      await AuthService.signOut();
      //print('Firebase signout successful');

      await messageSub?.cancel();
      messageSub = null;

      await messageSubBack?.cancel();
      messageSubBack = null;

      //todo: if it breaks something just delete it from here and main file
      if (kIsWeb) {
        setState(() {
          globalIsSignedIn = false;
          globalSignedUser = User(
            userID: 0,
            name: '',
            userName: '',
            email: '',
            password: '',
            isSignedIn: false,
            isAdmin: false,
            isVerified: false,
          );
        });

        print('globalIsSignedIn = $globalIsSignedIn');
        print('globalSignedUser = ${globalSignedUser.email}');
      }

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder:
              (context) => WebApp(
                isSignedIn: false,
                user: User(
                  isVerified: false,
                  userID: 0,
                  name: '',
                  userName: '',
                  email: '',
                  phoneNum: '',
                  password: '',
                  profileImgUrl: '',
                  isSignedIn: false,
                  isAdmin: false,
                ),
              ),
        ),
      );
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (context) => SigninPage()));
      showSnackBar(isLightTheme, 'Signed out successfully');
    }
    if (selected == "AdminPage") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminPanel(theme: isLightTheme, user: user!),
        ),
      );
    }
  }

  Future<void> signOutUser(String email) async {
    final Map<String, dynamic> dataToSend = {
      'email': email,
      'isSignedIn': false,
    };
    final url = Uri.parse('http://$serverUrl:3000/user/signout');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
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
}
