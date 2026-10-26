import '../modelos/cliente.dart';
import '../modelos/enumeraciones.dart';
import '../modelos/estilista.dart';
import '../modelos/servicio.dart';
import '../modelos/turno.dart';

class DatosPrueba {
  static const List<Servicio> servicios = [
    Servicio(id: 1, nombre: 'Corte de dama', categoria: CategoriaServicio.corte,
        duracionMinutos: 60, precio: 25, publico: PublicoServicio.mujeres),
    Servicio(id: 2, nombre: 'Corte de caballero', categoria: CategoriaServicio.corte,
        duracionMinutos: 30, precio: 12, publico: PublicoServicio.hombres),
    Servicio(id: 3, nombre: 'Corte infantil', categoria: CategoriaServicio.corte,
        duracionMinutos: 30, precio: 10, publico: PublicoServicio.unisex),
    Servicio(id: 4, nombre: 'Tinte completo', categoria: CategoriaServicio.color,
        duracionMinutos: 120, precio: 60, publico: PublicoServicio.mujeres),
    Servicio(id: 5, nombre: 'Matiz de canas', categoria: CategoriaServicio.color,
        duracionMinutos: 60, precio: 30, publico: PublicoServicio.hombres),
    Servicio(id: 6, nombre: 'Reflejos', categoria: CategoriaServicio.color,
        duracionMinutos: 90, precio: 50, publico: PublicoServicio.unisex),
    Servicio(id: 7, nombre: 'Arreglo de barba', categoria: CategoriaServicio.barba,
        duracionMinutos: 30, precio: 10, publico: PublicoServicio.hombres),
    Servicio(id: 8, nombre: 'Afeitado clásico', categoria: CategoriaServicio.barba,
        duracionMinutos: 30, precio: 15, publico: PublicoServicio.hombres),
    Servicio(id: 9, nombre: 'Peinado de fiesta', categoria: CategoriaServicio.peinado,
        duracionMinutos: 60, precio: 35, publico: PublicoServicio.mujeres),
    Servicio(id: 10, nombre: 'Lavado y secado', categoria: CategoriaServicio.peinado,
        duracionMinutos: 30, precio: 15, publico: PublicoServicio.unisex),
    Servicio(id: 11, nombre: 'Tratamiento capilar', categoria: CategoriaServicio.tratamiento,
        duracionMinutos: 60, precio: 40, publico: PublicoServicio.unisex),
    Servicio(id: 12, nombre: 'Hidratación profunda', categoria: CategoriaServicio.tratamiento,
        duracionMinutos: 60, precio: 30, publico: PublicoServicio.mujeres),
  ];

  static const List<Estilista> estilistas = [
    // Solo servicios de mujeres
    Estilista(id: 1, nombre: 'Camila Reyes',
        rutaAvatar: 'assets/imagenes/avatares/estilista_1.png',
        idsServicios: [1, 4, 9, 12]),
    // Solo servicios de hombres
    Estilista(id: 2, nombre: 'Daniel Ortega',
        rutaAvatar: 'assets/imagenes/avatares/estilista_2.png',
        idsServicios: [2, 5, 7, 8]),
    // Ambos públicos
    Estilista(id: 3, nombre: 'Sofía Mendoza',
        rutaAvatar: 'assets/imagenes/avatares/estilista_3.png',
        idsServicios: [1, 2, 3, 6, 10, 11]),
    Estilista(id: 4, nombre: 'Lucía Fernández',
        rutaAvatar: 'assets/imagenes/avatares/estilista_4.png',
        idsServicios: [4, 6, 10, 11, 12]),
    Estilista(id: 5, nombre: 'Mateo Salazar',
        rutaAvatar: 'assets/imagenes/avatares/estilista_5.png',
        idsServicios: [2, 3, 7, 8, 10]),
  ];

  static List<Cliente> clientes() {
    final ahora = DateTime.now();
    Cliente crear(int id, String nombre, String telefono, GeneroCliente genero,
        int diasAtras, {String? correo}) =>
        Cliente(
          id: id,
          nombre: nombre,
          telefono: telefono,
          genero: genero,
          correo: correo,
          fechaRegistro: ahora.subtract(Duration(days: diasAtras)),
        );

    return [
      crear(1, 'Laura Gómez', '51234567', GeneroCliente.mujer, 120,
          correo: 'laura.gomez@ejemplo.com'),
      crear(2, 'Carlos Díaz', '52345678', GeneroCliente.hombre, 110),
      crear(3, 'María Torres', '53456789', GeneroCliente.mujer, 100,
          correo: 'maria.torres@ejemplo.com'),
      crear(4, 'Jorge Ramírez', '54567890', GeneroCliente.hombre, 90),
      crear(5, 'Elena Castro', '55678901', GeneroCliente.mujer, 80),
      crear(6, 'Pedro Núñez', '56789012', GeneroCliente.hombre, 70,
          correo: 'pedro.nunez@ejemplo.com'),
      crear(7, 'Rosa Herrera', '57890123', GeneroCliente.mujer, 60),
      crear(8, 'Luis Vega', '58901234', GeneroCliente.hombre, 50),
      crear(9, 'Sara Molina', '59012345', GeneroCliente.mujer, 40),
      // Sin turnos
      crear(10, 'Andrés Silva', '50123456', GeneroCliente.hombre, 30),
    ];
  }

  // Avanza o retrocede N días laborables
  static DateTime _diaLaborable(DateTime desde, int pasos) {
    var dia = desde;
    final sentido = pasos < 0 ? -1 : 1;
    var restantes = pasos.abs();
    while (restantes > 0) {
      dia = DateTime(dia.year, dia.month, dia.day + sentido);
      if (dia.weekday != DateTime.sunday) restantes--;
    }
    return dia;
  }

  static List<Turno> turnos() {
    final ahora = DateTime.now();
    var base = DateTime(ahora.year, ahora.month, ahora.day);
    if (base.weekday == DateTime.sunday) {
      base = DateTime(base.year, base.month, base.day + 1);
    }
    // Siete días laborables: 3 antes, hoy y 3 después
    final d = [for (var i = -3; i <= 3; i++) _diaLaborable(base, i)];

    Turno crear(int id, int idCliente, int idEstilista, List<int> idsServicios,
        DateTime dia, int hora, int minuto,
        {String? notas, EstadoTurno? estado}) {
      final inicio = DateTime(dia.year, dia.month, dia.day, hora, minuto);
      final estadoFinal = estado ??
          (inicio.isBefore(ahora)
              ? EstadoTurno.completado
              : EstadoTurno.programado);
      final creacion = ahora.subtract(const Duration(days: 7));
      return Turno(
        id: id,
        idCliente: idCliente,
        idEstilista: idEstilista,
        servicios: [
          for (final i in idsServicios) servicios.firstWhere((s) => s.id == i),
        ],
        inicio: inicio,
        notas: notas,
        estado: estadoFinal,
        fechaCreacion: creacion,
        fechaModificacion:
        estadoFinal == EstadoTurno.programado ? creacion : inicio,
      );
    }

    return [
      // Días pasados: completados o cancelados
      crear(1, 2, 2, [2], d[0], 9, 0,
          notas: 'Corte clásico, pide degradado bajo.',
          estado: EstadoTurno.completado),
      crear(2, 1, 1, [1], d[0], 10, 0, estado: EstadoTurno.cancelado),
      crear(3, 3, 4, [4], d[1], 11, 0,
          notas: 'Tono castaño claro.', estado: EstadoTurno.completado),
      crear(4, 4, 5, [2, 7], d[1], 15, 0, estado: EstadoTurno.completado),
      crear(5, 5, 3, [1, 10], d[2], 9, 30,
          notas: 'Prefiere puntas limpias, sin mucho largo.',
          estado: EstadoTurno.completado),
      crear(6, 6, 2, [2, 8], d[2], 16, 0,
          notas: 'El cliente avisó que no podía asistir.',
          estado: EstadoTurno.cancelado),
      // Hoy (el estado depende de la hora actual)
      crear(7, 7, 1, [9], d[3], 9, 0, notas: 'Peinado para una boda.'),
      crear(8, 8, 2, [5, 7], d[3], 11, 0),
      crear(9, 9, 4, [6, 12], d[3], 14, 0, notas: 'Quiere reflejos suaves.'),
      crear(10, 3, 3, [10, 11], d[3], 16, 30),
      // Días futuros: programados
      crear(11, 1, 1, [1, 12], d[4], 10, 0),
      crear(12, 2, 5, [2, 7, 8], d[4], 12, 0, notas: 'Servicio completo.'),
      crear(13, 4, 2, [5], d[5], 9, 30),
      crear(14, 5, 4, [4], d[5], 14, 0,
          notas: 'La clienta quiere pasar de castaño oscuro a un castaño '
              'claro con reflejos dorados, sin dañar el cabello. Trae fotos '
              'de referencia en el teléfono y pidió revisar primero el estado '
              'de las puntas. Prefiere probar el producto en una zona pequeña '
              'antes de aplicarlo en todo el cabello. Quiere que el proceso '
              'no pase de dos horas y que al final le expliquen cómo cuidar '
              'el color en casa.'),
      // Termina exactamente a las 19:00
      crear(15, 6, 5, [2, 7, 8], d[6], 17, 30),
      crear(16, 7, 3, [1, 11], d[6], 10, 0, notas: 'Primera visita al salón.'),
    ];
  }
}