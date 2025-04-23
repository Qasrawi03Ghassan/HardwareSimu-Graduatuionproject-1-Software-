import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
                : Stack(
                  children: [
                    ScrollConfiguration(
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(scrollbars: false),
                      child: WebSmoothScroll(
                        scrollSpeed: 3.2,
                        controller: _controller,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: _controller,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 50),
                              Text(
                                'Scroll through posts here',
                                style: GoogleFonts.comfortaa(
                                  fontSize: 50,
                                  color:
                                      isLightTheme
                                          ? Colors.blue.shade600
                                          : Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(height: 50),
                              buildPost(isLightTheme),
                              const SizedBox(height: 10),
                              buildPost(isLightTheme),
                              const SizedBox(height: 10),
                              buildPost(isLightTheme),
                              const SizedBox(height: 10),
                              buildPost(isLightTheme),
                              const SizedBox(height: 10),
                              buildPost(isLightTheme),
                              const SizedBox(height: 10),
                              buildPost(isLightTheme),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  //Use this function to build the post design when signed in
  Container buildPost(bool isLightTheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
      ),
      width: 600,
      height: 800,
    );
  }
}
