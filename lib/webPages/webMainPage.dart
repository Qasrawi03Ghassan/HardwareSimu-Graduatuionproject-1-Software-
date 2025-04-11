import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/ContactPage.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';

import 'package:hardwaresimu_software_graduation_project/mobilePages/signIn.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';

class WebApp extends StatefulWidget {
  const WebApp({super.key});

  @override
  _WebApp createState() => _WebApp();
}

class _WebApp extends State<WebApp> {
  final _controller = ScrollController();
  final _isHover = [false, false, false, false, false];
  bool isLightTheme = true;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
                      //SizedBox(width: 400),
                      Flexible(
                        child: Row(
                          children: [
                            Expanded(
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 150),
                                padding: EdgeInsets.only(
                                  top: _isHover[0] ? 8 : 0,
                                ),
                                child: InkWell(
                                  onTap: () {},
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
                                  onTap: () {},
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
                                  onTap: () {},
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
                                  onTap: () {},
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ContactPage(),
                                      ),
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
                      InkWell(
                        onTap: () {
                          //Change theme here
                          setState(() {
                            isLightTheme = !isLightTheme;
                          });
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
      body: WebSmoothScroll(
        scrollSpeed: 1,
        controller: _controller,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _controller,
          child: Column(
            children: [
              SizedBox(height: 250),
              Center(
                child: Text(
                  "Welcome to CircuitAcademy",
                  style: GoogleFonts.comfortaa(
                    fontSize: screenSize.width / 18,
                    fontWeight: FontWeight.w900,
                    color: isLightTheme ? Colors.black : Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 500),
              Container(
                height: 500,
                color:
                    isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
                child: Row(),
              ),
              SizedBox(height: 700),
            ],
          ),
        ),
      ),
    );
  }
}
