import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OpcionSelector<T> {
  const OpcionSelector({required this.valor, required this.texto});

  final T valor;
  final String texto;
}

Future<T?> mostrarSelectorOpciones<T>(
    BuildContext context, {
      required String titulo,
      required List<OpcionSelector<T>> opciones,
      required String mensajeVacio,
      T? seleccionado,
    }) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (contextoHoja) {
      final tema = Theme.of(contextoHoja);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(titulo,
                style: tema.textTheme.titleLarge!.copyWith(fontSize: 18)),
          ),
          if (opciones.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Text(mensajeVacio, style: tema.textTheme.bodyMedium),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: opciones.length,
                itemBuilder: (context, indice) {
                  final opcion = opciones[indice];
                  final elegida = opcion.valor == seleccionado;
                  return ListTile(
                    title: Text(opcion.texto),
                    selected: elegida,
                    trailing: elegida ? const Icon(Icons.check) : null,
                    onTap: () => contextoHoja.pop(opcion.valor),
                  );
                },
              ),
            ),
        ],
      );
    },
  );
}