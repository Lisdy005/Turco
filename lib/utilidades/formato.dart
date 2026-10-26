String normalizarTexto(String texto) {
  const conAcento = 'áàäâãéèëêíìïîóòöôõúùüûñ';
  const sinAcento = 'aaaaaeeeeiiiiooooouuuun';
  var resultado = texto.toLowerCase().trim();
  for (var i = 0; i < conAcento.length; i++) {
    resultado = resultado.replaceAll(conAcento[i], sinAcento[i]);
  }
  return resultado;
}

String formatearTelefono(String telefono) => telefono.length == 8
    ? '${telefono.substring(0, 2)} ${telefono.substring(2, 5)} ${telefono.substring(5)}'
    : telefono;

String formatearDiaMes(DateTime fecha) =>
    '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}';

String textoCantidadTurnos(int cantidad) =>
    cantidad == 1 ? '1 turno' : '$cantidad turnos';

const List<String> _nombresDias = [
  'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
];
const List<String> _nombresMeses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
  'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String formatearFechaLarga(DateTime fecha) =>
    '${_nombresDias[fecha.weekday - 1]} ${fecha.day} de '
        '${_nombresMeses[fecha.month - 1]} de ${fecha.year}';

String formatearFechaCompleta(DateTime fecha) =>
    '${formatearDiaMes(fecha)}/${fecha.year}';

String formatearHora(DateTime fecha) =>
    '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

String formatearDuracion(int minutos) {
  final horas = minutos ~/ 60;
  final resto = minutos % 60;
  if (horas == 0) return '$resto min';
  if (resto == 0) return '$horas h';
  return '$horas h $resto min';
}

const List<String> _abreviaturasDias = [
  'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom',
];

String abreviaturaDia(DateTime fecha) => _abreviaturasDias[fecha.weekday - 1];

String formatearMesAnio(DateTime fecha) {
  final mes = _nombresMeses[fecha.month - 1];
  return '${mes[0].toUpperCase()}${mes.substring(1)} ${fecha.year}';
}

// Ejemplo: "mié 21 de octubre"
String formatearFechaCorta(DateTime fecha) =>
    '${abreviaturaDia(fecha).toLowerCase()} ${fecha.day} de ${_nombresMeses[fecha.month - 1]}';