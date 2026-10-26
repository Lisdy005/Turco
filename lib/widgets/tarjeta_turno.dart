import 'package:flutter/material.dart';
import '../modelos/enumeraciones.dart';
import '../modelos/turno.dart';
import '../utilidades/formato.dart';
import 'etiqueta_estado.dart';

class TarjetaTurno extends StatelessWidget {
  const TarjetaTurno({
    super.key,
    required this.turno,
    required this.nombreCliente,
    required this.nombreEstilista,
    required this.alTocar,
    this.alPulsacionLarga,
  });

  final Turno turno;
  final String nombreCliente;
  final String nombreEstilista;
  final VoidCallback alTocar;
  final VoidCallback? alPulsacionLarga;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final colorBarra = switch (turno.estado) {
      EstadoTurno.programado => colores.primary,
      EstadoTurno.completado => colores.tertiary,
      EstadoTurno.cancelado => colores.error,
    };
    final cancelado = turno.estado == EstadoTurno.cancelado;
    final colorSecundario =
    cancelado ? colores.outline : colores.onSurfaceVariant;
    final servicios = turno.servicios.map((s) => s.nombre).join(' + ');

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colores.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alTocar,
        onLongPress: alPulsacionLarga,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 0, 12),
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: colorBarra,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatearHora(turno.inicio),
                      style: tema.textTheme.titleMedium!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colores.onSurface),
                    ),
                    Text(formatearHora(turno.fin),
                        style: tema.textTheme.bodyMedium!.copyWith(fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreCliente,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.titleMedium!.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: colores.onSurface),
                      ),
                      Text(
                        servicios,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.bodyMedium!
                            .copyWith(fontSize: 14, color: colorSecundario),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 16, color: colorSecundario),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              nombreEstilista,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tema.textTheme.bodyMedium!.copyWith(
                                  fontSize: 13, color: colorSecundario),
                            ),
                          ),
                          const SizedBox(width: 8),
                          EtiquetaEstado(estado: turno.estado),
                        ],
                      ),
                    ],
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