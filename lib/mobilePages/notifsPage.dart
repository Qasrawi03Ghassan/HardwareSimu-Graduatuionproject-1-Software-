import 'package:flutter/material.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;

class NotifsScreen extends StatefulWidget {
  final myUser.User? user;
  const NotifsScreen({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _NotifsScreenState(user: this.user);
}

class _NotifsScreenState extends State<NotifsScreen> {
  myUser.User? user;
  _NotifsScreenState({required this.user});

  List<Map<String, dynamic>> posts = [];
  TextEditingController postController = TextEditingController();

  bool isLightTheme = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    isLightTheme =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w100),
        ),
      ),
      body: const Center(
        child: Text(
          "Notifications appear here",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
