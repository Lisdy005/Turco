import 'package:flutter/material.dart';

import '../modelos/estilista.dart';

class AvatarEstilista extends StatelessWidget {
  const AvatarEstilista({super.key, required this.estilista, this.tamano = 56});

  final Estilista estilista;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final inicial =
    estilista.nombre.isEmpty ? '?' : estilista.nombre[0].toUpperCase();
    return ClipOval(
      child: Container(
        width: tamano,
        height: tamano,
        color: colores.primaryContainer,
        child: Image.asset(
          estilista.rutaAvatar,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              inicial,
              style: TextStyle(
                fontSize: tamano * 0.4,
                fontWeight: FontWeight.w600,
                color: colores.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}