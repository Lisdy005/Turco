import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/datos_iniciales_turno.dart';
import '../modelos/enumeraciones.dart';
import '../modelos/servicio.dart';
import '../modelos/turno.dart';
import '../utilidades/formato.dart';
import '../viewmodelos/salon_viewmodelo.dart';
import '../widgets/campo_caja.dart';
import '../widgets/selector_opciones.dart';
import 'hoja_formulario_cliente.dart';

class PantallaFormularioTurno extends StatefulWidget {
  const PantallaFormularioTurno({
    super.key,
    required this.salon,
    this.idTurno,
    this.datosIniciales,
  });

  final SalonViewModelo salon;
  final int? idTurno; // null = crear, con valor = editar
  final DatosInicialesTurno? datosIniciales;

  @override
  State<PantallaFormularioTurno> createState() =>
      _EstadoPantallaFormularioTurno();
}

class _EstadoPantallaFormularioTurno extends State<PantallaFormularioTurno> {
  final GlobalKey<FormState> _clave = GlobalKey<FormState>();
  final TextEditingController _notas = TextEditingController();
  final FocusNode _focoCliente = FocusNode();
  final FocusNode _focoServicios = FocusNode();
  final FocusNode _focoEstilista = FocusNode();
  final FocusNode _focoFecha = FocusNode();
  final FocusNode _focoHora = FocusNode();
  final FocusNode _focoNotas = FocusNode();

  int? _idCliente;
  PublicoServicio? _publico; // null = Todos
  final Set<int> _idsServicios = {};
  int? _idEstilista;
  DateTime? _fecha;
  DateTime? _horaInicio;
  bool _modificado = false;
  Turno? _turnoEditado;

  bool get _esEdicion => widget.idTurno != null;
  bool get _edicionNoDisponible =>
      _esEdicion &&
          (_turnoEditado == null ||
              _turnoEditado!.estado != EstadoTurno.programado);

  //  Inicio
  @override
  void initState() {
    super.initState();
    final salon = widget.salon;
    if (_esEdicion) {
      final turno = salon.turnoPorId(widget.idTurno!);
      _turnoEditado = turno;
      if (turno != null) {
        _idCliente = turno.idCliente;
        _idsServicios.addAll(turno.servicios.map((s) => s.id));
        _idEstilista = turno.idEstilista;
        _fecha = _soloDia(turno.inicio);
        _horaInicio = turno.inicio;
        _notas.text = turno.notas ?? '';
        _publico =
            salon.clientePorId(turno.idCliente)?.genero.publicoPorDefecto;
      }
    } else {
      final datos = widget.datosIniciales;
      final idCliente = datos?.idCliente;
      if (idCliente != null && salon.clientePorId(idCliente) != null) {
        _idCliente = idCliente;
        _publico = salon.clientePorId(idCliente)!.genero.publicoPorDefecto;
      }
      final idServicio = datos?.idServicio;
      if (idServicio != null && salon.servicios.any((s) => s.id == idServicio)) {
        _idsServicios.add(idServicio);
      }
      final fecha = datos?.fecha;
      if (fecha != null && _fechaPermitida(_soloDia(fecha))) {
        _fecha = _soloDia(fecha);
      }
    }
  }

  @override
  void dispose() {
    _notas.dispose();
    _focoCliente.dispose();
    _focoServicios.dispose();
    _focoEstilista.dispose();
    _focoFecha.dispose();
    _focoHora.dispose();
    _focoNotas.dispose();
    super.dispose();
  }

  //  Utilidades de fecha
  static DateTime _soloDia(DateTime f) => DateTime(f.year, f.month, f.day);

  static bool _fechaPermitida(DateTime dia) {
    final hoy = _soloDia(DateTime.now());
    return !dia.isBefore(hoy) && SalonViewModelo.esDiaLaborable(dia);
  }

  static DateTime _primerDiaValido() {
    var dia = _soloDia(DateTime.now());
    while (!SalonViewModelo.esDiaLaborable(dia)) {
      dia = DateTime(dia.year, dia.month, dia.day + 1);
    }
    return dia;
  }

  //  Datos derivados
  List<Servicio> get _serviciosElegidos => widget.salon.servicios
      .where((s) => _idsServicios.contains(s.id))
      .toList();

  int get _duracionMinutos =>
      _serviciosElegidos.fold(0, (suma, s) => suma + s.duracionMinutos);

  int get _precioTotal =>
      _serviciosElegidos.fold(0, (suma, s) => suma + s.precio);

  EstadoFranja _estadoDeFranja(DateTime inicio) => widget.salon.estadoFranja(
    inicio: inicio,
    duracionMinutos: _duracionMinutos == 0
        ? SalonViewModelo.pasoMinutos
        : _duracionMinutos,
    idEstilista: _idEstilista,
    idCliente: _idCliente,
    idTurnoEditado: widget.idTurno,
  );

  List<({DateTime inicio, EstadoFranja estado})> _franjas() {
    final dia = _fecha;
    if (dia == null) return const [];
    return [
      for (final inicio in widget.salon.franjasDelDia(dia))
        (inicio: inicio, estado: _estadoDeFranja(inicio)),
    ];
  }

  // Las franjas se recalculan solas; si la hora elegida ya no es libre se limpia
  void _limpiarHoraSiYaNoEsValida() {
    final hora = _horaInicio;
    if (hora != null && _estadoDeFranja(hora) != EstadoFranja.libre) {
      _horaInicio = null;
    }
  }

  // Muestra los servicios que coinciden con el filtro y los ya elegidos
  Map<CategoriaServicio, List<Servicio>> _serviciosVisibles() {
    final mapa = <CategoriaServicio, List<Servicio>>{};
    for (final servicio in widget.salon.servicios) {
      final coincide = _publico == null ||
          servicio.publico == _publico ||
          servicio.publico == PublicoServicio.unisex;
      if (coincide || _idsServicios.contains(servicio.id)) {
        mapa.putIfAbsent(servicio.categoria, () => []).add(servicio);
      }
    }
    return mapa;
  }

  //  Acciones
  void _elegirCliente(int id) {
    final cliente = widget.salon.clientePorId(id);
    setState(() {
      _idCliente = id;
      if (cliente != null) _publico = cliente.genero.publicoPorDefecto;
      _modificado = true;
      _limpiarHoraSiYaNoEsValida();
    });
  }

  Future<void> _abrirSelectorCliente() async {
    final id = await mostrarSelectorOpciones<int>(
      context,
      titulo: 'Cliente',
      opciones: [
        for (final c in widget.salon.clientes)
          OpcionSelector<int>(valor: c.id, texto: c.nombre),
      ],
      seleccionado: _idCliente,
      mensajeVacio: 'Aún no hay clientes. Crea uno nuevo.',
    );
    if (id == null || !mounted) return;
    _elegirCliente(id);
  }

  // Reutiliza la misma hoja de alta de la pantalla Clientes
  Future<void> _crearClienteNuevo() async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => HojaFormularioCliente(salon: widget.salon),
    );
    if (guardado != true || !mounted) return;
    _elegirCliente(widget.salon.clientes.last.id);
  }

  void _alternarServicio(int id) {
    var estilistaLimpiado = false;
    setState(() {
      if (!_idsServicios.remove(id)) _idsServicios.add(id);
      _modificado = true;
      final idEstilista = _idEstilista;
      if (idEstilista != null) {
        final estilista = widget.salon.estilistaPorId(idEstilista);
        final elegidos = _serviciosElegidos;
        if (estilista == null ||
            elegidos.isEmpty ||
            !estilista.realizaTodos(elegidos)) {
          _idEstilista = null;
          estilistaLimpiado = true;
        }
      }
      _limpiarHoraSiYaNoEsValida();
    });
    if (estilistaLimpiado) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Se quitó el estilista: ya no realiza todos los servicios elegidos.'),
      ));
    }
  }

  Future<void> _abrirSelectorEstilista() async {
    final id = await mostrarSelectorOpciones<int>(
      context,
      titulo: 'Estilista',
      opciones: [
        for (final e in widget.salon.estilistasParaServicios(_serviciosElegidos))
          OpcionSelector<int>(valor: e.id, texto: e.nombre),
      ],
      seleccionado: _idEstilista,
      mensajeVacio:
      'Ningún estilista realiza todos los servicios elegidos. Cambia la selección de servicios.',
    );
    if (id == null || !mounted) return;
    setState(() {
      _idEstilista = id;
      _modificado = true;
      _limpiarHoraSiYaNoEsValida();
    });
  }

  Future<void> _abrirSelectorFecha() async {
    final hoy = _soloDia(DateTime.now());
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha ?? _primerDiaValido(),
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
      selectableDayPredicate: SalonViewModelo.esDiaLaborable,
      helpText: 'Fecha del turno',
    );
    if (elegida == null || !mounted) return;
    setState(() {
      final anterior = _horaInicio;
      _fecha = _soloDia(elegida);
      _horaInicio = anterior == null
          ? null
          : DateTime(elegida.year, elegida.month, elegida.day, anterior.hour,
          anterior.minute);
      _modificado = true;
      _limpiarHoraSiYaNoEsValida();
    });
  }

  // Al fallar la validación el foco va al primer campo con error
  void _enfocarPrimerError() {
    final FocusNode? nodo;
    if (_idCliente == null) {
      nodo = _focoCliente;
    } else if (_idsServicios.isEmpty) {
      nodo = _focoServicios;
    } else if (_idEstilista == null) {
      nodo = _focoEstilista;
    } else if (_fecha == null) {
      nodo = _focoFecha;
    } else if (_horaInicio == null) {
      nodo = _focoHora;
    } else {
      nodo = null;
    }
    if (nodo == null) return;
    nodo.requestFocus();
    final contexto = nodo.context;
    if (contexto != null) {
      Scrollable.ensureVisible(contexto,
          alignment: 0.1, duration: const Duration(milliseconds: 300));
    }
  }

  void _guardar() {
    if (!_clave.currentState!.validate()) {
      _enfocarPrimerError();
      return;
    }
    final servicios = _serviciosElegidos;
    final inicio = _horaInicio!;
    final error = widget.salon.validarTurno(
      idCliente: _idCliente!,
      idEstilista: _idEstilista!,
      servicios: servicios,
      inicio: inicio,
      idTurnoEditado: widget.idTurno,
    );
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final Turno turno = _esEdicion
        ? widget.salon.actualizarTurno(
      widget.idTurno!,
      idCliente: _idCliente!,
      idEstilista: _idEstilista!,
      servicios: servicios,
      inicio: inicio,
      notas: _notas.text,
    )
        : widget.salon.crearTurno(
      idCliente: _idCliente!,
      idEstilista: _idEstilista!,
      servicios: servicios,
      inicio: inicio,
      notas: _notas.text,
    );
    _cerrar(turno);
  }

  // Quita la marca de cambios y cierra en el siguiente frame para que PopScope no bloquee la salida
  void _cerrar([Turno? resultado]) {
    setState(() => _modificado = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop(resultado);
      } else {
        context.go('/agenda');
      }
    });
  }

  void _alPulsarCancelar() {
    if (_modificado) {
      _preguntarYSalir();
    } else {
      _cerrar();
    }
  }

  Future<void> _preguntarYSalir() async {
    final descartar = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) {
        final tema = Theme.of(contextoDialogo);
        final colores = tema.colorScheme;
        return AlertDialog(
          backgroundColor: colores.surfaceContainer,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: colores.error),
              const SizedBox(height: 14),
              Text('¿Descartar los cambios?',
                  style: tema.textTheme.titleLarge!.copyWith(fontSize: 20)),
            ],
          ),
          content: const Text(
              'Tienes cambios sin guardar en este turno. Si sales ahora se perderán.'),
          actions: [
            TextButton(
              onPressed: () => contextoDialogo.pop(false),
              child: const Text('Seguir editando'),
            ),
            TextButton(
              onPressed: () => contextoDialogo.pop(true),
              child: Text('Descartar', style: TextStyle(color: colores.error)),
            ),
          ],
        );
      },
    );
    if (descartar == true && mounted) _cerrar();
  }

  //  Pantalla
  @override
  Widget build(BuildContext context) {
    if (_edicionNoDisponible) return const _SinAcceso();

    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final salon = widget.salon;
    final cliente = _idCliente == null ? null : salon.clientePorId(_idCliente!);
    final estilista =
    _idEstilista == null ? null : salon.estilistaPorId(_idEstilista!);
    final hayServicios = _idsServicios.isNotEmpty;
    final inicio = _horaInicio;
    final fin = inicio?.add(Duration(minutes: _duracionMinutos));
    final visibles = _serviciosVisibles();
    final etiquetaPequena =
    tema.textTheme.bodyMedium!.copyWith(fontSize: 12, fontWeight: FontWeight.w500);
    final tituloSeccion = tema.textTheme.titleMedium!
        .copyWith(fontSize: 14, fontWeight: FontWeight.w600);

    return PopScope(
      canPop: !_modificado,
      onPopInvokedWithResult: (seHizoPop, resultado) {
        if (!seHizoPop) _preguntarYSalir();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 56,
          leading: IconButton(
            tooltip: 'Volver',
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: _alPulsarCancelar,
          ),
          title: Text(_esEdicion ? 'Editar turno' : 'Nuevo turno',
              style: tema.textTheme.titleLarge!.copyWith(fontSize: 20)),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Form(
            key: _clave,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  Cliente
                CampoCaja<int>(
                  key: ValueKey('cliente_$_idCliente'),
                  initialValue: _idCliente,
                  etiqueta: 'Cliente',
                  icono: Icons.person_outline,
                  textoVacio: 'Selecciona un cliente',
                  textoValor: cliente?.nombre,
                  nodoFoco: _focoCliente,
                  validator: (valor) =>
                  valor == null ? 'Selecciona un cliente' : null,
                  alTocar: _abrirSelectorCliente,
                ),
                TextButton.icon(
                  onPressed: _crearClienteNuevo,
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                  label: const Text('Crear cliente nuevo',
                      style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  style:
                  TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                const SizedBox(height: 8),

                //  Filtro de público
                Text('Servicios para', style: etiquetaPequena),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<PublicoServicio?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('Todos')),
                      ButtonSegment(
                          value: PublicoServicio.mujeres, label: Text('Mujeres')),
                      ButtonSegment(
                          value: PublicoServicio.hombres, label: Text('Hombres')),
                    ],
                    selected: {_publico},
                    onSelectionChanged: (seleccion) => setState(() {
                      _publico = seleccion.first;
                      _modificado = true;
                    }),
                  ),
                ),
                const SizedBox(height: 14),

                //  Servicios agrupados por categoría
                FormField<Set<int>>(
                  key: ValueKey('servicios_${_idsServicios.join('_')}'),
                  initialValue: _idsServicios,
                  validator: (valor) => (valor == null || valor.isEmpty)
                      ? 'Elige al menos un servicio'
                      : null,
                  builder: (estado) => Focus(
                    focusNode: _focoServicios,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Servicios', style: tituloSeccion),
                        const SizedBox(height: 8),
                        for (final categoria in CategoriaServicio.values)
                          if (visibles.containsKey(categoria)) ...[
                            Text(categoria.etiqueta.toUpperCase(),
                                style: tema.textTheme.bodyMedium!.copyWith(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final servicio in visibles[categoria]!)
                                  FilterChip(
                                    label: Text(servicio.nombre),
                                    labelStyle: tema.textTheme.bodyMedium!
                                        .copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                    selected:
                                    _idsServicios.contains(servicio.id),
                                    onSelected: (_) =>
                                        _alternarServicio(servicio.id),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        if (estado.hasError) _MensajeError(estado.errorText!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                //  Estilista
                CampoCaja<int>(
                  key: ValueKey('estilista_$_idEstilista'),
                  initialValue: _idEstilista,
                  etiqueta: 'Estilista',
                  icono: Icons.content_cut,
                  textoVacio: hayServicios
                      ? 'Selecciona un estilista'
                      : 'Primero elige los servicios',
                  textoValor: estilista?.nombre,
                  nodoFoco: _focoEstilista,
                  validator: (valor) =>
                  valor == null ? 'Selecciona un estilista' : null,
                  alTocar: hayServicios ? _abrirSelectorEstilista : null,
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: colores.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Solo se muestran estilistas que realizan todos los servicios elegidos.',
                        style: tema.textTheme.bodyMedium!.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                //  Fecha
                CampoCaja<DateTime>(
                  key: ValueKey('fecha_${_fecha?.millisecondsSinceEpoch}'),
                  initialValue: _fecha,
                  etiqueta: 'Fecha',
                  icono: Icons.calendar_today_outlined,
                  textoVacio: 'Selecciona una fecha',
                  textoValor: _fecha == null ? null : formatearFechaLarga(_fecha!),
                  nodoFoco: _focoFecha,
                  validator: (valor) =>
                  valor == null ? 'Elige una fecha válida (no domingos)' : null,
                  alTocar: _abrirSelectorFecha,
                ),
                const SizedBox(height: 16),

                //  Cuadrícula de franjas
                FormField<DateTime>(
                  key: ValueKey('hora_${_horaInicio?.millisecondsSinceEpoch}'),
                  initialValue: _horaInicio,
                  validator: (valor) =>
                  valor == null ? 'Elige una hora para el turno' : null,
                  builder: (estado) {
                    final franjas = _franjas();
                    final hayLibres =
                    franjas.any((f) => f.estado == EstadoFranja.libre);
                    return Focus(
                      focusNode: _focoHora,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hora de inicio', style: tituloSeccion),
                          const SizedBox(height: 8),
                          const _Leyenda(),
                          const SizedBox(height: 8),
                          if (_fecha == null)
                            Text('Elige primero una fecha para ver las franjas.',
                                style: tema.textTheme.bodyMedium)
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                mainAxisExtent: 40,
                              ),
                              itemCount: franjas.length,
                              itemBuilder: (context, indice) {
                                final franja = franjas[indice];
                                return _CeldaFranja(
                                  texto: formatearHora(franja.inicio),
                                  disponible: franja.estado == EstadoFranja.libre,
                                  elegida: _horaInicio == franja.inicio,
                                  conError: estado.hasError,
                                  alTocar: () => setState(() {
                                    _horaInicio = franja.inicio;
                                    _modificado = true;
                                  }),
                                );
                              },
                            ),
                          if (_fecha != null && !hayLibres)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'No quedan franjas libres para este día con la selección actual.',
                                style: tema.textTheme.bodyMedium!
                                    .copyWith(fontSize: 12, color: colores.error),
                              ),
                            ),
                          if (estado.hasError) _MensajeError(estado.errorText!),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ----- Notas -----
                TextFormField(
                  controller: _notas,
                  focusNode: _focoNotas,
                  maxLength: 500,
                  minLines: 3,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    alignLabelWithHint: true,
                  ),
                  onChanged: (_) {
                    if (!_modificado) setState(() => _modificado = true);
                  },
                ),
              ],
            ),
          ),
        ),

        // Resumen siempre visible y botones
        bottomNavigationBar: Container(
          color: colores.surfaceContainer,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colores.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DatoResumen(
                          icono: Icons.schedule,
                          texto: formatearDuracion(_duracionMinutos)),
                      _DatoResumen(
                          icono: Icons.flag_outlined,
                          texto: fin == null
                              ? 'Fin --:--'
                              : 'Fin ${formatearHora(fin)}'),
                      _DatoResumen(
                          icono: Icons.payments_outlined,
                          texto: '\$ $_precioTotal',
                          negrita: true),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _alPulsarCancelar,
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 46),
                            shape: const StadiumBorder()),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _guardar,
                        icon: const Icon(Icons.check, size: 18),
                        label: const FittedBox(
                            fit: BoxFit.scaleDown, child: Text('Guardar turno')),
                        style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 46),
                            shape: const StadiumBorder()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MensajeError extends StatelessWidget {
  const _MensajeError(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final error = tema.colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 14, color: error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(texto,
                style: tema.textTheme.bodyMedium!
                    .copyWith(fontSize: 12, color: error)),
          ),
        ],
      ),
    );
  }
}

class _DatoResumen extends StatelessWidget {
  const _DatoResumen({
    required this.icono,
    required this.texto,
    this.negrita = false,
  });

  final IconData icono;
  final String texto;
  final bool negrita;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 14, color: colores.primary),
        const SizedBox(width: 4),
        Text(
          texto,
          style: tema.textTheme.bodyMedium!.copyWith(
            fontSize: 13,
            fontWeight: negrita ? FontWeight.w700 : FontWeight.w600,
            color: colores.onSurface,
          ),
        ),
      ],
    );
  }
}

class _Leyenda extends StatelessWidget {
  const _Leyenda();

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    Widget elemento(String texto, Color? relleno, Color? borde) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: relleno,
            borderRadius: BorderRadius.circular(3),
            border: borde == null ? null : Border.all(color: borde),
          ),
        ),
        const SizedBox(width: 4),
        Text(texto,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: 11)),
      ],
    );
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        elemento('Libre', null, colores.outline),
        elemento('No disponible', colores.surfaceContainerHigh, null),
        elemento('Elegida', colores.primary, null),
      ],
    );
  }
}

class _CeldaFranja extends StatelessWidget {
  const _CeldaFranja({
    required this.texto,
    required this.disponible,
    required this.elegida,
    required this.conError,
    required this.alTocar,
  });

  final String texto;
  final bool disponible;
  final bool elegida;
  final bool conError;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final Color fondo;
    final Color colorTexto;
    Color? borde;
    var peso = FontWeight.w500;

    if (elegida) {
      fondo = colores.primary;
      colorTexto = colores.onPrimary;
      peso = FontWeight.w600;
    } else if (!disponible) {
      fondo = colores.surfaceContainerHigh;
      colorTexto = colores.outline;
    } else {
      fondo = colores.surface;
      colorTexto = colores.onSurface;
      borde = conError ? colores.error : colores.outline;
    }

    return Material(
      color: fondo,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: borde == null ? BorderSide.none : BorderSide(color: borde),
      ),
      child: InkWell(
        onTap: disponible ? alTocar : null,
        child: Center(
          child: Text(
            texto,
            style: tema.textTheme.bodyMedium!
                .copyWith(fontSize: 13, fontWeight: peso, color: colorTexto),
          ),
        ),
      ),
    );
  }
}

class _SinAcceso extends StatelessWidget {
  const _SinAcceso();

  void _volver(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/agenda');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => _volver(context),
        ),
        title: Text('Editar turno',
            style: tema.textTheme.titleLarge!.copyWith(fontSize: 20)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Este turno no se puede editar',
                  style: tema.textTheme.titleLarge!.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              Text('No existe o ya no está programado.',
                  style: tema.textTheme.bodyMedium),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _volver(context),
                style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    shape: const StadiumBorder()),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}