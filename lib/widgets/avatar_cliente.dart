import 'package:flutter/material.dart';
import '../modelos/cliente.dart';
import '../modelos/enumeraciones.dart';

class AvatarCliente extends StatelessWidget {
  const AvatarCliente({super.key, required this.cliente, this.tamano = 44});

  final Cliente cliente;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final esMujer = cliente.genero == GeneroCliente.mujer;
    final inicial =
    cliente.nombre.isEmpty ? '?' : cliente.nombre[0].toUpperCase();
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: esMujer ? colores.primaryContainer : colores.tertiaryContainer,
      ),
      child: Text(
        inicial,
        style: TextStyle(
          fontSize: tamano * 0.4,
          fontWeight: FontWeight.w600,
          color: esMujer
              ? colores.onPrimaryContainer
              : colores.onTertiaryContainer,
        ),
      ),
    );
  }
}