// Los nombres de los campos siguen el esquema de datos de la agenda.
// ignore_for_file: non_constant_identifier_names

class Client {
  String id;
  String nombre;
  String telefono;
  String genero;
  String? correo;
  DateTime fecha_registro;

  Client({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.fecha_registro,
    required this.genero,
    required this.telefono,
  });
}
