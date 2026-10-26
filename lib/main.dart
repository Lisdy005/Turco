import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'rutas/rutas_app.dart';
import 'tema/tema_app.dart';
import 'viewmodelos/salon_viewmodelo.dart';
import 'viewmodelos/tema_viewmodelo.dart';

void main() => runApp(const AplicacionTurco());

class AplicacionTurco extends StatefulWidget {
  const AplicacionTurco({super.key});

  @override
  State<AplicacionTurco> createState() => _EstadoAplicacionTurco();
}

class _EstadoAplicacionTurco extends State<AplicacionTurco> {
  final SalonViewModelo _salon = SalonViewModelo();
  final TemaViewModelo _tema = TemaViewModelo();
  late final GoRouter _router = crearRouter(salon: _salon, tema: _tema);

  @override
  void dispose() {
    _router.dispose();
    _tema.dispose();
    _salon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _tema,
      builder: (context, _) => MaterialApp.router(
        title: 'Turco',
        debugShowCheckedModeBanner: false,
        theme: TemaApp.claro,
        darkTheme: TemaApp.oscuro,
        themeMode: _tema.modo,
        routerConfig: _router,
      ),
    );
  }
}