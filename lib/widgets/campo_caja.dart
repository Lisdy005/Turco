import 'package:flutter/material.dart';

class CampoCaja<T> extends FormField<T> {
  CampoCaja({
    super.key,
    super.initialValue,
    super.validator,
    required String etiqueta,
    required IconData icono,
    required String textoVacio,
    required String? textoValor,
    required VoidCallback? alTocar,
    required FocusNode nodoFoco,
  }) : super(
    builder: (estado) {
      final tema = Theme.of(estado.context);
      final colores = tema.colorScheme;
      return InkWell(
        focusNode: nodoFoco,
        onTap: alTocar,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          isEmpty: false,
          decoration: InputDecoration(
            labelText: etiqueta,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixIcon: Icon(icono),
            suffixIcon: const Icon(Icons.expand_more),
            errorText: estado.errorText,
            enabled: alTocar != null,
          ),
          child: Text(
            textoValor ?? textoVacio,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tema.textTheme.bodyMedium!.copyWith(
              fontSize: 14,
              color: textoValor == null
                  ? colores.onSurfaceVariant
                  : colores.onSurface,
            ),
          ),
        ),
      );
    },
  );
}