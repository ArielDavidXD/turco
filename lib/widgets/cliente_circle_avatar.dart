import 'package:flutter/material.dart';
import 'package:turco/models/client.dart';
import 'package:turco/utils/formato.dart';

class ClienteAvatar extends StatelessWidget {
  final Client cliente;
  final double radio;

  const ClienteAvatar({super.key, required this.cliente, this.radio = 21});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final esMujer = cliente.genero.toLowerCase() == 'mujer';

    final fondo = esMujer
        ? colores.primaryContainer
        : colores.secondaryContainer;
    final texto = esMujer
        ? colores.onPrimaryContainer
        : colores.onSecondaryContainer;

    return CircleAvatar(
      radius: radio,
      backgroundColor: fondo,
      child: Text(
        inicialDe(cliente.nombre),
        style: TextStyle(fontWeight: FontWeight.bold, color: texto),
      ),
    );
  }
}
