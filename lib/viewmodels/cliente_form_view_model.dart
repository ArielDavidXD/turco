import 'package:flutter/material.dart';
import 'package:turco/models/client.dart';
import 'package:turco/router/app_state.dart';

/// Lógica y controladores del formulario de alta/edición de clientes.
class ClienteFormViewModel extends ChangeNotifier {
  ClienteFormViewModel({required this.appState, this.original}) {
    nombreController = TextEditingController(text: original?.nombre ?? '');
    telefonoController = TextEditingController(text: original?.telefono ?? '');
    correoController = TextEditingController(text: original?.correo ?? '');
    _genero = original?.genero.toLowerCase();
  }

  final AppState appState;
  final Client? original;

  late final TextEditingController nombreController;
  late final TextEditingController telefonoController;
  late final TextEditingController correoController;

  String? _genero;
  String? _errorGenero;

  bool get editando => original != null;
  String? get genero => _genero;
  String? get errorGenero => _errorGenero;

  String? validarNombre(String? valor) {
    final nombre = valor?.trim() ?? '';

    if (nombre.isEmpty) return 'Escribe el nombre';
    if (nombre.length < 3 || nombre.length > 60) {
      return 'Escribe entre 3 y 60 caracteres';
    }
    return null;
  }

  String? validarTelefono(String? valor) {
    final telefono = valor?.trim() ?? '';

    if (telefono.isEmpty) return 'Escribe el teléfono';
    if (!RegExp(r'^\d{8}$').hasMatch(telefono)) {
      return 'Debe tener exactamente 8 dígitos';
    }
    return null;
  }

  String? validarCorreo(String? valor) {
    final correo = valor?.trim() ?? '';

    if (correo.isEmpty) return null;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(correo)) {
      return 'Escribe un correo válido';
    }
    return null;
  }

  void seleccionarGenero(String? genero) {
    _genero = genero;
    _errorGenero = null;
    notifyListeners();
  }

  /// Devuelve `null` si falta el género.
  String? validarGenero() {
    _errorGenero = _genero == null ? 'Selecciona un género' : null;
    notifyListeners();
    return _errorGenero;
  }

  Client? guardar() {
    if (validarGenero() != null) return null;

    final correoTexto = correoController.text.trim();
    final guardado = Client(
      id: original?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombreController.text.trim(),
      telefono: telefonoController.text.trim(),
      genero: _genero!,
      correo: correoTexto.isEmpty ? null : correoTexto,
      fecha_registro: original?.fecha_registro ?? DateTime.now(),
    );

    appState.guardarCliente(guardado);
    return guardado;
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    super.dispose();
  }
}
