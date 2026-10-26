import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turco/models/appointment.dart';
import 'package:turco/models/client.dart';
import 'package:turco/models/service.dart';
import 'package:turco/models/stylist.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/viewmodels/agenda_view_model.dart';
import 'package:turco/viewmodels/client_view_model.dart';
import 'package:turco/viewmodels/horario_view_model.dart';
import 'package:turco/viewmodels/turno_form_view_model.dart';

void main() {
  Client crearCliente({
    String id = 'c1',
    String nombre = 'Sofía Méndez',
    String genero = 'Mujer',
  }) {
    return Client(
      id: id,
      nombre: nombre,
      correo: null,
      fecha_registro: DateTime(2026, 1, 1),
      genero: genero,
      telefono: '51234001',
    );
  }

  Service crearServicio({
    String id = 's1',
    String nombre = 'Corte',
    String categoria = 'corte',
    String duracion = '30',
    String publico = 'Unisex',
  }) {
    return Service(
      id: id,
      nombre: nombre,
      categoria: categoria,
      duracion_minutos: duracion,
      precio: 500,
      publico: publico,
    );
  }

  Stylist crearEstilista({
    String id = 'e1',
    String nombre = 'Ana',
    List<String> servicios = const ['s1'],
  }) {
    return Stylist(
      id: id,
      nombre: nombre,
      ruta_avatar: 'assets/avatars/alejandro.png',
      lista_servicios: servicios,
    );
  }

  Appointment crearTurno({
    String id = 'a1',
    String idCliente = 'c1',
    String idEstilista = 'e1',
    String estado = 'scheduled',
    required DateTime inicio,
  }) {
    return Appointment(
      id: id,
      id_cliente: idCliente,
      id_estilista: idEstilista,
      lista_servicios: const ['s1'],
      fecha_inicio: inicio,
      estado: estado,
      notas: null,
      creadoEn: inicio.subtract(const Duration(days: 1)),
      modificadoEn: inicio,
    );
  }

  AppState crearApp({
    List<Appointment> turnos = const [],
    List<Client>? clientes,
    List<Service>? servicios,
    List<Stylist>? estilistas,
  }) {
    return AppState(
      turnos: turnos,
      clientes: clientes ?? [crearCliente()],
      servicios: servicios ?? [crearServicio()],
      estilistas: estilistas ?? [crearEstilista()],
    );
  }

  /// Un día futuro que no sea domingo.
  DateTime proximoDiaHabil() {
    var fecha = DateTime.now().add(const Duration(days: 1));
    while (fecha.weekday == DateTime.sunday) {
      fecha = fecha.add(const Duration(days: 1));
    }
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  HorarioViewModel crearHorario(
    AppState app, {
    DateTime? fecha,
    Appointment? turno,
    List<String> servicios = const ['s1'],
  }) {
    return HorarioViewModel(
      appState: app,
      cliente: app.clientes.first,
      estilista: app.estilistas.first,
      serviciosElegidos: servicios,
      fechaInicial: fecha,
      turno: turno,
    );
  }

  test('Rechaza turnos en domingo', () {
    var domingo = DateTime.now().add(const Duration(days: 1));
    while (domingo.weekday != DateTime.sunday) {
      domingo = domingo.add(const Duration(days: 1));
    }

    final app = crearApp();
    final vm = crearHorario(
      app,
      fecha: DateTime(domingo.year, domingo.month, domingo.day),
    );

    expect(vm.esDomingo, isTrue);
    expect(vm.guardar(), isFalse);
    expect(vm.errorFecha, contains('domingos'));

    vm.dispose();
    app.dispose();
  });

  test('Rechaza turnos en el pasado', () {
    final app = crearApp();
    final vm = crearHorario(app);

    final ayer = DateTime.now().subtract(const Duration(days: 1));
    vm.cambiarFecha(ayer);

    expect(vm.fechaEnPasado, isTrue);
    expect(vm.guardar(), isFalse);
    expect(vm.errorFecha, contains('pasado'));

    vm.dispose();
    app.dispose();
  });

  test('Rechaza solape con otro turno del mismo cliente', () {
    final fecha = proximoDiaHabil();
    final inicio = DateTime(fecha.year, fecha.month, fecha.day, 10);

    final app = crearApp(
      turnos: [
        crearTurno(
          id: 'a1',
          idCliente: 'c1',
          idEstilista: 'e2',
          inicio: inicio,
        ),
      ],
      estilistas: [
        crearEstilista(),
        crearEstilista(id: 'e2', nombre: 'Luis'),
      ],
    );

    final vm = crearHorario(app, fecha: fecha);
    vm.seleccionarHora(const TimeOfDay(hour: 10, minute: 0));

    final conflicto = vm.conflictoCliente(
      inicio,
      inicio.add(const Duration(minutes: 30)),
    );
    expect(conflicto, isNotNull);
    expect(conflicto!.id_cliente, 'c1');

    expect(vm.estaDisponible(const TimeOfDay(hour: 10, minute: 0)), isFalse);
    expect(vm.guardar(), isFalse);
    expect(vm.errorHora, isNotNull);

    vm.dispose();
    app.dispose();
  });

  test('Un turno cancelado deja el horario libre', () {
    final fecha = proximoDiaHabil();
    final inicio = DateTime(fecha.year, fecha.month, fecha.day, 10);

    final app = crearApp(
      turnos: [
        crearTurno(
          id: 'a1',
          idCliente: 'c1',
          idEstilista: 'e1',
          estado: 'cancelled',
          inicio: inicio,
        ),
      ],
    );

    final vm = crearHorario(app, fecha: fecha);

    expect(vm.estaDisponible(const TimeOfDay(hour: 10, minute: 0)), isTrue);

    vm.dispose();
    app.dispose();
  });

  test('Solo muestra estilistas que hacen todos los servicios', () {
    final app = crearApp(
      servicios: [
        crearServicio(),
        crearServicio(id: 's2', nombre: 'Barba', categoria: 'barba'),
      ],
      estilistas: [
        crearEstilista(servicios: const ['s1']),
        crearEstilista(id: 'e2', nombre: 'Luis', servicios: const ['s1', 's2']),
      ],
    );

    final vm = TurnoFormViewModel(appState: app);
    vm.alternarServicio('s1');
    vm.alternarServicio('s2');

    expect(vm.estilistasDisponibles.length, 1);
    expect(vm.estilistasDisponibles.first.id, 'e2');

    vm.dispose();
    app.dispose();
  });

  test('La búsqueda ignora acentos y se combina con el género', () {
    final app = crearApp(
      clientes: [
        crearCliente(id: 'c1', nombre: 'Sofía Méndez', genero: 'Mujer'),
        crearCliente(id: 'c2', nombre: 'Andrés Fernández', genero: 'Hombre'),
      ],
    );

    final vm = ClientesViewModel(appState: app);

    vm.buscar('sofia');
    expect(vm.clientesFiltrados.length, 1);
    expect(vm.clientesFiltrados.first.nombre, 'Sofía Méndez');

    vm.filtrarPorGenero('hombres');
    expect(vm.clientesFiltrados, isEmpty);

    vm.buscar('andres');
    expect(vm.clientesFiltrados.length, 1);
    expect(vm.clientesFiltrados.first.nombre, 'Andrés Fernández');

    vm.dispose();
    app.dispose();
  });

  test('Bloquea eliminar un cliente con turnos programados', () {
    final fecha = proximoDiaHabil();
    final app = crearApp(
      turnos: [
        crearTurno(inicio: DateTime(fecha.year, fecha.month, fecha.day, 10)),
      ],
    );

    expect(app.eliminarCliente('c1'), isFalse);
    expect(app.clientePorId('c1'), isNotNull);

    app.cambiarEstadoTurno('a1', 'cancelled');
    expect(app.eliminarCliente('c1'), isTrue);
    expect(app.clientePorId('c1'), isNull);

    app.dispose();
  });

  test('Los ViewModels se actualizan al instante al cambiar AppState', () {
    final fecha = proximoDiaHabil();
    final app = crearApp();
    final agenda = AgendaViewModel(appState: app, fechaInicial: fecha);
    final clientes = ClientesViewModel(appState: app);

    var avisosAgenda = 0;
    var avisosClientes = 0;
    agenda.addListener(() => avisosAgenda++);
    clientes.addListener(() => avisosClientes++);

    app.guardarTurno(
      crearTurno(inicio: DateTime(fecha.year, fecha.month, fecha.day, 10)),
    );

    expect(avisosAgenda, 1);
    expect(avisosClientes, 1);
    expect(agenda.turnosDelDia.length, 1);
    expect(clientes.cantidadTurnos('c1'), 1);

    app.guardarCliente(
      crearCliente(id: 'c2', nombre: 'Nuevo Cliente', genero: 'Hombre'),
    );

    expect(avisosClientes, 2);
    expect(clientes.clientes.length, 2);

    agenda.dispose();
    clientes.dispose();
    app.dispose();
  });
}
