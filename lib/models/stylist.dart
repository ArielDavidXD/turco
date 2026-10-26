// Los nombres de los campos siguen el esquema de datos de la agenda.
// ignore_for_file: non_constant_identifier_names

class Stylist {
  String id;
  String nombre;
  String ruta_avatar;
  List<String> lista_servicios;

  Stylist({
    required this.id,
    required this.nombre,
    required this.ruta_avatar,
    required this.lista_servicios,
  });
}
