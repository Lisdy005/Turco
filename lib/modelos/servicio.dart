import 'enumeraciones.dart';

class Servicio {
  const Servicio({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.duracionMinutos,
    required this.precio,
    required this.publico,
  });

  final int id;
  final String nombre;
  final CategoriaServicio categoria;
  final int duracionMinutos;
  final int precio;
  final PublicoServicio publico;
}