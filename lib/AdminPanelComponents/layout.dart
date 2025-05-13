import 'package:flutter/material.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'sideBar.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final bool theme;
  final User user;

  const AppLayout({
    super.key,
    required this.child,
    required this.theme,
    required this.user,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool isCollapsed = false;

  void toggleSidebar() {
    setState(() => isCollapsed = !isCollapsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme ? Colors.white : Colors.grey.shade900,
      body: Row(
        children: [
          Sidebar(
            isCollapsed: isCollapsed,
            onToggle: toggleSidebar,
            theme: widget.theme,
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
