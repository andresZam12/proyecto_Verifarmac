# VeriPharmac

Aplicación móvil Flutter para verificar la autenticidad y estado de medicamentos en Colombia mediante escaneo OCR e integración con el registro INVIMA.

## Características

- **Escaneo OCR** — captura el texto del empaque con la cámara y extrae el registro sanitario usando Google ML Kit (on-device, sin internet)
- **Verificación INVIMA** — consulta en tiempo real la base de datos oficial (`datos.gov.co`) para validar el estado del registro sanitario
- **Detección de vencimiento físico** — detecta la fecha "Vence: MM/YYYY" del empaque mediante regex sobre el texto OCR y alerta si el lote está vencido, independientemente del estado INVIMA
- **Historial de escaneos** — guarda localmente cada verificación con estado, método y nivel de confianza
- **Mapa de farmacias** — muestra clínicas y farmacias cercanas usando OpenStreetMap (Nominatim + flutter_map), sin API key
- **Dashboard con estadísticas** — gráfico de torta (fl_chart) con distribución de escaneos por estado
- **Soporte multilenguaje** — español e inglés (Flutter l10n / ARB)
- **Tema claro/oscuro** — configurable desde ajustes, persiste con SharedPreferences
- **Autenticación** — Google OAuth vía Supabase

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Framework | Flutter 3.x / Dart |
| Estado | Riverpod 2.6.1 |
| Navegación | GoRouter 14.6.2 |
| Auth + BD remota | Supabase Flutter 2.8.4 |
| Persistencia local | SharedPreferences |
| OCR on-device | Google ML Kit Text Recognition |
| HTTP | Dio 5.7.0 |
| Mapas | flutter_map 8.3.0 + latlong2 |
| Gráficas | fl_chart 0.69.0 |

## APIs externas

| API | Uso |
|---|---|
| INVIMA / Socrata (`datos.gov.co`) | Validación del registro sanitario |
| Open Food Facts | Nombre del producto por código de barras |
| Nominatim (OpenStreetMap) | Búsqueda de farmacias y clínicas cercanas |
| Anthropic Claude API (`claude-opus-4-5`) | Análisis visual de empaques |

## Arquitectura

Clean Architecture por feature. Cada módulo en `lib/features/<feature>/` tiene tres capas: `domain/` (entidades y contratos), `data/` (repositorios, datasources, modelos) y `presentation/` (páginas, providers Riverpod, widgets).

## Requisitos

- Flutter SDK ≥ 3.19
- Android SDK 21+
- Credenciales configuradas en `lib/core/config/`: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `CLAUDE_API_KEY`
