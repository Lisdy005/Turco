enum CategoriaServicio {
  corte('Corte'),
  color('Color'),
  barba('Barba'),
  peinado('Peinado'),
  tratamiento('Tratamiento');

  const CategoriaServicio(this.etiqueta);
  final String etiqueta;
}

enum PublicoServicio {
  mujeres('Mujeres'),
  hombres('Hombres'),
  unisex('Unisex');

  const PublicoServicio(this.etiqueta);
  final String etiqueta;
}

enum GeneroCliente {
  mujer('Mujer', PublicoServicio.mujeres),
  hombre('Hombre', PublicoServicio.hombres);

  const GeneroCliente(this.etiqueta, this.publicoPorDefecto);
  final String etiqueta;
  final PublicoServicio publicoPorDefecto;
}

enum EstadoTurno {
  programado('Programado'),
  completado('Completado'),
  cancelado('Cancelado');

  const EstadoTurno(this.etiqueta);
  final String etiqueta;
}

enum EstadoFranja {
  libre,
  pasada,
  excedeCierre,
  ocupadaEstilista,
  ocupadaCliente,
}