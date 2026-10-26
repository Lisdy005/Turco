import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../modelos/cliente.dart';
import '../modelos/enumeraciones.dart';
import '../viewmodelos/salon_viewmodelo.dart';

class HojaFormularioCliente extends StatefulWidget {
  const HojaFormularioCliente({super.key, required this.salon, this.cliente});

  final SalonViewModelo salon;
  final Cliente? cliente; // null = alta, con valor = edición

  @override
  State<HojaFormularioCliente> createState() => _EstadoHojaFormularioCliente();
}

class _EstadoHojaFormularioCliente extends State<HojaFormularioCliente> {
  final GlobalKey<FormState> _clave = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _correo;
  final FocusNode _focoNombre = FocusNode();
  final FocusNode _focoTelefono = FocusNode();
  final FocusNode _focoCorreo = FocusNode();
  GeneroCliente? _genero;

  @override
  void initState() {
    super.initState();
    final cliente = widget.cliente;
    _nombre = TextEditingController(text: cliente?.nombre ?? '');
    _telefono = TextEditingController(text: cliente?.telefono ?? '');
    _correo = TextEditingController(text: cliente?.correo ?? '');
    _genero = cliente?.genero;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _correo.dispose();
    _focoNombre.dispose();
    _focoTelefono.dispose();
    _focoCorreo.dispose();
    super.dispose();
  }

  String? _validarNombre(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.length < 3 || texto.length > 60) {
      return 'Escribe entre 3 y 60 caracteres';
    }
    return null;
  }

  String? _validarTelefono(String? valor) {
    final texto = (valor ?? '').trim();
    if (!RegExp(r'^\d{8}$').hasMatch(texto)) {
      return 'Debe tener exactamente 8 dígitos';
    }
    if (widget.salon.telefonoRepetido(texto, idExcluido: widget.cliente?.id)) {
      return 'Ese teléfono ya está registrado';
    }
    return null;
  }

  String? _validarCorreo(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return null;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto)) {
      return 'Escribe un correo válido';
    }
    return null;
  }

  // Al fallar la validación el foco va al primer campo con error
  void _enfocarPrimerError() {
    if (_validarNombre(_nombre.text) != null) {
      _focoNombre.requestFocus();
    } else if (_validarTelefono(_telefono.text) != null) {
      _focoTelefono.requestFocus();
    } else if (_genero != null && _validarCorreo(_correo.text) != null) {
      _focoCorreo.requestFocus();
    }
  }

  void _guardar() {
    if (!_clave.currentState!.validate()) {
      _enfocarPrimerError();
      return;
    }
    final cliente = widget.cliente;
    if (cliente == null) {
      widget.salon.crearCliente(
        nombre: _nombre.text,
        telefono: _telefono.text.trim(),
        genero: _genero!,
        correo: _correo.text,
      );
    } else {
      widget.salon.actualizarCliente(
        cliente.id,
        nombre: _nombre.text,
        telefono: _telefono.text.trim(),
        genero: _genero!,
        correo: _correo.text,
      );
    }
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    const forma = StadiumBorder();

    return Padding(
      // Sube el contenido cuando aparece el teclado
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _clave,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.cliente == null ? 'Nuevo cliente' : 'Editar cliente',
                style: tema.textTheme.titleLarge!.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nombre,
                focusNode: _focoNombre,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: _validarNombre,
                onFieldSubmitted: (_) => _focoTelefono.requestFocus(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _telefono,
                focusNode: _focoTelefono,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: _validarTelefono,
                onFieldSubmitted: (_) => _focoCorreo.requestFocus(),
              ),
              const SizedBox(height: 14),
              FormField<GeneroCliente>(
                initialValue: _genero,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (valor) =>
                valor == null ? 'Selecciona un género' : null,
                builder: (estado) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Género',
                      style: tema.textTheme.bodyMedium!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: estado.hasError
                            ? colores.error
                            : colores.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<GeneroCliente>(
                        emptySelectionAllowed: true,
                        segments: [
                          for (final genero in GeneroCliente.values)
                            ButtonSegment(
                                value: genero, label: Text(genero.etiqueta)),
                        ],
                        selected: estado.value == null
                            ? <GeneroCliente>{}
                            : {estado.value!},
                        onSelectionChanged: (seleccion) {
                          final nuevo =
                          seleccion.isEmpty ? null : seleccion.first;
                          _genero = nuevo;
                          estado.didChange(nuevo);
                        },
                      ),
                    ),
                    if (estado.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          estado.errorText!,
                          style: tema.textTheme.bodyMedium!
                              .copyWith(fontSize: 12, color: colores.error),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _correo,
                focusNode: _focoCorreo,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration:
                const InputDecoration(labelText: 'Correo (opcional)'),
                validator: _validarCorreo,
                onFieldSubmitted: (_) => _guardar(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 46), shape: forma),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _guardar,
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 46), shape: forma),
                      child: const Text('Guardar cliente'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}