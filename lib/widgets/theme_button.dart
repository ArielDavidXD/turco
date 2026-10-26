import 'package:flutter/material.dart';
import 'package:turco/theme/app_theme.dart';

class ThemeButton extends StatelessWidget {
  final AppThemeController themeController;

  const ThemeButton({required this.themeController, super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ThemeMode>(
      tooltip: 'Cambiar apariencia',
      initialValue: themeController.themeMode,
      icon: Icon(
        themeController.themeMode == ThemeMode.dark
            ? Icons.dark_mode
            : themeController.themeMode == ThemeMode.light
            ? Icons.light_mode
            : Icons.brightness_auto,
      ),
      onSelected: themeController.cambiarTema,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: ThemeMode.light,
          child: ListTile(
            leading: Icon(Icons.light_mode),
            title: Text('Tema claro'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Tema oscuro'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.system,
          child: ListTile(
            leading: Icon(Icons.brightness_auto),
            title: Text('Seguir el sistema'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
