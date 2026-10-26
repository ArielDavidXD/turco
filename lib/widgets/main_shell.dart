import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/theme/app_theme.dart';
import 'package:turco/widgets/theme_button.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final AppThemeController themeController;

  const MainShell({
    super.key,
    required this.navigationShell,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    final esAgenda = navigationShell.currentIndex == 0;

    return Scaffold(
      // Solo Agenda tiene la barra "Turco"
      appBar: esAgenda
          ? AppBar(
              title: Row(
                children: [
                  Image.asset('assets/images/logo.png', width: 28, height: 28),
                  const SizedBox(width: 10),
                  const Text(
                    'Turco',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [ThemeButton(themeController: themeController)],
            )
          : null,
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.content_cut),
            label: 'Servicios',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Estilistas',
          ),
        ],
      ),
    );
  }
}
