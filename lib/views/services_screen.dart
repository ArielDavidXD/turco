import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/models/service.dart';
import 'package:turco/models/turnos_args.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/viewmodels/servicios_view_model.dart';

class ServicesScreen extends StatefulWidget {
  final AppState appState;

  const ServicesScreen({required this.appState, super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late final ServiciosViewModel viewModel = ServiciosViewModel(
    appState: widget.appState,
  );

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  IconData iconoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'corte':
        return Icons.content_cut;
      case 'color':
        return Icons.palette_outlined;
      case 'barba':
        return Icons.auto_awesome;
      case 'peinado':
        return Icons.auto_fix_high;
      case 'tratamiento':
        return Icons.water_drop_outlined;
      default:
        return Icons.spa_outlined;
    }
  }

  Future<void> reservar(Service servicio) async {
    final resultado = await context.push(
      '/agendaForm',
      extra: AgendaFormArgs(fecha: DateTime.now(), servicioId: servicio.id),
    );

    if (resultado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turno guardado correctamente.')),
      );
    }
  }

  Widget chipCategoria(String categoria) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          categoria == 'todos' ? 'Todas' : viewModel.capitalizar(categoria),
        ),
        selected: viewModel.categoria == categoria,
        onSelected: (_) => viewModel.filtrarPorCategoria(categoria),
      ),
    );
  }

  Widget crearTarjeta(Service servicio) {
    final colores = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => reservar(servicio),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colores.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconoCategoria(servicio.categoria),
                  size: 40,
                  color: colores.onPrimaryContainer,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servicio.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 13,
                        color: colores.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${servicio.duracion_minutos} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: colores.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        '\$ ${servicio.precio.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colores.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colores.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      viewModel.etiquetaPublico(servicio.publico),
                      style: TextStyle(
                        fontSize: 11,
                        color: colores.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    final colores = Theme.of(context).colorScheme;
    final filtrados = viewModel.serviciosFiltrados;

    return Scaffold(
      appBar: AppBar(title: const Text('Servicios')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Servicios',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Toca un servicio para reservar',
                  style: TextStyle(
                    fontSize: 13,
                    color: colores.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                chipCategoria('todos'),
                ...viewModel.categorias.map(chipCategoria),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: SingleChildScrollView(
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
                  viewModel.filtrarPorPublico(seleccion.first);
                },
              ),
            ),
          ),

          Expanded(
            child: filtrados.isEmpty
                ? const Center(child: Text('No hay servicios'))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filtrados.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemBuilder: (context, index) {
                      return crearTarjeta(filtrados[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
