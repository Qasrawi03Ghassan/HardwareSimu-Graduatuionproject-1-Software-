import 'package:flutter/material.dart';

class NotifsScreen extends StatefulWidget {
  const NotifsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _NotifsScreenState();
}

class _NotifsScreenState extends State<NotifsScreen> {
  List<Map<String, dynamic>> posts = [];
  TextEditingController postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
