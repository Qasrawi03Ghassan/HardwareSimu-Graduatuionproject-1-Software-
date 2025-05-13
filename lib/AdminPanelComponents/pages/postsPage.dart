import 'package:flutter/material.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';

class PostsPage extends StatefulWidget {
  final bool theme;
  final User user;
  const PostsPage({super.key, required this.theme, required this.user});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Posts Page', style: TextStyle(fontSize: 40)));
    ;
  }
}
