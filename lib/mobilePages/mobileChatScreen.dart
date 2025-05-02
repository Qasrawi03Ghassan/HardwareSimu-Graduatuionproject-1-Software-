import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:provider/provider.dart';

class Mobilechatscreen extends StatefulWidget {
  final User selectedUser;
  final User signedUser;
  const Mobilechatscreen({
    super.key,
    required this.signedUser,
    required this.selectedUser,
  });

  @override
  State<Mobilechatscreen> createState() => _ChatPageState();
}

class _ChatPageState extends State<Mobilechatscreen> {
  bool isLightTheme = false;

  @override
  Widget build(BuildContext context) {
    isLightTheme =
        kIsWeb
            ? context.watch<SysThemes>().isLightTheme
            : MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectedUser.name,
          style: GoogleFonts.comfortaa(
            fontSize: 25,
            color: isLightTheme ? Colors.white : Colors.green.shade600,
          ),
        ),
        centerTitle: true,
        backgroundColor: isLightTheme ? Colors.blue.shade600 : Colors.black,
        iconTheme: IconThemeData(
          color: isLightTheme ? Colors.white : Colors.green.shade600,
          size: 35,
        ),
      ),
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      //body: Center(child: Text('Chat with ${widget.selectedUser.email}')),
    );
  }
}
