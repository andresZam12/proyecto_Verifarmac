import 'package:dio/dio.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioClient {
  late final Dio dio;
  DioClient() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
    dio.interceptors.addAll([AuthInterceptor(), RetryInterceptor(dio)]);
  }
}
