import 'package:flutter/material.dart';
import '../modelos/enumeraciones.dart';
import '../tema/rutas_assets.dart';

IconData iconoDeCategoria(CategoriaServicio categoria) => switch (categoria) {
  CategoriaServicio.corte => Icons.content_cut,
  CategoriaServicio.color => Icons.palette_outlined,
  CategoriaServicio.barba => Icons.auto_awesome,
  CategoriaServicio.peinado => Icons.auto_fix_high,
  CategoriaServicio.tratamiento => Icons.water_drop_outlined,
};

class ImagenCategoria extends StatelessWidget {
  const ImagenCategoria({super.key, required this.categoria, this.alto = 84});

  final CategoriaServicio categoria;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: alto,
        width: double.infinity,
        color: colores.primaryContainer,
        child: Image.asset(
          // Versión clara u oscura según el tema actual
          RutasAssets.imagenCategoria(categoria, tema.brightness),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              iconoDeCategoria(categoria),
              size: 36,
              color: colores.primary,
            ),
          ),
        ),
      ),
    );
  }
}