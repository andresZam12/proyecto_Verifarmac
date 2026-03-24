// Reintenta requests fallidos por red (máx 2 intentos).
import 'package:dio/dio.dart';

// Interceptor que reintenta automáticamente un request
// cuando falla por problemas de red (máximo 2 intentos).
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);
  final Dio _dio;

  static const _maxIntentos = 2;

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    // Solo reintenta si es un error de conexión
    final esErrorDeRed = error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionTimeout;

    if (!esErrorDeRed) {
      handler.next(error); // no reintenta, pasa el error
      return;
    }

    // Lee cuántos intentos llevamos (guardado en el header del request)
    final intentos = error.requestOptions.extra['intentos'] ?? 0;

    if (intentos < _maxIntentos) {
      // Incrementa el contador de intentos
      error.requestOptions.extra['intentos'] = intentos + 1;

      // Espera 1 segundo antes de reintentar
      await Future.delayed(const Duration(seconds: 1));

      try {
        // Reintenta el mismo request
        final respuesta = await _dio.fetch(error.requestOptions);
        handler.resolve(respuesta);
      } catch (e) {
        handler.next(error);
      }
    } else {
      handler.next(error); // agotó los intentos, pasa el error
    }
  }
}
