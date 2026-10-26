import 'appointment.dart';
import 'client.dart';
import 'stylist.dart';

/// Datos que viajan del formulario de servicios a la pantalla de fecha/hora.
class TurnoArgs {
  final Client cliente;
  final Stylist estilista;
  final List<String> serviciosElegidos;
  final DateTime? fecha;
  final Appointment? turno; // null = crear, distinto de null = editar

  const TurnoArgs({
    required this.cliente,
    required this.estilista,
    required this.serviciosElegidos,
    this.fecha,
    this.turno,
  });
}

/// Datos opcionales con los que se abre el formulario de turno.
class AgendaFormArgs {
  final Client? cliente;
  final DateTime? fecha;
  final Appointment? turno;
  final String? servicioId;

  const AgendaFormArgs({this.cliente, this.fecha, this.turno, this.servicioId});
}
