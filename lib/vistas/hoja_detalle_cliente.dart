import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utilidades/formato.dart';
import '../viewmodelos/salon_viewmodelo.dart';
import '../widgets/avatar_cliente.dart';
import '../widgets/etiqueta_estado.dart';

enum AccionCliente { nuevoTurno, editar, eliminar }

class HojaDetalleCliente extends StatelessWidget {
  const HojaDetalleCliente({
    super.key,
    required this.salon,
    required this.idCliente,
  });

  final SalonViewModelo salon;
  final int idCliente;

  @override
  Widget build(BuildContext context) {
    final cliente = salon.clientePorId(idCliente);
    if (cliente == null) return const SizedBox.shrink();
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final turnos = salon.turnosDeCliente(idCliente);
    const forma = StadiumBorder();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarCliente(cliente: cliente, tamano: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cliente.nombre,
                        style:
                        tema.textTheme.titleLarge!.copyWith(fontSize: 18)),
                    const SizedBox(height: 2),
                    _LineaDato(
                      icono: Icons.phone_outlined,
                      texto: formatearTelefono(cliente.telefono),
                    ),
                    if (cliente.correo != null)
                      _LineaDato(
                          icono: Icons.mail_outline, texto: cliente.correo!),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Historial de turnos · ${turnos.length}',
            style: tema.textTheme.bodyMedium!.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colores.onSurface),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: turnos.isEmpty
                ? Text('Este cliente aún no tiene turnos.',
                style: tema.textTheme.bodyMedium)
                : ListView.separated(
              shrinkWrap: true,
              itemCount: turnos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, indice) {
                final turno = turnos[indice];
                final servicios =
                turno.servicios.map((s) => s.nombre).join(' + ');
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${formatearDiaMes(turno.inicio)} · $servicios',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.bodyMedium!.copyWith(
                            fontSize: 13, color: colores.onSurface),
                      ),
                    ),
                    const SizedBox(width: 8),
                    EtiquetaEstado(estado: turno.estado),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.pop(AccionCliente.nuevoTurno),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nuevo turno'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 46), shape: forma),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => context.pop(AccionCliente.editar),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Editar'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 46), shape: forma),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                onPressed: () => context.pop(AccionCliente.eliminar),
                tooltip: 'Eliminar',
                icon: Icon(Icons.delete_outline, size: 18, color: colores.error),
                style: IconButton.styleFrom(
                  fixedSize: const Size(46, 46),
                  side: BorderSide(color: colores.outlineVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineaDato extends StatelessWidget {
  const _LineaDato({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      children: [
        Icon(icono, size: 13, color: tema.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(texto,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.bodyMedium!.copyWith(fontSize: 13)),
        ),
      ],
    );
  }
}