import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/datos_iniciales_turno.dart';
import '../modelos/enumeraciones.dart';
import '../modelos/turno.dart';
import '../tema/rutas_assets.dart';
import '../utilidades/formato.dart';
import '../viewmodelos/salon_viewmodelo.dart';
import '../viewmodelos/tema_viewmodelo.dart';
import '../widgets/dialogo_estado_turno.dart';
import '../widgets/ilustracion_circular.dart';
import '../widgets/logo_turco.dart';
import '../widgets/tarjeta_turno.dart';

class PantallaAgenda extends StatefulWidget {
  const PantallaAgenda({
    super.key,
    required this.salon,
    required this.tema,
    this.idEstilistaFiltro,
  });

  final SalonViewModelo salon;
  final TemaViewModelo tema;
  final int? idEstilistaFiltro;

  @override
  State<PantallaAgenda> createState() => _EstadoPantallaAgenda();
}

class _EstadoPantallaAgenda extends State<PantallaAgenda> {
  static const _opcionesTema = <({ThemeMode modo, String etiqueta, IconData icono})>[
    (modo: ThemeMode.system, etiqueta: 'Sistema', icono: Icons.smartphone),
    (modo: ThemeMode.light, etiqueta: 'Claro', icono: Icons.light_mode_outlined),
    (modo: ThemeMode.dark, etiqueta: 'Oscuro', icono: Icons.dark_mode_outlined),
  ];

  late DateTime _fecha;
  int? _idEstilista;
  EstadoTurno? _estado;

  static DateTime _soloDia(DateTime f) => DateTime(f.year, f.month, f.day);

  @override
  void initState() {
    super.initState();
    var hoy = _soloDia(DateTime.now());
    if (!SalonViewModelo.esDiaLaborable(hoy)) {
      hoy = DateTime(hoy.year, hoy.month, hoy.day + 1);
    }
    _fecha = hoy;
    _idEstilista = widget.idEstilistaFiltro;
  }

  // Si llegamos desde Estilistas con otro estilista se actualiza el filtro
  @override
  void didUpdateWidget(covariant PantallaAgenda anterior) {
    super.didUpdateWidget(anterior);
    if (widget.idEstilistaFiltro != anterior.idEstilistaFiltro) {
      _idEstilista = widget.idEstilistaFiltro;
    }
  }

  DateTime get _inicioSemana => DateTime(
      _fecha.year, _fecha.month, _fecha.day - (_fecha.weekday - 1));

  void _cambiarSemana(int pasos) => setState(() {
    _fecha = DateTime(_fecha.year, _fecha.month, _fecha.day + 7 * pasos);
  });

  Future<void> _elegirFecha() async {
    final hoy = _soloDia(DateTime.now());
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(hoy.year - 1, hoy.month, hoy.day),
      lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
      selectableDayPredicate: SalonViewModelo.esDiaLaborable,
      helpText: 'Elegir fecha',
    );
    if (elegida == null || !mounted) return;
    setState(() => _fecha = _soloDia(elegida));
  }

  // El turno guardado vuelve con context.pop(valor)
  Future<void> _nuevoTurno() async {
    final turno = await context.push<Turno>(
      '/turno/nuevo',
      extra: DatosInicialesTurno(fecha: _fecha),
    );
    if (turno == null || !mounted) return;
    setState(() => _fecha = _soloDia(turno.inicio));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Turno guardado para el ${formatearFechaCorta(turno.inicio)}'),
      action: SnackBarAction(
        label: 'Ver',
        onPressed: () => context.push('/turno/${turno.id}'),
      ),
    ));
  }

  // Pulsación larga: acciones rápidas (cada una pide confirmación)
  Future<void> _mostrarAcciones(Turno turno) async {
    final cliente = widget.salon.clientePorId(turno.idCliente);
    final estilista = widget.salon.estilistaPorId(turno.idEstilista);
    final servicios = turno.servicios.map((s) => s.nombre).join(' + ');

    final accion = await showModalBottomSheet<EstadoTurno>(
      context: context,
      showDragHandle: true,
      builder: (contextoHoja) {
        final tema = Theme.of(contextoHoja);
        final colores = tema.colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cliente?.nombre ?? 'Cliente'} · ${formatearHora(turno.inicio)}',
                  style: tema.textTheme.titleLarge!.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  '$servicios · ${estilista?.nombre.split(' ').first ?? ''}',
                  style: tema.textTheme.bodyMedium!.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.check_circle_outline,
                      color: colores.tertiary),
                  title: const Text('Marcar como completado'),
                  onTap: () => contextoHoja.pop(EstadoTurno.completado),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.block, color: colores.error),
                  title: Text('Cancelar turno',
                      style: TextStyle(color: colores.error)),
                  onTap: () => contextoHoja.pop(EstadoTurno.cancelado),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (accion == null || !mounted) return;
    await confirmarCambioEstado(context, widget.salon, turno, accion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoTurno,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo turno'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: Listenable.merge([widget.salon, widget.tema]),
          builder: (context, _) {
            final turnos = widget.salon.turnosFiltrados(
              _fecha,
              idEstilista: _idEstilista,
              estado: _estado,
            );
            final vacia = turnos.isEmpty;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: 1 + (vacia ? 1 : turnos.length),
              itemBuilder: (context, indice) {
                if (indice == 0) return _encabezado(context);
                if (vacia) return _mensajeVacio(context);
                final turno = turnos[indice - 1];
                final estilista = widget.salon.estilistaPorId(turno.idEstilista);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TarjetaTurno(
                    turno: turno,
                    nombreCliente:
                    widget.salon.clientePorId(turno.idCliente)?.nombre ?? '',
                    nombreEstilista: estilista?.nombre.split(' ').first ?? '',
                    alTocar: () => context.push('/turno/${turno.id}'),
                    alPulsacionLarga: turno.estado == EstadoTurno.programado
                        ? () => _mostrarAcciones(turno)
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final resumen = widget.salon.resumenDelDia(_fecha);
    final inicioSemana = _inicioSemana;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra superior: logo, título y botón de tema
        Row(
          children: [
            const LogoTurco(),
            const SizedBox(width: 12),
            Text('Turco', style: tema.textTheme.headlineSmall),
            const Spacer(),
            PopupMenuButton<ThemeMode>(
              tooltip: 'Cambiar tema',
              icon: const Icon(Icons.brightness_6_outlined),
              onSelected: widget.tema.elegir,
              itemBuilder: (context) => [
                for (final opcion in _opcionesTema)
                  PopupMenuItem<ThemeMode>(
                    value: opcion.modo,
                    child: Row(
                      children: [
                        Icon(opcion.icono, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(opcion.etiqueta)),
                        if (widget.tema.modo == opcion.modo)
                          Icon(Icons.check, size: 20, color: colores.primary),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Mes, semana anterior/siguiente y elegir fecha
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Semana anterior',
                    onPressed: () => _cambiarSemana(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Flexible(
                    child: Text(
                      formatearMesAnio(_fecha),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.titleMedium!
                          .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Semana siguiente',
                    onPressed: () => _cambiarSemana(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: _elegirFecha,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: const Text('Elegir fecha'),
            ),
          ],
        ),

        // Tira de los siete días
        SizedBox(
          height: 76,
          child: LayoutBuilder(
            builder: (context, restricciones) => ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemExtent: restricciones.maxWidth / 7,
              itemCount: 7,
              itemBuilder: (context, i) {
                final dia = DateTime(inicioSemana.year, inicioSemana.month,
                    inicioSemana.day + i);
                return _CeldaDia(
                  dia: dia,
                  seleccionado: _soloDia(dia) == _fecha,
                  cerrado: !SalonViewModelo.esDiaLaborable(dia),
                  alTocar: () => setState(() => _fecha = _soloDia(dia)),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('Domingo: salón cerrado',
            style: tema.textTheme.bodyMedium!.copyWith(fontSize: 13)),
        const SizedBox(height: 12),

        // Resumen del día
        Row(
          children: [
            Expanded(
              child: _TarjetaResumen(
                valor: '${resumen.programados}',
                etiqueta: 'Programados',
                colorValor: colores.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TarjetaResumen(
                valor: '${resumen.completados}',
                etiqueta: 'Completados',
                colorValor: colores.tertiary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TarjetaResumen(
                valor: '\$ ${resumen.ingreso}',
                etiqueta: 'Ingreso est.',
                colorValor: colores.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Filtro por estilista
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Todos'),
                selected: _idEstilista == null,
                onSelected: (_) => setState(() => _idEstilista = null),
              ),
              for (final estilista in widget.salon.estilistas) ...[
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(estilista.nombre.split(' ').first),
                  selected: _idEstilista == estilista.id,
                  onSelected: (_) =>
                      setState(() => _idEstilista = estilista.id),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Filtro por estado
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<EstadoTurno?>(
            segments: const [
              ButtonSegment(value: null, label: Text('Todos')),
              ButtonSegment(
                  value: EstadoTurno.programado, label: Text('Program.')),
              ButtonSegment(
                  value: EstadoTurno.completado, label: Text('Complet.')),
              ButtonSegment(
                  value: EstadoTurno.cancelado, label: Text('Cancel.')),
            ],
            selected: {_estado},
            onSelectionChanged: (seleccion) =>
                setState(() => _estado = seleccion.first),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _mensajeVacio(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          IlustracionCircular(
            rutaImagen: RutasAssets.ilustracionVacia(tema.brightness),
            icono: Icons.event_busy,
            colorFondo: colores.primaryContainer,
            colorIcono: colores.primary,
          ),
          const SizedBox(height: 16),
          Text('No hay turnos para este día',
              textAlign: TextAlign.center,
              style: tema.textTheme.titleLarge!.copyWith(fontSize: 20)),
          const SizedBox(height: 8),
          Text('Crea el primer turno con el botón de abajo o cambia los filtros.',
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium!.copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}

class _CeldaDia extends StatelessWidget {
  const _CeldaDia({
    required this.dia,
    required this.seleccionado,
    required this.cerrado,
    required this.alTocar,
  });

  final DateTime dia;
  final bool seleccionado;
  final bool cerrado;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final colorEtiqueta = seleccionado
        ? colores.onPrimary
        : cerrado
        ? colores.outline
        : colores.onSurfaceVariant;
    final colorNumero = seleccionado
        ? colores.onPrimary
        : cerrado
        ? colores.outline
        : colores.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Material(
        color: seleccionado ? colores.primary : colores.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: cerrado ? null : alTocar,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(abreviaturaDia(dia),
                  style: tema.textTheme.bodyMedium!.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorEtiqueta)),
              const SizedBox(height: 2),
              Text('${dia.day}',
                  style: tema.textTheme.titleMedium!.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorNumero)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen({
    required this.valor,
    required this.etiqueta,
    required this.colorValor,
  });

  final String valor;
  final String etiqueta;
  final Color colorValor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.headlineSmall!.copyWith(color: colorValor)),
          Text(etiqueta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.bodyMedium!.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}