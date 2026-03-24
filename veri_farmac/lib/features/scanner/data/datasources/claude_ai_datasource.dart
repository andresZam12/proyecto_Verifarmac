// Datasource de análisis visual con Claude API.

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

// Envía la imagen del empaque a Claude API para análisis visual.
// Detecta inconsistencias que sugieren que el medicamento es falso.
class ClaudeAiDataSource {
  ClaudeAiDataSource(this._dio);
  final Dio _dio;

  // Tu API key de Anthropic — guardarla segura, nunca en el código
  // En producción usar flutter_secure_storage
  static const _apiKey = 'TU_CLAUDE_API_KEY';
  static const _url = 'https://api.anthropic.com/v1/messages';
  static const _modelo = 'claude-opus-4-5';

  // Analiza la imagen del empaque y retorna el resultado
  Future<Map<String, dynamic>> analizarEmpaque(String rutaImagen) async {
    // Convierte la imagen a base64 para enviarla a la API
    final bytes = await File(rutaImagen).readAsBytes();
    final imagenBase64 = base64Encode(bytes);

    final respuesta = await _dio.post(
      _url,
      options: Options(
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
      ),
      data: {
        'model': _modelo,
        'max_tokens': 500,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                // Imagen del empaque
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/jpeg',
                  'data': imagenBase64,
                },
              },
              {
                // Instrucción clara y específica para Claude
                'type': 'text',
                'text': '''Analiza este empaque de medicamento colombiano.
Responde SOLO en JSON con este formato exacto:
{
  "esAudentico": true o false,
  "confianza": número entre 0.0 y 1.0,
  "observaciones": "descripción breve de lo que encontraste"
}
Busca: tipografía inconsistente, colores incorrectos, 
sellos del INVIMA ausentes o mal impresos, texto borroso.'''
              },
            ],
          },
        ],
      },
    );

    // Extrae el texto de la respuesta de Claude
    final texto = respuesta.data['content'][0]['text'] as String;

    // Convierte el JSON de la respuesta a un Map
    return jsonDecode(texto) as Map<String, dynamic>;
  }
}
