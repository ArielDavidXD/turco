import 'package:flutter/material.dart';
import 'package:turco/models/client.dart';
import 'package:turco/router/app_state.dart';
import 'package:turco/viewmodels/cliente_form_view_model.dart';

/// Abre el formulario como bottom sheet.
/// Sin [cliente] crea uno nuevo; con [cliente] lo edita.
/// Devuelve el cliente guardado, o null si se cerró sin guardar.
Future<Client?> mostrarNuevoCliente(
  BuildContext context,
  AppState appState, {
  Client? cliente,
}) {
  return showModalBottomSheet<Client>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => NuevoClienteScreen(appState: appState, cliente: cliente),
  );
}

class NuevoClienteScreen extends StatefulWidget {
  final AppState appState;
  final Client? cliente;

  const NuevoClienteScreen({super.key, required this.appState, this.cliente});

  @override
  State<NuevoClienteScreen> createState() => _NuevoClienteScreenState();
}

class _NuevoClienteScreenState extends State<NuevoClienteScreen> {
  final formKey = GlobalKey<FormState>();

  late final ClienteFormViewModel viewModel = ClienteFormViewModel(
    appState: widget.appState,
    original: widget.cliente,
  );

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  InputDecoration decoracion(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  void guardar() {
    if (!formKey.currentState!.validate()) return;

    final guardado = viewModel.guardar();
    if (guardado == null) return;

    Navigator.of(context).pop(guardado);
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

    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        0,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.editando ? 'Editar cliente' : 'Nuevo cliente',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              const Text('Nombre'),
              const SizedBox(height: 6),
              TextFormField(
                controller: viewModel.nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: decoracion('Ej: Ariel David'),
                validator: viewModel.validarNombre,
              ),
              const SizedBox(height: 14),

              const Text('Teléfono'),
              const SizedBox(height: 6),
              TextFormField(
                controller: viewModel.telefonoController,
                keyboardType: TextInputType.phone,
                decoration: decoracion('Ej: 52537088'),
                validator: viewModel.validarTelefono,
              ),
              const SizedBox(height: 14),

              const Text('Género'),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'mujer', label: Text('Mujer')),
                    ButtonSegment(value: 'hombre', label: Text('Hombre')),
                  ],
                  selected: viewModel.genero == null
                      ? <String>{}
                      : <String>{viewModel.genero!},
                  onSelectionChanged: (seleccion) {
                    viewModel.seleccionarGenero(
                      seleccion.isEmpty ? null : seleccion.first,
                    );
                  },
                ),
              ),
              if (viewModel.errorGenero != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    viewModel.errorGenero!,
                    style: TextStyle(color: colores.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 14),

              const Text('Correo (opcional)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: viewModel.correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: decoracion('Ej: arieldavid@gmail.com'),
                validator: viewModel.validarCorreo,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: guardar,
                  child: Text(
                    viewModel.editando ? 'Guardar cambios' : 'Guardar cliente',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
