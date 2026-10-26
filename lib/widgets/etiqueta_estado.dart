import 'package:flutter/material.dart';
import '../modelos/enumeraciones.dart';

class EtiquetaEstado extends StatelessWidget {
  const EtiquetaEstado({super.key, required this.estado});

  final EstadoTurno estado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final (fondo, texto) = switch (estado) {
      EstadoTurno.programado => (
      colores.primaryContainer,
      colores.onPrimaryContainer
      ),
      EstadoTurno.completado => (
      colores.tertiaryContainer,
      colores.onTertiaryContainer
      ),
      EstadoTurno.cancelado => (
      colores.errorContainer,
      colores.onErrorContainer
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        estado.etiqueta,
        style: tema.textTheme.labelSmall!
            .copyWith(fontWeight: FontWeight.w600, color: texto),
      ),
    );
  }
}