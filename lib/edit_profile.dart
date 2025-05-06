import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';

class EditProfile extends StatefulWidget {
  final User user;
  final bool theme;
  const EditProfile({super.key, required this.theme, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.theme ? Colors.blue.shade600 : Colors.black,
        title: Text(
          'Edit your profile',
          style: GoogleFonts.comfortaa(
            color: widget.theme ? Colors.white : Colors.green.shade600,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: widget.theme ? Colors.white : Colors.green.shade600,
          size: 35,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                widget.theme
                    ? [Colors.blue.shade600, Colors.blue.shade200]
                    : [Colors.black, const Color.fromARGB(255, 68, 71, 90)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: kIsWeb ? 1000 : 500,
                  height: kIsWeb ? 800 : 670,
                  child: Card(
                    color: widget.theme ? Colors.white : Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
