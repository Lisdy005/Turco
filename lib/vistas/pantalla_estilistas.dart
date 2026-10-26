import 'package:flutter/material.dart';
import '../viewmodelos/salon_viewmodelo.dart';

class PantallaEstilistas extends StatelessWidget {
  const PantallaEstilistas({super.key, required this.salon});

  final SalonViewModelo salon;

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Estilistas')));
}