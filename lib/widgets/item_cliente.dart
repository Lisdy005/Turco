import 'package:flutter/material.dart';
import '../modelos/cliente.dart';
import '../utilidades/formato.dart';
import 'avatar_cliente.dart';

class ItemCliente extends StatelessWidget {
  const ItemCliente({
    super.key,
    required this.cliente,
    required this.cantidadTurnos,
    required this.alTocar,
  });

  final Cliente cliente;
  final int cantidadTurnos;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return InkWell(
      onTap: alTocar,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AvatarCliente(cliente: cliente),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cliente.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.titleMedium!
                        .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${formatearTelefono(cliente.telefono)} · ${cliente.genero.etiqueta}',
                    style: tema.textTheme.bodyMedium!.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              textoCantidadTurnos(cantidadTurnos),
              style: tema.textTheme.bodyMedium!
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}