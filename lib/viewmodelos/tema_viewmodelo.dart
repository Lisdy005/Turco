import 'package:flutter/material.dart';

class TemaViewModelo extends ChangeNotifier {
  ThemeMode _modo = ThemeMode.system;
  ThemeMode get modo => _modo;

  void elegir(ThemeMode nuevo) {
    if (nuevo == _modo) return;
    _modo = nuevo;
    notifyListeners();
  }
}