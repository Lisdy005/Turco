# Turco

Aplicación móvil Android, hecha con Flutter, para gestionar los turnos de una peluquería: agenda diaria, clientes, servicios y estilistas. Es el primer examen parcial de Programación de Dispositivos Móviles.

## Datos del proyecto

| Dato | Valor |
|---|---|
| Autora | Lisdania Díaz |
| Application id | `com.lisdaniadiaz.turco` |
| Versión de Flutter | 3.47.5 (canal stable) |
| Versión de Dart | 3.13.4 |
| Plataforma | Android |
| Navegación | `go_router` con `StatefulShellRoute` |
| Arquitectura | MVVM con `ChangeNotifier` y `ListenableBuilder` |
| Datos | En memoria (se cargan al iniciar la app) |
| Paquetes externos | Solo `go_router` |

## Requisitos

- Flutter SDK 3.47.5 (o compatible) instalado y en el `PATH`.
- Android Studio con el SDK de Android.
- Un emulador Android o un teléfono con la depuración USB activada.

## Cómo inicializar y ejecutar

```
git clone https://github.com/Lisdy005/turco.git
cd turco
flutter pub get
flutter run
```

También se puede abrir la carpeta en Android Studio, esperar a que termine `pub get`, elegir un emulador y pulsar **Run**.

## Cómo generar el APK release

```
flutter build apk --release
```

El archivo resultante queda en `build/app/outputs/flutter-apk/app-release.apk`.

## Estructura de carpetas

```
lib/
  main.dart              Punto de entrada y ViewModels globales
  datos/                 Datos de prueba cargados en memoria
  modelos/               Servicio, Estilista, Cliente, Turno y enumeraciones
  viewmodelos/           SalonViewModelo (reglas de negocio) y TemaViewModelo
  vistas/                Pantallas y hojas inferiores
  widgets/               Widgets reutilizables
  tema/                  Tema claro y oscuro, y rutas de assets
  rutas/                 Configuración de go_router
  utilidades/            Formato de fechas, teléfonos y búsqueda
assets/
  fuentes/               Fuente Poppins
  imagenes/              Logo e ilustraciones (versiones clara y oscura)
capturas/                Capturas reales de la app
```

## Rutas

| Ruta | Pantalla |
|---|---|
| `/agenda` | Agenda (admite `?estilista=ID` para filtrar) |
| `/clientes` | Clientes |
| `/servicios` | Servicios |
| `/estilistas` | Estilistas |
| `/turno/nuevo` | Formulario de turno (crear; recibe datos iniciales con `extra`) |
| `/turno/:id` | Detalle de turno |
| `/turno/:id/editar` | Formulario de turno (editar) |

## Funcionalidades

- **Agenda:** tira de siete días, resumen del día, filtros por estilista y estado, acciones rápidas y cambio de tema (sistema, claro u oscuro).
- **Clientes:** búsqueda por nombre o teléfono, filtro por género, alta, edición, eliminación e historial de turnos.
- **Servicios:** catálogo en cuadrícula con filtros por categoría y público.
- **Estilistas:** lista con especialidades y turnos programados de hoy.
- **Turnos:** formulario con validaciones, franjas libres calculadas según estilista, cliente y duración, detalle y cambio de estado.

Reglas principales: el salón abre de 9:00 a 19:00, cierra los domingos, y un estilista o un cliente no puede tener dos turnos programados que se solapen.
