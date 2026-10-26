import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/theme/app_theme.dart';
import 'package:turco/views/agenda_form_screen.dart';
import 'package:turco/views/agenda_form_fecha_screen.dart';
import 'package:turco/views/agenda_screen.dart';
import 'package:turco/views/client_screen.dart';
import 'package:turco/views/services_screen.dart';
import 'package:turco/views/stylists_screen.dart';

import '../models/turnos_args.dart';
import '../views/detalle_turno_screen.dart';
import '../widgets/main_shell.dart';
import 'app_state.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter crearRoute(AppState appstate, AppThemeController themeController) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/agenda',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(
            navigationShell: navigationShell,
            themeController: themeController,
          );
        },
        // El orden debe coincidir con el BottomNavigationBar:
        // 0 Agenda, 1 Clientes, 2 Servicios, 3 Estilistas.
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/agenda',
                builder: (context, state) {
                  // Parámetro de consulta: /agenda?fecha=2026-10-25
                  final fechaTexto = state.uri.queryParameters['fecha'];
                  final fecha = fechaTexto == null
                      ? null
                      : DateTime.tryParse(fechaTexto);

                  return AgendaScreen(appState: appstate, fechaInicial: fecha);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/client',
                builder: (context, state) => ClientScreen(appState: appstate),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/services',
                builder: (context, state) => ServicesScreen(appState: appstate),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stylists',
                builder: (context, state) => StylistsScreen(appState: appstate),
              ),
            ],
          ),
        ],
      ),

      // Flujo "Nuevo turno" (sobre la barra inferior)
      GoRoute(
        path: '/agendaForm',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          final args = extra is AgendaFormArgs ? extra : null;

          return AgendaFormScreen(
            appState: appstate,
            cliente: args?.cliente,
            fechaInicial: args?.fecha,
            turno: args?.turno,
            servicioInicial: args?.servicioId,
          );
        },
        routes: [
          // Se resuelve como /agendaForm/fecha
          GoRoute(
            path: 'fecha',
            parentNavigatorKey: _rootNavigatorKey,
            redirect: (context, state) {
              if (state.extra is! TurnoArgs) return '/agendaForm';
              return null;
            },
            builder: (context, state) {
              final args = state.extra as TurnoArgs;
              return FechaTurnoScreen(
                appState: appstate,
                cliente: args.cliente,
                estilista: args.estilista,
                serviciosElegidos: args.serviciosElegidos,
                fechaInicial: args.fecha,
                turno: args.turno,
              );
            },
          ),
        ],
      ),

      GoRoute(
        path: '/turno/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => DetalleTurnoScreen(
          appState: appstate,
          turnoId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}
