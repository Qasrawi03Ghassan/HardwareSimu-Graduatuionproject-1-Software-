import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLightTheme = true;
  @override
  Widget build(BuildContext context) {
    bool isLightTheme =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "\$Username\$",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w100),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            //implement sign out here
            // try {
            //   await FirebaseAuth.instance.signOut();
            //   print("User signed out successfully.");
            // } catch (e) {
            //   print('Sign out error: $e');
            // }

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
              (route) => false,
            );
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
}
