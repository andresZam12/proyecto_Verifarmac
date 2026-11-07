# Backlog y plan de trabajo — VeriFarmac

Este documento traduce el Capítulo 3 (Metodología) y el Capítulo 4 (Requisitos) del trabajo de grado *"Sistema móvil inteligente para la verificación de la autenticidad y vigencia del registro sanitario de medicamentos convencionales y productos naturales en Colombia"* (CTG_29Oct_Zambrano_Moran) en un Product Backlog y un Sprint Backlog verificables, usados para poblar el tablero de GitHub Projects en [`users/andresZam12/projects/2`](https://github.com/users/andresZam12/projects/2/views/1).

Fuente de la metodología: Scrum adaptado, 5 fases, 24 sprints de dos semanas, periodo febrero 2026 – julio 2027 (78 semanas, 72 efectivas). Ver sección 3.3 y Tabla 9 del documento.

## 1. Estado del proyecto a la fecha (2026-11-07)

- **Fase vigente:** Fase 3 — Desarrollo iterativo (agosto 2026 – febrero 2027, sprints 7 a 18).
- **Sprint vigente:** Sprint 14 (07–20 de noviembre de 2026), calculado a partir del inicio de fase (01 de agosto de 2026) con sprints de 2 semanas.
- **Commits en el repositorio `proyecto_Verifarmac`:** 91, desde `378341a` (2026-03-17, inicialización) hasta `7ecdfb1` (2026-11-05, primeras pruebas unitarias).
- **Cobertura funcional observada en el código** (`veri_farmac/lib/features/*`): autenticación, escaneo por código de barras, OCR, análisis visual con IA (Claude), consulta INVIMA en vivo, historial, dashboard y un módulo adicional de mapa de farmacias no contemplado en la tabla de requisitos del documento.
- **Pruebas:** 50 pruebas unitarias (commit `7ecdfb1`) sobre parsers y modelos (`scan_text_parser`, `invima_status_parser`, `health_product_classifier`, modelos de `medicine`, `history_entry`, `scan_result`). Aún no hay reporte de cobertura (RNF008 exige ≥90% en dominio y aplicación) ni pruebas funcionales/E2E, de carga o piloto de usabilidad: el documento mismo marca esas secciones (4.4.1 a 4.5) como "Pendiente".

## 2. Product Backlog por épica

Cada historia de usuario (HU) referencia su requisito (RF/RNF) y caso de uso (CU) del documento. **Estado** se determinó revisando el código fuente y el historial de commits, no por reporte manual.

### Épica A — Autenticación (RF001, RF002, CU-01, CU-02)

| HU | Historia | Prioridad | Estado | Evidencia |
|---|---|---|---|---|
| HU-01 | Como ciudadano quiero crear una cuenta con correo y contraseña, aceptando la política de tratamiento de datos, para usar la app de forma identificada | Media | **Hecho** | `register_page.dart`, `auth_remote_datasource.dart` |
| HU-02 | Como ciudadano quiero iniciar y cerrar sesión para acceder a mi historial | Media | **Hecho** | `login_page.dart`, commit `034bbf2` |
| HU-03 | (Adición no contemplada en el documento) Inicio de sesión con Google | — | **Hecho (fuera de alcance documentado)** | `sign_in_with_google_usecase.dart`, `google_sign_in_button.dart` |

### Épica B — Verificación por código de barras (RF003, RF004, CU-03)

| HU | Historia | Prioridad | Estado | Evidencia |
|---|---|---|---|---|
| HU-04 | Como ciudadano quiero escanear el código de barras del empaque para identificar el producto sin escribir nada | Alta | **Hecho** | `3eedb47`, `scanner_page.dart` |
| HU-05 | Como ciudadano quiero que, si el código no tiene correspondencia, el sistema me remita automáticamente al módulo OCR | Alta | **Hecho** | commit `7b8e4e9` |
| HU-06 | Como ciudadano quiero un respaldo de consulta (UPCItemDB / Open Products Facts) cuando el código no está en la base del INVIMA, para no quedarme sin información | Media (adición) | **Hecho** | commits `42e29a6`, `155e97b` |

### Épica C — Verificación por OCR (RF005, RF006, RF007, CU-04)

| HU | Historia | Prioridad | Estado | Evidencia |
|---|---|---|---|---|
| HU-07 | Como ciudadano quiero fotografiar el empaque con guía de encuadre para que el sistema lea el texto | Alta | **Hecho** | `scanner_overlay.dart`, `ocr_datasource.dart` |
| HU-08 | Como ciudadano quiero que el sistema extraiga nombre, registro sanitario, lote y fecha de vencimiento del texto reconocido | Alta | **Hecho** | `scan_text_parser.dart` + `scan_text_parser_test.dart` |
| HU-09 | Como ciudadano quiero poder revisar y corregir manualmente los campos extraídos antes de consultar | Media | **Backlog (no implementado)** | sin UI de corrección en `scanner_page.dart` |

### Épica D — Consulta regulatoria INVIMA (RF008, RF009, RF015, CU-08)

| HU | Historia | Prioridad | Estado | Evidencia |
|---|---|---|---|---|
| HU-10 | Como ciudadano quiero consultar el registro sanitario por número y ver estado, titular y vigencia | Alta | **Hecho** | `invima_api_datasource.dart`, `invima_status_parser.dart` |
| HU-11 | Como ciudadano quiero buscar un producto por nombre cuando no tengo el número de registro | Media | **Hecho** | método `findByName` en `invima_api_datasource.dart` |
| HU-12 | Como sistema quiero sincronizar periódicamente los datos del INVIMA en Supabase, registrando la fecha de actualización | Alta | **Divergencia de diseño** — ver sección 4 | consulta en vivo a Socrata, sin tabla de sincronización local |

### Épica E — Análisis visual con IA (RF010, CU-05)

| HU | Historia | Prioridad | Estado | Evidencia |
|---|---|---|---|---|
| HU-13 | Como ciudadano quiero que, ante un empaque deteriorado o ambiguo, la IA describa inconsistencias visuales o textuales | Alta | **Hecho** | `claude_ai_datasource.dart`, commits `2581f86`, `4f29b51` |
| HU-14 | Como sistema quiero cruzar el resultado del análisis visual contra la base del INVIMA antes de mostrar la categoría final | Alta | **Hecho** | commit `2581f86` |

### Épica F — Resultados (RF011, RF012, RF013, RF016)

| HU | Historia | Prioridad | Estado | Evidencia |
|---|---|---|---|---|
| HU-15 | Como ciudadano quiero ver una de las cinco categorías de resultado con color e ícono distintivo | Alta | **Hecho** | `status_badge.dart`, `medicine_detail_page.dart` |
| HU-16 | Como ciudadano quiero ver siempre el aviso de que la app no certifica autenticidad física ni seguridad del producto | Alta | **Por verificar** | no se encontró cadena de aviso explícita en `app_strings.dart`; requiere confirmación manual en UI |
| HU-17 | Como ciudadano quiero saber si el registro corresponde a un medicamento convencional o a un producto natural | Media | **Hecho** | `health_product_classifier.dart` + test |
| HU-18 | Como ciudadano quiero un enlace al canal oficial del INVIMA cuando el resultado es "no encontrado" o "sospechoso" | Media | **Backlog (no implementado)** | sin referencia en el código a canal/enlace INVIMA |

### Épica G — Historial (RF014, CU-06)

| HU | Historia | Prioridad | Estado | Evidencia |
|---|---|---|---|---|
| HU-19 | Como ciudadano quiero ver mis consultas pasadas con fecha, producto, mecanismo usado y resultado | Media | **Hecho** | `history_page.dart`, `history_entry_tile.dart` |
| HU-20 | Como sistema quiero sincronizar el historial local con Supabase de forma confiable | Media | **Hecho** | commit `7315cbf` |

### Épica H — No funcionales transversales (RNF001–RNF011)

| HU | Requisito | Estado | Evidencia / observación |
|---|---|---|---|
| HU-21 | RNF002 — OCR y código de barras procesados on-device con ML Kit | **Hecho** | `ocr_datasource.dart` usa ML Kit |
| HU-22 | RNF003 — HTTPS/TLS y claves de IA fuera del cliente | **Hecho** | commit `c74bede` (flujo `--dart-define-from-file` para `CLAUDE_API_KEY`) |
| HU-23 | RNF007 — Aviso de sin conexión y acceso a historial local | **Hecho** | `offline_banner.dart`, `network_info.dart` |
| HU-24 | RNF008 — Cobertura de pruebas ≥90% en dominio/aplicación | **En progreso** | 50 pruebas (commit `7ecdfb1`), falta reporte de cobertura y ampliar a casos de uso y repositorios |
| HU-25 | RNF004 — Consentimiento explícito de datos personales / imágenes | **Backlog** | no se encontró pantalla de consentimiento explícito |
| HU-26 | RNF011 — Límite de análisis de IA por usuario/día configurable desde backend | **Backlog** | no implementado |
| HU-27 | RNF006 — Texto escalable y contraste WCAG 2.1 AA | **Backlog (sin verificar)** | pendiente auditoría de accesibilidad |

## 3. Sprint Backlog — Fase 3 (sprints 7 a 18, agosto 2026 – febrero 2027)

Este backlog ya está poblado como tablero real en GitHub Projects: [users/andresZam12/projects/2](https://github.com/users/andresZam12/projects/2/views/1), con 27 issues en `andresZam12/proyecto_Verifarmac` (uno por historia), 24 milestones (Sprint 1 a Sprint 24, con fecha de vencimiento según la Tabla 9 del documento) y los campos Status, Priority y Labels configurados por historia.

| Sprint | Fechas | Objetivo | Historias | Estado |
|---|---|---|---|---|
| 7 | 01–14 ago 2026 | Autenticación | HU-01, HU-02, HU-03 | Hecho |
| 8 | 15–28 ago 2026 | Código de barras + seguridad de credenciales | HU-04, HU-05, HU-06, HU-22 | Hecho |
| 9 | 29 ago–11 sep 2026 | OCR base, procesamiento on-device | HU-07, HU-08, HU-21 | Hecho |
| 10 | 12–25 sep 2026 | Consulta INVIMA por número y por nombre | HU-10, HU-11 | Hecho |
| 11 | 26 sep–9 oct 2026 | Análisis visual con IA y cruce contra INVIMA | HU-13, HU-14 | Hecho |
| 12 | 10–23 oct 2026 | Resultados por categoría y diferenciación de producto | HU-15, HU-17 | Hecho |
| 13 | 24 oct–6 nov 2026 | Historial, sincronización y modo sin conexión | HU-19, HU-20, HU-23 | Hecho |
| **14 (actual)** | **07–20 nov 2026** | Cerrar brechas: corrección manual OCR, aviso de alcance, enlace INVIMA, cobertura de pruebas | HU-09 (Sprint Backlog), HU-16 (In review), HU-18 (Sprint Backlog), HU-24 (In progress) | **En progreso** |
| 15 | 21 nov–4 dic 2026 | Consentimiento de datos personales (RNF004) | HU-25 | Backlog |
| 16 | 05–18 dic 2026 | Límite de uso de IA (RNF011) | HU-26 | Backlog |
| 17 | 19 dic 2026–1 ene 2027 | Auditoría de accesibilidad WCAG 2.1 AA (RNF006) | HU-27 | Backlog |
| 18 | 02–15 ene 2027 | Resolver divergencia de sincronización INVIMA (HU-12) o actualizar el documento; cierre de desarrollo de Fase 3 | HU-12 | Backlog |

## 4. Divergencias documento ↔ código (para decidir con el director de tesis)

1. **RF015 / HU-12.** El documento describe una *sincronización periódica hacia Supabase* de los datos del INVIMA. El código implementado consulta la API Socrata de datos.gov.co **en tiempo real** en cada búsqueda (`invima_api_datasource.dart`), sin tabla de sincronización ni fecha de "última actualización" visible al usuario (RNF010). Decisión pendiente: implementar la sincronización tal como está documentada, o actualizar la sección 2.5 / RF015 del documento para describir la arquitectura real de consulta directa.
2. **RF001/RF002.** El sistema añade inicio de sesión con Google, no mencionado en el documento. Se recomienda documentarlo como ampliación en la sección 4.1.1.
3. **Alcance adicional no documentado.** Existe un módulo de mapa de farmacias (`features/map`) sin caso de uso ni requisito asociado en el Capítulo 4. Debe decidirse si se documenta como ampliación de alcance o se excluye de la entrega académica.

## 5. Tablero GitHub Projects (poblado)

El tablero se migró a la cuenta `andresZam12` ([users/andresZam12/projects/2](https://github.com/users/andresZam12/projects/2/views/1), privado, 2 colaboradores: `andresZam12` y `DeividJulian`) y se pobló por completo el 2026-11-07 a partir de este documento, usando `gh` CLI:

- **27 issues** (HU-01 a HU-27) en `andresZam12/proyecto_Verifarmac`, cada uno con historia de usuario, criterios de aceptación, RF/RNF/CU relacionado y evidencia en el código, tal como aparecen en las tablas de la sección 2.
- **24 milestones** (Sprint 1 a Sprint 24) con fecha de vencimiento calculada a partir de la Tabla 9 del documento (inicio de Fase 2: 01-may-2026; Fase 3: 01-ago-2026; Fase 4: 01-mar-2027).
- **Labels de fase** (`fase-1-planificacion` … `fase-5-cierre`); todas las historias actuales quedaron en `fase-3-desarrollo`.
- **Campo Status** (nativo del tablero: Backlog, Sprint Backlog, In progress, In review, Done) y **campo Priority** (P0/P1/P2) asignados por historia según la sección 2.
- **Assignees:** `andresZam12` y `DeividJulian` en las 27 historias, conforme a la sección 3.4 del documento (Development Team compartido).

Estado resultante: 18 historias en Done, 2 en Sprint Backlog, 1 en In review, 1 en In progress y 5 en Backlog — coherente con que el proyecto está en el Sprint 14 de 24.
