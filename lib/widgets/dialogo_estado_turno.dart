import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/enumeraciones.dart';
import '../modelos/turno.dart';
import '../utilidades/formato.dart';
import '../viewmodelos/salon_viewmodelo.dart';

// Pide confirmación y cambia el estado
Future<bool> confirmarCambioEstado(
    BuildContext context,
    SalonViewModelo salon,
    Turno turno,
    EstadoTurno nuevoEstado,
    ) async {
  final completar = nuevoEstado == EstadoTurno.completado;
  final cliente = salon.clientePorId(turno.idCliente)?.nombre ?? 'el cliente';
  final horario =
      '${formatearHora(turno.inicio)} a ${formatearHora(turno.fin)}';

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
            Icon(
              completar ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: completar ? colores.primary : colores.error,
            ),
            const SizedBox(height: 14),
            Text(
              completar ? '¿Completar este turno?' : '¿Cancelar este turno?',
              style: tema.textTheme.titleLarge!.copyWith(fontSize: 20),
            ),
          ],
        ),
        content: Text(completar
            ? 'El turno de $cliente ($horario) pasará a completado y quedará en solo lectura.'
            : 'El horario de $cliente ($horario) quedará libre. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => contextoDialogo.pop(false),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () => contextoDialogo.pop(true),
            child: Text(
              completar ? 'Completar' : 'Cancelar turno',
              style: completar ? null : TextStyle(color: colores.error),
            ),
          ),
        ],
      );
    },
  );

  if (confirmado != true || !context.mounted) return false;
  if (completar) {
    salon.completarTurno(turno.id);
  } else {
    salon.cancelarTurno(turno.id);
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(completar ? 'Turno completado' : 'Turno cancelado')),
  );
  return true;
}