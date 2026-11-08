# Prueba de carga — datos para las Figuras 19 y 20

Prueba real ejecutada con Apache JMeter 5.6.3 (Java 24.0.1) contra el backend
en producción de VeriFarmac (Supabase / PostgREST, tabla `scan_history`),
el 2026-11-08.

## Archivos

| Archivo | Qué es |
|---|---|
| `verifarmac_load_test.jmx` | Plan de prueba (abrir con JMeter para reproducir) |
| `results.jtl` | Resultados crudos, una fila por petición |
| `statistics.json` | Resumen agregado (el mismo que genera el reporte HTML de JMeter) |

## Configuración

- 20 usuarios concurrentes, ramp-up 10 s, 5 iteraciones cada uno → 100 peticiones.
- `GET /rest/v1/scan_history?select=id,nombre_medicamento,estado,creado_en&order=creado_en.desc&limit=20`
- Se eligió el backend propio (Supabase) y no la API pública de INVIMA porque
  esta última es infraestructura del Estado compartida — no es apropiado
  someterla a carga artificial para una prueba académica.

## Resultado real

0 errores en 100 peticiones. Tiempo medio 133.9 ms, p95 187.6 ms,
throughput 9.98 peticiones/segundo. Detalle completo en `statistics.json`.
