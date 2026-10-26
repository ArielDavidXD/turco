/// Utilidades de texto compartidas por las vistas.
library;

const List<String> _meses = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

const List<String> _dias = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

String nombreMes(DateTime fecha) => '${_meses[fecha.month - 1]} ${fecha.year}';

String fechaCorta(DateTime fecha) {
  return '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
}

String fechaLarga(DateTime fecha) {
  return '${_dias[fecha.weekday - 1]} ${fecha.day} '
      'de ${_meses[fecha.month - 1].toLowerCase()} de ${fecha.year}';
}

String horaCorta(DateTime fecha) {
  return '${fecha.hour.toString().padLeft(2, '0')}:'
      '${fecha.minute.toString().padLeft(2, '0')}';
}

String fechaHoraCompleta(DateTime fecha) {
  return '${fechaCorta(fecha)} · ${horaCorta(fecha)}';
}

String textoEstado(String estado) {
  switch (estado.toLowerCase()) {
    case 'scheduled':
      return 'Programado';
    case 'completed':
      return 'Completado';
    case 'cancelled':
      return 'Cancelado';
    default:
      return estado;
  }
}

String duracionTexto(int minutos) {
  final horas = minutos ~/ 60;
  final resto = minutos % 60;

  if (horas == 0) return '$resto min';
  if (resto == 0) return '$horas h';
  return '$horas h $resto min';
}

String inicialDe(String texto) {
  final limpio = texto.trim();
  return limpio.isEmpty ? '?' : limpio[0].toUpperCase();
}
