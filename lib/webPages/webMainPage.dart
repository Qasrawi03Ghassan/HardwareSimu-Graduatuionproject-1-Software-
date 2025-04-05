import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CircuitAcademy"),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Center(
        child: Text(
          "Welcome to CircuitAcademy",
          style: GoogleFonts.comfortaa(
            fontSize: 35,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
