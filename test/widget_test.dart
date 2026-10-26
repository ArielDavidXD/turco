import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turco/main.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/theme/app_theme.dart';

void main() {
  testWidgets('La app abre en la agenda con la marca Turco', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      TurcoApp(appState: AppState(), themeController: AppThemeController()),
    );

    await tester.pump();

    expect(find.text('Turco'), findsOneWidget);
    expect(find.text('Nuevo turno'), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
