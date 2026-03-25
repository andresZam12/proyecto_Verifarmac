import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);
  final Dio _dio;
  static const _maxReintentos = 2;

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    final esErrorDeRed = error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionTimeout;
    final intentos = error.requestOptions.extra['intentos'] ?? 0;
    if (esErrorDeRed && intentos < _maxReintentos) {
      error.requestOptions.extra['intentos'] = intentos + 1;
      try {
        final respuesta = await _dio.fetch(error.requestOptions);
        handler.resolve(respuesta);
        return;
      } catch (_) {}
    }
    handler.next(error);
  }
}
