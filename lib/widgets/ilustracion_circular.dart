import 'package:flutter/material.dart';

class IlustracionCircular extends StatelessWidget {
  const IlustracionCircular({
    super.key,
    required this.rutaImagen,
    required this.icono,
    required this.colorFondo,
    required this.colorIcono,
    this.tamano = 120,
  });

  final String rutaImagen;
  final IconData icono;
  final Color colorFondo;
  final Color colorIcono;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: tamano,
        height: tamano,
        alignment: Alignment.center,
        color: colorFondo,
        child: Image.asset(
          rutaImagen,
          width: tamano,
          height: tamano,
          fit: BoxFit.cover,
          // Mientras no exista el archivo se muestra el icono del diseño
          errorBuilder: (_, __, ___) =>
              Icon(icono, size: tamano * 0.465, color: colorIcono),
        ),
      ),
    );
  }
}