import 'package:flutter/foundation.dart';
import '../datos/datos_prueba.dart';
import '../modelos/cliente.dart';
import '../modelos/enumeraciones.dart';
import '../modelos/estilista.dart';
import '../modelos/servicio.dart';
import '../modelos/turno.dart';
import '../utilidades/formato.dart';

class SalonViewModelo extends ChangeNotifier {
  SalonViewModelo()
      : _clientes = DatosPrueba.clientes(),
        _turnos = DatosPrueba.turnos();

  static const int horaApertura = 9;
  static const int horaCierre = 19;
  static const int pasoMinutos = 30;

  final List<Cliente> _clientes;
  final List<Turno> _turnos;

  // Consultas:
  List<Servicio> get servicios => DatosPrueba.servicios;
  List<Estilista> get estilistas => DatosPrueba.estilistas;
  List<Cliente> get clientes => List.unmodifiable(_clientes);
  List<Turno> get turnos => List.unmodifiable(_turnos);

  Cliente? clientePorId(int id) =>
      _clientes.where((c) => c.id == id).firstOrNull;
  Estilista? estilistaPorId(int id) =>
      estilistas.where((e) => e.id == id).firstOrNull;
  Turno? turnoPorId(int id) => _turnos.where((t) => t.id == id).firstOrNull;

  List<Estilista> estilistasParaServicios(List<Servicio> elegidos) =>
      estilistas.where((e) => e.realizaTodos(elegidos)).toList();

  List<Servicio> serviciosFiltrados({
    CategoriaServicio? categoria,
    PublicoServicio? publico,
  }) =>
      servicios
          .where((s) =>
      (categoria == null || s.categoria == categoria) &&
          (publico == null ||
              s.publico == publico ||
              s.publico == PublicoServicio.unisex))
          .toList();

  List<CategoriaServicio> categoriasDeEstilista(Estilista estilista) {
    final categorias = servicios
        .where((s) => estilista.idsServicios.contains(s.id))
        .map((s) => s.categoria)
        .toSet();
    return CategoriaServicio.values.where(categorias.contains).toList();
  }

  // Horario del salón:
  static bool mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool esDiaLaborable(DateTime fecha) =>
      fecha.weekday != DateTime.sunday;

  List<Turno> turnosDelDia(DateTime dia) {
    final lista = _turnos.where((t) => mismoDia(t.inicio, dia)).toList();
    lista.sort((a, b) => a.inicio.compareTo(b.inicio));
    return lista;
  }

  List<Turno> turnosFiltrados(
      DateTime dia, {
        int? idEstilista,
        EstadoTurno? estado,
      }) =>
      turnosDelDia(dia)
          .where((t) =>
      (idEstilista == null || t.idEstilista == idEstilista) &&
          (estado == null || t.estado == estado))
          .toList();

  // Franjas de inicio posibles: 9:00, 9:30, ... 18:30
  List<DateTime> franjasDelDia(DateTime dia) => [
    for (var min = horaApertura * 60;
    min < horaCierre * 60;
    min += pasoMinutos)
      DateTime(dia.year, dia.month, dia.day, 0, min),
  ];

  EstadoFranja estadoFranja({
    required DateTime inicio,
    required int duracionMinutos,
    int? idEstilista,
    int? idCliente,
    int? idTurnoEditado,
  }) {
    if (!inicio.isAfter(DateTime.now())) return EstadoFranja.pasada;
    final fin = inicio.add(Duration(minutes: duracionMinutos));
    final cierre =
    DateTime(inicio.year, inicio.month, inicio.day, horaCierre);
    if (fin.isAfter(cierre)) return EstadoFranja.excedeCierre;
    for (final t in _turnos) {
      if (!t.ocupaHorario || t.id == idTurnoEditado) continue;
      if (!t.seSolapaConRango(inicio, fin)) continue;
      if (t.idEstilista == idEstilista) return EstadoFranja.ocupadaEstilista;
      if (t.idCliente == idCliente) return EstadoFranja.ocupadaCliente;
    }
    return EstadoFranja.libre;
  }

  // Resúmenes:
  ({int programados, int completados, int ingreso}) resumenDelDia(
      DateTime dia) {
    var programados = 0;
    var completados = 0;
    var ingreso = 0;
    for (final t in turnosDelDia(dia)) {
      if (t.estado == EstadoTurno.programado) {
        programados++;
        ingreso += t.precioTotal;
      } else if (t.estado == EstadoTurno.completado) {
        completados++;
        ingreso += t.precioTotal;
      }
    }
    return (
    programados: programados,
    completados: completados,
    ingreso: ingreso
    );
  }

  int turnosProgramadosHoy(int idEstilista) {
    final hoy = DateTime.now();
    return _turnos
        .where((t) =>
    t.idEstilista == idEstilista &&
        t.estado == EstadoTurno.programado &&
        mismoDia(t.inicio, hoy))
        .length;
  }

  // Turnos:
  // Devuelve null si el turno es válido o el mensaje de error
  String? validarTurno({
    required int idCliente,
    required int idEstilista,
    required List<Servicio> servicios,
    required DateTime inicio,
    int? idTurnoEditado,
  }) {
    if (servicios.isEmpty) return 'Elige al menos un servicio.';
    final estilista = estilistaPorId(idEstilista);
    if (estilista == null || !estilista.realizaTodos(servicios)) {
      return 'El estilista no realiza todos los servicios elegidos.';
    }
    if (!esDiaLaborable(inicio)) return 'El salón está cerrado los domingos.';
    if (inicio.hour < horaApertura || inicio.minute % pasoMinutos != 0) {
      return 'La hora debe ser una franja de 30 minutos desde las 9:00.';
    }
    final duracion = servicios.fold(0, (suma, s) => suma + s.duracionMinutos);
    switch (estadoFranja(
      inicio: inicio,
      duracionMinutos: duracion,
      idEstilista: idEstilista,
      idCliente: idCliente,
      idTurnoEditado: idTurnoEditado,
    )) {
      case EstadoFranja.libre:
        return null;
      case EstadoFranja.pasada:
        return 'No se puede elegir una fecha y hora que ya pasaron.';
      case EstadoFranja.excedeCierre:
        return 'El turno debe terminar a las 19:00 como máximo.';
      case EstadoFranja.ocupadaEstilista:
        return 'El estilista ya tiene un turno en ese horario.';
      case EstadoFranja.ocupadaCliente:
        return 'El cliente ya tiene un turno en ese horario.';
    }
  }

  String? _limpiarNotas(String? notas) {
    final limpia = notas?.trim();
    return (limpia == null || limpia.isEmpty) ? null : limpia;
  }

  int _siguienteIdTurno() =>
      _turnos.fold(0, (mayor, t) => t.id > mayor ? t.id : mayor) + 1;

  Turno crearTurno({
    required int idCliente,
    required int idEstilista,
    required List<Servicio> servicios,
    required DateTime inicio,
    String? notas,
  }) {
    final error = validarTurno(
      idCliente: idCliente,
      idEstilista: idEstilista,
      servicios: servicios,
      inicio: inicio,
    );
    if (error != null) throw StateError(error);
    final ahora = DateTime.now();
    final turno = Turno(
      id: _siguienteIdTurno(),
      idCliente: idCliente,
      idEstilista: idEstilista,
      servicios: List.unmodifiable(servicios),
      inicio: inicio,
      notas: _limpiarNotas(notas),
      fechaCreacion: ahora,
      fechaModificacion: ahora,
    );
    _turnos.add(turno);
    notifyListeners();
    return turno;
  }

  Turno actualizarTurno(
      int id, {
        required int idCliente,
        required int idEstilista,
        required List<Servicio> servicios,
        required DateTime inicio,
        String? notas,
      }) {
    final actual = turnoPorId(id);
    if (actual == null || actual.estado != EstadoTurno.programado) {
      throw StateError('Solo se pueden editar turnos programados.');
    }
    final error = validarTurno(
      idCliente: idCliente,
      idEstilista: idEstilista,
      servicios: servicios,
      inicio: inicio,
      idTurnoEditado: id,
    );
    if (error != null) throw StateError(error);
    final nuevo = Turno(
      id: id,
      idCliente: idCliente,
      idEstilista: idEstilista,
      servicios: List.unmodifiable(servicios),
      inicio: inicio,
      notas: _limpiarNotas(notas),
      estado: actual.estado,
      fechaCreacion: actual.fechaCreacion,
      fechaModificacion: DateTime.now(),
    );
    _turnos[_turnos.indexWhere((t) => t.id == id)] = nuevo;
    notifyListeners();
    return nuevo;
  }

  void completarTurno(int id) => _cambiarEstado(id, EstadoTurno.completado);
  void cancelarTurno(int id) => _cambiarEstado(id, EstadoTurno.cancelado);

  void _cambiarEstado(int id, EstadoTurno nuevoEstado) {
    final actual = turnoPorId(id);
    if (actual == null || actual.estado != EstadoTurno.programado) return;
    _turnos[_turnos.indexWhere((t) => t.id == id)] =
        actual.conEstado(nuevoEstado, DateTime.now());
    notifyListeners();
  }

  // Clientes:
  int get totalClientes => _clientes.length;

  int totalPorGenero(GeneroCliente genero) =>
      _clientes.where((c) => c.genero == genero).length;

  List<Cliente> clientesFiltrados({
    String busqueda = '',
    GeneroCliente? genero,
  }) =>
      _clientes
          .where((c) =>
      (genero == null || c.genero == genero) &&
          _coincideBusqueda(c, busqueda))
          .toList();

  // Ignora mayúsculas y acentos
  bool _coincideBusqueda(Cliente cliente, String busqueda) {
    final consulta = normalizarTexto(busqueda);
    if (consulta.isEmpty) return true;
    if (RegExp(r'^[\d\s]+$').hasMatch(consulta)) {
      return cliente.telefono.contains(consulta.replaceAll(RegExp(r'\s'), ''));
    }
    return normalizarTexto(cliente.nombre).contains(consulta);
  }

  bool telefonoRepetido(String telefono, {int? idExcluido}) => _clientes
      .any((c) => c.telefono == telefono && c.id != idExcluido);

  List<Turno> turnosDeCliente(int idCliente) {
    final lista = _turnos.where((t) => t.idCliente == idCliente).toList();
    lista.sort((a, b) => b.inicio.compareTo(a.inicio));
    return lista;
  }

  int cantidadTurnosDeCliente(int idCliente) =>
      _turnos.where((t) => t.idCliente == idCliente).length;

  int turnosProgramadosDeCliente(int idCliente) => _turnos
      .where((t) =>
  t.idCliente == idCliente && t.estado == EstadoTurno.programado)
      .length;

  Cliente crearCliente({
    required String nombre,
    required String telefono,
    required GeneroCliente genero,
    String? correo,
  }) {
    final id = _clientes.fold(0, (mayor, c) => c.id > mayor ? c.id : mayor) + 1;
    final cliente = Cliente(
      id: id,
      nombre: nombre.trim(),
      telefono: telefono,
      genero: genero,
      correo: (correo == null || correo.trim().isEmpty) ? null : correo.trim(),
      fechaRegistro: DateTime.now(),
    );
    _clientes.add(cliente);
    notifyListeners();
    return cliente;
  }

  void actualizarCliente(
      int id, {
        required String nombre,
        required String telefono,
        required GeneroCliente genero,
        String? correo,
      }) {
    final actual = clientePorId(id);
    if (actual == null) return;
    _clientes[_clientes.indexWhere((c) => c.id == id)] = Cliente(
      id: id,
      nombre: nombre.trim(),
      telefono: telefono,
      genero: genero,
      correo: (correo == null || correo.trim().isEmpty) ? null : correo.trim(),
      fechaRegistro: actual.fechaRegistro,
    );
    notifyListeners();
  }

  // Devuelve un mensaje si no se puede eliminar, null si se eliminó
  String? eliminarCliente(int id) {
    final tieneProgramados = _turnos.any(
            (t) => t.idCliente == id && t.estado == EstadoTurno.programado);
    if (tieneProgramados) {
      return 'No se puede eliminar: el cliente tiene turnos programados. '
          'Cancélalos primero.';
    }
    _turnos.removeWhere((t) => t.idCliente == id);
    _clientes.removeWhere((c) => c.id == id);
    notifyListeners();
    return null;
  }
}