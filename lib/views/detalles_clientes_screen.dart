import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/models/client.dart';
import 'package:turco/models/turnos_args.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/utils/formato.dart';
import 'package:turco/viewmodels/client_view_model.dart';
import 'package:turco/views/nuevo_cliente_screen.dart';

import '../widgets/cliente_circle_avatar.dart';

/// Abre el detalle del cliente como bottom sheet.
Future<void> mostrarDetallesCliente(
  BuildContext context,
  AppState appState,
  Client cliente,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.75,
      child: DetallesClientesScreen(appState: appState, cliente: cliente),
    ),
  );
}

class DetallesClientesScreen extends StatefulWidget {
  final AppState appState;
  final Client cliente;

  const DetallesClientesScreen({
    super.key,
    required this.appState,
    required this.cliente,
  });

  @override
  State<DetallesClientesScreen> createState() => _DetallesClientesScreenState();
}

class _DetallesClientesScreenState extends State<DetallesClientesScreen> {
  late final ClientesViewModel viewModel = ClientesViewModel(
    appState: widget.appState,
  );

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> agendarTurno(Client cliente) async {
    await context.push(
      '/agendaForm',
      extra: AgendaFormArgs(cliente: cliente, fecha: DateTime.now()),
    );
  }

  Future<void> editarCliente(Client cliente) async {
    await mostrarNuevoCliente(context, widget.appState, cliente: cliente);
  }

  Future<void> eliminarCliente(Client cliente) async {
    final programados = viewModel.turnosProgramados(cliente.id);

    if (!viewModel.puedeEliminar(cliente.id)) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('No se puede eliminar'),
          content: Text(
            '${cliente.nombre} tiene $programados '
            '${programados == 1 ? 'turno programado' : 'turnos programados'}. '
            'Cancélalos o complétalos antes de eliminar al cliente.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    final total = viewModel.cantidadTurnos(cliente.id);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: Text(
          total == 0
              ? '¿Seguro que quieres eliminar a ${cliente.nombre}?'
              : '¿Seguro que quieres eliminar a ${cliente.nombre}? '
                    'También se borrará su historial de $total '
                    '${total == 1 ? 'turno' : 'turnos'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    final eliminado = viewModel.eliminarCliente(cliente.id);
    if (eliminado && mounted) {
      Navigator.of(context).pop();
    }
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
    final cliente = viewModel.clientePorId(widget.cliente.id);

    if (cliente == null) {
      return const Center(child: Text('Cliente no disponible'));
    }

    final historial = viewModel.turnosDeCliente(cliente.id);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              ClienteAvatar(cliente: cliente, radio: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(cliente.telefono),
                    const SizedBox(height: 6),
                    Text(
                      cliente.correo ?? 'Sin correo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Historial de turnos',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              Text('${historial.length}'),
            ],
          ),
        ),

        Expanded(
          child: historial.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Este cliente todavía no tiene turnos.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: historial.length,
                  itemBuilder: (context, index) {
                    final turno = historial[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.calendar_month),
                        ),
                        title: Text(fechaCorta(turno.fecha_inicio)),
                        subtitle: Text(
                          '${horaCorta(turno.fecha_inicio)} · '
                          '${textoEstado(turno.estado)}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
        ),

        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => agendarTurno(cliente),
                    icon: const Icon(Icons.add),
                    label: const Text('Agendar turno'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => editarCliente(cliente),
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colores.error,
                          side: BorderSide(color: colores.error),
                        ),
                        onPressed: () => eliminarCliente(cliente),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Eliminar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
