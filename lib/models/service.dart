// Los nombres de los campos siguen el esquema de datos de la agenda.
// ignore_for_file: non_constant_identifier_names

class Service {
  String id;
  String nombre;
  String categoria;
  String duracion_minutos;
  double precio;
  String publico;

  Service({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.duracion_minutos,
    required this.precio,
    required this.publico,
  });
}
