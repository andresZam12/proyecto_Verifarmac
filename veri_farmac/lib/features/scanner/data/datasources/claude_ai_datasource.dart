import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class ClaudeAiDataSource {
  ClaudeAiDataSource(this._dio);
  final Dio _dio;
  static const _apiKey = 'TU_CLAUDE_API_KEY';
  static const _url    = 'https://api.anthropic.com/v1/messages';
  static const _model  = 'claude-opus-4-5';

  Future<Map<String, dynamic>> analyzePackaging(String imagePath) async {
    final bytes       = await File(imagePath).readAsBytes();
    final imageBase64 = base64Encode(bytes);
    final response    = await _dio.post(
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
              {'type': 'text', 'text': 'Analiza este empaque de medicamento colombiano.\nResponde SOLO en JSON:\n{"isAuthentic": true/false, "confidence": 0.0-1.0, "observations": "texto"}'},
            ],
          },
        ],
      },
    );
    final text = response.data['content'][0]['text'] as String;
    return jsonDecode(text) as Map<String, dynamic>;
  }
}
