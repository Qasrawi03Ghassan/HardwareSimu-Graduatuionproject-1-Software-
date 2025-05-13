import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';

import 'layout.dart';
import 'pages/dashboardPage.dart';
import 'pages/usersPage.dart';
import 'pages/postsPage.dart';
import 'pages/coursePage.dart';

class AppRouter {
  final bool theme;
  final User user;

  AppRouter({required this.theme, required this.user});

  late final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/dashboard'),
      GoRoute(
        path: '/dashboard',
        builder:
            (context, state) => AppLayout(
              theme: theme,
              user: user,
              child: DashboardPage(theme: theme, user: user),
            ),
      ),
      GoRoute(
        path: '/users',
        builder:
            (context, state) => AppLayout(
              theme: theme,
              user: user,
              child: UsersPage(theme: theme, user: user),
            ),
      ),
      GoRoute(
        path: '/posts',
        builder:
            (context, state) => AppLayout(
              theme: theme,
              user: user,
              child: PostsPage(theme: theme, user: user),
            ),
      ),
      GoRoute(
        path: '/courses',
        builder:
            (context, state) => AppLayout(
              theme: theme,
              user: user,
              child: CoursesPage(theme: theme, user: user),
            ),
      ),
    ],
  );
}
