import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../viewmodelos/salon_viewmodelo.dart';
import '../widgets/tarjeta_estilista.dart';

class PantallaEstilistas extends StatelessWidget {
  const PantallaEstilistas({super.key, required this.salon});

  final SalonViewModelo salon;

  String _resumen() {
    final profesionales = salon.estilistas.length;
    final turnos = salon.estilistas
        .fold(0, (suma, e) => suma + salon.turnosProgramadosHoy(e.id));
    final textoTurnos =
    turnos == 1 ? '1 turno programado hoy' : '$turnos turnos programados hoy';
    return '$profesionales profesionales · $textoTurnos';
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      body: ListenableBuilder(
        listenable: salon,
        builder: (context, _) {
          final estilistas = salon.estilistas;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 170,
                scrolledUnderElevation: 0,
                backgroundColor: colores.primary,
                foregroundColor: colores.onPrimary,
                flexibleSpace: _EncabezadoEstilistas(resumen: _resumen()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, indice) {
                      final estilista = estilistas[indice];
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: indice == estilistas.length - 1 ? 0 : 10),
                        child: TarjetaEstilista(
                          estilista: estilista,
                          categorias: salon.categoriasDeEstilista(estilista),
                          turnosHoy: salon.turnosProgramadosHoy(estilista.id),
                          alTocar: () =>
                              context.go('/agenda?estilista=${estilista.id}'),
                        ),
                      );
                    },
                    childCount: estilistas.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Al plegarse el encabezado grande se desvanece y aparece un título compacto
class _EncabezadoEstilistas extends StatelessWidget {
  const _EncabezadoEstilistas({required this.resumen});

  final String resumen;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final arriba = MediaQuery.paddingOf(context).top;

    return LayoutBuilder(
      builder: (context, restricciones) {
        final minimo = kToolbarHeight + arriba;
        final maximo = 170 + arriba;
        final expansion = ((restricciones.maxHeight - minimo) / (maximo - minimo))
            .clamp(0.0, 1.0);

        return ClipRect(
          child: Padding(
            padding: EdgeInsets.only(top: arriba),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: expansion,
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      minHeight: 0,
                      maxHeight: 170,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.badge_outlined,
                                size: 28, color: colores.onPrimary),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estilistas',
                                  style: tema.textTheme.headlineSmall!.copyWith(
                                      fontSize: 28, color: colores.onPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  resumen,
                                  style: tema.textTheme.bodyMedium!.copyWith(
                                    fontSize: 13,
                                    color: colores.onPrimary
                                        .withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: kToolbarHeight,
                  child: Opacity(
                    opacity: 1 - expansion,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'Estilistas',
                          style: tema.textTheme.titleLarge!
                              .copyWith(color: colores.onPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}