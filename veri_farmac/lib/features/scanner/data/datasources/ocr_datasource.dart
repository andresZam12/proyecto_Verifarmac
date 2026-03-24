// Datasource de OCR con Google ML Kit.

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// Extrae texto de una imagen usando Google ML Kit.
// Funciona sin internet — todo el procesamiento es local en el dispositivo.
class OcrDataSource {
  final _reconocedor = TextRecognizer(script: TextRecognitionScript.latin);

  // Recibe la ruta de una imagen y retorna el texto encontrado
  Future<String> extraerTexto(String rutaImagen) async {
    final imagen = InputImage.fromFilePath(rutaImagen);
    final resultado = await _reconocedor.processImage(imagen);

    // Retorna todo el texto encontrado en la imagen
    return resultado.text;
  }

  // Libera los recursos del reconocedor al terminar
  Future<void> dispose() async {
    await _reconocedor.close();
  }
}
