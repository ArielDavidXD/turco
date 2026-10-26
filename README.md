# Turco

Aplicación Flutter para la gestión de turnos de la peluquería **Turco**.

Permite organizar la agenda diaria, administrar clientes, consultar el catálogo de
servicios y ver el equipo de estilistas. Toda la información de la demo vive en
memoria (no hay backend ni persistencia).

## Funcionalidades

- **Agenda**: navegación por semana, selección de día, resumen de turnos
  programados/completados e ingreso estimado, filtros por estilista y por estado.
- **Turnos**: alta y edición en dos pasos (cliente/servicios/estilista y
  fecha/hora), notas opcionales, detalle con historial de cambios, completar y
  cancelar.
- **Clientes**: búsqueda por nombre o teléfono, filtro por género, alta/edición en
  un bottom sheet e historial de turnos por cliente.
- **Servicios**: catálogo agrupado por categoría (corte, barba, color, peinado y
  tratamiento) con filtro por público.
- **Estilistas**: equipo con avatar, especialidades y turnos programados del día.
- **Tema claro/oscuro** con tipografía Poppins y paleta definida en un único
  archivo.

## Reglas de negocio

- No se agendan turnos los **domingos** (el salón está cerrado).
- No se agendan turnos en el **pasado**.
- El horario de atención es de **09:00 a 19:00**; la grilla usa bloques de 30
  minutos y solo habilita los que permiten terminar antes del cierre.
- Un turno no puede **solaparse** con otro del mismo estilista ni con otro del
  mismo cliente.
- Un turno **cancelado libera** su horario.
- Solo se ofrecen estilistas que realizan **todos** los servicios elegidos.
- Un cliente con turnos **programados** no se puede eliminar; al eliminarlo se
  borra también su historial de turnos completados/cancelados.
- Completar o cancelar un turno actualiza su fecha de modificación.

## Arquitectura (MVVM)

```
lib/
├── data/          # Datos de ejemplo
├── models/        # Client, Service, Stylist, Appointment y argumentos de ruta
├── router/        # Rutas (go_router) y AppState
├── theme/         # Tema y colores centralizados
├── utils/         # Formato de fechas y normalización de texto
├── viewmodels/    # ChangeNotifier con el estado y la lógica de cada pantalla
├── views/         # Widgets de UI
└── widgets/       # Componentes reutilizables
```

- `AppState` es la **fuente de verdad** de la aplicación y notifica cada cambio
  (`ChangeNotifier`).
- Cada pantalla tiene su **ViewModel** (`ChangeNotifier`) que escucha a
  `AppState`, expone estado derivado y concentra la lógica de negocio.
- Las vistas se reconstruyen con `ListenableBuilder`; **no usan `setState`**.
  Solo son `StatefulWidget` para crear y liberar su ViewModel.
- Al compartir `AppState`, cualquier cambio se refleja **al instante** en todas
  las pestañas.

| ViewModel | Responsabilidad |
| --- | --- |
| `AgendaViewModel` | Día/semana seleccionada, filtros, resumen e ingreso estimado |
| `TurnoFormViewModel` | Cliente, servicios, filtro por público y estilistas válidos |
| `HorarioViewModel` | Fecha, hora, disponibilidad, solapes y guardado del turno |
| `TurnoDetalleViewModel` | Datos del turno, estado y acciones de completar/cancelar |
| `ClientesViewModel` | Búsqueda sin acentos, filtro por género y guardas de borrado |
| `ClienteFormViewModel` | Controladores y validaciones del formulario de cliente |
| `ServiciosViewModel` | Catálogo y filtros por categoría/público |
| `EstilistasViewModel` | Especialidades y turnos del día por estilista |

### Navegación

Se usa `go_router` con una barra inferior de cuatro secciones y rutas que se
abren sobre ella para el flujo de turnos.

La agenda acepta un **parámetro de consulta** con la fecha a mostrar:

```
/agenda?fecha=2026-10-25
```

## Requisitos

- Flutter 3.47 o superior (Dart 3.13)
- Android SDK para compilar el APK

## Ejecutar

```bash
flutter pub get
flutter run
```

## Assets

- Tipografía Poppins (Regular, Medium, SemiBold y Bold) en `assets/fonts`.
- Logo en `assets/images/logo.png` y avatares en `assets/avatars/`.
