import 'package:flutter/foundation.dart';
import 'package:turco/models/appointment.dart';
import 'package:turco/router/app_state.dart';

class AgendaViewModel extends ChangeNotifier {
  AgendaViewModel({required this.appState, DateTime? fechaInicial})
    : _fechaSeleccionada = soloFecha(fechaInicial ?? DateTime.now()) {
    appState.addListener(_alCambiarAppState);
  }

  final AppState appState;

  DateTime _fechaSeleccionada;
  String _filtroEstilista = 'Todos';
  String _estadoFiltro = 'todos';

  DateTime get fechaSeleccionada => _fechaSeleccionada;
  String get filtroEstilista => _filtroEstilista;
  String get estadoFiltro => _estadoFiltro;

  static DateTime soloFecha(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  DateTime get lunesSeleccionado {
    final fecha = soloFecha(_fechaSeleccionada);
    return fecha.subtract(Duration(days: fecha.weekday - 1));
  }

  List<String> get nombresEstilistas {
    return appState.estilistas.map((estilista) => estilista.nombre).toList();
  }

  List<Appointment> get turnosDelDia {
    final fecha = soloFecha(_fechaSeleccionada);

    final resultado = appState.turnos.where((turno) {
      return soloFecha(turno.fecha_inicio) == fecha;
    }).toList();

    resultado.sort((a, b) => a.fecha_inicio.compareTo(b.fecha_inicio));
    return resultado;
  }

  List<Appointment> get turnosFiltrados {
    return turnosDelDia.where((turno) {
      final coincideEstilista =
          _filtroEstilista == 'Todos' ||
          nombreEstilista(turno.id_estilista) == _filtroEstilista;

      final estado = turno.estado.toLowerCase();
      final coincideEstado =
          _estadoFiltro == 'todos' ||
          (_estadoFiltro == 'programado' && estado == 'scheduled') ||
          (_estadoFiltro == 'completado' && estado == 'completed') ||
          (_estadoFiltro == 'cancelado' && estado == 'cancelled');

      return coincideEstilista && coincideEstado;
    }).toList();
  }

  int get cantidadProgramados {
    return turnosDelDia
        .where((turno) => turno.estado.toLowerCase() == 'scheduled')
        .length;
  }

  int get cantidadCompletados {
    return turnosDelDia
        .where((turno) => turno.estado.toLowerCase() == 'completed')
        .length;
  }

  double get ingresoEstimado {
    return turnosDelDia
        .where((turno) {
          final estado = turno.estado.toLowerCase();
          return estado == 'scheduled' || estado == 'completed';
        })
        .fold<double>(
          0,
          (total, turno) => total + appState.precioDeTurno(turno),
        );
  }

  String nombreCliente(String id) {
    return appState.clientePorId(id)?.nombre ?? 'Cliente desconocido';
  }

  String nombreEstilista(String id) {
    return appState.estilistaPorId(id)?.nombre ?? 'Estilista desconocido';
  }

  String nombresServicios(List<String> ids) {
    final nombres = appState.servicios
        .where((servicio) => ids.contains(servicio.id))
        .map((servicio) => servicio.nombre)
        .toList();

    return nombres.isEmpty ? 'Sin servicios' : nombres.join(' + ');
  }

  int duracionTurno(Appointment turno) => appState.duracionDeTurno(turno);

  DateTime finTurno(Appointment turno) {
    return turno.fecha_inicio.add(Duration(minutes: duracionTurno(turno)));
  }

  void cambiarFecha(DateTime fecha) {
    final nueva = soloFecha(fecha);
    if (nueva == _fechaSeleccionada) return;

    _fechaSeleccionada = nueva;
    notifyListeners();
  }

  void cambiarSemana(int cantidad) {
    _fechaSeleccionada = soloFecha(
      _fechaSeleccionada.add(Duration(days: 7 * cantidad)),
    );
    notifyListeners();
  }

  void filtrarPorEstilista(String nombre) {
    if (_filtroEstilista == nombre) return;

    _filtroEstilista = nombre;
    notifyListeners();
  }

  void filtrarPorEstado(String estado) {
    if (_estadoFiltro == estado) return;

    _estadoFiltro = estado;
    notifyListeners();
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
