import 'enumeraciones.dart';
import 'servicio.dart';

class Turno {
  const Turno({
    required this.id,
    required this.idCliente,
    required this.idEstilista,
    required this.servicios,
    required this.inicio,
    this.notas,
    this.estado = EstadoTurno.programado,
    required this.fechaCreacion,
    required this.fechaModificacion,
  });

  final int id;
  final int idCliente;
  final int idEstilista;
  final List<Servicio> servicios;
  final DateTime inicio;
  final String? notas;
  final EstadoTurno estado;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;

  // Se calculan no se guardan
  int get duracionMinutos =>
      servicios.fold(0, (suma, s) => suma + s.duracionMinutos);
  DateTime get fin => inicio.add(Duration(minutes: duracionMinutos));
  int get precioTotal => servicios.fold(0, (suma, s) => suma + s.precio);

  // Solo los programados ocupan horario
  bool get ocupaHorario => estado == EstadoTurno.programado;

  // Un turno que termina a las 10:00 no choca con otro que empieza a las 10:00
  bool seSolapaConRango(DateTime desde, DateTime hasta) =>
      inicio.isBefore(hasta) && desde.isBefore(fin);

  bool seSolapaCon(Turno otro) => seSolapaConRango(otro.inicio, otro.fin);

  Turno conEstado(EstadoTurno nuevoEstado, DateTime ahora) => Turno(
    id: id,
    idCliente: idCliente,
    idEstilista: idEstilista,
    servicios: servicios,
    inicio: inicio,
    notas: notas,
    estado: nuevoEstado,
    fechaCreacion: fechaCreacion,
    fechaModificacion: ahora,
  );
}