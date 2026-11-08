# Resultados de verificación — datos para la Figura 18 (matriz de confusión)

Cada fila de `resultados_verificacion.csv` es un escaneo real hecho en el
teléfono. Cuando haya suficientes filas, se genera la matriz de confusión
real y las métricas (precisión, exhaustividad, F1 — Tabla 7) a partir de
este archivo. No se inventan datos: si una fila no corresponde a una
prueba real hecha en el dispositivo, no se agrega.

## Columnas

| Columna            | Qué va aquí |
|---------------------|-------------|
| `fecha`             | AAAA-MM-DD |
| `medicamento`        | Nombre o descripción corta de lo escaneado |
| `metodo`             | `ocr`, `barcode` o `visual` |
| `estado_real`        | La verdad conocida de antemano (ver clases abajo) |
| `estado_predicho`    | Lo que mostró la app después de escanear |
| `coincide`           | `si` si estado_real == estado_predicho, si no `no` |
| `notas`              | Cualquier detalle útil (ej. qué se alteró, calidad de la foto) |

## Clases válidas para `estado_real` / `estado_predicho`

- `vigente`
- `vencido`
- `invalido` (código alterado/adulterado o registro suspendido)
- `sospechoso`
- `no_encontrado`

## Meta mínima antes de generar la Figura 18

Al menos **4-5 escaneos reales por clase** (~20-25 filas en total), para
que la matriz tenga sentido estadístico.

## Progreso actual

| Clase           | Filas registradas | Meta |
|------------------|:---:|:---:|
| `vigente`        | 17 | 4-5 ✅ |
| `vencido`        | 4 | 4-5 ✅ |
| `invalido`       | 4 | 4-5 ✅ |
| `sospechoso`     | 0 | 4-5 ⚠️ |
| `no_encontrado`  | 0 | 4-5 ⚠️ |

`sospechoso` y `no_encontrado` solo aparecen hasta ahora como **estado_predicho**
(la app respondiendo "no encontrado" o "sospechoso"), nunca como la verdad real
de un producto probado — no hemos tenido en mano un producto cuyo estado real
conocido sea literalmente "sospechoso" o "no encontrado". Queda como limitación
reconocida de la muestra piloto (ver Figura 18 en el documento), no como dato
inventado para rellenar la tabla.

*(Esta tabla se actualiza a mano cada vez que se agregan filas al CSV. Última
actualización: 25 filas totales, 8 productos adicionales del lote 2026-09-25
a 2026-11-07, código de barras reportado aparte por limitación de datos externa.)*
