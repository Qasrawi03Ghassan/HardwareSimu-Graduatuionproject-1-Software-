import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:hardwaresimu_software_graduation_project/AdminPanelComponents/layout.dart';
import 'package:hardwaresimu_software_graduation_project/AdminPanelComponents/pages/coursePage.dart';
import 'package:hardwaresimu_software_graduation_project/AdminPanelComponents/pages/dashboardPage.dart';
import 'package:hardwaresimu_software_graduation_project/AdminPanelComponents/pages/postsPage.dart';
import 'package:hardwaresimu_software_graduation_project/AdminPanelComponents/pages/usersPage.dart';
import 'package:hardwaresimu_software_graduation_project/AdminPanelComponents/router.dart';
import 'package:hardwaresimu_software_graduation_project/AdminPanelComponents/sideBar.dart';

import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:hardwaresimu_software_graduation_project/posts.dart';
import 'package:hardwaresimu_software_graduation_project/courses.dart';
import 'package:hardwaresimu_software_graduation_project/comments.dart';
import 'package:hardwaresimu_software_graduation_project/enrollment.dart';
import 'package:hardwaresimu_software_graduation_project/courseVideo.dart';

class AdminPanel extends StatefulWidget {
  final bool theme;
  final User user;
  const AdminPanel({super.key, required this.theme, required this.user});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  bool isCollapsed = false;

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder:
            (context, state) => AppLayout(
              theme: widget.theme,
              user: widget.user,
              child: DashboardPage(theme: widget.theme, user: widget.user),
            ),
      ),

      GoRoute(
        path: '/users',
        builder:
            (context, state) => AppLayout(
              theme: widget.theme,
              user: widget.user,
              child: /*_buildPage(*/ UsersPage(
                theme: widget.theme,
                user: widget.user,
              ),
              //),
            ),
      ),
      GoRoute(
        path: '/posts',
        builder:
            (context, state) => AppLayout(
              theme: widget.theme,
              user: widget.user,
              child: /*_buildPage(*/ PostsPage(
                theme: widget.theme,
                user: widget.user,
              ),
              //),
            ),
      ),
      GoRoute(
        path: '/courses',
        builder:
            (context, state) => AppLayout(
              theme: widget.theme,
              user: widget.user,
              child: /*_buildPage(*/ CoursesPage(
                theme: widget.theme,
                user: widget.user,
              ),
              //),
            ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CircuitAcademy',
      theme: ThemeData.light(),
      routerConfig: _router,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'CircuitAcademy',
              style: GoogleFonts.comfortaa(
                color: widget.theme ? Colors.white : Colors.green.shade600,
                fontSize: 25,
              ),
            ),
            backgroundColor: widget.theme ? Colors.blue.shade600 : darkBg,
            iconTheme: IconThemeData(
              color: widget.theme ? Colors.white : Colors.green.shade600,
              size: 35,
            ),
          ),
          backgroundColor: widget.theme ? Colors.white : Colors.grey.shade900,
          body: child ?? const SizedBox(),
        );
      },
    );
  }
}
