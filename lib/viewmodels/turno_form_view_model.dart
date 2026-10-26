import 'package:flutter/foundation.dart';
import 'package:turco/models/appointment.dart';
import 'package:turco/models/client.dart';
import 'package:turco/models/service.dart';
import 'package:turco/models/stylist.dart';
import 'package:turco/router/app_state.dart';

/// Lógica del primer paso del formulario: cliente, servicios y estilista.
class TurnoFormViewModel extends ChangeNotifier {
  TurnoFormViewModel({
    required this.appState,
    Client? cliente,
    this.turno,
    String? servicioInicial,
  }) {
    appState.addListener(_alCambiarAppState);
    _cliente = cliente;

    if (turno != null) {
      _cliente = appState.clientePorId(turno!.id_cliente);
      _estilista = appState.estilistaPorId(turno!.id_estilista);
      _serviciosElegidos = List<String>.of(turno!.lista_servicios);
    } else if (servicioInicial != null) {
      _serviciosElegidos = <String>[servicioInicial];
      _validarEstilista();
    }
  }

  static const Map<String, String> categorias = {
    'corte': 'Corte',
    'barba': 'Barba',
    'color': 'Color',
    'peinado': 'Peinado',
    'tratamiento': 'Tratamiento',
  };

  final AppState appState;
  final Appointment? turno;

  Client? _cliente;
  Stylist? _estilista;
  String _publico = 'todos';
  List<String> _serviciosElegidos = [];
  String? _errorServicios;

  Client? get cliente => _cliente;
  Stylist? get estilista => _estilista;
  String get publico => _publico;
  List<String> get serviciosElegidos => List.unmodifiable(_serviciosElegidos);
  String? get errorServicios => _errorServicios;

  bool get editando => turno != null;
  List<Client> get clientes => appState.clientes;

  bool get tieneServicios => _serviciosElegidos.isNotEmpty;

  int get duracion => appState.duracionDeServicios(_serviciosElegidos);

  double get precio => appState.precioDeServicios(_serviciosElegidos);

  /// Un estilista solo aparece si realiza todos los servicios elegidos.
  bool haceTodosLosServicios(Stylist estilista) {
    if (_serviciosElegidos.isEmpty) return true;

    return _serviciosElegidos.every(
      (id) => estilista.lista_servicios.contains(id),
    );
  }

  List<Stylist> get estilistasDisponibles {
    return appState.estilistas.where(haceTodosLosServicios).toList();
  }

  List<Service> serviciosDeCategoria(String categoria) {
    return appState.servicios.where((servicio) {
      final coincideCategoria =
          servicio.categoria.toLowerCase() == categoria.toLowerCase();

      final publicoServicio = servicio.publico.toLowerCase();
      final esUnisex =
          publicoServicio != 'mujeres' && publicoServicio != 'hombres';
      final coincidePublico =
          _publico == 'todos' || publicoServicio == _publico || esUnisex;

      return coincideCategoria && coincidePublico;
    }).toList();
  }

  void seleccionarCliente(Client? cliente) {
    _cliente = cliente;
    notifyListeners();
  }

  void seleccionarEstilista(Stylist? estilista) {
    _estilista = estilista;
    notifyListeners();
  }

  void seleccionarPublico(String publico) {
    if (_publico == publico) return;

    _publico = publico;

    // Quita servicios que dejan de estar visibles con el filtro elegido.
    _serviciosElegidos.removeWhere((id) {
      final servicio = appState.servicioPorId(id);
      if (servicio == null) return true;

      final publicoServicio = servicio.publico.toLowerCase();
      final esUnisex =
          publicoServicio != 'mujeres' && publicoServicio != 'hombres';

      return !(publico == 'todos' || publicoServicio == publico || esUnisex);
    });

    _validarEstilista();
    notifyListeners();
  }

  void alternarServicio(String id) {
    if (_serviciosElegidos.contains(id)) {
      _serviciosElegidos.remove(id);
    } else {
      _serviciosElegidos.add(id);
    }

    _errorServicios = null;
    _validarEstilista();
    notifyListeners();
  }

  bool validarServicios() {
    if (_serviciosElegidos.isNotEmpty) {
      _errorServicios = null;
      return true;
    }

    _errorServicios = 'Selecciona al menos un servicio.';
    notifyListeners();
    return false;
  }

  void _validarEstilista() {
    if (_estilista != null && !haceTodosLosServicios(_estilista!)) {
      _estilista = null;
    }
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
