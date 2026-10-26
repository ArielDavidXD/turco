import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/models/appointment.dart';
import 'package:turco/models/turnos_args.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/utils/formato.dart';
import 'package:turco/viewmodels/agenda_view_model.dart';

class AgendaScreen extends StatefulWidget {
  final AppState appState;
  final DateTime? fechaInicial;

  const AgendaScreen({required this.appState, this.fechaInicial, super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late final AgendaViewModel viewModel = AgendaViewModel(
    appState: widget.appState,
    fechaInicial: widget.fechaInicial,
  );

  static const nombresDias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  void didUpdateWidget(covariant AgendaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nuevaFecha = widget.fechaInicial;
    if (nuevaFecha != null && nuevaFecha != oldWidget.fechaInicial) {
      viewModel.cambiarFecha(nuevaFecha);
    }
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: viewModel.fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (fecha != null) {
      viewModel.cambiarFecha(fecha);
    }
  }

  Color colorEstado(String estado, ColorScheme colores) {
    switch (estado.toLowerCase()) {
      case 'completed':
        return colores.tertiary;
      case 'cancelled':
        return colores.error;
      default:
        return colores.primary;
    }
  }

  Widget crearTarjeta(Appointment turno) {
    final colores = Theme.of(context).colorScheme;
    final inicio = turno.fecha_inicio;
    final fin = viewModel.finTurno(turno);
    final color = colorEstado(turno.estado, colores);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/turno/${turno.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 54,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      horaCorta(inicio),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      horaCorta(fin),
                      style: TextStyle(
                        fontSize: 12,
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 3,
                height: 66,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.nombreCliente(turno.id_cliente),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      viewModel.nombresServicios(turno.lista_servicios),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: colores.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            viewModel.nombreEstilista(turno.id_estilista),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  textoEstado(turno.estado),
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tarjetaResumen(String cantidad, String titulo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              cantidad,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget chipEstilista(String nombre) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: ChoiceChip(
        label: Text(nombre),
        selected: viewModel.filtroEstilista == nombre,
        onSelected: (_) => viewModel.filtrarPorEstilista(nombre),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) => _construir(context),
    );
  }

  Widget _construir(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final lunes = viewModel.lunesSeleccionado;
    final turnos = viewModel.turnosFiltrados;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Semana anterior',
                  onPressed: () => viewModel.cambiarSemana(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      nombreMes(viewModel.fechaSeleccionada),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Semana siguiente',
                  onPressed: () => viewModel.cambiarSemana(1),
                  icon: const Icon(Icons.chevron_right),
                ),
                TextButton(
                  onPressed: seleccionarFecha,
                  child: const Text('Fecha'),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 76,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final dia = lunes.add(Duration(days: index));
                final seleccionado =
                    AgendaViewModel.soloFecha(dia) ==
                    AgendaViewModel.soloFecha(viewModel.fechaSeleccionada);
                final domingo = dia.weekday == DateTime.sunday;

                return SizedBox(
                  width: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => viewModel.cambiarFecha(dia),
                      child: Container(
                        decoration: BoxDecoration(
                          color: seleccionado ? colores.primary : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              nombresDias[index],
                              style: TextStyle(
                                color: seleccionado
                                    ? colores.onPrimary
                                    : domingo
                                    ? colores.error
                                    : colores.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${dia.day}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: seleccionado
                                    ? colores.onPrimary
                                    : domingo
                                    ? colores.error
                                    : colores.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              'Domingo: salón cerrado',
              style: TextStyle(color: colores.onSurfaceVariant, fontSize: 12),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: tarjetaResumen(
                  '${viewModel.cantidadProgramados}',
                  'Programados',
                ),
              ),
              Expanded(
                child: tarjetaResumen(
                  '${viewModel.cantidadCompletados}',
                  'Completados',
                ),
              ),
              Expanded(
                child: tarjetaResumen(
                  '\$${viewModel.ingresoEstimado.toStringAsFixed(2)}',
                  'Ingreso est.',
                ),
              ),
            ],
          ),

          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                chipEstilista('Todos'),
                ...viewModel.nombresEstilistas.map(chipEstilista),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'todos', label: Text('Todos')),
                  ButtonSegment(value: 'programado', label: Text('Program.')),
                  ButtonSegment(value: 'completado', label: Text('Complet.')),
                  ButtonSegment(value: 'cancelado', label: Text('Cancel.')),
                ],
                selected: {viewModel.estadoFiltro},
                onSelectionChanged: (seleccion) {
                  viewModel.filtrarPorEstado(seleccion.first);
                },
              ),
            ),
          ),

          Expanded(
            child: turnos.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 54,
                            color: colores.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            viewModel.turnosDelDia.isEmpty
                                ? 'No hay turnos para este día.'
                                : 'No hay turnos que coincidan con los filtros.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colores.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: turnos.length,
                    itemBuilder: (context, index) {
                      return crearTarjeta(turnos[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_agenda',
        onPressed: () async {
          final resultado = await context.push(
            '/agendaForm',
            extra: AgendaFormArgs(fecha: viewModel.fechaSeleccionada),
          );

          if (resultado == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Turno guardado correctamente.')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo turno'),
      ),
    );
  }
}
