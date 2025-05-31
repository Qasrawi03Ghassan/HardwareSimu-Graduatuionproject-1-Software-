import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hardwaresimu_software_graduation_project/main.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/feedPage.dart';

import 'package:hardwaresimu_software_graduation_project/mobilePages/signUp.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/signIn.dart';
import 'package:hardwaresimu_software_graduation_project/authService.dart';
import 'package:hardwaresimu_software_graduation_project/themeMobile.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webCommScreen.dart';
import 'package:provider/provider.dart';

const darkBg = Color.fromARGB(255, 39, 41, 54);

class WelcomePage extends StatefulWidget {
  WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final AuthService _authService = AuthService();

  void showSnackBar(BuildContext context, bool barTheme, String text) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Provider.of<MobileThemeProvider>(
      context,
    ).isLightTheme(context);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: const Text(
            "Welcome",
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isLightTheme
                    ? [Colors.blue.shade100, Colors.blue.shade200]
                    : [Colors.black, const Color.fromARGB(255, 68, 71, 90)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        alignment: const Alignment(0, 0),
        child: Container(
          width: 350,
          height: 610,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            color: isLightTheme ? Colors.blue.shade500 : Colors.green.shade700,
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 60,
                      color: isLightTheme ? Colors.black26 : darkBg,
                      spreadRadius: 15,
                      blurStyle: BlurStyle.normal,
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(
                  left: 50,
                  right: 50,
                  top: 50,
                  bottom: 30,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    "Images/webIcon.png",
                    fit: BoxFit.cover,
                    width: 220,
                    height: 220,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SigninPage()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: isLightTheme ? Colors.white : darkBg,
                  ),
                  width: 300,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    "Sign in",
                    style: GoogleFonts.comfortaa(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: isLightTheme ? Colors.white : darkBg,
                  ),
                  margin: const EdgeInsets.only(top: 20, bottom: 35),
                  width: 300,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    "Create a new account",
                    style: GoogleFonts.comfortaa(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Text(
                "Or use the links below",
                style: GoogleFonts.comfortaa(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 10,
                  bottom: 30,
                  left: 30,
                  right: 30,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final User? user =
                            await _authService.signInWithGoogle();
                        if (!mounted) return;
                        if (user != null) {
                          print("Logged in via Google as: ${user.name}");
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => FeedPage(
                                    key: feedPageKey,
                                    user: user,
                                    selectedIndex: 0,
                                  ),
                            ),
                            (route) => false,
                          );
                          showSnackBar(
                            context,
                            isLightTheme,
                            'Welcome back ${user.name}',
                          );
                        } else {
                          showSnackBar(
                            context,
                            isLightTheme,
                            'Signing in via Google canceled',
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLightTheme ? Colors.white : darkBg,
                          borderRadius: BorderRadius.circular(200),
                        ),
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.all(10),
                        child: const Icon(FontAwesomeIcons.google, size: 40),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final User? user =
                            await _authService.signInWithMicrosoft();
                        if (!mounted) return;
                        if (user != null) {
                          print("Logged in via Microsoft as: ${user.name}");
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => FeedPage(
                                    key: feedPageKey,
                                    user: user,
                                    selectedIndex: 0,
                                  ),
                            ),
                            (route) => false,
                          );
                          showSnackBar(
                            context,
                            isLightTheme,
                            'Welcome back ${user.name}',
                          );
                        } else {
                          showSnackBar(
                            context,
                            isLightTheme,
                            'Signing in via Microsoft canceled',
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLightTheme ? Colors.white : darkBg,
                          borderRadius: BorderRadius.circular(200),
                        ),
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.all(10),
                        child: const Icon(FontAwesomeIcons.microsoft, size: 40),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final User? user =
                            await _authService.signInWithGitHub();
                        if (!mounted) return;
                        if (user != null) {
                          print("Logged in via GitHub as: ${user.name}");
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => FeedPage(
                                    key: feedPageKey,
                                    user: user,
                                    selectedIndex: 0,
                                  ),
                            ),
                            (route) => false,
                          );
                          showSnackBar(
                            context,
                            isLightTheme,
                            'Welcome back ${user.name}',
                          );
                        } else {
                          showSnackBar(
                            context,
                            isLightTheme,
                            'Signing in via Github canceled',
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLightTheme ? Colors.white : darkBg,
                          borderRadius: BorderRadius.circular(200),
                        ),
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.all(10),
                        child: const Icon(FontAwesomeIcons.github, size: 40),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
