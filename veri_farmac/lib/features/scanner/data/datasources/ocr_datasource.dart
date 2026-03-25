import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrDataSource {
  final _reconocedor = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extraerTexto(String rutaImagen) async {
    final imagen    = InputImage.fromFilePath(rutaImagen);
    final resultado = await _reconocedor.processImage(imagen);
    return resultado.text;
  }

  Future<void> dispose() async => await _reconocedor.close();
}
