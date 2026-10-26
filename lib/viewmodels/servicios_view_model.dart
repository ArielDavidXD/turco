import 'package:flutter/foundation.dart';
import 'package:turco/models/service.dart';
import 'package:turco/router/app_state.dart';

class ServiciosViewModel extends ChangeNotifier {
  ServiciosViewModel({required this.appState}) {
    appState.addListener(_alCambiarAppState);
  }

  final AppState appState;

  String _categoria = 'todos';
  String _publico = 'todos';

  String get categoria => _categoria;
  String get publico => _publico;

  List<Service> get servicios => appState.servicios;

  List<String> get categorias {
    final valores = appState.servicios
        .map((servicio) => servicio.categoria.toLowerCase())
        .toSet()
        .toList();
    valores.sort();
    return valores;
  }

  List<Service> get serviciosFiltrados {
    return appState.servicios.where((servicio) {
      final coincideCategoria =
          _categoria == 'todos' ||
          servicio.categoria.toLowerCase() == _categoria;

      final publicoServicio = servicio.publico.toLowerCase();
      final esUnisex =
          publicoServicio != 'mujeres' && publicoServicio != 'hombres';

      // Los servicios unisex aparecen en cualquier filtro.
      final coincidePublico =
          _publico == 'todos' || publicoServicio == _publico || esUnisex;

      return coincideCategoria && coincidePublico;
    }).toList();
  }

  void filtrarPorCategoria(String categoria) {
    if (_categoria == categoria) return;

    _categoria = categoria;
    notifyListeners();
  }

  void filtrarPorPublico(String publico) {
    if (_publico == publico) return;

    _publico = publico;
    notifyListeners();
  }

  String capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  String etiquetaPublico(String valor) {
    final normalizado = valor.toLowerCase();
    if (normalizado == 'mujeres' || normalizado == 'hombres') {
      return capitalizar(normalizado);
    }
    return 'Unisex';
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
