import '../models/service.dart';
import '../models/stylist.dart';
import '../models/client.dart';
import '../models/appointment.dart';

// ============================================================
// SERVICIOS
// ============================================================

final List<Service> serviciosPrueba = [
  Service(
    id: 's1',
    nombre: 'Corte clásico',
    categoria: 'corte',
    duracion_minutos: '30',
    precio: 500,
    publico: 'Hombres',
  ),
  Service(
    id: 's2',
    nombre: 'Corte degradado',
    categoria: 'corte',
    duracion_minutos: '45',
    precio: 700,
    publico: 'Hombres',
  ),
  Service(
    id: 's3',
    nombre: 'Corte femenino',
    categoria: 'corte',
    duracion_minutos: '60',
    precio: 900,
    publico: 'Mujeres',
  ),
  Service(
    id: 's4',
    nombre: 'Corte infantil',
    categoria: 'corte',
    duracion_minutos: '30',
    precio: 400,
    publico: 'Unisex',
  ),
  Service(
    id: 's5',
    nombre: 'Tinte completo',
    categoria: 'color',
    duracion_minutos: '120',
    precio: 2500,
    publico: 'Mujeres',
  ),
  Service(
    id: 's6',
    nombre: 'Mechas',
    categoria: 'color',
    duracion_minutos: '150',
    precio: 3000,
    publico: 'Mujeres',
  ),
  Service(
    id: 's7',
    nombre: 'Coloración masculina',
    categoria: 'color',
    duracion_minutos: '60',
    precio: 1200,
    publico: 'Hombres',
  ),
  Service(
    id: 's8',
    nombre: 'Arreglo de barba',
    categoria: 'barba',
    duracion_minutos: '30',
    precio: 400,
    publico: 'Hombres',
  ),
  Service(
    id: 's9',
    nombre: 'Diseño de barba',
    categoria: 'barba',
    duracion_minutos: '45',
    precio: 600,
    publico: 'Hombres',
  ),
  Service(
    id: 's10',
    nombre: 'Peinado de evento',
    categoria: 'peinado',
    duracion_minutos: '60',
    precio: 1200,
    publico: 'Mujeres',
  ),
  Service(
    id: 's11',
    nombre: 'Lavado y peinado',
    categoria: 'peinado',
    duracion_minutos: '30',
    precio: 500,
    publico: 'Unisex',
  ),
  Service(
    id: 's12',
    nombre: 'Tratamiento capilar',
    categoria: 'tratamiento',
    duracion_minutos: '45',
    precio: 1000,
    publico: 'Unisex',
  ),
];

// ============================================================
// ESTILISTAS
// ============================================================

final List<Stylist> estilistasPrueba = [
  Stylist(
    id: 'e1',
    nombre: 'Alejandro Ruiz',
    ruta_avatar: 'assets/avatars/alejandro.png',
    lista_servicios: ['s1', 's2', 's8', 's9'],
  ),
  Stylist(
    id: 'e2',
    nombre: 'Camila Torres',
    ruta_avatar: 'assets/avatars/camila.png',
    lista_servicios: ['s3', 's5', 's6', 's10'],
  ),
  Stylist(
    id: 'e3',
    nombre: 'Daniela Pérez',
    ruta_avatar: 'assets/avatars/daniela.png',
    lista_servicios: ['s5', 's6', 's12'],
  ),
  Stylist(
    id: 'e4',
    nombre: 'Miguel Herrera',
    ruta_avatar: 'assets/avatars/miguel.png',
    lista_servicios: ['s1', 's2', 's7', 's8', 's9'],
  ),
  Stylist(
    id: 'e5',
    nombre: 'Valentina Gómez',
    ruta_avatar: 'assets/avatars/valentina.png',
    lista_servicios: ['s1', 's3', 's4', 's11', 's12'],
  ),
];

// ============================================================
// CLIENTES
// ============================================================

final List<Client> clientesPrueba = [
  Client(
    id: 'c1',
    nombre: 'Laura Méndez',
    telefono: '51234001',
    genero: 'Mujer',
    correo: 'laura@example.com',
    fecha_registro: DateTime(2026, 6, 1),
  ),
  Client(
    id: 'c2',
    nombre: 'Carlos Rodríguez',
    telefono: '51234002',
    genero: 'Hombre',
    correo: 'carlos@example.com',
    fecha_registro: DateTime(2026, 6, 10),
  ),
  Client(
    id: 'c3',
    nombre: 'Sofía Hernández',
    telefono: '51234003',
    genero: 'Mujer',
    correo: 'sofia@example.com',
    fecha_registro: DateTime(2026, 6, 18),
  ),
  Client(
    id: 'c4',
    nombre: 'Daniel González',
    telefono: '51234004',
    genero: 'Hombre',
    correo: 'daniel@example.com',
    fecha_registro: DateTime(2026, 7, 2),
  ),
  Client(
    id: 'c5',
    nombre: 'Mariana López',
    telefono: '51234005',
    genero: 'Mujer',
    correo: 'mariana@example.com',
    fecha_registro: DateTime(2026, 7, 12),
  ),
  Client(
    id: 'c6',
    nombre: 'Javier Martínez',
    telefono: '51234006',
    genero: 'Hombre',
    correo: 'javier@example.com',
    fecha_registro: DateTime(2026, 7, 20),
  ),
  Client(
    id: 'c7',
    nombre: 'Valeria Sánchez',
    telefono: '51234007',
    genero: 'Mujer',
    correo: 'valeria@example.com',
    fecha_registro: DateTime(2026, 8, 1),
  ),
  Client(
    id: 'c8',
    nombre: 'Andrés Fernández',
    telefono: '51234008',
    genero: 'Hombre',
    correo: 'andres@example.com',
    fecha_registro: DateTime(2026, 8, 14),
  ),
  Client(
    id: 'c9',
    nombre: 'Gabriela Díaz',
    telefono: '51234009',
    genero: 'Mujer',
    correo: 'gabriela@example.com',
    fecha_registro: DateTime(2026, 9, 1),
  ),
  Client(
    id: 'c10',
    nombre: 'Ricardo Pérez',
    telefono: '51234010',
    genero: 'Hombre',
    correo: null,
    fecha_registro: DateTime(2026, 10, 1),
  ),
];

// ============================================================
// TURNOS
// ============================================================

final DateTime hoy = DateTime.now();

DateTime fechaTurno(int dias, int hora, int minuto) {
  return DateTime(hoy.year, hoy.month, hoy.day + dias, hora, minuto);
}

String estadoTurno(DateTime inicio, String estadoAnterior) {
  return inicio.isAfter(hoy) ? 'scheduled' : estadoAnterior;
}

final List<Appointment> turnosPrueba = [
  Appointment(
    id: 'a1',
    id_cliente: 'c1',
    id_estilista: 'e1',
    lista_servicios: ['s1'],
    fecha_inicio: fechaTurno(-2, 9, 0),
    notas: 'Prefiere un corte discreto.',
    estado: estadoTurno(fechaTurno(-2, 9, 0), 'completed'),
    creadoEn: fechaTurno(-5, 10, 0),
    modificadoEn: fechaTurno(-2, 9, 30),
  ),
  Appointment(
    id: 'a2',
    id_cliente: 'c3',
    id_estilista: 'e2',
    lista_servicios: ['s3'],
    fecha_inicio: fechaTurno(-2, 11, 0),
    notas: 'Solicita mantener el largo.',
    estado: estadoTurno(fechaTurno(-2, 11, 0), 'cancelled'),
    creadoEn: fechaTurno(-4, 11, 0),
    modificadoEn: fechaTurno(-2, 10, 0),
  ),
  Appointment(
    id: 'a3',
    id_cliente: 'c5',
    id_estilista: 'e2',
    lista_servicios: ['s5'],
    fecha_inicio: fechaTurno(-2, 17, 0),
    notas: 'Tinte completo. El servicio termina a las 19:00.',
    estado: estadoTurno(fechaTurno(-2, 17, 0), 'completed'),
    creadoEn: fechaTurno(-6, 12, 0),
    modificadoEn: fechaTurno(-2, 19, 0),
  ),
  Appointment(
    id: 'a4',
    id_cliente: 'c2',
    id_estilista: 'e4',
    lista_servicios: ['s2'],
    fecha_inicio: fechaTurno(-1, 9, 0),
    notas: 'Prefiere un degradado bajo.',
    estado: estadoTurno(fechaTurno(-1, 9, 0), 'completed'),
    creadoEn: fechaTurno(-4, 9, 0),
    modificadoEn: fechaTurno(-1, 9, 45),
  ),
  Appointment(
    id: 'a5',
    id_cliente: 'c7',
    id_estilista: 'e3',
    lista_servicios: ['s6'],
    fecha_inicio: fechaTurno(-1, 13, 0),
    notas: 'Desea unas mechas naturales. Revisar el cabello antes de comenzar.',
    estado: estadoTurno(fechaTurno(-1, 13, 0), 'cancelled'),
    creadoEn: fechaTurno(-3, 15, 0),
    modificadoEn: fechaTurno(-1, 12, 0),
  ),
  Appointment(
    id: 'a6',
    id_cliente: 'c6',
    id_estilista: 'e5',
    lista_servicios: ['s4'],
    fecha_inicio: fechaTurno(-1, 10, 0),
    notas: null,
    estado: estadoTurno(fechaTurno(-1, 10, 0), 'completed'),
    creadoEn: fechaTurno(-3, 10, 0),
    modificadoEn: fechaTurno(-1, 10, 30),
  ),

  // Cuatro turnos para hoy.
  Appointment(
    id: 'a7',
    id_cliente: 'c2',
    id_estilista: 'e1',
    lista_servicios: ['s8'],
    fecha_inicio: fechaTurno(0, 9, 0),
    notas: 'Arreglo de barba.',
    estado: estadoTurno(fechaTurno(0, 9, 0), 'completed'),
    creadoEn: fechaTurno(-2, 14, 0),
    modificadoEn: fechaTurno(0, 9, 30),
  ),
  Appointment(
    id: 'a8',
    id_cliente: 'c1',
    id_estilista: 'e2',
    lista_servicios: ['s3'],
    fecha_inicio: fechaTurno(0, 10, 0),
    notas: 'Corte y retoque de puntas.',
    estado: estadoTurno(fechaTurno(0, 10, 0), 'completed'),
    creadoEn: fechaTurno(-1, 11, 0),
    modificadoEn: fechaTurno(0, 11, 0),
  ),
  Appointment(
    id: 'a9',
    id_cliente: 'c3',
    id_estilista: 'e5',
    lista_servicios: ['s4', 's11', 's12'],
    fecha_inicio: fechaTurno(0, 13, 0),
    notas: 'La clienta solicita corte, lavado y tratamiento. Antes de comenzar, consultar si ha utilizado productos químicos recientemente. Revisar el cuero cabelludo, explicar los pasos del tratamiento y confirmar que está de acuerdo con el procedimiento. Al finalizar, indicar los cuidados recomendados para mantener el cabello en buen estado y recomendar cuándo debería realizarse una nueva revisión.',
    estado: estadoTurno(fechaTurno(0, 13, 0), 'completed'),
    creadoEn: fechaTurno(-3, 16, 0),
    modificadoEn: fechaTurno(0, 14, 45),
  ),
  Appointment(
    id: 'a10',
    id_cliente: 'c4',
    id_estilista: 'e4',
    lista_servicios: ['s7'],
    fecha_inicio: fechaTurno(0, 15, 0),
    notas: 'Coloración masculina.',
    estado: estadoTurno(fechaTurno(0, 15, 0), 'cancelled'),
    creadoEn: fechaTurno(-1, 9, 0),
    modificadoEn: fechaTurno(0, 14, 0),
  ),

  Appointment(
    id: 'a11',
    id_cliente: 'c8',
    id_estilista: 'e3',
    lista_servicios: ['s12'],
    fecha_inicio: fechaTurno(1, 9, 0),
    notas: 'Evaluar el cabello antes del tratamiento.',
    estado: estadoTurno(fechaTurno(1, 9, 0), 'completed'),
    creadoEn: fechaTurno(0, 10, 0),
    modificadoEn: fechaTurno(0, 10, 0),
  ),
  Appointment(
    id: 'a12',
    id_cliente: 'c9',
    id_estilista: 'e1',
    lista_servicios: ['s9'],
    fecha_inicio: fechaTurno(1, 11, 0),
    notas: 'Diseño de barba.',
    estado: estadoTurno(fechaTurno(1, 11, 0), 'completed'),
    creadoEn: fechaTurno(0, 11, 0),
    modificadoEn: fechaTurno(0, 11, 0),
  ),
  Appointment(
    id: 'a13',
    id_cliente: 'c5',
    id_estilista: 'e2',
    lista_servicios: ['s6'],
    fecha_inicio: fechaTurno(2, 9, 0),
    notas: 'Mechas.',
    estado: estadoTurno(fechaTurno(2, 9, 0), 'completed'),
    creadoEn: fechaTurno(0, 12, 0),
    modificadoEn: fechaTurno(0, 12, 0),
  ),
  Appointment(
    id: 'a14',
    id_cliente: 'c6',
    id_estilista: 'e4',
    lista_servicios: ['s7'],
    fecha_inicio: fechaTurno(2, 12, 0),
    notas: 'Consultar el tono deseado antes de aplicar el color.',
    estado: estadoTurno(fechaTurno(2, 12, 0), 'completed'),
    creadoEn: fechaTurno(0, 13, 0),
    modificadoEn: fechaTurno(0, 13, 0),
  ),
  Appointment(
    id: 'a15',
    id_cliente: 'c8',
    id_estilista: 'e5',
    lista_servicios: ['s4'],
    fecha_inicio: fechaTurno(3, 9, 0),
    notas: 'Corte infantil.',
    estado: estadoTurno(fechaTurno(3, 9, 0), 'completed'),
    creadoEn: fechaTurno(0, 14, 0),
    modificadoEn: fechaTurno(0, 14, 0),
  ),
  Appointment(
    id: 'a16',
    id_cliente: 'c1',
    id_estilista: 'e2',
    lista_servicios: ['s10'],
    fecha_inicio: fechaTurno(3, 13, 0),
    notas: 'Peinado para evento.',
    estado: estadoTurno(fechaTurno(3, 13, 0), 'completed'),
    creadoEn: fechaTurno(0, 15, 0),
    modificadoEn: fechaTurno(0, 15, 0),
  ),
];
