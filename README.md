<div align="center">

# 💊 VeriPharmac

**Verificador de medicamentos colombianos en tiempo real**

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Auth%20%2B%20DB-3ECF8E?logo=supabase)](https://supabase.com)
[![Android](https://img.shields.io/badge/Android-5.0%2B-3DDC84?logo=android)](https://android.com)

[📥 Descargar APK v1.0.0](https://github.com/andresZam12/proyecto_Verifarmac/releases/download/v1.0.0/app-release.apk)

</div>

---

## ¿Qué es VeriPharmac?

VeriPharmac es una aplicación móvil Android que permite verificar si un medicamento colombiano está legalmente autorizado por el INVIMA, detectar si su lote está físicamente vencido y encontrar farmacias o clínicas cercanas — todo desde la cámara del celular.

---

## 📥 Descarga e instalación

1. Descarga el APK desde el botón de arriba o directamente aquí:
   ```
   https://github.com/andresZam12/proyecto_Verifarmac/releases/download/v1.0.0/app-release.apk
   ```
2. En tu Android ve a **Ajustes → Seguridad → Fuentes desconocidas** y actívalo
3. Abre el archivo `.apk` descargado y sigue los pasos
4. Inicia sesión con tu cuenta de Google

> **Requisitos mínimos:** Android 5.0 (API 21) · Cámara · Ubicación · Internet

---

## ✨ Funcionalidades

| Función | Descripción |
|---|---|
| 🔍 Escaneo OCR | Captura el texto del empaque con la cámara y extrae el registro sanitario |
| ✅ Verificación INVIMA | Consulta en tiempo real si el registro está vigente, vencido o suspendido |
| ⚠️ Detección de vencimiento | Detecta la fecha "Vence: MM/YYYY" del empaque y alerta si el lote expiró |
| 🗺️ Mapa de farmacias | Muestra clínicas y farmacias cercanas usando OpenStreetMap |
| 📊 Dashboard | Gráfico de torta con historial de escaneos por estado |
| 🕒 Historial | Registro local de todas las verificaciones realizadas |
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
| **Supabase** | Autenticación Google OAuth + base de datos PostgreSQL | Free tier |
| **INVIMA / Socrata** | Registro sanitario de medicamentos | Público, sin límite |
| **OpenStreetMap / Nominatim** | Tiles del mapa + búsqueda de farmacias | Público, sin API key |
| **Open Food Facts** | Nombre de producto por código de barras EAN | Público, sin API key |

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
GET https://world.openfoodfacts.org/api/v3/product/{barcode}.json
```
Obtiene el nombre del producto a partir de un código EAN/UPC.

### Nominatim — Farmacias cercanas
```
GET https://nominatim.openstreetmap.org/search
    ?q=pharmacy&bounded=1&viewbox={bbox}
```
Busca farmacias y clínicas dentro del área visible del mapa.

---

## 🤖 Inteligencia Artificial

El proyecto integra la **Claude API de Anthropic** (`claude-opus-4-5`) para análisis visual de empaques:

```dart
// Envía la imagen del empaque y recibe:
// { "isAuthentic": true/false, "confidence": 0.0-1.0, "observations": "..." }
await claude.analyzePackaging(imagePath);
```

> **Estado actual:** La función está construida y conectada en el código pero requiere una API key válida de [console.anthropic.com](https://console.anthropic.com) para activarse. El OCR + INVIMA cubren el caso de uso principal sin necesidad de IA externa.

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
| IA visual | Anthropic Claude API | claude-opus-4-5 |

---

## 🏛️ Arquitectura

Clean Architecture por feature. Cada módulo en `lib/features/<feature>/` tiene tres capas:

```
lib/
├── core/              # Router, providers globales, utilidades
├── features/
│   ├── auth/          # Login con Google (Supabase)
│   ├── dashboard/     # Estadísticas y accesos rápidos
│   ├── scanner/       # OCR + lógica de verificación
│   ├── medicine_detail/  # Detalle del medicamento + INVIMA
│   ├── history/       # Historial local de escaneos
│   ├── map/           # Mapa de farmacias
│   └── settings/      # Tema, idioma, perfil
└── shared/            # Widgets reutilizables
```

---

## 📋 Requisitos para desarrollo local

```bash
# 1. Clona el repositorio
git clone https://github.com/andresZam12/proyecto_Verifarmac.git
cd proyecto_Verifarmac/veri_farmac

# 2. Instala dependencias
flutter pub get

# 3. Configura credenciales en lib/core/config/
#    - SUPABASE_URL
#    - SUPABASE_ANON_KEY
#    - CLAUDE_API_KEY (opcional)

# 4. Corre en modo debug
flutter run
```

---

<div align="center">
  <sub>VeriPharmac v1.0.0 · 2025 · Desarrollado con Flutter</sub>
</div>
