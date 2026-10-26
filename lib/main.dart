import 'package:flutter/material.dart';
import 'package:turco/router/app_router.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/theme/app_theme.dart';

void main() {
  runApp(TurcoApp(appState: AppState(), themeController: AppThemeController()));
}

class TurcoApp extends StatefulWidget {
  final AppState appState;
  final AppThemeController themeController;

  const TurcoApp({
    super.key,
    required this.appState,
    required this.themeController,
  });

  @override
  State<TurcoApp> createState() => _TurcoAppState();
}

class _TurcoAppState extends State<TurcoApp> {
  late final router = crearRoute(widget.appState, widget.themeController);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.themeController,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Turco',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          themeMode: widget.themeController.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
