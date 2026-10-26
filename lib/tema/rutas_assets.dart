import 'package:flutter/material.dart';
import '../modelos/enumeraciones.dart';

class RutasAssets {
  static const String _imagenes = 'assets/imagenes';

  static String _modo(Brightness brillo) =>
      brillo == Brightness.dark ? 'oscuro' : 'claro';

  static String imagenCategoria(
      CategoriaServicio categoria, Brightness brillo) =>
      '$_imagenes/categorias/${_modo(brillo)}/${categoria.name}.png';

  static String logo(Brightness brillo) =>
      '$_imagenes/logo_${_modo(brillo)}.png';

  static String ilustracionVacia(Brightness brillo) =>
      '$_imagenes/ilustracion_vacia_${_modo(brillo)}.png';

  static String ilustracionNoEncontrado(Brightness brillo) =>
      '$_imagenes/ilustracion_no_encontrado_${_modo(brillo)}.png';
}