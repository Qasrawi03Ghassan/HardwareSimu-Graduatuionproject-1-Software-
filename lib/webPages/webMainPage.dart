import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/signIn.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webSimScreen.dart';
import 'package:provider/provider.dart';

import 'package:hardwaresimu_software_graduation_project/webPages/webAboutScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webCoursesScreen.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webContactScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webHomeScreen.dart';

class WebApp extends StatefulWidget {
  const WebApp({super.key});

  @override
  _WebApp createState() => _WebApp();
}

class _WebApp extends State<WebApp> {
  final _isHover = [false, false, false, false, false];
  int currentIndex = 0;
  final GlobalKey<NavigatorState> webNavigatorKey = GlobalKey<NavigatorState>();

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
                child: Container(
                  color: isLightTheme ? Colors.blue.shade600 : Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                                      '/webHomeScreen',
                                    );
                                  },
                                  onHover: (value) {
                                    setState(() {
                                      _isHover[0] = value;
                                    });
                                  },
                                  child: Text(
                                    "Home",
                                    style: TextStyle(
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
                                      '/webCoursesScreen',
                                    );
                                  },
                                  onHover: (value) {
                                    setState(() {
                                      _isHover[1] = value;
                                    });
                                  },
                                  child: Text(
                                    "Courses",
                                    style: TextStyle(
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
                                      '/webSimScreen',
                                    );
                                  },
                                  onHover: (value) {
                                    setState(() {
                                      _isHover[2] = value;
                                    });
                                  },
                                  child: Text(
                                    "Simulator",
                                    style: TextStyle(
                                      color:
                                          isLightTheme
                                              ? Colors.white
                                              : Colors.green.shade600,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
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
                                      '/webAboutScreen',
                                    );
                                  },
                                  onHover: (value) {
                                    setState(() {
                                      _isHover[3] = value;
                                    });
                                  },
                                  child: Text(
                                    "About us",
                                    style: TextStyle(
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
                                      '/webContactScreen',
                                    );
                                  },
                                  onHover: (value) {
                                    setState(() {
                                      _isHover[4] = value;
                                    });
                                  },
                                  child: Text(
                                    "Contact us",
                                    style: TextStyle(
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
                                  : Colors.green.shade600,
                        ),
                      ),
                      SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {
                          //Sign in here
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SigninPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
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
                    ],
                  ),
                ),
              )
              : AppBar(
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
      body: Navigator(
        key: webNavigatorKey,
        initialRoute: '/webHomeScreen',
        onGenerateRoute: (RouteSettings settings) {
          late Widget screen;
          switch (settings.name) {
            case '/webHomeScreen':
              screen = WebHomeScreen();
              break;
            case '/webContactScreen':
              screen = WebContactScreen();
              break;
            case '/webCoursesScreen':
              screen = WebCoursesScreen();
              break;
            case '/webAboutScreen':
              screen = WebAboutScreen();
              break;
            case '/webSimScreen':
              screen = WebSimScreen();
              break;
            default:
              screen = WebHomeScreen();
              break;
          }
          return MaterialPageRoute(builder: (_) => screen);
        },
      ),
    );
  }
}
