import 'package:flutter/material.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';

class CoursesPage extends StatefulWidget {
  final bool theme;
  final User user;
  const CoursesPage({super.key, required this.theme, required this.user});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Courses Page', style: TextStyle(fontSize: 40)));
  }
}
