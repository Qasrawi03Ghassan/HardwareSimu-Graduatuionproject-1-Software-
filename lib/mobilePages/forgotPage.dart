import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/signIn.dart';

class ForgotPage extends StatelessWidget {
  const ForgotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 35),
        title: Text(
          "Password recovery",
          style: GoogleFonts.comfortaa(fontSize: 30),
        ),
      ),
      body: Text(
        "Implement password recovery here",
        style: GoogleFonts.comfortaa(fontSize: 24),
      ),
    );
  }
}
