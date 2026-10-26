import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turco/models/appointment.dart';
import 'package:turco/models/client.dart';
import 'package:turco/models/stylist.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/utils/formato.dart';
import 'package:turco/viewmodels/horario_view_model.dart';

class FechaTurnoScreen extends StatefulWidget {
  final AppState appState;
  final Client cliente;
  final Stylist estilista;
  final List<String> serviciosElegidos;
  final DateTime? fechaInicial;
  final Appointment? turno;

  const FechaTurnoScreen({
    required this.appState,
    required this.cliente,
    required this.estilista,
    required this.serviciosElegidos,
    this.fechaInicial,
    this.turno,
    super.key,
  });

  @override
  State<FechaTurnoScreen> createState() => _FechaTurnoScreenState();
}

class _FechaTurnoScreenState extends State<FechaTurnoScreen> {
  late final HorarioViewModel viewModel = HorarioViewModel(
    appState: widget.appState,
    cliente: widget.cliente,
    estilista: widget.estilista,
    serviciosElegidos: widget.serviciosElegidos,
    fechaInicial: widget.fechaInicial,
    turno: widget.turno,
  );

  String formatoHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}';
  }

  Future<void> elegirFecha() async {
    final hoy = HorarioViewModel.soloFecha(DateTime.now());
    final inicial = viewModel.fechaSeleccionada;
    final primera = inicial.isBefore(hoy) ? inicial : hoy;

    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: primera,
      lastDate: hoy.add(const Duration(days: 365)),
      selectableDayPredicate: (dia) => dia.weekday != DateTime.sunday,
    );

    if (fecha != null) {
      viewModel.cambiarFecha(fecha);
    }
  }

  void guardar() {
    if (viewModel.guardar()) {
      context.pop(true);
    }
  }

  Widget leyenda(ColorScheme colores) {
    Widget item(Color? fondo, Color borde, String texto) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: borde),
            ),
          ),
          const SizedBox(width: 4),
          Text(texto, style: const TextStyle(fontSize: 11)),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        item(null, colores.outline, 'Libre'),
        item(colores.surfaceContainer, colores.outlineVariant, 'No disponible'),
        item(colores.primary, colores.primary, 'Elegida'),
      ],
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
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
    final fin = viewModel.finSeleccionado;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewModel.editando ? 'Editar turno' : 'Nuevo turno',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Fecha', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 6),

          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
            ),
            onPressed: elegirFecha,
            child: Row(
              children: [
                const Icon(Icons.calendar_month),
                const SizedBox(width: 12),
                Expanded(child: Text(fechaCorta(viewModel.fechaSeleccionada))),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),

          if (viewModel.errorFecha != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Text(
                viewModel.errorFecha!,
                style: TextStyle(color: colores.error, fontSize: 12),
              ),
            ),

          if (viewModel.esDomingo)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Domingo: salón cerrado.',
                style: TextStyle(
                  color: colores.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const SizedBox(height: 16),

          const Text(
            'Hora de inicio',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: HorarioViewModel.horarios.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final hora = HorarioViewModel.horarios[index];
              final disponible = viewModel.estaDisponible(hora);
              final seleccionada = viewModel.horaSeleccionada == hora;

              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: seleccionada
                      ? colores.primary
                      : disponible
                      ? null
                      : colores.surfaceContainer,
                  foregroundColor: seleccionada
                      ? colores.onPrimary
                      : disponible
                      ? colores.onSurface
                      : colores.onSurfaceVariant,
                  disabledForegroundColor: colores.onSurfaceVariant,
                  side: BorderSide(
                    color: seleccionada
                        ? colores.primary
                        : colores.outlineVariant,
                  ),
                ),
                onPressed: disponible
                    ? () => viewModel.seleccionarHora(hora)
                    : null,
                child: Text(formatoHora(hora)),
              );
            },
          ),

          const SizedBox(height: 8),
          leyenda(colores),

          if (viewModel.errorHora != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                viewModel.errorHora!,
                style: TextStyle(color: colores.error, fontSize: 12),
              ),
            ),

          const SizedBox(height: 16),

          const Text(
            'Notas (opcional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: viewModel.notasController,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Preferencias o indicaciones del cliente...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colores.outlineVariant)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colores.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      '◷ ${viewModel.duracion} min',
                      style: TextStyle(color: colores.onPrimaryContainer),
                    ),
                    Text(
                      fin == null ? 'Fin: --:--' : 'Fin: ${horaCorta(fin)}',
                      style: TextStyle(color: colores.onPrimaryContainer),
                    ),
                    Text(
                      '\$${viewModel.precio.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colores.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: guardar,
                      icon: const Icon(Icons.check),
                      label: Text(
                        viewModel.editando
                            ? 'Guardar cambios'
                            : 'Guardar turno',
                      ),
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
