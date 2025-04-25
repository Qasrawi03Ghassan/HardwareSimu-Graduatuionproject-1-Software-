import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webCommScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webCoursesScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webSimScreen.dart';
import 'package:provider/provider.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';

import 'package:hardwaresimu_software_graduation_project/theme.dart';

class WebHomeScreen extends StatefulWidget {
  final bool isSignedIn;
  const WebHomeScreen({super.key, required this.isSignedIn});

  @override
  State<WebHomeScreen> createState() =>
      _WebHomeScreenState(isSignedIn: isSignedIn);
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  final bool isSignedIn;
  _WebHomeScreenState({required this.isSignedIn});
  final ScrollController _controller = ScrollController();
  bool _showBackToTop = false;
  // final bool _isHoverCourses = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.offset > 600 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_controller.offset <= 600 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });
  }

  void _scrollToTop() {
    _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late BuildContext cContext;
  @override
  Widget build(BuildContext context) {
    cContext = context;
    final screenSize = MediaQuery.of(context).size;
    bool isLightTheme = context.watch<SysThemes>().isLightTheme;
    return Stack(
      children: [
        WebSmoothScroll(
          scrollSpeed: 2.2,
          controller: _controller,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _controller,
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 70, top: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(300),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    isLightTheme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                                blurRadius: 300,
                                spreadRadius: 50,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'Images/webIcon.png',
                            width: 400,
                          ), //width:450
                        ),
                        Text(
                          "Welcome to CircuitAcademy",
                          style: GoogleFonts.comfortaa(
                            fontSize: screenSize.width / 26,
                            fontWeight: FontWeight.w900,
                            color: isLightTheme ? Colors.black : Colors.white,
                          ),
                        ),
                        Text(
                          "Design, simulate, learn and master electronics with our web-based simulator platform",
                          style: GoogleFonts.comfortaa(
                            fontSize: screenSize.width / 100,
                            color: isLightTheme ? Colors.black : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 70),
                        Container(
                          alignment: Alignment.center,
                          //                    color: Colors.amber,
                          width: 800,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebCoursesScreen(),
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
                                  'Explore courses',
                                  style: GoogleFonts.comfortaa(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => WebSimScreen(
                                            isSignedIn: isSignedIn,
                                          ),
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
                                  'Start simulating',
                                  style: GoogleFonts.comfortaa(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  (screenSize.width > 800)
                      ? Container(
                        margin: EdgeInsets.only(top: 150),
                        color:
                            isLightTheme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 50,
                          children: [
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 400.0,
                                enlargeCenterPage: true,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    currentIndex = index;
                                  });
                                },
                                autoPlay: true,
                                autoPlayAnimationDuration: Duration(
                                  milliseconds: 1300,
                                ),
                                autoPlayInterval: Duration(seconds: 3),
                                autoPlayCurve: Curves.easeOutCirc,
                              ),
                              items: buildCList(isLightTheme, screenSize),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: DotsIndicator(
                                dotsCount: 3,
                                position: currentIndex.toDouble(),
                                decorator: DotsDecorator(
                                  activeColor:
                                      isLightTheme
                                          ? Colors.white
                                          : Colors.black,
                                  size: const Size.square(9),
                                  activeSize: const Size(18, 9),
                                  activeShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  spacing: const EdgeInsets.all(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : SizedBox(height: 0),
                  Column(
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        'Try our NGSpice-based simulator - No download needed!',
                        style: GoogleFonts.comfortaa(
                          fontSize: 50,
                          color:
                              isLightTheme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 500,
                        width: 500,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1000),
                          color:
                              isLightTheme ? Colors.transparent : Colors.white,
                        ),
                        //width: 500,
                        alignment: Alignment.center,
                        child: Image.asset('Images/cct.gif', fit: BoxFit.fill),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Sample design of a circuit',
                        style: GoogleFonts.comfortaa(
                          fontSize: 16,
                          color: isLightTheme ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(15),
                          backgroundColor:
                              isLightTheme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                        onPressed: () {},
                        child: Text(
                          'Try sample circuit',
                          style: GoogleFonts.comfortaa(
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      buildGridCourses(isLightTheme, screenSize),
                      const SizedBox(height: 50),

                      Text(
                        'Join our community platform now',
                        style: GoogleFonts.comfortaa(
                          fontSize: 60,
                          color:
                              isLightTheme
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                        ),
                      ),

                      //Implement social part here
                      Container(
                        width: screenSize.width,
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.comfortaa(
                                  fontSize: 20,
                                  color:
                                      isLightTheme
                                          ? Colors.black
                                          : Colors.white,
                                ),
                                children: <TextSpan>[
                                  TextSpan(text: 'BE'),
                                  TextSpan(
                                    text: ' ACTIVE\n\n',
                                    style: GoogleFonts.comfortaa(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          isLightTheme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Contribute ',
                                    style: GoogleFonts.comfortaa(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          isLightTheme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'in our community that connects students and lecturers ',
                                  ),
                                  TextSpan(
                                    text: 'productively',
                                    style: GoogleFonts.comfortaa(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          isLightTheme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              'Images/social.png',
                              width: screenSize.width / 3,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: screenSize.width,
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.symmetric(horizontal: 100),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'Images/chat.png',
                              width: screenSize.width / 3,
                            ),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.comfortaa(
                                  fontSize: 20,
                                  color:
                                      isLightTheme
                                          ? Colors.black
                                          : Colors.white,
                                ),
                                children: <TextSpan>[
                                  TextSpan(text: 'Reach others '),
                                  TextSpan(
                                    text: 'EASILY\n\n',
                                    style: GoogleFonts.comfortaa(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          isLightTheme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Chat ',
                                    style: GoogleFonts.comfortaa(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          isLightTheme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'with hundreds of students and ask lecturers as you like ',
                                  ),
                                  TextSpan(
                                    text: 'anywhere',
                                    style: GoogleFonts.comfortaa(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          isLightTheme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: screenSize.width,
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.symmetric(horizontal: 100),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.comfortaa(
                                  fontSize: 20,
                                  color:
                                      isLightTheme
                                          ? Colors.black
                                          : Colors.white,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'SHARE\n',
                                    style: GoogleFonts.comfortaa(
                                      fontSize: 60,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          isLightTheme
                                              ? Colors.blue.shade600
                                              : Colors.green.shade600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'your simulation files with others',
                                    style: GoogleFonts.comfortaa(fontSize: 30),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              'Images/share.png',
                              width: screenSize.width / 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(20),
                      backgroundColor:
                          isLightTheme
                              ? Colors.blue.shade600
                              : Colors.green.shade600,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  WebCommScreen(isSignedIn: isSignedIn),
                        ),
                      );
                    },
                    child: Text(
                      !isSignedIn ? 'JOIN NOW' : 'Check community',
                      style: GoogleFonts.comfortaa(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    height: 150,
                    child: Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.all(10),
                      color: isLightTheme ? Colors.blue.shade600 : Colors.black,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'CircuitAcademy',
                            style: GoogleFonts.comfortaa(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color:
                                  isLightTheme
                                      ? Colors.white
                                      : Colors.green.shade600,
                            ),
                          ),
                          Row(
                            spacing: 30,
                            children: [
                              Text(
                                'Developed and maintained by:\nGhassan Qasrawi\nAdel Qadi',
                                style: GoogleFonts.comfortaa(
                                  fontSize: 18,
                                  color:
                                      isLightTheme
                                          ? Colors.white
                                          : Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          bottom: 24,
          right: _showBackToTop ? 24 : -100, // Slide in/out from the side
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _showBackToTop ? 1.0 : 0.0,
            child: FloatingActionButton.small(
              elevation: 10,
              backgroundColor:
                  isLightTheme ? Colors.blue.shade400 : Colors.green.shade600,
              onPressed: _scrollToTop,
              child: Icon(
                FontAwesomeIcons.arrowUp,
                size: 25,
                color: isLightTheme ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGridCourses(bool isLightTheme, Size sSize) {
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 50),
      width: 1500,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Check some of the provided courses',
              style: GoogleFonts.comfortaa(
                fontSize: 60,
                color:
                    isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 4,
              children: List.generate(4, (index) {
                return SizedBox(
                  child: Card(
                    color:
                        isLightTheme
                            ? Colors.blue.shade600
                            : Colors.green.shade600,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    index == 0
                                        ? 'Nodal Linear Circuits 1 - 14 - Nodal Analysis, Part 1'
                                        : index == 1
                                        ? 'Linear Circuits 1 - 15 - Nodal Analysis, Part 2'
                                        : index == 2
                                        ? 'Circuits and Electronics 1: Basic Circuit Analysis'
                                        : 'Linear Circuits 1: DC Analysis',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          isLightTheme
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    index == 0
                                        ? 'By Mark Budnik'
                                        : index == 1
                                        ? 'By Mark Budnik'
                                        : index == 2
                                        ? 'By Massachusetts Institute of Technology'
                                        : 'By Dr. Bonnie H. Ferri and 2 others',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          isLightTheme
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 60),
                                Text(
                                  index == 0
                                      ? 'Beginner - 40 mins'
                                      : index == 1
                                      ? 'Beginner - 44 mins'
                                      : index == 2
                                      ? 'Beginner - 35 hrs'
                                      : 'Intermediate - 85 hrs',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isLightTheme
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: isLightTheme ? Colors.white : darkBg,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            width: 300,
                            padding: EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                index == 0
                                    ? 'Images/courseExample.webp'
                                    : index == 1
                                    ? 'Images/courseExample.webp'
                                    : index == 2
                                    ? 'Images/courseExample3.jpg'
                                    : 'Images/courseExample4.jpeg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  cContext,
                  MaterialPageRoute(builder: (context) => WebCoursesScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(20),
                backgroundColor:
                    isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
              child: Text(
                'Check courses now',
                style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildCList(bool isLight, Size sSize) {
    return [
      Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Text(
                'DESIGN\nunlimited number of circuits and see how they behave using our NGSpice simulator.',
                style: GoogleFonts.comfortaa(
                  fontSize: sSize.width / 40,
                  fontWeight: FontWeight.w900,
                  color: isLight ? Colors.white : Colors.black,
                ),
              ),
            ),
            Image.asset(isLight ? 'Images/build.png' : 'Images/builddark.png'),
          ],
        ),
      ),
      Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(
              isLight ? 'Images/connect2.png' : 'Images/connectdark.png',
            ),
            const SizedBox(width: 200),
            Flexible(
              child: Text(
                'CONNECT\n and communicate with different people from different areas of the world and share your thoughts.',
                style: GoogleFonts.comfortaa(
                  fontSize: sSize.width / 40,
                  fontWeight: FontWeight.w900,
                  color: isLight ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Text(
                'LEARN\nabout elements in circuits and study different circuitry principles to help you achieve better results and standout.',
                style: GoogleFonts.comfortaa(
                  fontSize: sSize.width / 40,
                  fontWeight: FontWeight.w900,
                  color: isLight ? Colors.white : Colors.black,
                ),
              ),
            ),
            Image.asset(isLight ? 'Images/learn.png' : 'Images/learndark.png'),
          ],
        ),
      ),
    ];
  }
}
