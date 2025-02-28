import 'package:flutter/material.dart';

//Important
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Container(
            alignment: Alignment.center,
            child: Text(
              "Welcome", //IDK what to name the app yet
              style: GoogleFonts.comfortaa(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Colors.green.shade600,
        ),
        body: Center(
          child: Container(
            width: 350,
            height: 550,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              color: Colors.green.shade600,
            ),
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.all(50),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "Images/mainIcon.png",
                        fit: BoxFit.cover,
                        width: 150,
                        height: 150,
                      ),
                    )),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color.fromARGB(255, 39, 41, 54),
                  ),
                  width: 300,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    "Sign in",
                    style: GoogleFonts.comfortaa(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color.fromARGB(255, 39, 41, 54),
                  ),
                  margin: const EdgeInsets.only(top: 20, bottom: 35),
                  width: 300,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    "Create an account",
                    style: GoogleFonts.comfortaa(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  "Or use the links below",
                  style: GoogleFonts.comfortaa(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      top: 10, bottom: 30, left: 30, right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(200)),
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(10),
                          child: const Icon(
                            FontAwesomeIcons.facebook,
                            color: Color.fromARGB(255, 39, 41, 54),
                            size: 33,
                          )),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(200)),
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(10),
                          child: const Icon(
                            FontAwesomeIcons.google,
                            color: Color.fromARGB(255, 39, 41, 54),
                            size: 33,
                          )),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(200)),
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(10),
                          child: const Icon(
                            FontAwesomeIcons.microsoft,
                            color: Color.fromARGB(255, 39, 41, 54),
                            size: 33,
                          )),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(200)),
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(10),
                          child: const Icon(
                            FontAwesomeIcons.github,
                            color: Color.fromARGB(255, 39, 41, 54),
                            size: 33,
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 39, 41, 54),
      ),
    );
  }
}
