import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';

class Sidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;
  final bool theme;

  const Sidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? 70 : 200,
      color: theme ? Colors.blue.shade600 : darkBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(
                Icons.menu,
                color: theme ? Colors.white : Colors.black,
                size: 30,
              ),
              onPressed: onToggle,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/',
                  isCollapsed: isCollapsed,
                  theme: theme,
                ),
                _NavItem(
                  icon: Icons.people,
                  label: 'Users',
                  route: '/users',
                  isCollapsed: isCollapsed,
                  theme: theme,
                ),
                _NavItem(
                  icon: Icons.post_add,
                  label: 'Posts',
                  route: '/posts',
                  isCollapsed: isCollapsed,
                  theme: theme,
                ),
                _NavItem(
                  icon: Icons.school,
                  label: 'Courses',
                  route: '/courses',
                  isCollapsed: isCollapsed,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isCollapsed;
  final bool theme;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isCollapsed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: theme ? Colors.white : Colors.green.shade600,
        size: 26,
      ),
      title:
          isCollapsed
              ? null
              : Text(
                label,
                style: GoogleFonts.comfortaa(
                  fontSize: 16,
                  color: theme ? Colors.white : Colors.green.shade600,
                ),
              ),
      onTap: () {
        final currentLocation =
            GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
        if (currentLocation != route) {
          context.go(route);
        }
      },

      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
