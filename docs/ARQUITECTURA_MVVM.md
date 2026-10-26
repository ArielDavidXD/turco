# Arquitectura MVVM de Turco

Documento de referencia sobre cómo está organizada la aplicación, qué se cambió
para pasar a MVVM y cómo se conecta cada pieza.

---

## 1. Resumen

La aplicación pasó de tener **toda la lógica y el estado dentro de un único
`AppState` usado directamente por los widgets** (con `setState` y cálculos en los
`build`) a una arquitectura **MVVM** con:

- `AppState` como **fuente de verdad** de los datos (`ChangeNotifier`).
- **8 ViewModels** (`ChangeNotifier`) que exponen el estado de cada pantalla y
  concentran la lógica de negocio.
- Vistas que solo declaran UI y se reconstruyen con `ListenableBuilder`.
- **Cero `setState`** en `lib/`.
- Actualización **inmediata entre pestañas** porque todos los ViewModels
  escuchan al mismo `AppState`.

---

## 2. Qué es MVVM y por qué se usó

MVVM separa tres responsabilidades:

| Capa | En este proyecto | Responsabilidad |
| --- | --- | --- |
| **Model** | `models/`, `data/` | Datos: `Client`, `Service`, `Stylist`, `Appointment` |
| **ViewModel** | `viewmodels/` | Estado de pantalla + lógica de negocio + validaciones |
| **View** | `views/`, `widgets/` | Widgets, layout, navegación y temas |

El problema del código anterior era que la vista **decidía y calculaba**:

- filtraba turnos, sumaba precios y calculaba duraciones dentro del `build`;
- validaba formularios con `setState`;
- no había una única fuente de notificaciones, así que una pestaña podía quedar
  desactualizada.

Con MVVM:

- la vista **pregunta** (`viewModel.turnosFiltrados`) y **ordena**
  (`viewModel.filtrarPorEstado('completado')`);
- el ViewModel decide, valida y notifica;
- cualquier cambio en los datos se propaga solo.

---

## 3. Diagrama de flujo

```
                    ┌──────────────────────────────┐
                    │  AppState (ChangeNotifier)   │
                    │  turnos / clientes /         │
                    │  estilistas / servicios      │
                    └──────────────┬───────────────┘
                                   │ addListener
             ┌─────────────────────┼─────────────────────┐
             ▼                     ▼                     ▼
   AgendaViewModel       ClientesViewModel       HorarioViewModel ...
   (ChangeNotifier)      (ChangeNotifier)        (ChangeNotifier)
             │                     │                     │
             │ notifyListeners     │                     │
             ▼                     ▼                     ▼
      ListenableBuilder     ListenableBuilder     ListenableBuilder
             │                     │                     │
             ▼                     ▼                     ▼
       AgendaScreen          ClientScreen         FechaTurnoScreen
```

Dos direcciones:

1. **Datos → pantalla**: `AppState.notifyListeners()` → cada VM recibe el aviso,
   re-emite el suyo → `ListenableBuilder` reconstruye.
2. **Usuario → datos**: la vista llama a un método del VM → el VM valida y llama
   a `AppState` (por ejemplo `guardarTurno`) → `AppState` notifica → todas las
   pantallas se actualizan.

---

## 4. `AppState`: la fuente de verdad

Archivo: `lib/router/app_state.dart` (180 líneas).

```dart
class AppState extends ChangeNotifier {
  final List<Appointment> turnos;
  final List<Client> clientes;
  final List<Stylist> estilistas;
  final List<Service> servicios;
  ...
}
```

Contiene **solo datos y operaciones de dominio**, sin nada de UI:

- **Búsquedas**: `clientePorId`, `estilistaPorId`, `servicioPorId`, `turnoPorId`.
- **Cálculos**: `duracionDeServicios`, `precioDeServicios`, `duracionDeTurno`,
  `precioDeTurno`, `serviciosDeTurno`.
- **Turnos**: `guardarTurno` (alta o reemplazo por id), `eliminarTurno`,
  `cambiarEstadoTurno` (actualiza `modificadoEn`).
- **Consultas de clientes**: `tieneTurnosProgramados`,
  `cantidadTurnosProgramados`.
- **Clientes**: `guardarCliente`, `eliminarCliente` (bloquea si hay turnos
  programados y devuelve `bool`).

Cada operación de escritura termina en `notifyListeners()`. Ese es el mecanismo
que hace que la actualización sea instantánea en toda la app.

> El estado es **en memoria**: no hay base de datos ni backend. Los datos iniciales
> viven en `lib/data/mock_data.dart`.

---

## 5. Los 8 ViewModels

Todos extienden `ChangeNotifier`, reciben `AppState` por constructor, se
suscriben con `appState.addListener(_alCambiarAppState)` y se desuscriben en
`dispose()`.

| ViewModel | Archivo | Estado propio | Lo que resuelve |
| --- | --- | --- | --- |
| `AgendaViewModel` | `agenda_view_model.dart` | fecha seleccionada, filtro de estilista, filtro de estado | Turnos del día, filtros combinados, contadores, ingreso estimado, nombres y duraciones |
| `TurnoFormViewModel` | `turno_form_view_model.dart` | cliente, estilista, público, servicios elegidos, error | Selección de servicios, filtro por público, estilistas válidos, validación |
| `HorarioViewModel` | `horario_view_model.dart` | fecha, hora, notas, errores | Grilla de horarios, disponibilidad, solapes, guardado |
| `TurnoDetalleViewModel` | `turno_detalle_view_model.dart` | — (deriva todo) | Datos del turno, total, duración, si es editable, completar/cancelar |
| `ClientesViewModel` | `client_view_model.dart` | búsqueda, género | Filtro combinado, contadores, historial, guarda de borrado |
| `ClienteFormViewModel` | `cliente_form_view_model.dart` | controladores, género, error | Validaciones de nombre/teléfono/correo/género y guardado |
| `ServiciosViewModel` | `servicios_view_model.dart` | categoría, público | Catálogo filtrado y etiquetas |
| `EstilistasViewModel` | `estilistas_view_model.dart` | — | Especialidades y turnos de hoy por estilista |

### 5.1 `AgendaViewModel`

```dart
class AgendaViewModel extends ChangeNotifier {
  AgendaViewModel({required this.appState, DateTime? fechaInicial})
    : _fechaSeleccionada = soloFecha(fechaInicial ?? DateTime.now()) {
    appState.addListener(_alCambiarAppState);
  }
  ...
  void cambiarFecha(DateTime fecha) { ... notifyListeners(); }
  void cambiarSemana(int cantidad) { ... }
  void filtrarPorEstilista(String nombre) { ... }
  void filtrarPorEstado(String estado) { ... }
}
```

Expone estado **derivado**, no copias:

- `turnosDelDia` → filtra por fecha y ordena por hora.
- `turnosFiltrados` → aplica estilista + estado.
- `cantidadProgramados`, `cantidadCompletados`, `ingresoEstimado`.
- `nombreCliente`, `nombreEstilista`, `nombresServicios`, `finTurno`.

Ventaja: al no guardar listas copiadas, es imposible mostrar datos viejos.

### 5.2 `TurnoFormViewModel` (paso 1: cliente + servicios + estilista)

- Mantiene `_serviciosElegidos` y lo expone con `List.unmodifiable`.
- `serviciosDeCategoria('color')` filtra por categoría **y** por público.
- `estilistasDisponibles` solo devuelve quienes hacen **todos** los servicios
  elegidos (`haceTodosLosServicios`).
- `seleccionarPublico` quita servicios que dejan de ser visibles y revalida el
  estilista (`_validarEstilista`).
- `validarServicios()` devuelve `bool` y publica `errorServicios` para mostrarlo
  debajo de la grilla.
- En modo edición precarga cliente, estilista y servicios del turno.

### 5.3 `HorarioViewModel` (paso 2: fecha, hora y notas)

Es el VM con más reglas. Expone:

```dart
List<TimeOfDay> horarios;          // 09:00 a 18:30, cada 30 min
bool estaDisponible(TimeOfDay);    // pinta la grilla
void cambiarFecha(DateTime);
void seleccionarHora(TimeOfDay);
bool guardar();                    // true = guardado
String? errorFecha;
String? errorHora;
```

`estaDisponible` devuelve `false` si:

1. es domingo,
2. la fecha es pasada,
3. la hora ya pasó,
4. el turno terminaría después de las 19:00,
5. hay solape con otro turno **del estilista**,
6. hay solape con otro turno **del cliente**.

Los solapes ignoran los turnos `cancelled` y el propio turno cuando se edita:

```dart
if (otro.id == turno?.id) continue;
if (otro.estado.toLowerCase() != 'scheduled') continue;
```

`guardar()` repite todas las validaciones (no confía en la UI), construye el
`Appointment` conservando `creadoEn` y `estado` si es edición, actualiza
`modificadoEn` y llama a `appState.guardarTurno`.

También es dueño del `TextEditingController` de notas y lo libera en `dispose()`.

### 5.4 `TurnoDetalleViewModel`

No guarda copias: busca el turno por id en cada `get` (`appState.turnoPorId`).
Por eso, al completar/cancelar o editar, la pantalla se refresca sola.
`editable` es `true` solo si el estado es `scheduled`.

### 5.5 `ClientesViewModel`

- `clientesFiltrados` combina **búsqueda + género** en un solo getter.
- La búsqueda usa `normalizarTexto` (`lib/utils/texto.dart`), que pasa a
  minúsculas y quita acentos: `"sofia"` encuentra `"Sofía"`.
- `puedeEliminar`, `turnosProgramados`, `cantidadTurnos`, `turnosDeCliente`.

### 5.6 `ClienteFormViewModel`

- Es dueño de los tres `TextEditingController` (nombre, teléfono, correo), así la
  vista no necesita `setState` ni estado propio.
- Validaciones: nombre 3–60, teléfono 8 dígitos, correo opcional con formato,
  género obligatorio.
- `guardar()` devuelve el `Client` guardado o `null` si falta género.

### 5.7 `ServiciosViewModel` y `EstilistasViewModel`

- `ServiciosViewModel`: categorías únicas ordenadas, filtro por público (los
  unisex aparecen siempre), `etiquetaPublico`.
- `EstilistasViewModel`: `especialidadesDe` (categorías de los servicios que
  ofrece el estilista, capitalizadas) y `turnosHoyDe`.

---

## 6. Cómo se conecta una vista (patrón repetido)

Todas las pantallas siguen la misma estructura:

```dart
class ClientScreen extends StatefulWidget {
  final AppState appState;
  const ClientScreen({required this.appState, super.key});
  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  // 1. El VM se crea una sola vez.
  late final ClientesViewModel viewModel =
      ClientesViewModel(appState: widget.appState);

  // 2. Se libera.
  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  // 3. La UI se reconstruye escuchando al VM.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) => _construir(context),
    );
  }
}
```

- `StatefulWidget` **solo** para tener un lugar donde crear y destruir el VM.
- Ningún `setState`.
- Los eventos van al VM: `onChanged: viewModel.buscar`,
  `onSelectionChanged: (s) => viewModel.filtrarPorGenero(s.first)`.

---

## 7. Flujo completo: crear un turno

```
AgendaScreen (FAB "Nuevo turno")
   └─ push('/agendaForm', extra: AgendaFormArgs(fecha: ...))
        └─ AgendaFormScreen  → TurnoFormViewModel
             ├─ Form.validate()            (cliente y estilista)
             ├─ viewModel.validarServicios() (error debajo de la grilla)
             └─ push('/agendaForm/fecha', extra: TurnoArgs(...))
                  └─ FechaTurnoScreen → HorarioViewModel
                       ├─ estaDisponible(hora) pinta cada botón
                       ├─ viewModel.guardar()
                       │    └─ appState.guardarTurno(...)
                       │         └─ notifyListeners()
                       │              ├─ AgendaViewModel se entera → agenda se actualiza
                       │              ├─ ClientesViewModel se entera → contadores
                       │              └─ EstilistasViewModel se entera → turnos de hoy
                       └─ pop(true) → el formulario hace pop(true)
                            └─ AgendaScreen muestra "Turno guardado correctamente."
```

Detalle de navegación:

- `AppState` se inyecta desde `crearRoute(...)` en `lib/router/app_router.dart`.
- Los datos que viajan entre pasos van en `TurnoArgs` / `AgendaFormArgs`
  (`lib/models/turnos_args.dart`).
- La ruta `/agendaForm/fecha` tiene un `redirect` que vuelve al formulario si no
  recibió `TurnoArgs` (evita abrirla sin contexto).

---

## 8. Actualización instantánea entre pestañas

Cada VM se suscribe en su constructor:

```dart
void _alCambiarAppState() => notifyListeners();

@override
void dispose() {
  appState.removeListener(_alCambiarAppState);
  super.dispose();
}
```

Como las cuatro pestañas viven en un `IndexedStack`
(`StatefulShellRoute.indexedStack`) y cada una tiene su VM activo, no hace falta
recargar nada: al guardar un turno, todas reciben la notificación.

Eso está cubierto por la prueba:

```dart
test('Los ViewModels se actualizan al instante al cambiar AppState', () {
  ...
  app.guardarTurno(...);
  expect(avisosAgenda, 1);
  expect(avisosClientes, 1);
  expect(agenda.turnosDelDia.length, 1);
  expect(clientes.cantidadTurnos('c1'), 1);
});
```

---

## 9. Reglas de negocio y dónde viven

| Regla | Dónde |
| --- | --- |
| No domingos | `HorarioViewModel.esDomingo`, `guardar()`, y `selectableDayPredicate` del date picker |
| No pasado | `HorarioViewModel.fechaEnPasado`, `guardar()` |
| Cierre 19:00 / bloques de 30 min | `HorarioViewModel.horarios`, `_cierreDelDia`, `estaDisponible` |
| Solape estilista / cliente | `HorarioViewModel.conflictoEstilista` / `conflictoCliente` |
| Cancelado libera horario | `_buscarConflicto` filtra `scheduled` |
| Estilista debe hacer todos los servicios | `TurnoFormViewModel.haceTodosLosServicios` |
| No borrar cliente con turnos programados | `AppState.eliminarCliente` + `ClientesViewModel.puedeEliminar` |
| Búsqueda sin acentos + género | `ClientesViewModel.clientesFiltrados` + `normalizarTexto` |
| `modificadoEn` al completar/cancelar | `AppState.cambiarEstadoTurno` |
| Totales y duraciones | `AppState.duracionDeTurno` / `precioDeTurno` |

Los mensajes de error de los formularios se muestran **debajo del campo**
(`errorFecha`, `errorHora`, `errorServicios`, `errorGenero`), sin SnackBars para
errores de validación.

---

## 10. Limpieza adicional

Durante la revisión final del MVVM se corrigió:

1. **Se eliminó `AppScope`** (`InheritedNotifier`) de `main.dart` y
   `app_state.dart`: estaba declarado pero nadie lo usaba. Se dejó una sola forma
   de inyectar el estado (por constructor desde el router), para no tener dos
   mecanismos compitiendo.
2. **Se eliminó `ServiciosViewModel.coincideBusqueda`**: código muerto (la
   pantalla de servicios no tiene buscador).
3. **Especialidades de estilistas**: el cálculo estaba duplicado en la vista
   (con `categoria[0].toUpperCase()`). Ahora vive en
   `EstilistasViewModel.especialidadesDe`, ordenado y capitalizado.
4. **Guarda de borrado de clientes**: la vista ahora consulta
   `ClientesViewModel.puedeEliminar` en lugar de repetir la condición
   `programados > 0`.
5. **README** reemplazado (estaba el de plantilla y con un fragmento corrupto en
   UTF-16).

---

## 11. Pruebas

```bash
flutter analyze   # 0 issues
flutter test      # 9 tests
```

Archivos:

- `test/reglas_turnos_test.dart`
  1. Rechaza turnos en domingo
  2. Rechaza turnos en el pasado
  3. Rechaza solape con otro turno del mismo cliente
  4. Un turno cancelado deja el horario libre
  5. Solo muestra estilistas que hacen todos los servicios
  6. La búsqueda ignora acentos y se combina con el género
  7. Bloquea eliminar un cliente con turnos programados
  8. Los ViewModels se actualizan al instante al cambiar AppState
- `test/widget_test.dart`
  9. La app abre en la agenda con la marca Turco

Las pruebas construyen `AppState` con datos propios, así que no dependen de la
fecha real ni de los datos de ejemplo (salvo el test de widget).

---

## 12. Estructura de archivos

```
lib/
├── main.dart                     # MaterialApp.router + tema
├── data/
│   └── mock_data.dart            # Servicios, estilistas, clientes y turnos de ejemplo
├── models/
│   ├── appointment.dart
│   ├── client.dart
│   ├── service.dart
│   ├── stylist.dart
│   └── turnos_args.dart          # AgendaFormArgs / TurnoArgs
├── router/
│   ├── app_state.dart            # Fuente de verdad (ChangeNotifier)
│   └── app_router.dart           # go_router + /agenda?fecha=YYYY-MM-DD
├── theme/
│   └── app_theme.dart            # Colores, tipografía Poppins, claro/oscuro
├── utils/
│   ├── formato.dart              # Fechas, horas, duraciones
│   └── texto.dart                # normalizarTexto (sin acentos)
├── viewmodels/                   # 8 ViewModels
│   ├── agenda_view_model.dart
│   ├── cliente_form_view_model.dart
│   ├── client_view_model.dart
│   ├── estilistas_view_model.dart
│   ├── horario_view_model.dart
│   ├── servicios_view_model.dart
│   ├── turno_detalle_view_model.dart
│   └── turno_form_view_model.dart
├── views/
│   ├── agenda_screen.dart
│   ├── agenda_form_screen.dart
│   ├── agenda_form_fecha_screen.dart
│   ├── detalle_turno_screen.dart
│   ├── client_screen.dart
│   ├── detalles_clientes_screen.dart
│   ├── nuevo_cliente_screen.dart
│   ├── services_screen.dart
│   └── stylists_screen.dart
└── widgets/
    ├── cliente_circle_avatar.dart
    ├── main_shell.dart
    └── theme_button.dart
```

---

## 13. Cómo agregar una pantalla nueva con MVVM

1. Crear el modelo o reutilizar uno existente.
2. Crear `XViewModel extends ChangeNotifier`:
   - recibir `AppState` por constructor y suscribirse;
   - exponer getters derivados;
   - exponer métodos que muten o consulten y llamen `notifyListeners()`;
   - desuscribirse y liberar controladores en `dispose()`.
3. Crear `XScreen` como `StatefulWidget` que:
   - cree el VM con `late final`;
   - lo libere en `dispose()`;
   - devuelva `ListenableBuilder(listenable: viewModel, ...)`.
4. Registrar la ruta en `app_router.dart` pasando `appState`.
5. Agregar tests del VM (sin widgets) para las reglas nuevas.

---

## 14. Límites y decisiones

- **Sin persistencia**: todo vive en memoria; al reiniciar se vuelve a
  `mock_data.dart`.
- **Sin pestaña "Estilos"**: el proyecto no tenía modelo, datos ni pantalla para
  esa sección. Agregarla habría implicado inventar funcionalidad; se documentó la
  decisión en el README.
- **Application ID**: `com.arieldavid.turco`. El requisito original decía
  `com.nombrealumno.turco`; se usó el nombre del alumno (`Ariel David`). Cambiarlo
  requiere editar `android/app/build.gradle.kts` y mover
  `MainActivity.kt` a la carpeta correspondiente.
- **APK release**: el build está bloqueado por la red de este entorno. Gradle no
  puede descargar los artefactos del motor desde
  `storage.googleapis.com/download.flutter.io` (HTTP **403**), por lo que
  `flutter build apk --release` falla en `mergeReleaseNativeLibs`. No es un error
  del código: `flutter analyze` y `flutter test` pasan. El APK debug sí se generó
  antes (`build/app/outputs/flutter-apk/app-debug.apk`).
- **Capturas/servidor web**: se descartaron por pedido explícito; no se agregó la
  plataforma `web` al proyecto.
