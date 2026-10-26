import 'package:flutter/foundation.dart';
import 'package:turco/models/appointment.dart';
import 'package:turco/models/service.dart';
import 'package:turco/models/stylist.dart';
import 'package:turco/router/app_state.dart';

class EstilistasViewModel extends ChangeNotifier {
  EstilistasViewModel({required this.appState}) {
    appState.addListener(_alCambiarAppState);
  }

  final AppState appState;

  List<Stylist> get estilistas => appState.estilistas;

  List<Appointment> get turnosHoy {
    return appState.turnos.where((turno) {
      return _esHoy(turno.fecha_inicio) &&
          turno.estado.toLowerCase() == 'scheduled';
    }).toList();
  }

  int turnosHoyDe(String idEstilista) {
    return turnosHoy.where((turno) => turno.id_estilista == idEstilista).length;
  }

  List<String> especialidadesDe(String idEstilista) {
    final categorias = serviciosDe(
      idEstilista,
    ).map((servicio) => servicio.categoria.toLowerCase()).toSet().toList();
    categorias.sort();

    return categorias.map(_capitalizar).toList();
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  List<Service> serviciosDe(String idEstilista) {
    final estilista = appState.estilistaPorId(idEstilista);
    if (estilista == null) return [];

    return appState.servicios
        .where((servicio) => estilista.lista_servicios.contains(servicio.id))
        .toList();
  }

  bool _esHoy(DateTime fecha) {
    final ahora = DateTime.now();
    return fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day;
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
