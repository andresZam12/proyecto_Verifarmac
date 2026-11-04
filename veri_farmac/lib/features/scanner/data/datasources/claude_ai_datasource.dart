import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';

class ClaudeAiDataSource {
  ClaudeAiDataSource(this._dio);
  final Dio _dio;

  // La API key se pasa en tiempo de compilación, nunca se hardcodea en el
  // repo: flutter run --dart-define=CLAUDE_API_KEY=sk-ant-...
  static const _apiKey = String.fromEnvironment('CLAUDE_API_KEY');
  static const _url    = 'https://api.anthropic.com/v1/messages';
  static const _model  = 'claude-sonnet-5';

  static bool get isConfigured => _apiKey.isNotEmpty;

  Future<Map<String, dynamic>> analyzePackaging(String imagePath) async {
    if (!isConfigured) {
      throw const ServerException(
        'La función de análisis con IA no está configurada '
        '(falta CLAUDE_API_KEY al compilar la app).',
      );
    }

    final bytes       = await File(imagePath).readAsBytes();
    final imageBase64 = base64Encode(bytes);

    final Response response;
    try {
      response = await _dio.post(
        _url,
        options: Options(headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        }),
        data: {
          'model': _model,
          'max_tokens': 500,
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'image', 'source': {'type': 'base64', 'media_type': 'image/jpeg', 'data': imageBase64}},
                {'type': 'text', 'text':
                    'Analiza este empaque de medicamento o producto natural colombiano. '
                    'Busca la fecha de vencimiento visible (puede decir "Vence", "Exp", '
                    '"Vencimiento", "F.V.", "FV", etc.) y, si alcanzas a leerlo con claridad, '
                    'el número de registro sanitario INVIMA impreso en el empaque '
                    '(formato "INVIMA 2008M-0007952" o similar).\n'
                    'Responde SOLO en JSON con exactamente estas claves:\n'
                    '{"isAuthentic": true/false, "confidence": 0.0-1.0, '
                    '"expiryDate": "MM/YYYY o null si no se ve", '
                    '"registrySanitario": "INVIMA XXXXM-XXXXXXX o null si no es legible", '
                    '"observations": "texto"}'},
              ],
            },
          ],
        },
      );
    } on DioException catch (e) {
      debugPrint('[Claude] Error HTTP ${e.response?.statusCode}: ${e.response?.data ?? e.message}');
      throw ServerException(
        'Error al llamar a la API de Claude '
        '(${e.response?.statusCode ?? 'sin conexión'}): '
        '${e.response?.data?['error']?['message'] ?? e.message}',
      );
    }

    final text = response.data['content'][0]['text'] as String;
    debugPrint('[Claude] Respuesta cruda: $text');
    try {
      return jsonDecode(_stripMarkdownFence(text)) as Map<String, dynamic>;
    } catch (e) {
      throw ServerException('La IA no devolvió un JSON válido: $text');
    }
  }

  // Claude normalmente responde JSON puro, pero por si acaso lo envuelve
  // en una cerca de código ```json ... ``` (ocurre con otros modelos).
  String _stripMarkdownFence(String text) {
    final trimmed = text.trim();
    if (!trimmed.startsWith('```')) return trimmed;
    return trimmed
        .replaceFirst(RegExp(r'^```[a-zA-Z]*\n?'), '')
        .replaceFirst(RegExp(r'```$'), '')
        .trim();
  }
}
