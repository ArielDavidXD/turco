import 'package:flutter/material.dart';
import 'package:turco/models/client.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/viewmodels/client_view_model.dart';

import '../widgets/cliente_circle_avatar.dart';
import 'detalles_clientes_screen.dart';
import 'nuevo_cliente_screen.dart';

class ClientScreen extends StatefulWidget {
  final AppState appState;

  const ClientScreen({required this.appState, super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  late final ClientesViewModel viewModel = ClientesViewModel(
    appState: widget.appState,
  );

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Widget crearTarjeta(Client cliente) {
    final colores = Theme.of(context).colorScheme;
    final cantidadTurnos = viewModel.cantidadTurnos(cliente.id);

    return Card(
      color: colores.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => mostrarDetallesCliente(context, widget.appState, cliente),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              ClienteAvatar(cliente: cliente),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${cliente.telefono} · ${cliente.genero}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$cantidadTurnos '
                '${cantidadTurnos == 1 ? 'turno' : 'turnos'}',
                style: const TextStyle(fontSize: 12),
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
    final clientesFiltrados = viewModel.clientesFiltrados;

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o teléfono',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: viewModel.buscar,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'todos', label: Text('Todos')),
                  ButtonSegment(value: 'mujeres', label: Text('Mujeres')),
                  ButtonSegment(value: 'hombres', label: Text('Hombres')),
                ],
                selected: {viewModel.genero},
                onSelectionChanged: (seleccion) {
                  viewModel.filtrarPorGenero(seleccion.first);
                },
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                Text('${viewModel.clientes.length} clientes'),
                Text('${viewModel.cantidadMujeres} mujeres'),
                Text('${viewModel.cantidadHombres} hombres'),
              ],
            ),
            const SizedBox(height: 15),
            if (clientesFiltrados.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No se encontraron clientes'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: clientesFiltrados.length,
                itemBuilder: (context, index) {
                  return crearTarjeta(clientesFiltrados[index]);
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_clientes',
        onPressed: () => mostrarNuevoCliente(context, widget.appState),
        elevation: 3,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nuevo Cliente',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
