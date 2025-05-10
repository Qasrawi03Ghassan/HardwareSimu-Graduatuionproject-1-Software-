import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/signIn.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                //color: Colors.amber,
                height: 700,
                width: 900,
                child: Image.asset(
                  isLightTheme ? 'Images/usdark.png' : 'Images/us.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                alignment: Alignment.center,
                child: Text(
                  textAlign: TextAlign.center,
                  softWrap: true,
                  'Circuit academy is a web based solution for students struggling in different electrical courses, we provide a simple yet effective platform that helps students understand circuits principals much easier through the provided courses, the community and a web-based simulator',
                  style: GoogleFonts.comfortaa(
                    color:
                        isLightTheme
                            ? Colors.blue.shade600
                            : Colors.green.shade600,
                    fontSize: 25,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
