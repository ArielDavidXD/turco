import 'package:flutter/foundation.dart';
import 'package:turco/models/appointment.dart';
import 'package:turco/models/client.dart';
import 'package:turco/models/service.dart';
import 'package:turco/models/stylist.dart';
import 'package:turco/router/app_state.dart';

class TurnoDetalleViewModel extends ChangeNotifier {
  TurnoDetalleViewModel({required this.appState, required this.turnoId}) {
    appState.addListener(_alCambiarAppState);
  }

  final AppState appState;
  final String turnoId;

  Appointment? get turno => appState.turnoPorId(turnoId);

  Client? get cliente {
    final actual = turno;
    if (actual == null) return null;
    return appState.clientePorId(actual.id_cliente);
  }

  Stylist? get estilista {
    final actual = turno;
    if (actual == null) return null;
    return appState.estilistaPorId(actual.id_estilista);
  }

  List<Service> get servicios {
    final actual = turno;
    if (actual == null) return [];
    return appState.serviciosDeTurno(actual);
  }

  int get duracion {
    final actual = turno;
    if (actual == null) return 0;
    return appState.duracionDeTurno(actual);
  }

  double get total {
    final actual = turno;
    if (actual == null) return 0;
    return appState.precioDeTurno(actual);
  }

  DateTime? get fin {
    final actual = turno;
    if (actual == null) return null;
    return actual.fecha_inicio.add(Duration(minutes: duracion));
  }

  bool get editable {
    final actual = turno;
    return actual != null && actual.estado.toLowerCase() == 'scheduled';
  }

  void cambiarEstado(String estado) {
    appState.cambiarEstadoTurno(turnoId, estado);
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
