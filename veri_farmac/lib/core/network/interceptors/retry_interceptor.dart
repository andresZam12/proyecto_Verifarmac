import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);
  final Dio _dio;
  static const _maxRetries = 2;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isNetworkError = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionTimeout;
    final attempts = err.requestOptions.extra['attempts'] ?? 0;
    if (isNetworkError && attempts < _maxRetries) {
      err.requestOptions.extra['attempts'] = attempts + 1;
      try {
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {}
    }
    handler.next(err);
  }
}
