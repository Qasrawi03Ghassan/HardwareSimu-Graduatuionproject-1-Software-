import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final myUser.User? user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState(user: this.user);
}

class _ProfileScreenState extends State<ProfileScreen> {
  myUser.User? user;

  _ProfileScreenState({this.user});

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  bool isLightTheme = true;
  @override
  Widget build(BuildContext context) {
    bool isLightTheme =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          user!.userName,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w100),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            //implement sign out here
            await signOutUser(user!.email);
            try {
              await FirebaseAuth.instance.signOut();
              print("Firebase signout successful");
            } catch (e) {
              print('Firebase sign out error: $e');
            }

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
              (route) => false,
            );
            showSnackBar(isLightTheme, 'Signed out successfully');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isLightTheme ? Colors.blue.shade600 : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: Text(
            "Sign out",
            style: TextStyle(
              fontSize: 18,
              color: isLightTheme ? Colors.white : Colors.green.shade600,
            ),
          ),
        ),
      ),
    );
  }

  void showSnackBar(bool barTheme, String text) {
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
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> signOutUser(String email) async {
    final Map<String, dynamic> dataToSend = {
      'email': email,
      'isSignedIn': false,
    };
    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/user/signout')
            : Uri.parse('http://10.0.2.2:3000/user/signout');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}
