import 'package:flutter/material.dart';
import 'package:hardwaresimu_software_graduation_project/chatComponents.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;

class ChatScreen extends StatefulWidget {
  final myUser.User? user;
  const ChatScreen({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _ChatScreenState(user: this.user);
}

class _ChatScreenState extends State<ChatScreen> {
  bool isLightTheme = false;
  myUser.User? user;
  _ChatScreenState({required this.user});

  List<Map<String, dynamic>> posts = [];
  TextEditingController postController = TextEditingController();

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
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "Message others",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w100),
        ),
      ),
      body: Center(
        //child: Text("Messages appear here", style: TextStyle(fontSize: 24)),
        child: chatComps(isLightTheme: isLightTheme, user: user),
      ),
    );
  }
}
