import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/models/appointment.dart';
import 'package:turco/models/turnos_args.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/utils/formato.dart';
import 'package:turco/viewmodels/turno_detalle_view_model.dart';

class DetalleTurnoScreen extends StatefulWidget {
  final AppState appState;
  final String turnoId;

  const DetalleTurnoScreen({
    required this.appState,
    required this.turnoId,
    super.key,
  });

  @override
  State<DetalleTurnoScreen> createState() => _DetalleTurnoScreenState();
}

class _DetalleTurnoScreenState extends State<DetalleTurnoScreen> {
  late final TurnoDetalleViewModel viewModel = TurnoDetalleViewModel(
    appState: widget.appState,
    turnoId: widget.turnoId,
  );

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
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

  Future<void> cancelarTurno() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar turno'),
        content: const Text('¿Seguro que quieres cancelar este turno?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Volver'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancelar turno'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      viewModel.cambiarEstado('cancelled');
    }
  }

  Future<void> editarTurno(Appointment turno) async {
    await context.push('/agendaForm', extra: AgendaFormArgs(turno: turno));
  }

  void completarTurno() {
    viewModel.cambiarEstado('completed');
  }

  Widget filaDato(IconData icono, String etiqueta, String valor) {
    final colores = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: colores.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: TextStyle(
                    fontSize: 11,
                    color: colores.onSurfaceVariant,
                  ),
                ),
                Text(
                  valor,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget vistaNoEncontrado() {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del turno')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: colores.errorContainer,
                child: Icon(
                  Icons.search_off,
                  size: 40,
                  color: colores.onErrorContainer,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No encontramos este turno',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'El turno no existe o ya no está disponible.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colores.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.go('/agenda'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver a la agenda'),
              ),
            ],
          ),
        ),
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
    final turno = viewModel.turno;
    if (turno == null) return vistaNoEncontrado();

    final colores = Theme.of(context).colorScheme;
    final cliente = viewModel.cliente;
    final estilista = viewModel.estilista;
    final servicios = viewModel.servicios;
    final estado = turno.estado.toLowerCase();
    final color = colorEstado(estado, colores);
    final editable = viewModel.editable;
    final fin = viewModel.fin!;
    final nombreCliente = cliente?.nombre ?? 'Cliente desconocido';
    final notas = turno.notas?.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del turno',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: colores.primaryContainer,
                        child: Text(
                          inicialDe(nombreCliente),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colores.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombreCliente,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (cliente != null)
                              Text(
                                cliente.telefono,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colores.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          textoEstado(estado),
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  filaDato(
                    Icons.calendar_month,
                    'Fecha',
                    fechaLarga(turno.fecha_inicio),
                  ),
                  filaDato(
                    Icons.schedule,
                    'Hora',
                    '${horaCorta(turno.fecha_inicio)} a ${horaCorta(fin)} '
                        '(${duracionTexto(viewModel.duracion)})',
                  ),
                  filaDato(
                    Icons.person_outline,
                    'Estilista',
                    estilista?.nombre ?? 'Estilista desconocido',
                  ),
                ],
              ),
            ),
          ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Servicios',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (servicios.isEmpty)
                    const Text('Sin servicios')
                  else
                    for (final servicio in servicios)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(servicio.nombre),
                                  Text(
                                    '${servicio.duracion_minutos} min',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colores.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${servicio.precio.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '\$${viewModel.total.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colores.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notas == null || notas.isEmpty ? 'Sin notas' : notas,
                    style: TextStyle(
                      color: notas == null || notas.isEmpty
                          ? colores.onSurfaceVariant
                          : colores.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registro',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  filaDato(
                    Icons.add_circle_outline,
                    'Creado el',
                    fechaHoraCompleta(turno.creadoEn),
                  ),
                  filaDato(
                    Icons.update,
                    'Modificado el',
                    fechaHoraCompleta(turno.modificadoEn),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: editable
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => editarTurno(turno),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Editar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: completarTurno,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Completar'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: colores.error,
                        ),
                        onPressed: cancelarTurno,
                        icon: const Icon(Icons.block, size: 18),
                        label: const Text('Cancelar turno'),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: colores.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          estado == 'completed'
                              ? 'Turno completado: solo lectura'
                              : 'Turno cancelado: solo lectura',
                          style: TextStyle(
                            fontSize: 13,
                            color: colores.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
