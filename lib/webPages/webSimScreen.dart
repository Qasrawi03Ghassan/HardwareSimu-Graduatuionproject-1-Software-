import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:provider/provider.dart';

class WebSimScreen extends StatefulWidget {
  final bool isSignedIn;
  const WebSimScreen({super.key, required this.isSignedIn});

  @override
  State<WebSimScreen> createState() =>
      _WebSimScreenState(isSignedIn: isSignedIn);
}

class _WebSimScreenState extends State<WebSimScreen> {
  final bool isSignedIn;
  _WebSimScreenState({required this.isSignedIn});
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
