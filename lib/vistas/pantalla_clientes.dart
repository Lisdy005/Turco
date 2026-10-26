import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/cliente.dart';
import '../modelos/datos_iniciales_turno.dart';
import '../modelos/enumeraciones.dart';
import '../modelos/turno.dart';
import '../viewmodelos/salon_viewmodelo.dart';
import '../widgets/item_cliente.dart';
import 'hoja_detalle_cliente.dart';
import 'hoja_formulario_cliente.dart';

class PantallaClientes extends StatefulWidget {
  const PantallaClientes({super.key, required this.salon});

  final SalonViewModelo salon;

  @override
  State<PantallaClientes> createState() => _EstadoPantallaClientes();
}

class _EstadoPantallaClientes extends State<PantallaClientes> {
  final TextEditingController _busqueda = TextEditingController();
  GeneroCliente? _genero;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario({Cliente? cliente}) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) =>
          HojaFormularioCliente(salon: widget.salon, cliente: cliente),
    );
    if (guardado != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(cliente == null ? 'Cliente registrado' : 'Cliente actualizado'),
    ));
  }

  // Abre el formulario de turno con el cliente elegido y espera el resultado
  Future<void> _crearTurnoPara(Cliente cliente) async {
    final turno = await context.push<Turno>(
      '/turno/nuevo',
      extra: DatosInicialesTurno(idCliente: cliente.id),
    );
    if (turno != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Turno guardado')));
    }
  }

  Future<void> _abrirDetalle(Cliente cliente) async {
    final accion = await showModalBottomSheet<AccionCliente>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) =>
          HojaDetalleCliente(salon: widget.salon, idCliente: cliente.id),
    );
    if (!mounted || accion == null) return;
    switch (accion) {
      case AccionCliente.nuevoTurno:
        await _crearTurnoPara(cliente);
      case AccionCliente.editar:
        await _abrirFormulario(cliente: cliente);
      case AccionCliente.eliminar:
        await _eliminar(cliente);
    }
  }

  Future<void> _eliminar(Cliente cliente) async {
    final mensajero = ScaffoldMessenger.of(context);
    final programados = widget.salon.turnosProgramadosDeCliente(cliente.id);

    // Con turnos programados no se puede eliminar
    if (programados > 0) {
      final texto =
      programados == 1 ? '1 turno programado' : '$programados turnos programados';
      mensajero.showSnackBar(SnackBar(
        content: Text('No se puede eliminar: ${cliente.nombre} tiene $texto.'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () => _abrirDetalle(cliente),
        ),
      ));
      return;
    }

    final confirmado = await showDialog<bool>(
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
              Text('¿Eliminar a ${cliente.nombre}?',
                  style: tema.textTheme.titleLarge!.copyWith(fontSize: 20)),
            ],
          ),
          content: const Text(
              'Se eliminará el cliente junto con su historial de turnos completados y cancelados.'),
          actions: [
            TextButton(
              onPressed: () => contextoDialogo.pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => contextoDialogo.pop(true),
              child: Text('Eliminar', style: TextStyle(color: colores.error)),
            ),
          ],
        );
      },
    );
    if (confirmado != true || !mounted) return;
    widget.salon.eliminarCliente(cliente.id);
    mensajero.showSnackBar(const SnackBar(content: Text('Cliente eliminado')));
  }

  String _resumen() {
    final total = widget.salon.totalClientes;
    final mujeres = widget.salon.totalPorGenero(GeneroCliente.mujer);
    final hombres = widget.salon.totalPorGenero(GeneroCliente.hombre);
    return '$total ${total == 1 ? 'cliente' : 'clientes'} · '
        '$mujeres ${mujeres == 1 ? 'mujer' : 'mujeres'} · '
        '$hombres ${hombres == 1 ? 'hombre' : 'hombres'}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        titleSpacing: 16,
        title: Text('Clientes',
            style: tema.textTheme.titleLarge!.copyWith(fontSize: 20)),
        actions: [
          IconButton(
            tooltip: 'Nuevo cliente',
            onPressed: () => _abrirFormulario(),
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Nuevo cliente'),
      ),
      body: ListenableBuilder(
        listenable: widget.salon,
        builder: (context, _) {
          final clientes = widget.salon
              .clientesFiltrados(busqueda: _busqueda.text, genero: _genero);

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              children: [
                TextField(
                  controller: _busqueda,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o teléfono',
                    filled: true,
                    fillColor: colores.surfaceContainerHigh,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busqueda.text.isEmpty
                        ? null
                        : IconButton(
                      tooltip: 'Borrar búsqueda',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(_busqueda.clear),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<GeneroCliente?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('Todos')),
                      ButtonSegment(
                          value: GeneroCliente.mujer, label: Text('Mujeres')),
                      ButtonSegment(
                          value: GeneroCliente.hombre, label: Text('Hombres')),
                    ],
                    selected: {_genero},
                    onSelectionChanged: (seleccion) =>
                        setState(() => _genero = seleccion.first),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_resumen(),
                      style: tema.textTheme.bodyMedium!.copyWith(fontSize: 12)),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: clientes.isEmpty
                      ? _MensajeVacio(
                    texto: widget.salon.totalClientes == 0
                        ? 'Aún no hay clientes registrados'
                        : 'No encontramos clientes con esa búsqueda',
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: clientes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, indice) {
                      final cliente = clientes[indice];
                      return ItemCliente(
                        cliente: cliente,
                        cantidadTurnos: widget.salon
                            .cantidadTurnosDeCliente(cliente.id),
                        alTocar: () => _abrirDetalle(cliente),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MensajeVacio extends StatelessWidget {
  const _MensajeVacio({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search_outlined,
              size: 48, color: tema.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(texto, style: tema.textTheme.titleMedium),
        ],
      ),
    );
  }
}