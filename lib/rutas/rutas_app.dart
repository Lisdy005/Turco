import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/datos_iniciales_turno.dart';
import '../viewmodelos/salon_viewmodelo.dart';
import '../viewmodelos/tema_viewmodelo.dart';
import '../vistas/estructura_principal.dart';
import '../vistas/pantalla_agenda.dart';
import '../vistas/pantalla_clientes.dart';
import '../vistas/pantalla_detalle_turno.dart';
import '../vistas/pantalla_estilistas.dart';
import '../vistas/pantalla_formulario_turno.dart';
import '../vistas/pantalla_servicios.dart';

final GlobalKey<NavigatorState> _claveNavegadorRaiz =
GlobalKey<NavigatorState>(debugLabel: 'raiz');

GoRouter crearRouter({
  required SalonViewModelo salon,
  required TemaViewModelo tema,
}) {
  return GoRouter(
    navigatorKey: _claveNavegadorRaiz,
    initialLocation: '/agenda',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navegacion) =>
            EstructuraPrincipal(navegacion: navegacion),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/agenda',
              builder: (context, state) {
                final idEstilista = int.tryParse(
                    state.uri.queryParameters['estilista'] ?? '');
                return PantallaAgenda(
                  salon: salon,
                  tema: tema,
                  idEstilistaFiltro: idEstilista,
                );
              },
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/clientes',
              builder: (context, state) => PantallaClientes(salon: salon),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/servicios',
              builder: (context, state) => PantallaServicios(salon: salon),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/estilistas',
              builder: (context, state) => PantallaEstilistas(salon: salon),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/turno/nuevo',
        parentNavigatorKey: _claveNavegadorRaiz,
        builder: (context, state) => PantallaFormularioTurno(
          salon: salon,
          datosIniciales: state.extra as DatosInicialesTurno?,
        ),
      ),
      GoRoute(
        path: '/turno/:id',
        parentNavigatorKey: _claveNavegadorRaiz,
        builder: (context, state) => PantallaDetalleTurno(
          salon: salon,
          idTurno: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
        ),
        routes: [
          GoRoute(
            path: 'editar',
            parentNavigatorKey: _claveNavegadorRaiz,
            builder: (context, state) => PantallaFormularioTurno(
              salon: salon,
              idTurno: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
            ),
          ),
        ],
      ),
    ],
  );
}