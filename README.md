<div align="center">

# 💊 VeriFarmac

**Verificador de medicamentos colombianos en tiempo real**

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11%2B-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Auth%20%2B%20DB-3ECF8E?logo=supabase)](https://supabase.com)
[![Android](https://img.shields.io/badge/Android-8.0%2B-3DDC84?logo=android)](https://android.com)
[![Tests](https://img.shields.io/badge/tests-55%20passing-brightgreen)](veri_farmac/test)

[📥 Descargar APK v1.1.0](https://github.com/andresZam12/proyecto_Verifarmac/releases/download/v1.1.0/VeriFarmac-v1.1.0.apk)

</div>

---

## ¿Qué es VeriFarmac?

VeriFarmac es una aplicación móvil Android que permite verificar si un medicamento o producto natural colombiano tiene registro sanitario vigente ante el INVIMA, detectar si está vencido o si la información del empaque fue alterada, y encontrar farmacias o clínicas cercanas — todo desde la cámara del celular. Es el prototipo del trabajo de grado homónimo (Universidad Cooperativa de Colombia, Campus Pasto).

---

## 📥 Descarga e instalación

1. Descarga el APK desde el botón de arriba o directamente aquí:
   ```
   https://github.com/andresZam12/proyecto_Verifarmac/releases/download/v1.1.0/VeriFarmac-v1.1.0.apk
   ```
2. En tu Android ve a **Ajustes → Seguridad → Fuentes desconocidas** y actívalo
3. Abre el archivo `.apk` descargado y sigue los pasos
4. Crea una cuenta con correo y contraseña, o inicia sesión con Google

> **Requisitos mínimos:** Android 8.0 (API 26) · Cámara · Ubicación · Internet

---

## ✨ Funcionalidades

| Función | Descripción |
|---|---|
| 🔍 Escaneo OCR | Captura el texto del empaque con la cámara y extrae el registro sanitario |
| 📷 Escaneo por código de barras | Decodifica el EAN/UPC de la foto y busca el producto (Open Food Facts / UPCItemDB) antes de cruzar con INVIMA |
| ✨ Análisis visual con IA | Claude interpreta empaques deteriorados/borrosos y extrae el registro cuando el OCR no alcanza (requiere `CLAUDE_API_KEY`, ver abajo) |
| ✅ Verificación INVIMA | Consulta en tiempo real si el registro está vigente, vencido o suspendido |
| ⚠️ Detección de vencimiento | Detecta la fecha "Vence: MM/YYYY" del empaque y alerta si el lote expiró |
| ⌨️ Entrada manual | Respaldo para escribir el código EAN o el número de registro INVIMA cuando la cámara no logra leerlo |
| 🗺️ Mapa de farmacias | Muestra clínicas y farmacias cercanas usando OpenStreetMap |
| 📊 Dashboard | Gráfico de torta con historial de escaneos por estado |
| 🕒 Historial | Registro local de todas las verificaciones, sincronizado con Supabase si hay sesión activa |
| 🌗 Tema claro/oscuro | Configurable desde ajustes |
| 🌐 Multilenguaje | Español e inglés |

---

## 🏗️ Infraestructura

```
┌─────────────────────────────────────────────────────┐
│                    APP (Android)                     │
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐  │
│  │  Flutter │  │ Riverpod │  │    GoRouter       │  │
│  │  3.41    │  │  2.6.1   │  │     14.6.2        │  │
│  └──────────┘  └──────────┘  └───────────────────┘  │
│                                                     │
│  ┌─────────────────────┐  ┌──────────────────────┐  │
│  │  ML Kit OCR         │  │  SharedPreferences   │  │
│  │  (on-device)        │  │  (historial local)   │  │
│  └─────────────────────┘  └──────────────────────┘  │
└──────────────────────┬──────────────────────────────┘
                       │ Internet
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
  ┌──────────┐  ┌────────────┐  ┌──────────────┐
  │ Supabase │  │   INVIMA   │  │ OpenStreetMap│
  │ Auth+DB  │  │ datos.gov  │  │  Nominatim  │
  └──────────┘  └────────────┘  └──────────────┘
```

### Servicios en la nube

| Servicio | Uso | Plan |
|---|---|---|
| **Supabase** | Autenticación (Google OAuth o correo/contraseña) + base de datos PostgreSQL | Free tier |
| **INVIMA / Socrata** | Registro sanitario de medicamentos | Público, sin límite |
| **OpenStreetMap / Nominatim** | Tiles del mapa + búsqueda de farmacias | Público, sin API key |
| **Open Food Facts** | Nombre de producto por código de barras EAN (mayormente alimentos) | Público, sin API key |
| **Open Products Facts** | Respaldo de Open Food Facts para productos no alimenticios (misma organización) | Público, sin API key |
| **UPCItemDB** | Último respaldo para códigos de barras generales | Trial gratuito, sin API key |
| **Claude (Anthropic)** | Análisis visual de empaques deteriorados | De pago, requiere `CLAUDE_API_KEY` propia |

---

## 🔌 APIs utilizadas

### INVIMA — Registro Sanitario
```
GET https://www.datos.gov.co/resource/i7cb-raxc.json
    ?expediente=INVIMA2008M-XXXXXXX
```
Verifica si un medicamento tiene autorización sanitaria vigente en Colombia.

### Open Food Facts — Código de barras
```
GET https://world.openfoodfacts.org/api/v0/product/{barcode}.json
```
Obtiene el nombre del producto a partir de un código EAN/UPC.

### Open Products Facts — Código de barras (no alimentos)
```
GET https://world.openproductsfacts.org/api/v0/product/{barcode}.json
```
Misma organización y formato que Open Food Facts, pero para el resto
del catálogo (aseo, electrónica, papelería, etc.). Se consulta cuando
Open Food Facts no tiene el producto.

### UPCItemDB — Último respaldo de código de barras
```
GET https://api.upcitemdb.com/prod/trial/lookup?upc={barcode}
```
Se consulta cuando ninguna de las dos bases anteriores tiene el
producto. No existe ninguna base pública gratuita que cruce código de
barras con registro INVIMA directamente — por eso, si el producto
encontrado no parece un medicamento (por nombre/categoría), la app
avisa que está fuera de su
alcance en vez de intentar una búsqueda sin sentido en INVIMA.

### Nominatim — Farmacias cercanas
```
GET https://nominatim.openstreetmap.org/search
    ?q=pharmacy&bounded=1&viewbox={bbox}
```
Busca farmacias y clínicas dentro del área visible del mapa.

---

## 🤖 Inteligencia Artificial

El proyecto integra la **Claude API de Anthropic** (`claude-sonnet-5`) para análisis visual de empaques, con su propio modo en la pantalla de escaneo ("IA Visual"):

```dart
// Envía la imagen del empaque y recibe:
// { "isAuthentic": true/false, "confidence": 0.0-1.0, "expiryDate": "...",
//   "registrySanitario": "...", "observations": "..." }
await claude.analyzePackaging(imagePath);
```

Si Claude logra leer un registro sanitario legible en el empaque, se
contrasta contra INVIMA igual que en el modo OCR — la IA interpreta el
empaque, pero la decisión de vigencia siempre la da el dato oficial.

> **Estado actual:** completamente funcional en la UI (toggle de modo,
> obturador, pantalla de resultado). Solo requiere una `CLAUDE_API_KEY`
> propia con saldo activo en [console.anthropic.com](https://console.anthropic.com),
> pasada en tiempo de compilación — ver "Requisitos para desarrollo
> local" más abajo. Sin ella, el modo avisa claramente que no está
> configurado en vez de fallar. El OCR + INVIMA cubren el caso de uso
> principal sin necesidad de IA externa.

---

## 🛠️ Stack tecnológico

| Categoría | Tecnología | Versión |
|---|---|---|
| Framework | Flutter / Dart | 3.41 / 3.x |
| Estado | Riverpod | 2.6.1 |
| Navegación | GoRouter | 14.6.2 |
| Auth + BD | Supabase Flutter | 2.8.4 |
| Almacenamiento local | SharedPreferences | — |
| OCR on-device | Google ML Kit Text Recognition | — |
| HTTP | Dio | 5.7.0 |
| Mapas | flutter_map + latlong2 | 8.3.0 |
| Gráficas | fl_chart | 0.69.0 |
| IA visual | Anthropic Claude API | claude-sonnet-5 |

---

## 🏛️ Arquitectura

Clean Architecture por feature. Cada módulo en `lib/features/<feature>/` tiene tres capas (domain / data / presentation). La inyección de dependencias es Riverpod puro — cada provider construye sus propios repositorios y datasources; no hay un service locator aparte.

```
lib/
├── core/              # Router, providers globales, utilidades
├── features/
│   ├── auth/          # Login con Google o correo/contraseña (Supabase)
│   ├── dashboard/     # Estadísticas y accesos rápidos
│   ├── scanner/       # Código de barras + OCR + IA visual
│   ├── medicine_detail/  # Detalle del medicamento + INVIMA
│   ├── history/       # Historial local y en la nube de escaneos
│   ├── map/           # Mapa de farmacias y clínicas cercanas
│   └── settings/      # Tema, idioma, perfil
└── shared/            # Widgets reutilizables
```

---

## ✅ Resultados de pruebas reales

Datos reales, sin simular — ver `veri_farmac/test_results/` para la evidencia completa.

| Prueba | Resultado |
|---|---|
| Pruebas unitarias | 55/55 pasando (`flutter test`), 97.6% de cobertura en los módulos cubiertos |
| Verificación OCR + IA visual (piloto, n=16) | 81.3% de exactitud, F1 macro 75.0% |
| Código de barras (piloto, n=7 productos reales) | 0/7 encontrados — limitación de datos externa, no del algoritmo (ver sección de APIs) |
| Carga (JMeter, 20 usuarios concurrentes, 100 peticiones) | 0% de error, 133.9 ms de respuesta promedio, 9.98 peticiones/s |

---

## 📋 Requisitos para desarrollo local

```bash
# 1. Clona el repositorio
git clone https://github.com/andresZam12/proyecto_Verifarmac.git
cd proyecto_Verifarmac/veri_farmac

# 2. Instala dependencias
flutter pub get

# 3. (Opcional) Habilita el análisis visual con IA
#    Sin esto, el modo "IA Visual" del escáner muestra un aviso en vez
#    de fallar — el resto de la app funciona igual sin configurarlo.
cp env/dev.json.example env/dev.json
#    Edita env/dev.json y pega tu CLAUDE_API_KEY real de
#    https://console.anthropic.com (requiere saldo/billing activo).
#    env/dev.json está en .gitignore — nunca se commitea.

# 4. Corre en modo debug
flutter run --dart-define-from-file=env/dev.json
#    (o simplemente `flutter run` si no vas a usar el modo IA Visual)
```

> Las credenciales de Supabase (URL + anon key) están hardcodeadas en
> `lib/main.dart` — es una práctica conocida a corregir, no un paso de
> configuración pendiente. La anon key de Supabase es pública por diseño
> (la seguridad real la da Row Level Security en la base de datos), así
> que no representa el mismo riesgo que una API key secreta.

---

<div align="center">
  <sub>VeriFarmac · 2026 · Trabajo de grado, Universidad Cooperativa de Colombia, Campus Pasto</sub>
</div>
