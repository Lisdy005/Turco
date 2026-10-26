import 'servicio.dart';

class Estilista {
  const Estilista({
    required this.id,
    required this.nombre,
    required this.rutaAvatar,
    required this.idsServicios,
  });

  final int id;
  final String nombre;
  final String rutaAvatar;
  final List<int> idsServicios;

  bool realizaTodos(List<Servicio> servicios) =>
      servicios.every((s) => idsServicios.contains(s.id));
}