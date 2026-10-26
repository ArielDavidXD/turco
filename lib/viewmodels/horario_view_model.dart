import 'package:flutter/material.dart';
import 'package:turco/models/appointment.dart';
import 'package:turco/models/client.dart';
import 'package:turco/models/stylist.dart';
import 'package:turco/router/app_state.dart';

/// Lógica del segundo paso del formulario: fecha, hora, disponibilidad y
/// validación de solapes.
class HorarioViewModel extends ChangeNotifier {
  HorarioViewModel({
    required this.appState,
    required this.cliente,
    required this.estilista,
    required List<String> serviciosElegidos,
    DateTime? fechaInicial,
    Appointment? turno,
  }) : turno = turno,
       _serviciosElegidos = List<String>.of(serviciosElegidos),
       notasController = TextEditingController(text: turno?.notas ?? '') {
    appState.addListener(_alCambiarAppState);

    final original = turno;
    if (original != null) {
      _fechaSeleccionada = soloFecha(original.fecha_inicio);
      _horaSeleccionada = TimeOfDay.fromDateTime(original.fecha_inicio);
    } else {
      _fechaSeleccionada = _fechaValidaInicial(fechaInicial);
    }

    if (esDomingo) {
      _errorFecha = 'El salón está cerrado los domingos.';
    }
  }

  static final List<TimeOfDay> horarios = List<TimeOfDay>.generate(
    19,
    (indice) => TimeOfDay(hour: 9 + indice ~/ 2, minute: (indice % 2) * 30),
  );

  final AppState appState;
  final Client cliente;
  final Stylist estilista;
  final List<String> _serviciosElegidos;
  final Appointment? turno;
  final TextEditingController notasController;

  late DateTime _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  String? _errorFecha;
  String? _errorHora;

  DateTime get fechaSeleccionada => _fechaSeleccionada;
  TimeOfDay? get horaSeleccionada => _horaSeleccionada;
  String? get errorFecha => _errorFecha;
  String? get errorHora => _errorHora;

  bool get editando => turno != null;

  int get duracion => appState.duracionDeServicios(_serviciosElegidos);

  double get precio => appState.precioDeServicios(_serviciosElegidos);

  bool get esDomingo => _fechaSeleccionada.weekday == DateTime.sunday;

  bool get fechaEnPasado {
    final hoy = soloFecha(DateTime.now());
    return _fechaSeleccionada.isBefore(hoy);
  }

  DateTime? get inicioSeleccionado {
    if (_horaSeleccionada == null) return null;
    return _inicioPara(_horaSeleccionada!);
  }

  DateTime? get finSeleccionado {
    final inicio = inicioSeleccionado;
    if (inicio == null) return null;
    return inicio.add(Duration(minutes: duracion));
  }

  static DateTime soloFecha(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  DateTime _fechaValidaInicial(DateTime? fechaInicial) {
    final hoy = soloFecha(DateTime.now());
    final inicial = soloFecha(fechaInicial ?? DateTime.now());
    return inicial.isBefore(hoy) ? hoy : inicial;
  }

  DateTime _inicioPara(TimeOfDay hora) {
    return DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      hora.hour,
      hora.minute,
    );
  }

  DateTime _cierreDelDia() {
    return DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      19,
    );
  }

  /// Una hora está disponible si no es domingo, no está en el pasado, el turno
  /// cabe antes del cierre y no choca con el estilista ni con el cliente.
  bool estaDisponible(TimeOfDay hora) {
    if (esDomingo || fechaEnPasado) return false;

    final inicio = _inicioPara(hora);
    final fin = inicio.add(Duration(minutes: duracion));

    if (!inicio.isAfter(DateTime.now())) return false;
    if (fin.isAfter(_cierreDelDia())) return false;
    if (conflictoEstilista(inicio, fin) != null) return false;
    if (conflictoCliente(inicio, fin) != null) return false;

    return true;
  }

  Appointment? conflictoEstilista(DateTime inicio, DateTime fin) {
    return _buscarConflicto(inicio, fin, idEstilista: estilista.id);
  }

  Appointment? conflictoCliente(DateTime inicio, DateTime fin) {
    return _buscarConflicto(inicio, fin, idCliente: cliente.id);
  }

  Appointment? _buscarConflicto(
    DateTime inicio,
    DateTime fin, {
    String? idEstilista,
    String? idCliente,
  }) {
    for (final otro in appState.turnos) {
      if (otro.id == turno?.id) continue;
      if (otro.estado.toLowerCase() != 'scheduled') continue;
      if (idEstilista != null && otro.id_estilista != idEstilista) continue;
      if (idCliente != null && otro.id_cliente != idCliente) continue;

      final finOtro = otro.fecha_inicio.add(
        Duration(minutes: appState.duracionDeTurno(otro)),
      );

      if (inicio.isBefore(finOtro) && fin.isAfter(otro.fecha_inicio)) {
        return otro;
      }
    }

    return null;
  }

  void cambiarFecha(DateTime fecha) {
    final nueva = soloFecha(fecha);
    if (nueva == _fechaSeleccionada) return;

    _fechaSeleccionada = nueva;

    if (_horaSeleccionada != null && !estaDisponible(_horaSeleccionada!)) {
      _horaSeleccionada = null;
    }

    _errorHora = null;
    _errorFecha = esDomingo
        ? 'El salón está cerrado los domingos.'
        : fechaEnPasado
        ? 'No se pueden agendar turnos en el pasado.'
        : null;

    notifyListeners();
  }

  void seleccionarHora(TimeOfDay hora) {
    if (!estaDisponible(hora)) {
      _errorHora = 'Esa hora ya no está disponible.';
      notifyListeners();
      return;
    }

    _horaSeleccionada = hora;
    _errorHora = null;
    notifyListeners();
  }

  /// Devuelve `true` cuando el turno se guardó correctamente.
  bool guardar() {
    _errorFecha = null;
    _errorHora = null;

    if (esDomingo) {
      _errorFecha = 'El salón está cerrado los domingos.';
      notifyListeners();
      return false;
    }

    if (fechaEnPasado) {
      _errorFecha = 'No se pueden agendar turnos en el pasado.';
      notifyListeners();
      return false;
    }

    if (_horaSeleccionada == null) {
      _errorHora = 'Selecciona una hora de inicio.';
      notifyListeners();
      return false;
    }

    final inicio = _inicioPara(_horaSeleccionada!);
    final fin = inicio.add(Duration(minutes: duracion));

    if (!inicio.isAfter(DateTime.now())) {
      _errorHora = 'La hora ya pasó. Elige otra.';
      notifyListeners();
      return false;
    }

    if (fin.isAfter(_cierreDelDia())) {
      _errorHora = 'El turno terminaría después del cierre (19:00).';
      notifyListeners();
      return false;
    }

    final choqueEstilista = conflictoEstilista(inicio, fin);
    if (choqueEstilista != null) {
      _errorHora = '${estilista.nombre} ya tiene un turno en ese horario.';
      notifyListeners();
      return false;
    }

    final choqueCliente = conflictoCliente(inicio, fin);
    if (choqueCliente != null) {
      _errorHora = '${cliente.nombre} ya tiene un turno en ese horario.';
      notifyListeners();
      return false;
    }

    final ahora = DateTime.now();
    final textoNotas = notasController.text.trim();

    final guardado = Appointment(
      id: turno?.id ?? ahora.millisecondsSinceEpoch.toString(),
      id_cliente: cliente.id,
      id_estilista: estilista.id,
      lista_servicios: List<String>.of(_serviciosElegidos),
      fecha_inicio: inicio,
      estado: turno?.estado ?? 'scheduled',
      notas: textoNotas.isEmpty ? null : textoNotas,
      creadoEn: turno?.creadoEn ?? ahora,
      modificadoEn: ahora,
    );

    appState.guardarTurno(guardado);
    return true;
  }

  void _alCambiarAppState() {
    if (_horaSeleccionada != null && !estaDisponible(_horaSeleccionada!)) {
      _horaSeleccionada = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    appState.removeListener(_alCambiarAppState);
    notasController.dispose();
    super.dispose();
  }
}
