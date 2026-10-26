import 'package:flutter/foundation.dart';
import 'package:turco/models/appointment.dart';
import 'package:turco/models/client.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/utils/texto.dart';

class ClientesViewModel extends ChangeNotifier {
  ClientesViewModel({required this.appState}) {
    appState.addListener(_alCambiarAppState);
  }

  final AppState appState;

  String _busqueda = '';
  String _genero = 'todos';

  String get busqueda => _busqueda;
  String get genero => _genero;

  List<Client> get clientes => appState.clientes;

  List<Client> get clientesFiltrados {
    final texto = normalizarTexto(_busqueda);

    return appState.clientes.where((cliente) {
      final coincideBusqueda =
          texto.isEmpty ||
          normalizarTexto(cliente.nombre).contains(texto) ||
          cliente.telefono.contains(texto);

      final generoCliente = cliente.genero.toLowerCase();
      final coincideGenero =
          _genero == 'todos' ||
          (_genero == 'mujeres' && generoCliente == 'mujer') ||
          (_genero == 'hombres' && generoCliente == 'hombre');

      return coincideBusqueda && coincideGenero;
    }).toList();
  }

  int get cantidadMujeres {
    return appState.clientes
        .where((cliente) => cliente.genero.toLowerCase() == 'mujer')
        .length;
  }

  int get cantidadHombres {
    return appState.clientes
        .where((cliente) => cliente.genero.toLowerCase() == 'hombre')
        .length;
  }

  Client? clientePorId(String id) => appState.clientePorId(id);

  int cantidadTurnos(String idCliente) {
    return appState.turnos
        .where((turno) => turno.id_cliente == idCliente)
        .length;
  }

  int turnosProgramados(String idCliente) {
    return appState.cantidadTurnosProgramados(idCliente);
  }

  bool puedeEliminar(String idCliente) {
    return !appState.tieneTurnosProgramados(idCliente);
  }

  List<Appointment> turnosDeCliente(String idCliente) {
    final turnos = appState.turnos
        .where((turno) => turno.id_cliente == idCliente)
        .toList();

    turnos.sort((a, b) => b.fecha_inicio.compareTo(a.fecha_inicio));
    return turnos;
  }

  void buscar(String texto) {
    if (_busqueda == texto) return;

    _busqueda = texto;
    notifyListeners();
  }

  void filtrarPorGenero(String genero) {
    if (_genero == genero) return;

    _genero = genero;
    notifyListeners();
  }

  /// Devuelve `false` si el cliente tiene turnos programados.
  bool eliminarCliente(String idCliente) {
    return appState.eliminarCliente(idCliente);
  }

  void _alCambiarAppState() {
    notifyListeners();
  }

  @override
  void dispose() {
    appState.removeListener(_alCambiarAppState);
    super.dispose();
  }
}
