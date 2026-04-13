import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrDataSource {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractText(String imagePath) async {
    final image  = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(image);
    return result.text;
  }

  Future<void> dispose() async => await _recognizer.close();
}
