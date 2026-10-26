import 'package:flutter/foundation.dart';
import 'package:turco/data/mock_data.dart';
import 'package:turco/models/appointment.dart';
import 'package:turco/models/client.dart';
import 'package:turco/models/service.dart';
import 'package:turco/models/stylist.dart';

/// Fuente de verdad de la aplicación.
///
/// Los ViewModels escuchan este objeto para que cualquier cambio en turnos o
/// clientes se refleje al instante en todas las pestañas.
class AppState extends ChangeNotifier {
  AppState({
    List<Appointment>? turnos,
    List<Client>? clientes,
    List<Stylist>? estilistas,
    List<Service>? servicios,
  }) : turnos = List<Appointment>.of(turnos ?? turnosPrueba),
       clientes = List<Client>.of(clientes ?? clientesPrueba),
       estilistas = List<Stylist>.of(estilistas ?? estilistasPrueba),
       servicios = List<Service>.of(servicios ?? serviciosPrueba);

  final List<Appointment> turnos;
  final List<Client> clientes;
  final List<Stylist> estilistas;
  final List<Service> servicios;

  // ---------------------------------------------------------------------------
  // Búsquedas
  // ---------------------------------------------------------------------------

  Client? clientePorId(String id) {
    for (final cliente in clientes) {
      if (cliente.id == id) return cliente;
    }
    return null;
  }

  Stylist? estilistaPorId(String id) {
    for (final estilista in estilistas) {
      if (estilista.id == id) return estilista;
    }
    return null;
  }

  Service? servicioPorId(String id) {
    for (final servicio in servicios) {
      if (servicio.id == id) return servicio;
    }
    return null;
  }

  Appointment? turnoPorId(String id) {
    for (final turno in turnos) {
      if (turno.id == id) return turno;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Cálculos de servicios y turnos
  // ---------------------------------------------------------------------------

  int duracionDeServicio(Service servicio) {
    return int.tryParse(servicio.duracion_minutos.trim()) ?? 0;
  }

  int duracionDeServicios(List<String> ids) {
    var total = 0;
    for (final servicio in servicios) {
      if (ids.contains(servicio.id)) {
        total += duracionDeServicio(servicio);
      }
    }
    return total;
  }

  double precioDeServicios(List<String> ids) {
    var total = 0.0;
    for (final servicio in servicios) {
      if (ids.contains(servicio.id)) {
        total += servicio.precio;
      }
    }
    return total;
  }

  int duracionDeTurno(Appointment turno) {
    return duracionDeServicios(turno.lista_servicios);
  }

  double precioDeTurno(Appointment turno) {
    return precioDeServicios(turno.lista_servicios);
  }

  List<Service> serviciosDeTurno(Appointment turno) {
    return servicios
        .where((servicio) => turno.lista_servicios.contains(servicio.id))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Turnos
  // ---------------------------------------------------------------------------

  void guardarTurno(Appointment turno) {
    final indice = turnos.indexWhere((t) => t.id == turno.id);

    if (indice == -1) {
      turnos.add(turno);
    } else {
      turnos[indice] = turno;
    }

    notifyListeners();
  }

  void eliminarTurno(String id) {
    turnos.removeWhere((turno) => turno.id == id);
    notifyListeners();
  }

  void cambiarEstadoTurno(String id, String estado) {
    final turno = turnoPorId(id);
    if (turno == null) return;

    turno.estado = estado;
    turno.modificadoEn = DateTime.now();
    notifyListeners();
  }

  bool tieneTurnosProgramados(String idCliente) {
    return turnos.any(
      (turno) =>
          turno.id_cliente == idCliente &&
          turno.estado.toLowerCase() == 'scheduled',
    );
  }

  int cantidadTurnosProgramados(String idCliente) {
    return turnos
        .where(
          (turno) =>
              turno.id_cliente == idCliente &&
              turno.estado.toLowerCase() == 'scheduled',
        )
        .length;
  }

  // ---------------------------------------------------------------------------
  // Clientes
  // ---------------------------------------------------------------------------

  void guardarCliente(Client cliente) {
    final indice = clientes.indexWhere((c) => c.id == cliente.id);

    if (indice == -1) {
      clientes.add(cliente);
    } else {
      clientes[indice] = cliente;
    }

    notifyListeners();
  }

  /// Elimina el cliente solo si no tiene turnos programados.
  ///
  /// Devuelve `false` cuando la operación se bloquea por tener turnos
  /// programados. Los turnos completados o cancelados sí se eliminan junto con
  /// el cliente para no dejar datos huérfanos en la agenda.
  bool eliminarCliente(String id) {
    if (tieneTurnosProgramados(id)) return false;

    turnos.removeWhere((turno) => turno.id_cliente == id);
    clientes.removeWhere((cliente) => cliente.id == id);
    notifyListeners();
    return true;
  }
}

