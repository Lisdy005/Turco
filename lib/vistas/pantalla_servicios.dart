import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/datos_iniciales_turno.dart';
import '../modelos/enumeraciones.dart';
import '../modelos/servicio.dart';
import '../modelos/turno.dart';
import '../viewmodelos/salon_viewmodelo.dart';
import '../widgets/tarjeta_servicio.dart';

class PantallaServicios extends StatefulWidget {
  const PantallaServicios({super.key, required this.salon});

  final SalonViewModelo salon;

  @override
  State<PantallaServicios> createState() => _EstadoPantallaServicios();
}

class _EstadoPantallaServicios extends State<PantallaServicios> {
  CategoriaServicio? _categoria;
  PublicoServicio? _publico;

  // 2 columnas por debajo de 600 dp, 3 hasta 840 dp y 4 por encima
  int _columnas(double ancho) {
    if (ancho < 600) return 2;
    if (ancho <= 840) return 3;
    return 4;
  }

  void _quitarFiltros() => setState(() {
    _categoria = null;
    _publico = null;
  });

  // Abre el formulario con el servicio elegido y espera el turno guardado
  Future<void> _reservar(Servicio servicio) async {
    final turno = await context.push<Turno>(
      '/turno/nuevo',
      extra: DatosInicialesTurno(idServicio: servicio.id),
    );
    if (turno != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Turno guardado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final servicios = widget.salon
        .serviciosFiltrados(categoria: _categoria, publico: _publico);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servicios',
                style: tema.textTheme.titleLarge!.copyWith(fontSize: 20)),
            Text('Toca un servicio para reservar',
                style: tema.textTheme.bodyMedium!.copyWith(fontSize: 12)),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, restricciones) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: _categoria == null,
                      onSelected: (_) => setState(() => _categoria = null),
                    ),
                    for (final categoria in CategoriaServicio.values) ...[
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(categoria.etiqueta),
                        selected: _categoria == categoria,
                        onSelected: (_) =>
                            setState(() => _categoria = categoria),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
                  onSelectionChanged: (seleccion) =>
                      setState(() => _publico = seleccion.first),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: servicios.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off,
                          size: 48,
                          color: tema.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text('No hay servicios con esos filtros',
                          style: tema.textTheme.titleMedium),
                      TextButton(
                        onPressed: _quitarFiltros,
                        child: const Text('Quitar filtros'),
                      ),
                    ],
                  ),
                )
                    : GridView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _columnas(restricciones.maxWidth),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 204,
                  ),
                  itemCount: servicios.length,
                  itemBuilder: (context, indice) {
                    final servicio = servicios[indice];
                    return TarjetaServicio(
                      servicio: servicio,
                      alTocar: () => _reservar(servicio),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}