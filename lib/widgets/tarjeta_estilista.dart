import 'package:flutter/material.dart';

import '../modelos/enumeraciones.dart';
import '../modelos/estilista.dart';
import 'avatar_estilista.dart';

class TarjetaEstilista extends StatelessWidget {
  const TarjetaEstilista({
    super.key,
    required this.estilista,
    required this.categorias,
    required this.turnosHoy,
    required this.alTocar,
  });

  final Estilista estilista;
  final List<CategoriaServicio> categorias;
  final int turnosHoy;
  final VoidCallback alTocar;

  String get _textoTurnos {
    if (turnosHoy == 0) return 'Sin turnos hoy';
    if (turnosHoy == 1) return '1 turno hoy';
    return '$turnosHoy turnos hoy';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colores.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AvatarEstilista(estilista: estilista),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estilista.nombre,
                      style: tema.textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final categoria in categorias)
                          Chip(
                            label: Text(categoria.etiqueta),
                            labelStyle: tema.textTheme.bodyMedium!.copyWith(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _textoTurnos,
                      style: tema.textTheme.bodyMedium!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: turnosHoy == 0
                            ? colores.onSurfaceVariant
                            : colores.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colores.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}