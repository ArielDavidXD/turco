import 'package:flutter/material.dart';
import 'package:turco/models/stylist.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/utils/formato.dart';
import 'package:turco/viewmodels/estilistas_view_model.dart';

class StylistsScreen extends StatefulWidget {
  final AppState appState;

  const StylistsScreen({required this.appState, super.key});

  @override
  State<StylistsScreen> createState() => _StylistsScreenState();
}

class _StylistsScreenState extends State<StylistsScreen> {
  late final EstilistasViewModel viewModel = EstilistasViewModel(
    appState: widget.appState,
  );

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Widget avatar(Stylist estilista, ColorScheme colores) {
    return ClipOval(
      child: Image.asset(
        estilista.ruta_avatar,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return CircleAvatar(
            radius: 26,
            backgroundColor: colores.primaryContainer,
            child: Text(
              inicialDe(estilista.nombre),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colores.onPrimaryContainer,
              ),
            ),
          );
        },
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
    final estilistas = viewModel.estilistas;
    final turnosHoy = viewModel.turnosHoy;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: colores.primary,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.badge_outlined, color: colores.onPrimary),
                const SizedBox(height: 8),
                Text(
                  'Estilistas',
                  style: TextStyle(
                    color: colores.onPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${estilistas.length} profesionales · '
                  '${turnosHoy.length} turnos programados hoy',
                  style: TextStyle(color: colores.onPrimary, fontSize: 13),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: estilistas.length,
              itemBuilder: (context, index) {
                final estilista = estilistas[index];
                final categorias = viewModel.especialidadesDe(estilista.id);
                final turnosDelEstilista = viewModel.turnosHoyDe(estilista.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        avatar(estilista, colores),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                estilista.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (categorias.isNotEmpty)
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: categorias.map((categoria) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: colores.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        categoria,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 6),
                              Text(
                                turnosDelEstilista == 0
                                    ? 'Sin turnos hoy'
                                    : '$turnosDelEstilista '
                                          '${turnosDelEstilista == 1 ? 'turno' : 'turnos'} hoy',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: turnosDelEstilista == 0
                                      ? colores.onSurfaceVariant
                                      : colores.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
