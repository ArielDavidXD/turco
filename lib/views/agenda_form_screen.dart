import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/models/appointment.dart';
import 'package:turco/models/client.dart';
import 'package:turco/models/service.dart';
import 'package:turco/models/stylist.dart';
import 'package:turco/models/turnos_args.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/viewmodels/turno_form_view_model.dart';
import 'package:turco/views/nuevo_cliente_screen.dart';

class AgendaFormScreen extends StatefulWidget {
  final Client? cliente;
  final AppState appState;
  final DateTime? fechaInicial;
  final Appointment? turno;
  final String? servicioInicial;

  const AgendaFormScreen({
    required this.appState,
    this.fechaInicial,
    this.cliente,
    this.turno,
    this.servicioInicial,
    super.key,
  });

  @override
  State<AgendaFormScreen> createState() => _AgendaFormScreenState();
}

class _AgendaFormScreenState extends State<AgendaFormScreen> {
  final formKey = GlobalKey<FormState>();

  late final TurnoFormViewModel viewModel = TurnoFormViewModel(
    appState: widget.appState,
    cliente: widget.cliente,
    turno: widget.turno,
    servicioInicial: widget.servicioInicial,
  );

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Widget crearChip(Service servicio) {
    return FilterChip(
      label: Text(servicio.nombre, style: const TextStyle(fontSize: 12)),
      selected: viewModel.serviciosElegidos.contains(servicio.id),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      onSelected: (_) => viewModel.alternarServicio(servicio.id),
    );
  }

  Widget grupoServicios(String titulo, String categoria) {
    final lista = viewModel.serviciosDeCategoria(categoria);
    if (lista.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(spacing: 8, children: lista.map(crearChip).toList()),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> continuar() async {
    if (!formKey.currentState!.validate()) return;
    if (!viewModel.validarServicios()) return;

    final resultado = await context.push(
      '/agendaForm/fecha',
      extra: TurnoArgs(
        cliente: viewModel.cliente!,
        estilista: viewModel.estilista!,
        serviciosElegidos: viewModel.serviciosElegidos,
        fecha: widget.turno?.fecha_inicio ?? widget.fechaInicial,
        turno: widget.turno,
      ),
    );

    if (resultado == true && mounted) {
      context.pop(true);
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
    final estilistasDisponibles = viewModel.estilistasDisponibles;
    final sinEstilistas = estilistasDisponibles.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewModel.editando ? 'Editar turno' : 'Nuevo turno',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Cliente'),
            const SizedBox(height: 8),

            DropdownButtonFormField<Client>(
              key: ValueKey(viewModel.cliente?.id ?? 'sin_cliente'),
              initialValue: viewModel.cliente,
              hint: const Text('Seleccionar cliente'),
              isExpanded: true,
              items: viewModel.clientes.map((cliente) {
                return DropdownMenuItem<Client>(
                  value: cliente,
                  child: Text(cliente.nombre),
                );
              }).toList(),
              validator: (valor) =>
                  valor == null ? 'Selecciona un cliente' : null,
              onChanged: viewModel.seleccionarCliente,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  final nuevo = await mostrarNuevoCliente(
                    context,
                    widget.appState,
                  );
                  if (nuevo != null) {
                    viewModel.seleccionarCliente(nuevo);
                  }
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Crear cliente nuevo'),
              ),
            ),

            const SizedBox(height: 8),

            const Text('Servicios para'),
            const SizedBox(height: 8),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'todos', label: Text('Todos')),
                  ButtonSegment(value: 'mujeres', label: Text('Mujeres')),
                  ButtonSegment(value: 'hombres', label: Text('Hombres')),
                ],
                selected: {viewModel.publico},
                onSelectionChanged: (seleccion) {
                  viewModel.seleccionarPublico(seleccion.first);
                },
              ),
            ),

            const SizedBox(height: 12),

            ...TurnoFormViewModel.categorias.entries.map(
              (categoria) => grupoServicios(categoria.value, categoria.key),
            ),

            if (viewModel.errorServicios != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  viewModel.errorServicios!,
                  style: TextStyle(color: colores.error, fontSize: 12),
                ),
              ),

            const SizedBox(height: 8),

            const Text('Estilista'),
            const SizedBox(height: 8),

            DropdownButtonFormField<Stylist>(
              key: ValueKey(
                '${viewModel.estilista?.id ?? 'sin_estilista'}_'
                '${estilistasDisponibles.length}',
              ),
              initialValue: viewModel.estilista,
              hint: Text(
                sinEstilistas
                    ? 'Sin estilistas disponibles'
                    : 'Seleccionar estilista',
              ),
              isExpanded: true,
              items: estilistasDisponibles.map((estilista) {
                return DropdownMenuItem<Stylist>(
                  value: estilista,
                  child: Text(estilista.nombre),
                );
              }).toList(),
              validator: (valor) => valor == null
                  ? sinEstilistas
                        ? 'Ningún estilista realiza todos los servicios.'
                        : 'Selecciona un estilista'
                  : null,
              onChanged: sinEstilistas ? null : viewModel.seleccionarEstilista,
            ),

            const SizedBox(height: 8),

            Text(
              'Solo se muestran estilistas que realizan todos los servicios elegidos.',
              style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${viewModel.duracion} min'),
                    Text(
                      '\$ ${viewModel.precio.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: continuar,
                      child: const Text('Continuar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
