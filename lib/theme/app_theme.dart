import 'package:flutter/material.dart';

class AppThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void cambiarTema(ThemeMode nuevoTema) {
    if (_themeMode == nuevoTema) return;

    _themeMode = nuevoTema;
    notifyListeners();
  }

  void alternarTema() {
    cambiarTema(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}

class AppTheme {
  static const Color primaryClaro = Color(0xFF006A60);
  static const Color primaryContainerClaro = Color(0xFF9FF2E4);
  static const Color secondaryContainerClaro = Color(0xFFCCE8E2);
  static const Color tertiaryClaro = Color(0xFF456179);
  static const Color errorClaro = Color(0xFFBA1A1A);
  static const Color errorContainerClaro = Color(0xFFFFDAD6);
  static const Color surfaceClaro = Color(0xFFF4FBF9);
  static const Color surfaceContainerClaro = Color(0xFFE5EFED);
  static const Color outlineClaro = Color(0xFF6F7977);

  static const Color primaryOscuro = Color(0xFF53DBC9);
  static const Color primaryContainerOscuro = Color(0xFF005047);
  static const Color secondaryContainerOscuro = Color(0xFF314B47);
  static const Color tertiaryOscuro = Color(0xFFADC6E6);
  static const Color errorOscuro = Color(0xFFFFB4AB);
  static const Color errorContainerOscuro = Color(0xFF93000A);
  static const Color surfaceOscuro = Color(0xFF0E1514);
  static const Color surfaceContainerOscuro = Color(0xFF1A2120);
  static const Color outlineOscuro = Color(0xFF899390);

  static final ThemeData claro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primaryClaro,
      onPrimary: Colors.white,
      primaryContainer: primaryContainerClaro,
      onPrimaryContainer: Color(0xFF00201C),
      secondary: Color(0xFF4A635E),
      onSecondary: Colors.white,
      secondaryContainer: secondaryContainerClaro,
      onSecondaryContainer: Color(0xFF051F1B),
      tertiary: tertiaryClaro,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFCDDEFA),
      onTertiaryContainer: Color(0xFF071D32),
      error: errorClaro,
      onError: Colors.white,
      errorContainer: errorContainerClaro,
      onErrorContainer: Color(0xFF410002),
      surface: surfaceClaro,
      onSurface: Color(0xFF191C1B),
      surfaceContainer: surfaceContainerClaro,
      outline: outlineClaro,
    ),
    scaffoldBackgroundColor: surfaceClaro,
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceClaro,
      foregroundColor: Color(0xFF191C1B),
      elevation: 0,
    ),
    cardTheme: const CardThemeData(color: Colors.white, elevation: 0),
  );

  static final ThemeData oscuro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryOscuro,
      onPrimary: Color(0xFF003731),
      primaryContainer: primaryContainerOscuro,
      onPrimaryContainer: Color(0xFF9FF2E4),
      secondary: Color(0xFFB1CCC6),
      onSecondary: Color(0xFF1C3531),
      secondaryContainer: secondaryContainerOscuro,
      onSecondaryContainer: Color(0xFFD0E8E2),
      tertiary: tertiaryOscuro,
      onTertiary: Color(0xFF203348),
      tertiaryContainer: Color(0xFF374B62),
      onTertiaryContainer: Color(0xFFCDDEFA),
      error: errorOscuro,
      onError: Color(0xFF690005),
      errorContainer: errorContainerOscuro,
      onErrorContainer: Color(0xFFFFDAD6),
      surface: surfaceOscuro,
      onSurface: Color(0xFFE0E3E1),
      surfaceContainer: surfaceContainerOscuro,
      outline: outlineOscuro,
    ),
    scaffoldBackgroundColor: surfaceOscuro,
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceOscuro,
      foregroundColor: Color(0xFFE0E3E1),
      elevation: 0,
    ),
    cardTheme: const CardThemeData(color: surfaceContainerOscuro, elevation: 0),
  );
}
