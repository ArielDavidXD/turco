// Los nombres de los campos siguen el esquema de datos de la agenda.
// ignore_for_file: non_constant_identifier_names

class Appointment {
  String id;
  String id_cliente;
  String id_estilista;
  List<String> lista_servicios;
  DateTime fecha_inicio;
  String? notas;
  String estado;
  DateTime creadoEn;
  DateTime modificadoEn;

  Appointment({
    required this.id,
    required this.id_cliente,
    required this.id_estilista,
    required this.notas,
    required this.creadoEn,
    required this.estado,
    required this.fecha_inicio,
    required this.lista_servicios,
    required this.modificadoEn,
  });
}
