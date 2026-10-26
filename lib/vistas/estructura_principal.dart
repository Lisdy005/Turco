import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EstructuraPrincipal extends StatelessWidget {
  const EstructuraPrincipal({super.key, required this.navegacion});

  final StatefulNavigationShell navegacion;

  @override
  Widget build(BuildContext context) {
    // Desde otra pestaña "atrás" vuelve a la Agenda, desde la Agenda sale
    return PopScope(
      canPop: navegacion.currentIndex == 0,
      onPopInvokedWithResult: (seHizoPop, resultado) {
        if (!seHizoPop) navegacion.goBranch(0);
      },
      child: Scaffold(
        body: navegacion,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navegacion.currentIndex,
          onDestinationSelected: (indice) => navegacion.goBranch(
            indice,
            initialLocation: indice == navegacion.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined), label: 'Agenda'),
            NavigationDestination(
                icon: Icon(Icons.people_outline), label: 'Clientes'),
            NavigationDestination(
                icon: Icon(Icons.content_cut), label: 'Servicios'),
            NavigationDestination(
                icon: Icon(Icons.badge_outlined), label: 'Estilistas'),
          ],
        ),
      ),
    );
  }
}