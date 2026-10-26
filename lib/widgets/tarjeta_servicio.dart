import 'package:flutter/material.dart';
import '../modelos/servicio.dart';
import 'imagen_categoria.dart';

class TarjetaServicio extends StatelessWidget {
  const TarjetaServicio({
    super.key,
    required this.servicio,
    required this.alTocar,
  });

  final Servicio servicio;
  final VoidCallback alTocar;

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
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImagenCategoria(categoria: servicio.categoria),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  servicio.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.titleMedium!
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 12, color: colores.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text('${servicio.duracionMinutos} min',
                          style: tema.textTheme.bodyMedium!
                              .copyWith(fontSize: 12)),
                    ],
                  ),
                  Text(
                    '\$ ${servicio.precio}',
                    style: tema.textTheme.bodyMedium!.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colores.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colores.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  servicio.publico.etiqueta,
                  style: tema.textTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colores.onSecondaryContainer,
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