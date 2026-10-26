import 'package:flutter/material.dart';
import '../tema/rutas_assets.dart';

class LogoTurco extends StatelessWidget {
  const LogoTurco({super.key, this.tamano = 32});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(tamano * 0.36),
      child: Image.asset(
        RutasAssets.logo(tema.brightness),
        width: tamano,
        height: tamano,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: tamano,
          height: tamano,
          color: colores.primary,
          child: Icon(Icons.content_cut,
              size: tamano * 0.56, color: colores.onPrimary),
        ),
      ),
    );
  }
}