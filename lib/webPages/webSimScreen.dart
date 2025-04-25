import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:provider/provider.dart';

class WebSimScreen extends StatefulWidget {
  final bool isSignedIn;
  final User? user;
  const WebSimScreen({super.key, required this.isSignedIn, this.user});

  @override
  State<WebSimScreen> createState() =>
      _WebSimScreenState(isSignedIn: isSignedIn, user: this.user);
}

class _WebSimScreenState extends State<WebSimScreen> {
  bool isSignedIn;
  User? user;
  _WebSimScreenState({required this.isSignedIn, this.user});
  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = context.watch<SysThemes>().isLightTheme;
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      body: Center(
        child: Text(
          "Simulator page",
          style: GoogleFonts.comfortaa(
            color: isLightTheme ? Colors.black : Colors.white,
            fontSize: 80,
          ),
        ),
      ),
    );
  }
}
