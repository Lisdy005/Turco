import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/enumeraciones.dart';
import '../modelos/turno.dart';
import '../tema/rutas_assets.dart';
import '../utilidades/formato.dart';
import '../viewmodelos/salon_viewmodelo.dart';
import '../widgets/avatar_cliente.dart';
import '../widgets/dialogo_estado_turno.dart';
import '../widgets/etiqueta_estado.dart';
import '../widgets/ilustracion_circular.dart';

class PantallaDetalleTurno extends StatelessWidget {
  const PantallaDetalleTurno({
    super.key,
    required this.salon,
    required this.idTurno,
  });

  final SalonViewModelo salon;
  final int idTurno;

  void _volver(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/agenda');
    }
  }

  PreferredSizeWidget _barra(BuildContext context) {
    return AppBar(
      toolbarHeight: 56,
      leading: IconButton(
        tooltip: 'Volver',
        icon: const Icon(Icons.chevron_left, size: 28),
        onPressed: () => _volver(context),
      ),
      title: Text(
        'Detalle del turno',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
      ),
    );
  }

  Future<void> _editar(BuildContext context, Turno turno) async {
    final guardado = await context.push<Turno>('/turno/${turno.id}/editar');
    if (guardado != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Turno actualizado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: salon,
      builder: (context, _) {
        final turno = salon.turnoPorId(idTurno);
        final cliente =
        turno == null ? null : salon.clientePorId(turno.idCliente);
        if (turno == null || cliente == null) {
          return _NoEncontrado(barra: _barra(context));
        }

        final tema = Theme.of(context);
        final colores = tema.colorScheme;
        final estilista = salon.estilistaPorId(turno.idEstilista);
        final notas = turno.notas;

        return Scaffold(
          appBar: _barra(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Tarjeta(
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AvatarCliente(cliente: cliente, tamano: 48),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cliente.nombre,
                                  style: tema.textTheme.titleMedium!.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.phone_outlined,
                                        size: 13,
                                        color: colores.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(formatearTelefono(cliente.telefono),
                                        style: tema.textTheme.bodyMedium!
                                            .copyWith(fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          EtiquetaEstado(estado: turno.estado),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _DatoConIcono(
                        icono: Icons.calendar_today_outlined,
                        titulo: 'Fecha',
                        valor: formatearFechaLarga(turno.inicio),
                      ),
                      const SizedBox(height: 10),
                      _DatoConIcono(
                        icono: Icons.schedule,
                        titulo: 'Hora',
                        valor: '${formatearHora(turno.inicio)} a '
                            '${formatearHora(turno.fin)} '
                            '(${formatearDuracion(turno.duracionMinutos)})',
                      ),
                      const SizedBox(height: 10),
                      _DatoConIcono(
                        icono: Icons.person_outline,
                        titulo: 'Estilista',
                        valor: estilista?.nombre ?? 'Sin asignar',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _Tarjeta(
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Servicios',
                          style: tema.textTheme.titleMedium!.copyWith(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      for (final servicio in turno.servicios) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(servicio.nombre,
                                      style: tema.textTheme.titleMedium!
                                          .copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                  Text('${servicio.duracionMinutos} min',
                                      style: tema.textTheme.bodyMedium!
                                          .copyWith(fontSize: 12)),
                                ],
                              ),
                            ),
                            Text('\$ ${servicio.precio}',
                                style: tema.textTheme.titleMedium!.copyWith(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Divider(height: 21),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total',
                              style: tema.textTheme.titleMedium!.copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('\$ ${turno.precioTotal}',
                              style: tema.textTheme.titleMedium!.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colores.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (notas != null) ...[
                  const SizedBox(height: 12),
                  _Tarjeta(
                    hijo: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notas',
                            style: tema.textTheme.titleMedium!.copyWith(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        // Área con scroll propio, no desborda con textos largos
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 120),
                          child: SingleChildScrollView(
                            child: Text(notas,
                                style: tema.textTheme.bodyMedium!
                                    .copyWith(fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Creado el ${formatearFechaCompleta(turno.fechaCreacion)} · '
                      'Modificado el ${formatearFechaCompleta(turno.fechaModificacion)}',
                  style: tema.textTheme.bodyMedium!.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _BarraAcciones(
            turno: turno,
            alEditar: () => _editar(context, turno),
            alCompletar: () => confirmarCambioEstado(
                context, salon, turno, EstadoTurno.completado),
            alCancelar: () => confirmarCambioEstado(
                context, salon, turno, EstadoTurno.cancelado),
          ),
        );
      },
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.hijo});

  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(padding: const EdgeInsets.all(16), child: hijo),
    );
  }
}

class _DatoConIcono extends StatelessWidget {
  const _DatoConIcono({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  final IconData icono;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      children: [
        Icon(icono, size: 18, color: tema.colorScheme.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: tema.textTheme.bodyMedium!.copyWith(fontSize: 11)),
              Text(valor,
                  style: tema.textTheme.titleMedium!.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: tema.colorScheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BarraAcciones extends StatelessWidget {
  const _BarraAcciones({
    required this.turno,
    required this.alEditar,
    required this.alCompletar,
    required this.alCancelar,
  });

  final Turno turno;
  final VoidCallback alEditar;
  final VoidCallback alCompletar;
  final VoidCallback alCancelar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    const forma = StadiumBorder();
    const tamanoMinimo = Size(0, 44);
    const relleno = EdgeInsets.symmetric(horizontal: 4);

    Widget etiqueta(String texto) =>
        FittedBox(fit: BoxFit.scaleDown, child: Text(texto));

    return Container(
      width: double.infinity,
      color: colores.surfaceContainer,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: turno.estado == EstadoTurno.programado
            ? Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: alEditar,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: etiqueta('Editar'),
                style: OutlinedButton.styleFrom(
                    minimumSize: tamanoMinimo,
                    padding: relleno,
                    shape: forma),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: alCompletar,
                icon: const Icon(Icons.check, size: 18),
                label: etiqueta('Completar'),
                style: FilledButton.styleFrom(
                    minimumSize: tamanoMinimo,
                    padding: relleno,
                    shape: forma),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextButton.icon(
                onPressed: alCancelar,
                icon: const Icon(Icons.block, size: 18),
                label: etiqueta('Cancelar'),
                style: TextButton.styleFrom(
                    foregroundColor: colores.error,
                    minimumSize: tamanoMinimo,
                    padding: relleno,
                    shape: forma),
              ),
            ),
          ],
        )
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline,
                  size: 16, color: colores.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Turno ${turno.estado.etiqueta.toLowerCase()}: solo lectura',
                style: tema.textTheme.bodyMedium!.copyWith(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoEncontrado extends StatelessWidget {
  const _NoEncontrado({required this.barra});

  final PreferredSizeWidget barra;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    return Scaffold(
      appBar: barra,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IlustracionCircular(
                rutaImagen: RutasAssets.ilustracionNoEncontrado(tema.brightness),
                icono: Icons.search_off,
                colorFondo: colores.errorContainer,
                colorIcono: colores.error,
                tamano: 112,
              ),
              const SizedBox(height: 14),
              Text('No encontramos este turno',
                  style: tema.textTheme.titleLarge!.copyWith(fontSize: 18)),
              const SizedBox(height: 14),
              Text('El turno no existe o ya no está disponible.',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodyMedium!.copyWith(fontSize: 13)),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => context.go('/agenda'),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Volver a la agenda'),
                style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: const StadiumBorder()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}