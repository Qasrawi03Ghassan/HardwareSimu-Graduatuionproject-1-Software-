import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:provider/provider.dart';

class WebAboutScreen extends StatefulWidget {
  const WebAboutScreen({super.key});

  @override
  State<WebAboutScreen> createState() => _WebAboutScreenState();
}

class _WebAboutScreenState extends State<WebAboutScreen> {
  @override
  Widget build(BuildContext context) {
    bool isLightTheme = context.watch<SysThemes>().isLightTheme;
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      body: Center(
        child: Text(
          "About us page",
          style: GoogleFonts.comfortaa(
            color: isLightTheme ? Colors.black : Colors.white,
            fontSize: 80,
          ),
        ),
      ),
    );
  }
}
