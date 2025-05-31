import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';

class Sim extends StatefulWidget {
  final bool isSignedIn;
  final User? user;
  const Sim({super.key, required this.isSignedIn, this.user});

  @override
  State<Sim> createState() => _SimState();
}

class _SimState extends State<Sim> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Simulator must be shown here',
          style: GoogleFonts.comfortaa(
            fontSize: 50,
            color: Colors.blue.shade600,
          ),
        ),
      ),
    );
  }
}
